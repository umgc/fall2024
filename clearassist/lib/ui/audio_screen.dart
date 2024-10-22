import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

/// AudioScreen widget provides the main interface for audio recording.
class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  /// Flags to track if recording or playback is currently in progress.
  bool _isRecording = false;

  /// Variable to track the duration of the current recording.
  Duration _duration = const Duration(seconds: 0);

  /// This variable will store the path where the recorded audio will be saved.
  String? _pathToSaveRecording;

  /// Timer is used to update the duration of the recording in real-time.

  late FlutterSoundRecorder _recorder;

  String? _audioFilePath;
  String _transcription = 'Transcription will appear here...';
  String _translatedText = 'Transcription will appear here...';
  String _selectedLanguage = 'en'; // Default language

  String transcription = '';
  String transcriptionSummary = '';

  int? audioId;

  @override
  void initState() {
    super.initState();

    /// Initializing recorder and player instances.
    _recorder = FlutterSoundRecorder();

    /// Setting up the recorder by checking permissions.
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
      // Request microphone permissions
      await requestPermissions();

      // Open the recorder
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

      // Print the file path after the recording is saved
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
      ..headers['Authorization'] =
          'Bearer Add Your Key Here'
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
      await translateText(
          _transcription); // Call the translate function after transcription
    } else {
      setState(() {
        _transcription = 'Failed to transcribe audio: ${response.statusCode}';
      });
    }
  }

  Future<void> saveTranscription(String? transcription) async {
    if (transcription == null) return;

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

    // Read the contents of the file and print them
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
        'Authorization':
            'Bearer Add Your Key Here',
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
    Directory cacheDir = Directory('/data/user/0/comclearassist.clearassistapp/cache/');

    // Check if the directory exists
    if (await cacheDir.exists()) {
      // List all files in the directory and its subdirectories
      List<FileSystemEntity> files = cacheDir.listSync(recursive: true);

      // Print each file path
      for (FileSystemEntity file in files) {
        if (file is File) {  // Ensure it's a file before printing
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

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 98, 167, 199),
      appBar: AppBar(
        title: Text(' Transcriber'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          // Center the Column within the available space
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
                printCacheFiles(); // Call to print files after starting or stopping recording
              },
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
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
                  color: Colors.white, // Background color of the dropdown
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow effect
                      blurRadius: 4,
                      offset: Offset(0, 2), // Offset for the shadow
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 12), // Padding inside the container
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  dropdownColor:
                      Colors.blue[100], // Background color of the dropdown menu
                  icon:
                      Icon(Icons.language, color: Colors.orange), // Icon color
                  underline: SizedBox(), // Remove the default underline
                  items: [
                    DropdownMenuItem<String>(
                      value: 'en',
                      child: Text('English',
                          style: TextStyle(color: Colors.orange)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'es',
                      child: Text('Español',
                          style: TextStyle(color: Colors.orange)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'fr',
                      child: Text('Français',
                          style: TextStyle(color: Colors.orange)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'pt',
                      child: Text('Português',
                          style: TextStyle(color: Colors.orange)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'de',
                      child: Text('Deutsch',
                          style: TextStyle(color: Colors.orange)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'he',
                      child: Text('עברית',
                          style: TextStyle(color: Colors.orange)), // Hebrew
                    ),
                    DropdownMenuItem<String>(
                      value: 'zh',
                      child: Text('中文',
                          style: TextStyle(color: Colors.orange)), // Mandarin
                    ),
                    DropdownMenuItem<String>(
                      value: 'ar',
                      child: Text('العربية',
                          style: TextStyle(color: Colors.orange)), // Arabic
                    ),
                    DropdownMenuItem<String>(
                      value: 'hi',
                      child: Text('हिन्दी',
                          style: TextStyle(color: Colors.orange)), // Hindi
                    ),
                  ],
                  onChanged: (String? newValue) async {
                    setState(() {
                      _selectedLanguage = newValue!;
                    });
                    await translateText(
                        _transcription); // Translate text when language changes
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
