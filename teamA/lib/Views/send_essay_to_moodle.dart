import 'package:flutter/material.dart';
import '../api/moodle_api_singleton.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class EssayAssignmentSettings extends StatefulWidget {
  // const EssayAssignmentSettings({super.key});
  final String updatedJson;

  EssayAssignmentSettings(this.updatedJson);
//String rubrickinjsonformat= updatedJson;
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

  // List of courses with their corresponding course IDs
  Map<String, String> courses = {
    'Select a course': '',
    'Course 1': '5',
    'Course 2': '6',
    'Course 3': '7'
  };

  // Selected course
  String selectedCourse = 'Select a course';

  // Rubric data
  List<Map<String, String>> rubricData = [
    {
      'criteria': 'Thesis Statement',
      'exemplary':
          'Clear, strong thesis; clearly states position on dress code.',
      'proficient': 'Thesis is present but may lack clarity or strength.',
      'needsImprovement': 'Thesis is unclear or missing.'
    }
  ];

  bool isRubricEditingEnabled = true;

  // Add new rubric row
  void _addNewRubricRow() {
    if (!isRubricEditingEnabled) return;
    setState(() {
      rubricData.add({
        'criteria': 'New Criteria',
        'exemplary': 'Exemplary description',
        'proficient': 'Proficient description',
        'needsImprovement': 'Needs Improvement description',
      });
    });
  }

  // Remove a rubric row
  void _removeRubricRow(int index) {
    if (!isRubricEditingEnabled) return;
    setState(() {
      rubricData.removeAt(index);
    });
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
    final fullUrl = 'https://www.swen670moodle.site/$url'; // Full URL
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
    // Prepare rubric data
    List<Map<String, dynamic>> rubric = widget.updatedJson.map((row) {
      return {
        'description': row['criteria'],
        'levels': [
          {'definition': row['exemplary'], 'score': 3},
          {'definition': row['proficient'], 'score': 2},
          {'definition': row['needsImprovement'], 'score': 1},
        ]
      };
    }).toList();

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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Assignment sent to Moodle successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send assignment to Moodle.')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    }
  }

  // Rubric Table UI
  Widget _buildRubricTable() {
    return Column(
      children: [
        Table(
          border: TableBorder.all(),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[300]),
              children: [
                _buildTableCell('Criteria'),
                _buildTableCell('3 - Exemplary'),
                _buildTableCell('2 - Proficient'),
                _buildTableCell('1 - Needs Improvement'),
                _buildTableCell('Actions'),
              ],
            ),
            ...rubricData.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, String> row = entry.value;
              return TableRow(
                children: [
                  _editableTableCell(index, 'criteria', row['criteria']!),
                  _editableTableCell(index, 'exemplary', row['exemplary']!),
                  _editableTableCell(index, 'proficient', row['proficient']!),
                  _editableTableCell(
                      index, 'needsImprovement', row['needsImprovement']!),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeRubricRow(index),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
        SizedBox(height: 12),
        if (isRubricEditingEnabled)
          ElevatedButton(
            onPressed: _addNewRubricRow,
            child: Text('Add New Row'),
          ),
      ],
    );
  }

  // Finish and Assign button action
  void _finishAndAssign() {
    setState(() {
      isRubricEditingEnabled = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Rubric editing finished')));
  }

  // Build fixed table cells
  Widget _buildTableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // Build editable table cells
  Widget _editableTableCell(int rowIndex, String key, String text) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        enabled: isRubricEditingEnabled,
        initialValue: text,
        onChanged: (value) {
          setState(() {
            rubricData[rowIndex][key] = value;
          });
        },
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
        actions: [
          ElevatedButton(
            onPressed: _finishAndAssign,
            child: Text('Finish and Assign'),
          ),
        ],
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

            // Course Dropdown with black outline
            SectionTitle(title: 'General'),
            DropdownButtonFormField<String>(
              value: selectedCourse,
              decoration: InputDecoration(
                labelText: 'Course name',
                border: OutlineInputBorder(),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCourse = newValue!;
                });
              },
              items: courses.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              isExpanded: true,
            ),
            SizedBox(height: 12),

            // Assignment Name TextField
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
            _buildRubricTable(),
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
                  onPressed: () async {
                    // Capture the form data
                    String courseId = courses[selectedCourse] ??
                        ''; // Get course ID from the map
                    String assignmentName = _assignmentNameController.text;
                    String description =
                        _quillController.document.toPlainText();
                    String dueDate =
                        '$selectedDayDue $selectedMonthDue $selectedYearDue $selectedHourDue:$selectedMinuteDue';
                    String allowSubmissionFrom =
                        '$selectedDaySubmission $selectedMonthSubmission $selectedYearSubmission $selectedHourSubmission:$selectedMinuteSubmission';
                    var result = await MoodleApiSingleton().createAssignnment(
                        courseId,
                        '2',
                        assignmentName,
                        allowSubmissionFrom,
                        dueDate,
                        widget.updatedJson,
                        description);
                    // Log the captured data for debugging
                    debugPrint('Course ID: $courseId');
                    debugPrint('Assignment Name: $assignmentName');
                    debugPrint('Description: $description');
                    debugPrint('Due Date: $dueDate');
                    debugPrint('Allow Submission From: $allowSubmissionFrom');

                    /*// Call createAssignment function to send the data to Moodle
                    createAssignment(
                      '130bde328dbbbe61eaea301c5ad2dcc8', // Add your token
                      courseId,
                      assignmentName,
                      description,
                      dueDate,
                      allowSubmissionFrom,
                    );*/
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
