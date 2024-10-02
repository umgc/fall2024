import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:http/http.dart' as http; // Add HTTP package for API requests
import 'dart:convert'; // Add JSON handling for API response
import 'dart:io';

void main() {
  // HttpOverrides.global = MyHttpOverrides();

  runApp(MyApp());
}

/*class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context) 
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removed the debug banner
      home: EssayAssignmentSettings(),
      theme: ThemeData(
        useMaterial3: true, // Using Material 3 design
      ),
      title: 'Learning Lens',
    );
  }
}

class EssayAssignmentSettings extends StatefulWidget {
  const EssayAssignmentSettings({super.key});

  @override
  _EssayAssignmentSettingsState createState() =>
      _EssayAssignmentSettingsState();
}

class _EssayAssignmentSettingsState extends State<EssayAssignmentSettings> {
  // Date selection variables for "Allow submissions from"
  String selectedDaySubmission = '01';
  String selectedMonthSubmission = 'January';
  String selectedYearSubmission = '2024';
  String selectedHourSubmission = '00';
  String selectedMinuteSubmission = '00';

  // Date selection variables for "Due date"
  String selectedDayDue = '01';
  String selectedMonthDue = 'January';
  String selectedYearDue = '2024';
  String selectedHourDue = '00';
  String selectedMinuteDue = '00';

  // Checkbox states
  bool isSubmissionEnabled = true;
  bool isDueDateEnabled = true;

  List<String> days =
      List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  List<String> years = ['2023', '2024', '2025'];
  List<String> hours =
      List.generate(24, (index) => index.toString().padLeft(2, '0'));
  List<String> minutes =
      List.generate(60, (index) => index.toString().padLeft(2, '0'));

  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _assignmentNameController =
      TextEditingController();

  // Quill Editor controller
  final quill.QuillController _quillController = quill.QuillController.basic();

  // Function to create the assignment and send it to Moodle
  Future<void> createAssignment(
      String token,
      String courseName,
      String assignmentName,
      String description,
      String dueDate,
      String startDate) async {
    const String url = 'webservice/rest/server.php';
    const fullUrl = 'https://www.swen670moodle.site/$url'; // Full URL
    debugPrint('Sending request to: $fullUrl');
    debugPrint('Course: $courseName, Assignment: $assignmentName');
    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        body: {
          'wstoken': token,
          'wsfunction': 'local_learninglens_create_assignment',
          'moodlewsrestformat': 'json',
          'courseid': '5', // You can dynamically set course ID here
          'sectionid': '1',
          'enddate': dueDate,
          'startdate': startDate,
          'description': description,
          'rubricJson': '0', // Set to 0 to skip rubric for now
          'assignmentName': assignmentName,
        },
      );

      debugPrint('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint('Response data: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Assignment sent to Moodle successfully!')));
      } else {
        debugPrint('Request failed with status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send assignment to Moodle.')));
      }
    } catch (error) {
      debugPrint('Error occurred while sending request: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Center the title in the AppBar
        title: Text('Learning Lens',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context)
            .colorScheme
            .primaryContainer, // Use primary container color
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title Centered Below the AppBar
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: Text(
                  'Send Essay to Moodle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Course Name
            SectionTitle(title: 'General'),
            TextField(
              controller: _courseNameController,
              decoration: InputDecoration(
                labelText: 'Course name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // Assignment Name
            TextField(
              controller: _assignmentNameController,
              decoration: InputDecoration(
                labelText: 'Assignment name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // Description with Quill Rich Text Editor
            SectionTitle(title: 'Description'),
            Container(
              height: 250, // Increased height for better usability
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  quill.QuillToolbar.simple(
                    controller: _quillController,
                  ),
                  Expanded(
                    child: quill.QuillEditor(
                      controller: _quillController,
                      scrollController: ScrollController(),
                      focusNode: FocusNode(),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Availability
            SectionTitle(title: 'Availability'),
            SizedBox(height: 14),

            // Allow submissions from
            Row(
              children: [
                Checkbox(
                  value: isSubmissionEnabled,
                  onChanged: (value) {
                    setState(() {
                      isSubmissionEnabled = value!;
                    });
                  },
                ),
                Text('Enable'),
                SizedBox(width: 10),
                _buildDropdown(
                    'Allow submissions from',
                    selectedDaySubmission,
                    selectedMonthSubmission,
                    selectedYearSubmission,
                    selectedHourSubmission,
                    selectedMinuteSubmission,
                    isSubmissionEnabled, (String? newValue) {
                  setState(() {
                    selectedDaySubmission = newValue!;
                  });
                }, (String? newValue) {
                  setState(() {
                    selectedMonthSubmission = newValue!;
                  });
                }, (String? newValue) {
                  setState(() {
                    selectedYearSubmission = newValue!;
                  });
                }, (String? newValue) {
                  setState(() {
                    selectedHourSubmission = newValue!;
                  });
                }, (String? newValue) {
                  setState(() {
                    selectedMinuteSubmission = newValue!;
                  });
                }),
              ],
            ),
            SizedBox(height: 14),

            // Due date
            Row(
              children: [
                Checkbox(
                  value: isDueDateEnabled,
                  onChanged: (value) {
                    setState(() {
                      isDueDateEnabled = value!;
                    });
                  },
                ),
                Text('Enable'),
                SizedBox(width: 10),
                _buildDropdown(
                    'Due date',
                    selectedDayDue,
                    selectedMonthDue,
                    selectedYearDue,
                    selectedHourDue,
                    selectedMinuteDue,
                    isDueDateEnabled, (String? newValue) {
                  setState(() {
                    selectedDayDue = newValue!;
                  });
                }, (String? newValue) {
                  setState(() {
                    selectedMonthDue = newValue!;
                  });
                }, (String? newValue) {
                  setState(() {
                    selectedYearDue = newValue!;
                  });
                }, (String? newValue) {
                  setState(() {
                    selectedHourDue = newValue!;
                  });
                }, (String? newValue) {
                  setState(() {
                    selectedMinuteDue = newValue!;
                  });
                }),
              ],
            ),
            SizedBox(height: 20),

            // Two Buttons at the Bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Capture the form data
                    String courseName = _courseNameController.text;
                    String assignmentName = _assignmentNameController.text;
                    String description =
                        _quillController.document.toPlainText();
                    String dueDate =
                        '$selectedDayDue $selectedMonthDue $selectedYearDue $selectedHourDue:$selectedMinuteDue';
                    String allowSubmissionFrom =
                        '$selectedDaySubmission $selectedMonthSubmission $selectedYearSubmission $selectedHourSubmission:$selectedMinuteSubmission';

                    // Log the captured data for debugging
                    debugPrint('Course Name: $courseName');
                    debugPrint('Assignment Name: $assignmentName');
                    debugPrint('Description: $description');
                    debugPrint('Due Date: $dueDate');
                    debugPrint('Allow Submission From: $allowSubmissionFrom');

                    // Call createAssignment function to send the data to Moodle
                    createAssignment(
                      '130bde328dbbbe61eaea301c5ad2dcc8', // Add my token
                      courseName,
                      assignmentName,
                      description,
                      dueDate,
                      allowSubmissionFrom,
                    );
                  },
                  child: Text('Send to Moodle'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle Go Back to Edit Assignment action
                  },
                  child: Text('Go back to edit assignment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dropdown Builder for each section
  Widget _buildDropdown(
      String label,
      String selectedDay,
      String selectedMonth,
      String selectedYear,
      String selectedHour,
      String selectedMinute,
      bool isEnabled,
      ValueChanged<String?> onDayChanged,
      ValueChanged<String?> onMonthChanged,
      ValueChanged<String?> onYearChanged,
      ValueChanged<String?> onHourChanged,
      ValueChanged<String?> onMinuteChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Row(
          children: [
            _buildDropdownButton(days, selectedDay, onDayChanged, isEnabled),
            SizedBox(width: 8),
            _buildDropdownButton(
                months, selectedMonth, onMonthChanged, isEnabled),
            SizedBox(width: 8),
            _buildDropdownButton(years, selectedYear, onYearChanged, isEnabled),
            SizedBox(width: 8),
            _buildDropdownButton(hours, selectedHour, onHourChanged, isEnabled),
            SizedBox(width: 8),
            _buildDropdownButton(
                minutes, selectedMinute, onMinuteChanged, isEnabled),
          ],
        ),
      ],
    );
  }

  // Dropdown Button Builder
  Widget _buildDropdownButton(List<String> items, String selectedValue,
      ValueChanged<String?> onChanged, bool isEnabled) {
    return DropdownButton<String>(
      value: selectedValue,
      onChanged:
          isEnabled ? onChanged : null, // Disable dropdown if not enabled
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  // Section Title Widget
  Widget SectionTitle({required String title}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
