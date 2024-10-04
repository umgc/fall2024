import 'package:flutter/material.dart';

final ColorScheme customColorScheme = ColorScheme(
  primary: Color(0xFF6A5A99), // Purple color as primary
  onPrimary: Color(0xFFFFFFFF), // White text on primary
  primaryContainer: Color(0xFFEDE6FF), // Light lavender
  onPrimaryContainer: Color(0xFF2D004A), // Dark purple
  secondary: Color(0xFF6A5A99), // Using similar purple as secondary
  onSecondary: Colors.white, // Black text on background
  surface: Color(0xFFFFFFFF), // White surface color
  onSurface: Colors.black, // Black text on surface
  error: Colors.red, // Error color red
  onError: Colors.white, // White on error
  brightness: Brightness.light, // Light mode
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: QuizMoodle(),
        theme: ThemeData(
          useMaterial3: true,
        ),
        title: 'Learning Lens');
  }
}

class QuizMoodle extends StatefulWidget {
  @override
  _QuizMoodleState createState() => _QuizMoodleState();
}

class _QuizMoodleState extends State<QuizMoodle> {
  // Submission form dates
  String selectedDaySubmission = '01';
  String selectedMonthSubmission = 'January';
  String selectedYearSubmission = '2024';
  String selectedHourSubmission = '00';
  String selectedMinuteSubmission = '00';

// Due date selection
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

  // Initial selected value for category
  String dropdownvalue = 'No selection';

  // List of categories in the dropdown menu
  var items = [
    'No selection',
    'Category 1',
    'Category 2',
    'Category 3',
    'Category 4',
  ];

  // List of attempts options

  var items2 = [
    'No selection',
    'Unlimited',
    'First',
    'Second',
    'Last',
  ];

  //List of grading methods
  var items3 = [
    'No selection',
    'Highest Grade',
    'Average Grade',
    'Low Grade',
  ];

  TextEditingController courseNameController = TextEditingController();
  TextEditingController quizNameController = TextEditingController();
  TextEditingController gradeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Learning Lens',
            textDirection: TextDirection.ltr,
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ), // Use primary container color
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text(
                  'Send Quiz to Moodle',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),

            sectionTitle(title: 'Quiz Information'),
            TextField(
              controller: courseNameController,
              decoration: InputDecoration(
                labelText: 'Course Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),

            TextField(
              controller: quizNameController,
              decoration: InputDecoration(
                labelText: 'Quiz name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),

            sectionTitle(title: 'Availability'),
            SizedBox(height: 15),

            // Submission Date
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  Checkbox(
                      value: isSubmissionEnabled,
                      onChanged: (value) {
                        setState(() {
                          isSubmissionEnabled = value!;
                        });
                      }),
                  Text('Enable'),
                  SizedBox(width: 10),
                  _buildDropdown(
                      'Allow Submissions From Date:',
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
            ),
            SizedBox(height: 16),
            // Due Date
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
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
                      'Due Date:',
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
            ),
            SizedBox(height: 16),

            // Grading Section
            sectionTitle(title: 'Grade'),
            SizedBox(height: 15),

            // Grading Catergories
            SizedBox(width: 10),
            sectionTitle(title: 'Grade Catergories:'),
            DropdownButton(
              value: dropdownvalue,
              icon: Icon(Icons.keyboard_arrow_down),
              items: items.map((String items) {
                return DropdownMenuItem<String>(
                  value: items,
                  child: Text(items),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownvalue = newValue!;
                });
              },
            ),
            SizedBox(height: 16),

            // Grade to pass
            sectionTitle(title: 'Grade to Pass:'),
            TextField(
              controller: gradeController,
              decoration: InputDecoration(
                labelText: 'Enter grade',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Attempts Allowed
            SizedBox(width: 10),
            sectionTitle(title: 'Attempts Allowed:'),
            DropdownButton(
              value: dropdownvalue,
              icon: Icon(Icons.keyboard_arrow_down),
              items: items2.map((String attempts) {
                return DropdownMenuItem<String>(
                  value: attempts,
                  child: Text(attempts),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownvalue = newValue!;
                });
              },
            ),
            SizedBox(height: 16),
            // Grading Method
            SizedBox(width: 10),
            sectionTitle(title: 'Grading Method:'),
            DropdownButton(
              value: dropdownvalue,
              icon: Icon(Icons.keyboard_arrow_down),
              items: items3.map((String methods) {
                return DropdownMenuItem<String>(
                  value: methods,
                  child: Text(methods),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownvalue = newValue!;
                });
              },
            ),

            // Bottom
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Send to Moodle action
                    },
                    child: Text(
                      'Send to Moodle',
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Back to quiz action
                    },
                    child: Text(
                      'Go back to update quiz',
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

// Dropdown Builder
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
    ValueChanged<String?> onMinuteChanged,
  ) {
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
            SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}

// Dropdown Button Builder
Widget _buildDropdownButton(List<String> items, String selectedValue,
    ValueChanged<String?> onChanged, bool isEnabled) {
  return DropdownButton<String>(
    value: selectedValue,
    onChanged: isEnabled ? onChanged : null,
    items: items.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
  );
}

// Section Title Widget
Widget sectionTitle({required String title}) {
  return Text(
    title,
    textDirection: TextDirection.ltr,
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );
}
