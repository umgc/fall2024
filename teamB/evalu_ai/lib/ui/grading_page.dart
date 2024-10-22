import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';

import 'package:intelligrade/controller/main_controller.dart';
import 'package:intelligrade/controller/model/beans.dart';

class GradingPage extends StatefulWidget {
  const GradingPage({super.key, required this.title});
  final String title;

  static MainController controller = MainController();

  @override
  _GradingPageState createState() => _GradingPageState();
}

class _GradingPageState extends State<GradingPage> {

  Course? _selectedCourse;
  Assignment? _selectedAssignment;
  String? _selectedLanguage;
  Participant? _selectedParticipant;
  Submission? _selectedSubmission; 
  List<FileNameAndBytes> _studentFiles = [];
  FileNameAndBytes? _gradingFile;
  // List<String> _studentFileNamesDisplay = []; // names to display
  // String? _gradingFileName;
  // Uint8List? _gradingFileBytes;
  // List<Uint8List> _studentFileBytesList = [];

  final List<String> _programmingLanguage = [
    'C#', 
    'C++', 
    'Dart', 
    'Java', 
    'JavaScript', 
    'Python', 
    'SQL'
  ]; // Example student list

  List<Course> courses = [];
  Iterable<Assignment> _assignments = [];
  List<Participant> _students = [];
  Iterable<Submission> _submissions = [];

  double? _finalGrade;

  bool readyForUpload() {
    return _gradingFile != null && _studentFiles.isNotEmpty;
    // return _studentFileName != null && _studentFileBytesList.isNotEmpty && _gradingFileName != null && _gradingFileBytes != null;
  }

  Future<String> _compileAndGrade() async {
    if (kDebugMode) {
      print(_gradingFile);
      print(_studentFiles.join('\n'));
    }
    if (!readyForUpload()) return 'Invalid files';
    String output;
    print(_selectedLanguage);
    try {
      if (_selectedLanguage == "JavaScript") {
        output = await MainController().compileJavascriptCodeAndGetOutput(List.from(_studentFiles)..add(_gradingFile!));
      } else if (_selectedLanguage == "SQL") {
        output = await MainController().compileSqlCodeAndGetOutput(List.from(_studentFiles)..add(_gradingFile!));
      } else if (_selectedLanguage == "Python") {
        output = await MainController().compilePythonCodeAndGetOutput(List.from(_studentFiles)..add(_gradingFile!));
      } else if (_selectedLanguage == "Dart") {
        output = await MainController().compileCodeAndGetOutput(List.from(_studentFiles)..add(_gradingFile!));
      } else {
        output = "Please select a Programming Language";
      }

      RegExp pattern = RegExp(r'(\d+)/(\d+)\s+tests\s+passed');
      RegExpMatch? match = pattern.firstMatch(output);

      if (match != null) {
        // Save the numerator and denominator to variables
        int numerator = int.parse(match.group(1)!);
        int denominator = int.parse(match.group(2)!);

        double percentage = (numerator / denominator) * 100;
        _finalGrade = percentage;
      } else {
        print('No match found');
        _finalGrade = 0;
      }

      return output;
    } catch (e) {
      return e.toString();
    }
  }

  void _showGradeOutput(String output) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Compile and Run Results'),
          content: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(output),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton (
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton (
                    onPressed: () async {
                      bool gradeRes = await MoodleApiSingleton().putGrade(_selectedAssignment!.id.toString(), 
                        _selectedParticipant!.id.toString(),
                        _finalGrade.toString());
                      Navigator.of(context).pop();
                      if (gradeRes) {
                         _showGradeSuccess();
                      } else {
                        _showGradeFailure();
                      }
                    },
                    child: const Text('Submit Grade to Moodle'),
                  )
                ]
            ),
          ),
        );
      },
    );
  }

  void _showGradeSuccess() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Grade Successfully Submitted to Moodle!'),
          content: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  ElevatedButton (
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ]
            ),
          ),
        );
      },
    );
  }

    void _showGradeFailure() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Failed to Submit Grade to Moodle'),
          content: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text("Please Try Again."),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton (
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ]
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    MainController().getCourses().then((result) {
      courses = result;
      for (var item in courses) {
        print(item.fullName);
      }
      setState((){});
    });
  }

  Future<void> pickStudentFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    // _studentFileName = result?.files.single.name ?? _studentFileName;
    // _studentFileBytes = result?.files.single.bytes ?? _studentFileBytes;
    _studentFiles = result?.files.map((file) => FileNameAndBytes(file.name, file.bytes!)).toList() ?? _studentFiles;
    // _studentFileBytesList = result?.files.map((file) => file.bytes!).toList() ?? [];
    setState((){});
  }

  Future<void> pickGradingFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      _gradingFile = FileNameAndBytes(result.files.single.name, result.files.single.bytes!);
    }
    // _gradingFileName = result?.files.single.name ?? _gradingFileName;
    // _gradingFileBytes = result?.files.single.bytes ?? _gradingFileBytes;
    // _studentFileName = _gradingFileName?.replaceAll('_test', '');
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<Course>(
              decoration: const InputDecoration(
                labelText: 'Select Course',
                border: OutlineInputBorder(),
              ),
              value: _selectedCourse,
              items: courses.map((course) {
                return DropdownMenuItem(
                  value: course,
                  child: Text(course.fullName),
                );
              }).toList(),
              onChanged: (value) async {
                String? courseIDString = value?.id!.toString();
                MoodleApiSingleton().getCourseParticipants(courseIDString!).then((result) {
                  _students = result;
                });
                MainController().getCourseAssignments(value!.id).then((result) {
                  Iterable<Assignment> codeAssignments = result.where((assignment) => assignment.name.contains("Code"));
                  _assignments = codeAssignments;
                  setState((){
                    _selectedCourse = value;
                  });
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Assignment>(
              decoration: const InputDecoration(
                labelText: 'Select Code Assignment',
                border: OutlineInputBorder(),
              ),
              value: _selectedAssignment,
              items: _assignments.map((assignment) {
                return DropdownMenuItem (
                  value: assignment,
                  child: Text(assignment.name)
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAssignment = value;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Programming Language',
                border: OutlineInputBorder(),
              ),
              value: _selectedLanguage,
              items: _programmingLanguage.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Participant>(
              decoration: const InputDecoration(
                labelText: 'Select Student',
                border: OutlineInputBorder(),
              ),
              value: _selectedParticipant,
              items: _students.map((student) {
                return DropdownMenuItem (
                  value: student,
                  child: Text(student.fullname),
                );
              }).toList(),
              onChanged: (value) async {
                int? assignmentID = _selectedAssignment!.id;
                _submissions = await MoodleApiSingleton().getAssignmentSubmissions(assignmentID!);
                setState(() {
                  _selectedParticipant = value;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Submission>(
              decoration: const InputDecoration(
                labelText: 'Select Student Submission Attempt',
                border: OutlineInputBorder(),
              ),
              value: _selectedSubmission,
              items: _submissions.map((submission) {
                return DropdownMenuItem (
                  value: submission,
                  child: Text("Attempt #${submission.attemptNumber + 1}"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubmission = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      pickStudentFile();
                    },
                    child: const Text('Upload Student\'s File')
                ),
                const SizedBox(width: 8),
                Text(
                    _studentFiles.map((file) => file.filename).toList().join(', '),
                    style: const TextStyle(
                        color: Colors.green
                    )
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      pickGradingFile();
                    },
                    child: const Text('Upload Grading File')
                ),
                const SizedBox(width: 8),
                Text(
                    _gradingFile?.filename ?? '',
                    style: const TextStyle(
                        color: Colors.green
                    )
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async{
                String output = await _compileAndGrade();
                _showGradeOutput(output);
              },
              child: const Text('Compile and Grade'),
            ),
          ],
        ),
      ),
    );
  }
}
