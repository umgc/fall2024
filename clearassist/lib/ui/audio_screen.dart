import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

// AudioScreen widget provides the main interface for audio recording.
class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  // Flags to track if recording or playback is currently in progress.
  bool _isRecording = false;

<<<<<<< HEAD
=======
  /// Variable to track the duration of the current recording.
  final Duration _duration = const Duration(seconds: 0);

  /// This variable will store the path where the recorded audio will be saved.
  String? _pathToSaveRecording;

  /// Timer is used to update the duration of the recording in real-time.

>>>>>>> cafe0a259e989ae6acdd0e96497a1db91e4f4c98
  late FlutterSoundRecorder _recorder;

  String? _audioFilePath;
  String _transcription = 'Transcription will appear here...';
  String _translatedText = 'Translation will appear here...';
  String _selectedLanguage = 'en'; // Default language
  String _maskedTranscription = '';
  String _summaryText = '';

  String transcriptionSummary = '';
  String openAIKey = 'Enter API Key Here';

  // Variables to hold the translated UI text
  String _transcriberTitleText = 'Transcriber';
  String _summarizeButtonText = 'Summarize Transcription';
  String _summaryLabelText = 'Summary:';

  @override
  void initState() {
    super.initState();

    // Initializing recorder and player instances.
    _recorder = FlutterSoundRecorder();

    // Setting up the recorder by checking permissions.
    _startRecording();
  }

  Future<void> requestPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
      status = await Permission.microphone.status;
    }
    if (!status.isGranted) {
      print("Microphone permission is not granted");
    }
  }

  Future<void> _startRecording() async {
    try {
      await requestPermissions();
      await _recorder.openRecorder();

      // Set the path for saving the recording
      Directory tempDir = await getTemporaryDirectory();
      _audioFilePath = '${tempDir.path}/recording.wav';

      // Start recording
      await _recorder.startRecorder(
        toFile: _audioFilePath,
        codec: Codec.pcm16WAV,
      );

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stopRecorder();
      await _recorder.closeRecorder(); // Close the recorder after stopping

      setState(() {
        _isRecording = false;
      });

      print('Recording saved to: $_audioFilePath');

      await transcribeAudio();
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> transcribeAudio() async {
    if (_audioFilePath == null) return;

    var url = Uri.parse('https://api.openai.com/v1/audio/transcriptions');
    var request = http.MultipartRequest('POST', url)
<<<<<<< HEAD
      ..headers['Authorization'] = 'Bearer $openAIKey'
=======
      ..headers['Authorization'] = 'Bearer Add Your Key Here'
>>>>>>> cafe0a259e989ae6acdd0e96497a1db91e4f4c98
      ..fields['model'] = 'whisper-1'
      ..fields['language'] = 'en'
      ..files.add(await http.MultipartFile.fromPath('file', _audioFilePath!));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      Map<String, dynamic> parsedResponse =
          json.decode(String.fromCharCodes(responseData));
      setState(() {
        _transcription = parsedResponse['text'] ?? 'No transcription available';
      });
      print(parsedResponse);
      await saveTranscription(parsedResponse['text']);
    } else {
      setState(() {
        _transcription = 'Failed to transcribe audio: ${response.statusCode}';
      });
    }
  }

// Function to convert number words to actual numbers
  String convertWordsToNumbers(String transcription) {
    Map<String, String> wordToNumberMap = {
      'zero': '0',
      'one': '1',
      'two': '2',
      'three': '3',
      'four': '4',
      'five': '5',
      'six': '6',
      'seven': '7',
      'eight': '8',
      'nine': '9',
      'ten': '10',
      'eleven': '11',
      'twelve': '12',
      'thirteen': '13',
      'fourteen': '14',
      'fifteen': '15',
      'sixteen': '16',
      'seventeen': '17',
      'eighteen': '18',
      'nineteen': '19',
      'twenty': '20',
      'thirty': '30',
      'forty': '40',
      'fifty': '50',
      'sixty': '60',
      'seventy': '70',
      'eighty': '80',
      'ninety': '90',
      'hundred': '100',
      'thousand': '1000',
      'million': '1000000'
    };

    // Splitting the transcription into individual words, handling spaces and punctuation
    List<String> words =
        transcription.toLowerCase().split(RegExp(r'[\s,?.!]+'));

    // Replacing words with their corresponding numbers
    for (int i = 0; i < words.length; i++) {
      if (wordToNumberMap.containsKey(words[i])) {
        words[i] = wordToNumberMap[words[i]]!;
      }
    }

    // Joining the words back together to form the final string with spaces
    return words.join(' ');
  }

  Future<void> saveTranscription(String? transcription) async {
    if (transcription == null) return;

    // Convert number words to numbers
    transcription = convertWordsToNumbers(transcription);

    // Mask Social Security Numbers and other sensitive information
    transcription = transcription.replaceAllMapped(
      RegExp(r'\b(\d[- ]?){9}\b'),
      (match) => '***-**-****',
    );
    transcription = transcription.replaceAllMapped(
      RegExp(r'\b\d{13,16}\b'),
      (match) => '**** **** **** ****',
    );
    transcription = transcription.replaceAllMapped(
      RegExp(r'\b\d{8}\b'),
      (match) => '********',
    );
    transcription = transcription.replaceAllMapped(
      RegExp(r'\b\d{1,3}(,\d{3})+\b'),
      (match) => match.group(0)!.replaceAll(RegExp(r'\d'), '*'),
    );

    _maskedTranscription = transcription; // Store the masked transcription

    await translateText(
        _maskedTranscription); // Use the masked transcription here

    // Get the current timestamp
    DateTime now = DateTime.now();
    String timestamp = now.toString();
    String transcriptionWithTimestamp = '[$timestamp] $transcription';

    // Get the user's last name from the user_data.txt file
    Directory appDir = await getApplicationDocumentsDirectory();
    String userDataPath = '${appDir.path}/user_data.txt';
    File userDataFile = File(userDataPath);

    // Read user data and extract the last name
    String userData = await userDataFile.readAsString();
    print('User data: $userData');
    String lastName = extractLastName(userData);

    // Get the temporary directory
    Directory tempDir = await getTemporaryDirectory();

    // Format the date and time for the file path
    String date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    String time =
        '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}-${now.millisecond.toString().padLeft(3, '0')}';

    // Create the directory for the date with the user's last name
    String dirPath = '${tempDir.path}/transcription/${lastName}_$date';
    Directory dir = Directory(dirPath);

    // Create the directory if it doesn't exist
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }

    // Define the full file path with the time part
    String filePath = '$dirPath/$time.txt';
    File file = File(filePath);

    // Write the transcription to the file
    await file.writeAsString(transcriptionWithTimestamp);
    print('Transcription saved to: $filePath');

    // Read the contents of the file
    final contents = await file.readAsString();
    print(contents);
  }

// Helper function to extract the last name from user data
  String extractLastName(String userData) {
    // Split the user data by commas and assume the second field is the last name
    List<String> userFields = userData.split(',');

    if (userFields.length >= 2) {
      // Trim the last name and return it
      return userFields[1].trim();
    }
    // Return 'unknown' if unable to find the last name
    return 'unknown';
  }

  Future<void> translateText(String text) async {
    if (text.isEmpty) return;

    var translationUrl =
        Uri.parse('https://api.openai.com/v1/chat/completions');
    var response = await http.post(
      translationUrl,
      headers: {
        'Content-Type': 'application/json',
<<<<<<< HEAD
        'Authorization': 'Bearer $openAIKey',
=======
        'Authorization': 'Bearer Add Your Key Here',
>>>>>>> cafe0a259e989ae6acdd0e96497a1db91e4f4c98
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a translation assistant.'},
          {
            'role': 'user',
            'content': _selectedLanguage == 'en'
                ? 'Original text: "$text"' // Show original for English
                : 'Translate to ${_getLanguageName(_selectedLanguage)}: "$text"', // Translate based on language
          }
        ],
        'max_tokens': 1000,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = utf8.decode(response.bodyBytes);
      var decodedJson = jsonDecode(jsonResponse); // Parse the JSON string
      var translatedText = decodedJson['choices'][0]['message']['content'];

      setState(() {
        _translatedText = _selectedLanguage == 'en'
            ? text
            : translatedText; // Show original for English
      });

      print(translatedText); // Print the translation
    } else {
      print('Failed to translate: ${response.statusCode}');
    }
  }

  Future<void> printCacheFiles() async {
    try {
      // Define the cache directory for the app
      Directory cacheDir =
          Directory('/data/user/0/comclearassist.clearassistapp/cache/');

      // Check if the directory exists
      if (await cacheDir.exists()) {
        // List all files in the directory and its subdirectories
        List<FileSystemEntity> files = cacheDir.listSync(recursive: true);

        // Print each file path
        for (FileSystemEntity file in files) {
          if (file is File) {
            // Ensure it's a file before printing
            print('File: ${file.path}');
          }
        }
      } else {
        print('Cache directory does not exist.');
      }
    } catch (e) {
      print('Error reading cache directory: $e');
    }
  }

// Helper method to get the language name based on the selected language code
  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'pt':
        return 'Portuguese';
      case 'de':
        return 'German';
      case 'he':
        return 'Hebrew';
      case 'zh':
        return 'Mandarin';
      case 'ar':
        return 'Arabic';
      case 'hi':
        return 'Hindi';
      default:
        return 'English';
    }
  }

// Function to summarize and translate the text
  Future<void> summarizeText(
      String maskedTranscription, String selectedLanguage) async {
    try {
      // Send the transcription to OpenAI for summarization
      final summaryResponse = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIKey', // Use the API key
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that summarizes text.'
            },
            {
              'role': 'user',
              'content': 'Please summarize the following: $maskedTranscription'
            },
          ],
        }),
      );

      if (summaryResponse.statusCode == 200) {
        final summaryData = jsonDecode(summaryResponse.body);
        String summaryText =
            summaryData['choices'][0]['message']['content'].trim();

        // Translate the summary into the selected language
        final translatedSummary = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAIKey',
          },
          body: jsonEncode({
            'model': 'gpt-3.5-turbo',
            'messages': [
              {'role': 'system', 'content': 'You are a translation assistant.'},
              {
                'role': 'user',
                'content': 'Translate this to $selectedLanguage: $summaryText'
              },
            ],
          }),
        );

        if (translatedSummary.statusCode == 200) {
          var translatedSummaryData = utf8.decode(translatedSummary.bodyBytes);
          var translatedData = jsonDecode(translatedSummaryData);
          String translatedText =
              translatedData['choices'][0]['message']['content'].trim();

          setState(() {
            _summaryText =
                translatedText; // Update the summary text with the translated version
          });
        } else {
          throw Exception('Failed to translate summary.');
        }
      } else {
        throw Exception('Failed to summarize transcription.');
      }
    } catch (error) {
      setState(() {
        _summaryText = 'Error: $error';
      });
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

 // Define the translations
final Map<String, Map<String, String>> _translations = {
  'en': {
    'transcriber': 'Transcriber',
    'summarize': 'Summarize Transcription',
    'summary': 'Summary:',
  },
  'es': {
    'transcriber': 'Transcriptor',
    'summarize': 'Resumir Transcripción',
    'summary': 'Resumen:',
  },
  'fr': {
    'transcriber': 'Transcripteur',
    'summarize': 'Résumer la Transcription',
    'summary': 'Résumé:',
  },
  'pt': {
    'transcriber': 'Transcritor',
    'summarize': 'Resumir Transcrição',
    'summary': 'Resumo:',
  },
  'de': {
    'transcriber': 'Schriftführer',
    'summarize': 'Transkription Zusammenfassen',
    'summary': 'Zusammenfassung:',
  },
  'he': {
    'transcriber': 'מתמלל',
    'summarize': 'סכם תמלול',
    'summary': 'סיכום:',
  },
  'zh': {
    'transcriber': '转录器',
    'summarize': '总结转录',
    'summary': '总结:',
  },
  'ar': {
    'transcriber': 'الناسخ',
    'summarize': 'تلخيص النسخ',
    'summary': 'الملخص:',
  },
  'hi': {
    'transcriber': 'प्रतिलेखक',
    'summarize': 'प्रतिलेखन का सारांश',
    'summary': 'सारांश:',
  },
};


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 98, 167, 199),
    appBar: AppBar(
      title: Text(_transcriberTitleText), // Dynamic transcriber text
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isRecording ? 'Recording...' : 'Press to Start Recording',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _isRecording ? _stopRecording() : _startRecording();
<<<<<<< HEAD
                },
                child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
=======
                  printCacheFiles(); // Call to print files after starting or stopping recording
                },
                child:
                    Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
>>>>>>> cafe0a259e989ae6acdd0e96497a1db91e4f4c98
              ),
              SizedBox(height: 20),
              Text(
                'Transcription:',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                _translatedText, // Show translated text here
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  dropdownColor: Colors.blue[100],
                  icon: Icon(Icons.language, color: Colors.orange),
                  underline: SizedBox(),
                  items: [
                    DropdownMenuItem<String>(
                      value: 'en',
                      child: Text('English', style: TextStyle(color: Colors.orange)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'es',
                      child: Text('Español', style: TextStyle(color: Colors.orange)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'fr',
                      child: Text('Français', style: TextStyle(color: Colors.orange)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'pt',
                      child: Text('Português', style: TextStyle(color: Colors.orange)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'de',
                      child: Text('Deutsch', style: TextStyle(color: Colors.orange)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'he',
                      child: Text('עברית', style: TextStyle(color: Colors.orange)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'zh',
                      child: Text('中文', style: TextStyle(color: Colors.orange)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'ar',
                      child: Text('العربية', style: TextStyle(color: Colors.orange)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'hi',
                      child: Text('हिन्दी', style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                  onChanged: (String? newValue) async {
                    setState(() {
                      _selectedLanguage = newValue!;
                      _transcriberTitleText = _translations[_selectedLanguage]!['transcriber']!;
                      _summarizeButtonText = _translations[_selectedLanguage]!['summarize']!;
                      _summaryLabelText = _translations[_selectedLanguage]!['summary']!;
                    });
                    // Translate the transcription and summarize it
                    await translateText(_maskedTranscription);
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await summarizeText(_maskedTranscription, _selectedLanguage);
                },
                child: Text(_summarizeButtonText), // Dynamic summarize button text
              ),
              SizedBox(height: 20),
              Text(
                _summaryLabelText, // Dynamic summary label
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                _summaryText, // Display the summary here
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}