import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:http/http.dart' as http;
import 'package:learninglens_app/Views/essay_edit_page.dart';
// import '../controller/main_controller.dart';
import '/Controller/beans.dart'; // Import the file that contains the Course class
import 'dart:convert';
// import 'dart:io';
import '../Api/moodle_api_singleton.dart'; // Import the Moodle API Singleton

class EssayAssignmentSettings extends StatefulWidget {
  final String updatedJson;

  EssayAssignmentSettings(this.updatedJson);

  @override
  EssayAssignmentSettingsState createState() => EssayAssignmentSettingsState();
}

class EssayAssignmentSettingsState extends State<EssayAssignmentSettings> {
  // Global key for the form
  final _formKey = GlobalKey<FormState>();

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

  // TextEditingController _courseNameController = TextEditingController();
  TextEditingController _assignmentNameController = TextEditingController();

  // Quill Editor controller
  final quill.QuillController _quillController = quill.QuillController.basic();

  // List of courses fetched from the controller
  List<Course> courses = [];
  String selectedCourse = 'Select a course';

@override
void initState() {
  super.initState();
  fetchCourses(); // Fetch courses on page load
  populateHeadersAndRows();
}

// Fetch courses from the controller
Future<void> fetchCourses() async {
  try {
    List<Course>? courseList = MoodleApiSingleton().moodleCourses;
    setState(() {
      courses = courseList ?? [];
      // Don't auto-select any course here, leave it to the user to select.
      selectedCourse = 'Select a course';
    });
  } catch (e) {
    debugPrint('Error fetching courses: $e');
    setState(() {
      selectedCourse = 'No courses available'; // Handle the empty case
    });
  }
}
  

  // Headers and Rows for Rubric Display
  List headers = [];
  List rows = [];

  // Function to populate headers and rows for rubric display
  void populateHeadersAndRows() {
    try {
      Map<String, dynamic> jsonData = jsonDecode(widget.updatedJson);

      List<dynamic> levels =
          List<dynamic>.from(jsonData['criteria'][0]['levels'] as List);
      headers = [
        {"title": 'Criteria', 'index': 1, 'key': 'name'},
      ];

      for (int i = 0; i < levels.length; i++) {
        headers.add({
          "title": '${levels[i]['score']}', // The score (5, 3, 1) as headers
          'index': i + 2,
          'key': 'level_$i'
        });
      }

      rows = (jsonData['criteria'] ?? []).map((criterion) {
        Map<String, dynamic> row = {
          "name": criterion['description'],
        };

        for (int i = 0; i < (criterion['levels'] as List).length; i++) {
          row['level_$i'] = (criterion['levels'] as List)[i]['definition'];
        }

        return row;
      }).toList();
    } catch (e) {
      debugPrint('Error parsing rubric JSON: $e');
    }

    setState(() {});
  }

  // Create and send assignment to Moodle
  Future<void> createAssignment(
      String token,
      String courseId,
      String assignmentName,
      String description,
      String dueDate,
      String startDate) async {
    const String url = 'webservice/rest/server.php';
    final fullUrl = 'https://www.swen670moodle.site/$url';

    String rubrickinjsonformat = '''
{
    "criteria": [
        {
            "description": "Content",
            "levels": [
                { "definition": "Excellent", "score": 5 },
                { "definition": "Good", "score": 3 },
                { "definition": "Poor", "score": 1 }
            ]
        },
        {
            "description": "Clarity",
            "levels": [
                { "definition": "Very Clear", "score": 5 },
                { "definition": "Somewhat Clear", "score": 3 },
                { "definition": "Unclear", "score": 1 }
            ]
        }
    ]
}
''';

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        body: {
          'wstoken': token,
          'wsfunction': 'local_learninglens_create_assignment',
          'moodlewsrestformat': 'json',
          'courseid': courseId,
          'sectionid': '1',
          'enddate': dueDate,
          'startdate': startDate,
          'description': description,
          'rubricJson': rubrickinjsonformat,
          'assignmentName': assignmentName,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Assignment sent to Moodle successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Assignment sent to Moodle successfully!')));
      } else {
        debugPrint(
            'Failed to send assignment to Moodle. Status Code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send assignment to Moodle.')));
      }
    } catch (error) {
      debugPrint('Error occurred while sending assignment: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    }
  }

// Dropdown to display courses with "Select a course" as the default option
  DropdownButtonFormField<String> _buildCourseDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCourse == 'Select a course'
          ? null
          : selectedCourse, // Set initial value to null if 'Select a course'
      decoration: InputDecoration(
        labelText: 'Course name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value == 'Select a course') {
          return 'Please select a course';
        }
        return null;
      },
      onChanged: (String? newValue) {
        setState(() {
          selectedCourse = newValue!;
        });
        debugPrint('Selected course: $selectedCourse');
      },
      items: [
        DropdownMenuItem<String>(
          value: 'Select a course',
          child: Text('Select a course'),
        ),
        ...courses.map<DropdownMenuItem<String>>((Course course) {
          return DropdownMenuItem<String>(
            value: course.fullName,
            child: Text(course.fullName),
          );
        }).toList(),
      ],
      isExpanded: true,
    );
  }

  // Custom Widget to build rubric table without editable package
  Widget buildRubricTable() {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(children: [
          _buildTableCell('Criteria'),
          for (var header in headers.skip(1)) _buildTableCell(header['title']),
        ]),
        for (var row in rows)
          TableRow(children: [
            _buildTableCell(row['name']),
            for (var i = 0; i < headers.length - 1; i++)
              _buildTableCell(row['level_$i']),
          ]),
      ],
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Function to validate if the availability date selections are not default values
  bool _validateAvailabilityDates() {
    if (selectedDaySubmission == '01' &&
        selectedMonthSubmission == 'January' &&
        selectedYearSubmission == '2024' &&
        selectedHourSubmission == '00' &&
        selectedMinuteSubmission == '00') {
      return false; // If the default date for submission is selected, return false
    }

    if (selectedDayDue == '01' &&
        selectedMonthDue == 'January' &&
        selectedYearDue == '2024' &&
        selectedHourDue == '00' &&
        selectedMinuteDue == '00') {
      return false; // If the default due date is selected, return false
    }

    return true; // If both dates have been customized, validation passes
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
        child: Form(
          key: _formKey, // Assigning the global form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              SectionTitle(title: 'General'),
              _buildCourseDropdown(),
              SizedBox(height: 12),
              TextFormField(
                controller: _assignmentNameController,
                decoration: InputDecoration(
                  labelText: 'Assignment name',
                  border: OutlineInputBorder(),
                ),
                // Adding validator to ensure assignment name is not empty
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an assignment name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              SectionTitle(title: 'Rubric'),
              buildRubricTable(),
              SizedBox(height: 20),
              SectionTitle(title: 'Description'),
              Container(
                height: 250,
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    quill.QuillToolbar.simple(controller: _quillController),
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
              SectionTitle(title: 'Availability'),
              SizedBox(height: 14),
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
                  Expanded(
                    child: _buildDropdown(
                      'Allow submissions from',
                      selectedDaySubmission,
                      selectedMonthSubmission,
                      selectedYearSubmission,
                      selectedHourSubmission,
                      selectedMinuteSubmission,
                      isSubmissionEnabled,
                      (String? newValue) {
                        setState(() {
                          selectedDaySubmission = newValue!;
                        });
                      },
                      (String? newValue) {
                        setState(() {
                          selectedMonthSubmission = newValue!;
                        });
                      },
                      (String? newValue) {
                        setState(() {
                          selectedYearSubmission = newValue!;
                        });
                      },
                      (String? newValue) {
                        setState(() {
                          selectedHourSubmission = newValue!;
                        });
                      },
                      (String? newValue) {
                        setState(() {
                          selectedMinuteSubmission = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
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
                  Expanded(
                    child: _buildDropdown(
                      'Due date',
                      selectedDayDue,
                      selectedMonthDue,
                      selectedYearDue,
                      selectedHourDue,
                      selectedMinuteDue,
                      isDueDateEnabled,
                      (String? newValue) {
                        setState(() {
                          selectedDayDue = newValue!;
                        });
                      },
                      (String? newValue) {
                        setState(() {
                          selectedMonthDue = newValue!;
                        });
                      },
                      (String? newValue) {
                        setState(() {
                          selectedYearDue = newValue!;
                        });
                      },
                      (String? newValue) {
                        setState(() {
                          selectedHourDue = newValue!;
                        });
                      },
                      (String? newValue) {
                        setState(() {
                          selectedMinuteDue = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     // Validate the form before submitting
                  //     if (_formKey.currentState!.validate() &&
                  //         _quillController.document
                  //             .toPlainText()
                  //             .trim()
                  //             .isNotEmpty &&
                  //         _validateAvailabilityDates()) {
                  //       var userInfo = MoodleApiSingleton();
                  //       String? token = userInfo.userToken;

                  //       if (token != null && token.isNotEmpty) {
                  //         String courseId = courses
                  //             .firstWhere(
                  //                 (course) => course.fullName == selectedCourse)
                  //             .id
                  //             .toString();
                  //         String assignmentName =
                  //             _assignmentNameController.text;
                  //         String description =
                  //             _quillController.document.toPlainText();
                  //         String dueDate =
                  //             '$selectedDayDue $selectedMonthDue $selectedYearDue $selectedHourDue:$selectedMinuteDue';
                  //         String allowSubmissionFrom =
                  //             '$selectedDaySubmission $selectedMonthSubmission $selectedYearSubmission $selectedHourSubmission:$selectedMinuteSubmission';

                  //         await createAssignment(
                  //           token,
                  //           courseId,
                  //           assignmentName,
                  //           description,
                  //           dueDate,
                  //           allowSubmissionFrom,
                  //         );
                  //       } else {
                  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //             content: Text('Failed to retrieve user token.')));
                  //       }
                  //     } else {
                  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //           content: Text(
                  //               'Please fill out all fields and ensure a course, description, and valid availability dates are selected.')));
                  //     }
                  //   },
                  //   child: Text('Send to Moodle'),
                  // ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EssayEditPage(),
                        ),
                      );
                    },
                    child: Text('Go Back to Edit Essay'),
                  ),
                ],
              ),
            ],
          ),
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
        Wrap(
          spacing: 8.0, // Space between dropdowns
          runSpacing: 8.0, // Space between rows when wrapping
          children: [
            _buildDropdownButton(days, selectedDay, onDayChanged, isEnabled),
            _buildDropdownButton(
                months, selectedMonth, onMonthChanged, isEnabled),
            _buildDropdownButton(years, selectedYear, onYearChanged, isEnabled),
            _buildDropdownButton(hours, selectedHour, onHourChanged, isEnabled),
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
    return Flexible(
      child: DropdownButton<String>(
        value: selectedValue,
        onChanged: isEnabled ? onChanged : null,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
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
