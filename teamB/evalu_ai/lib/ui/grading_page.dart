import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  List<Assignment> _assignments = [];

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
    try {
      output = await MainController().compileCodeAndGetOutput(List.from(_studentFiles)..add(_gradingFile!));
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
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(output ?? 'NO DATA'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton (
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  )
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
                MainController().getCourseAssignments(value!.id).then((result) {
                  _assignments = result;
                  setState((){
                    _selectedCourse = value;
                  });
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Assignment>(
              decoration: const InputDecoration(
                labelText: 'Select Assessment',
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
