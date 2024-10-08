import 'package:flutter/material.dart';
import '../api/moodle_api_singleton.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:http/http.dart' as http;
import '../controller/main_controller.dart';
import '/Controller/beans.dart'; // Import the file that contains the Course class
import 'dart:convert';
import 'dart:io';
import 'package:editable/editable.dart';

class EssayAssignmentSettings extends StatefulWidget {
  final String updatedJson; // Rubric data passed from the edit essay page

  EssayAssignmentSettings(this.updatedJson, {super.key});

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

  // Date selection variables for "Remind me to grade by"
  String selectedDayRemind = '01';
  String selectedMonthRemind = 'January';
  String selectedYearRemind = '2024';
  String selectedHourRemind = '00';
  String selectedMinuteRemind = '00';

  // Checkbox states
  bool isSubmissionEnabled = true;
  bool isDueDateEnabled = true;
  bool isRemindEnabled = true;

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

  final TextEditingController _assignmentNameController =
      TextEditingController();

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
      List<Course> courseList = await MainController().getCourses();
      setState(() {
        courses = courseList;
        if (courses.isNotEmpty) {
          selectedCourse = courses.first.fullName;
        } else {
          selectedCourse = 'No courses available'; // Handle the empty case
        }
      });
      // Debugging courses fetched
      //  debugPrint('Courses fetched: ${courses.map((c) => c.fullName).toList()}'); i dnt need it for now
    } catch (e) {
      debugPrint('Error fetching courses: $e');
    }
  }

  // Headers and Rows for Rubric Display
  List headers = [];
  List rows = [];

  // Function to populate headers and rows for rubric display
  void populateHeadersAndRows() {
    try {
      Map<String, dynamic> jsonData = jsonDecode(widget.updatedJson);
      // Debugging JSON passed from edit essay page
      // debugPrint('Rubric JSON from edit page: ${widget.updatedJson}');

      // Build headers dynamically based on the number of levels in the first criterion
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

      // Build rows by mapping each criterion and its levels dynamically
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
    // API Endpoint URL
    const String url = 'webservice/rest/server.php';
    final fullUrl = 'https://www.swen670moodle.site/$url'; // Full URL

    // Use the same rubric data format from the working code
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

    // Debugging rubric data
    debugPrint('Rubric JSON Data: $rubrickinjsonformat');

    try {
      // Prepare POST request body with the same parameter names as the working code
      final response = await http.post(
        Uri.parse(fullUrl),
        body: {
          'wstoken': token,
          'wsfunction': 'local_learninglens_create_assignment',
          'moodlewsrestformat': 'json',
          'courseid': courseId,
          'sectionid': '1', // Ensure the section ID is valid
          'enddate': dueDate, // You can keep this as a readable string
          'startdate': startDate, // You can keep this as a readable string
          'description': description, // Assignment description
          'rubricJson': rubrickinjsonformat, // Sending rubric as string
          'assignmentName': assignmentName, // Assignment name
        },
      );

      // Check response status
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

  // Dropdown to display courses
  DropdownButtonFormField<String> _buildCourseDropdown() {
    return DropdownButtonFormField<String>(
      value: courses.isNotEmpty && selectedCourse != 'No courses available'
          ? selectedCourse
          : null,
      decoration: InputDecoration(
        labelText: 'Course name',
        border: OutlineInputBorder(),
      ),
      onChanged: (String? newValue) {
        setState(() {
          selectedCourse = newValue!;
        });
        debugPrint('Selected course: $selectedCourse');
      },
      items: courses.isNotEmpty
          ? courses.map<DropdownMenuItem<String>>((Course course) {
              return DropdownMenuItem<String>(
                value: course.fullName,
                child: Text(course.fullName),
              );
            }).toList()
          : [
              DropdownMenuItem<String>(
                value: 'No courses available',
                child: Text('No courses available'),
              ),
            ],
      isExpanded: true,
    );
  }

  // Custom Widget to build rubric table without editable package
  Widget buildRubricTable() {
    return Table(
      border: TableBorder.all(),
      children: [
        // Header Row
        TableRow(children: [
          _buildTableCell('Criteria'),
          for (var header in headers.skip(1)) _buildTableCell(header['title']),
        ]),
        // Data Rows
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Learning Lens',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(14.0),
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

            // Course Dropdown with dynamic course fetching
            SectionTitle(title: 'General'),
            _buildCourseDropdown(),
            SizedBox(height: 12),
            TextField(
              controller: _assignmentNameController,
              decoration: InputDecoration(
                labelText: 'Assignment name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // Rubric Section
            SectionTitle(title: 'Rubric'),
            buildRubricTable(), // Manually create rubric table
            SizedBox(height: 20),

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

            // Availability Section
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
            SizedBox(height: 14),

            // Remind me to grade by
            Row(
              children: [
                Checkbox(
                  value: isRemindEnabled,
                  onChanged: (value) {
                    setState(() {
                      isRemindEnabled = value!;
                    });
                  },
                ),
                Text('Enable'),
                SizedBox(width: 10),
                _buildDropdown(
                    'Remind me to grade by',
                    selectedDayRemind,
                    selectedMonthRemind,
                    selectedYearRemind,
                    selectedHourRemind,
                    selectedMinuteRemind,
                    isRemindEnabled, (String? newValue) {
                  setState(() {
                    selectedDayRemind = newValue!;
                  });
                }, (String? newValue) {
                  setState(() {
                    selectedMonthRemind = newValue!;
                  });
                }, (String? newValue) {
                  setState(() {
                    selectedYearRemind = newValue!;
                  });
                }, (String? newValue) {
                  setState(() {
                    selectedHourRemind = newValue!;
                  });
                }, (String? newValue) {
                  setState(() {
                    selectedMinuteRemind = newValue!;
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
                    String courseId = courses
                        .firstWhere(
                            (course) => course.fullName == selectedCourse)
                        .id
                        .toString();
                    String assignmentName = _assignmentNameController.text;
                    String description =
                        _quillController.document.toPlainText();
                    String dueDate =
                        '$selectedDayDue $selectedMonthDue $selectedYearDue $selectedHourDue:$selectedMinuteDue';
                    String allowSubmissionFrom =
                        '$selectedDaySubmission $selectedMonthSubmission $selectedYearSubmission $selectedHourSubmission:$selectedMinuteSubmission';

                    createAssignment(
                      '130bde328dbbbe61eaea301c5ad2dcc8', // Add your token here
                      courseId,
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
