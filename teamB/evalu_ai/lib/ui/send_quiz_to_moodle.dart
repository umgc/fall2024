import 'package:flutter/material.dart';
import 'package:intelligrade/controller/model/beans.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';
import 'package:intelligrade/ui/dashboard_page.dart';
import 'package:intelligrade/ui/header.dart';

class QuizMoodle extends StatefulWidget {
  final Quiz quiz;
  QuizMoodle({required this.quiz});

  @override
  QuizMoodleState createState() => QuizMoodleState();
}

class QuizMoodleState extends State<QuizMoodle> {
  // Submission form dates
  String selectedDaySubmission = '01';
  String selectedMonthSubmission = 'January';
  String selectedYearSubmission = '2024';
  String selectedHourSubmission = '00';
  String selectedMinuteSubmission = '00';
  late String quizasxml;
  late MoodleApiSingleton api;
  List<Course> courses = [];
  String selectedCourse = 'Select a course';

  @override
  void initState() {
    super.initState();
    quizNameController = TextEditingController(text: widget.quiz.name ?? '');
    quizQuestionsController = TextEditingController();
    quizasxml = widget.quiz.toXmlString();
    fetchCourses();
  }

  // Fetch courses from the controller
  Future<void> fetchCourses() async {
    try {
      List<Course>? courseList = MoodleApiSingleton().moodleCourses;
      setState(() {
        courses = courseList ?? [];
        selectedCourse = 'Select a course';
      });
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      setState(() {
        selectedCourse = 'No courses available'; // Handle the empty case
      });
    }
  }

    void _showMoodleSuccess() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Successfully Submitted to Moodle!'),
          content: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  ElevatedButton (
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DashBoardPage(),
                          ),
                      );
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

      void _showMoodleFailure() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Failed to Submit to Moodle'),
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

  // Dropdown to display courses with "Select a course" as the default option
  DropdownButtonFormField<String> _buildCourseDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCourse == 'Select a course' ? null : selectedCourse,
      decoration: InputDecoration(
        labelText: 'Course name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFFC1C3C5)),
        ),
        filled: true,
        fillColor: const Color(0xFFF4F6F9),
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
            value: course.id.toString(),
            child: Text(course.fullName),
          );
        }),
      ],
      isExpanded: true,
    );
  }

  // Due date selection
  String selectedDayDue = '01';
  String selectedMonthDue = 'January';
  String selectedYearDue = '2024';
  String selectedHourDue = '00';
  String selectedMinuteDue = '00';

  // Checkbox states
  bool isSubmissionEnabled = true;
  bool isDueDateEnabled = true;

  List<String> days = List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  List<String> years = ['2023', '2024', '2025'];
  List<String> hours = List.generate(24, (index) => index.toString().padLeft(2, '0'));
  List<String> minutes = List.generate(60, (index) => index.toString().padLeft(2, '0'));

  // Initial selected values for dropdowns
  String selectedCategory = 'No Category Selected';
  String selectedAttempt = 'No attempt limit';
  String selectedGradingMethod = 'No grading method selected';

  // Lists of static items for dropdowns
  var categoryItems = [
    'No Category Selected', 'Category 1', 'Category 2', 'Category 3'
  ];
  var attemptItems = [
    'No attempt limit', 'Unlimited', 'First', 'Second', 'Last'
  ];
  var gradingMethodItems = [
    'No grading method selected', 'Highest Grade', 'Average Grade', 'Low Grade'
  ];

  late TextEditingController quizNameController;
  TextEditingController gradeController = TextEditingController();
  late TextEditingController quizQuestionsController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: const AppHeader(title: 'Send to Moodle'), // Using the AppHeader
        body: SingleChildScrollView(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Assignment Title Section
              sectionTitle(title: 'Assignment Title'),
              SizedBox(height: 15),
              TextField(
                controller: quizNameController,
                decoration: InputDecoration(
                  labelText: 'Assignment Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Color(0xFFC1C3C5)),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF4F6F9),
                ),
                enabled: false,
              ),
              SizedBox(height: 15),

              // Course Name and Number of Questions side by side
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(title: 'Course Name'),
                        SizedBox(height: 15),
                        _buildCourseDropdown(),
                      ],
                    ),
                  ),
                  SizedBox(width: 15), // Spacing between the columns
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(title: 'Number of Questions'),
                        SizedBox(height: 15),
                        TextField(
                          controller: quizQuestionsController,
                          decoration: InputDecoration(
                            labelText: 'Number of questions',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(color: Color(0xFFC1C3C5)),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF4F6F9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Grading Section
              sectionTitle(title: 'Grade'),
              SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Grade Categories
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(title: 'Grade Categories:'),
                        DropdownButton<String>(
                          value: selectedCategory,
                          icon: Icon(Icons.keyboard_arrow_down),
                          items: categoryItems.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15), // Space between the columns

                  // Grading Method
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(title: 'Grading Method:'),
                        DropdownButton<String>(
                          value: selectedGradingMethod,
                          icon: Icon(Icons.keyboard_arrow_down),
                          items: gradingMethodItems.map((String method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedGradingMethod = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15), // Space between the columns

                  // Attempts Allowed
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(title: 'Attempts Allowed:'),
                        DropdownButton<String>(
                          value: selectedAttempt,
                          icon: Icon(Icons.keyboard_arrow_down),
                          items: attemptItems.map((String attempt) {
                            return DropdownMenuItem<String>(
                              value: attempt,
                              child: Text(attempt),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedAttempt = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15), // Space between the columns

                  // Grade to Pass
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(title: 'Grade to Pass:'),
                        TextField(
                          controller: gradeController,
                          decoration: InputDecoration(
                            labelText: 'Enter grade',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(color: Color(0xFFC1C3C5)),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF4F6F9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20), // Space below the entire Grade section

              // Availability Section
              sectionTitle(title: 'Availability'),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Allow Submissions Section
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
                      Text('Allow Submissions'),
                      SizedBox(width: 10),
                      _buildDropdown(
                        'Allow Submissions From Date:',
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
                    ],
                  ),
                  // Due Date Section
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
                      Text('Enable Due Date'),
                      SizedBox(width: 10),
                      _buildDropdown(
                        'Due Date:',
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
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Action Buttons
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.quiz.name!.contains("Coding") || widget.quiz.name!.contains("Code")) {
                          print(selectedCourse);
                          courses.forEach((course) {
                            print(course.id);
                          });
                          List<Course> matchingCourse = courses.where((course) => course.id.toString() == selectedCourse).toList();
                          String dueDate =
                              '$selectedDayDue $selectedMonthDue $selectedYearDue $selectedHourDue:$selectedMinuteDue';
                          print(dueDate);
                          String allowSubmissionFrom =
                              '$selectedDaySubmission $selectedMonthSubmission $selectedYearSubmission $selectedHourSubmission:$selectedMinuteSubmission';
                          print(allowSubmissionFrom);
                          await MoodleApiSingleton().createAssignment(
                            matchingCourse!.first.id.toString(),
                            '3', // Section ID
                            widget.quiz.name ?? 'Code Assignment',
                            allowSubmissionFrom,
                            dueDate,
                            '''{"criteria":[{"description":"Full Score","levels":[{"definition":"Score Given by Code Compiler","score": 0}]}]}''',
                            widget.quiz.description ?? 'Code Assignment',
                          );
                          _showMoodleSuccess();
                        } else {
                          var quizid = await MoodleApiSingleton().createQuiz(
                            selectedCourse,
                            widget.quiz.name ?? 'Quiz Name',
                            widget.quiz.description ?? 'Quiz Description',
                          );
                          print('Quiz ID: $quizid');
                          var categoryid = await MoodleApiSingleton()
                              .importQuizQuestions(selectedCourse, quizasxml);
                          print('Category ID: $categoryid');
                          var randomresult = await MoodleApiSingleton()
                              .addRandomQuestions(categoryid.toString(),
                                  quizid.toString(), quizQuestionsController.text);
                          print('Random Result: $randomresult');
                          if (quizid != null) {
                            _showMoodleSuccess();
                          } else {
                            _showMoodleFailure();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7D6CE2), // Match the color
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Match the padding
                      ),
                      child: const Text(
                        'Send to Moodle',
                        style: TextStyle(color: Colors.white), // Adjust text color if needed
                      ),
                    ),
                    SizedBox(width: 10), // Space between buttons
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFB0B3B5), // Darker background color
                        foregroundColor: Colors.white, // Change text color to white for better contrast
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Add padding for better visibility
                      ),
                      child: const Text(
                        'Back to Edit Questions',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20), // Space between buttons and the next section
            ],
          ),
        ),
      ),
    );
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
            _buildDropdownButton(months, selectedMonth, onMonthChanged, isEnabled),
            SizedBox(width: 8),
            _buildDropdownButton(years, selectedYear, onYearChanged, isEnabled),
            SizedBox(width: 8),
            _buildDropdownButton(hours, selectedHour, onHourChanged, isEnabled),
            SizedBox(width: 8),
            _buildDropdownButton(minutes, selectedMinute, onMinuteChanged, isEnabled),
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
