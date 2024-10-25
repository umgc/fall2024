// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';
import 'package:intelligrade/controller/main_controller.dart';
import 'package:intelligrade/controller/model/beans.dart';
import 'package:intelligrade/ui/header.dart';
import 'package:intelligrade/ui/custom_navigation_bar.dart';
import 'view_submissions.dart';

class ViewAssignmentsPage extends StatefulWidget {
  const ViewAssignmentsPage({super.key});

  static MainController controller = MainController();

  @override
  _ViewAssignmentsPage createState() => _ViewAssignmentsPage();
}

class _ViewAssignmentsPage extends State<ViewAssignmentsPage> {
  List<Course> courses = [];
  List<Assignment> essays = [];
  List<Quiz> quizzes = [];
  var assignments = [];
  String? typeFilterSelection;

  @override
  void initState() {
    super.initState();
    fetchCourses();
    fetchAssignments();
  }

 Future<void> fetchCourses() async {
    try {
      List<Course>? courseList = MoodleApiSingleton().moodleCourses;
      setState(() {
        courses = courseList ?? [];
        
      });
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      setState(() {
      });
    }
  }

  Future<void> fetchAssignments() async {
    try{
      courses.forEach((course) {
        Course? selectedCourse = course;
        essays = [...?selectedCourse.essays ?? []];
        quizzes = [...?selectedCourse.quizzes ?? []];
        assignments = [...quizzes, ...essays];
      });
    } catch (e) {
      debugPrint('Error fetching assignments: $e');
      setState(() {
      });
    }
  }

  Future<void> refreshCourses() async {
    try {
      List<Course>? newCourseList = MoodleApiSingleton().moodleCourses;
      setState(() {
        courses = newCourseList ?? [];
      });
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      setState(() {
      });
    }
  }

  void _editQuiz(Quiz quiz) async {
    List<List<TextEditingController>> controllers =
        quiz.questionList.map((question) {
      List<TextEditingController> questionControllers = [
        TextEditingController(text: question.questionText)
      ];
      questionControllers.addAll(question.answerList
          .map((answer) => TextEditingController(text: answer.answerText))
          .toList());
      return questionControllers;
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Quiz'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...controllers.asMap().entries.map((entry) {
                  int questionIndex = entry.key;
                  List<TextEditingController> controllersForQuestion =
                      entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controllersForQuestion[0],
                        decoration: InputDecoration(
                            labelText: 'Edit question ${questionIndex + 1}'),
                        onChanged: (text) {
                          quiz.questionList[questionIndex].questionText = text;
                        },
                      ),
                      ...controllersForQuestion
                          .sublist(1)
                          .asMap()
                          .entries
                          .map((answerEntry) {
                        int answerIndex = answerEntry.key;
                        TextEditingController controller = answerEntry.value;

                        return TextField(
                          controller: controller,
                          decoration: InputDecoration(
                              labelText:
                                  'Edit answer ${String.fromCharCode('a'.codeUnitAt(0) + answerIndex)}'),
                          onChanged: (text) {
                            quiz.questionList[questionIndex]
                                .answerList[answerIndex].answerText = text;
                          },
                        );
                      }),
                      const SizedBox(height: 20),
                    ],
                  );
                }),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                try {
                  ViewAssignmentsPage.controller.updateFileLocally(quiz);
                  // _fetchQuizzes(); // Refresh quiz list
                  Navigator.of(context).pop();
                  // _showQuizDetails(quiz);
                } catch (e) {
                  if (kDebugMode) {
                    print('Error updating quiz: $e');
                  }
                }
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                // _showQuizDetails(quiz);
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _postQuizToMoodle(Quiz quiz) async {
    try {
      List<Course> courses = await ViewAssignmentsPage.controller.getCourses();
      String? selectedCourseId = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Moodle Course To Post To'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: courses.map((course) {
                  return ListTile(
                    title: Text(course.fullName),
                    onTap: () {
                      Navigator.of(context).pop(course.id.toString());
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );

      if (selectedCourseId != null) {
        await ViewAssignmentsPage.controller
            .postAssessmentToMoodle(quiz, selectedCourseId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz posted to Moodle successfully')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error posting quiz to Moodle: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error posting quiz to Moodle')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex =
        ModalRoute.of(context)?.settings.arguments as int? ?? 0;
    return Scaffold(
        appBar: const AppHeader(
          title: "View Assignments",
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return Row(
            children: <Widget>[
              Container(
                width: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 0.5,
                  ),
                ),
                child: CustomNavigationBar(selectedIndex: selectedIndex),
              ),
              (assignments.isEmpty)
                  ? Expanded(
                      child: Column(
                        //mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _filterBar(),
                          const SizedBox(height: 300),
                          const Text('No saved exams yet.'),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/create');
                            },
                            child: const Text('Create Exam'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubmissionList(
                                    assignmentId: 73,
                                    courseId: '2',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Test page'),
                          ),
                        ],
                      ),
                    )
                  : Expanded(
                    child: Center(
                     child: ListView.builder(
                      itemCount: (assignments.length),
                      itemBuilder: (context, index) {
                        var assignment = assignments[index];
                        if(assignment is Assignment) {
                          //handle like essay
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              assignment.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(assignment.description),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                         Navigator.pushReplacementNamed(
                                            context, 
                                            '/assignmentDetails',
                                            arguments: {
                                              'selectedIndex': selectedIndex,
                                              'assignment': assignment, // Pass the actual Assignment object
                                            },
                                          );
                                        },
                                        child: Text('View Details'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          //handle like quiz
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              assignment.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(assignment.description),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushReplacementNamed(
                                            context, 
                                            '/assignmentDetails',
                                            arguments: {
                                              'selectedIndex': selectedIndex,
                                              'assignment': assignment, // Pass the actual Assignment object
                                            },
                                          );
                                        },
                                        child: Text('View Details'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                     ),
                    ),
                  )
            ],
          );
        }));
  }

  Widget _filterBar() {
    return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black, // Border color
                                width: 1, // Border width
                              ),
                              borderRadius:
                                  BorderRadius.circular(60), // Circular border
                            ),
                            padding: EdgeInsets.all(
                                16), // Padding inside the container
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: Row(
                                      // ignore: prefer_const_literals_to_create_immutables
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            //onChanged: //_handleSearch,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              hintText: "Search",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Padding(
                                  //filter dropdown types
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0), // Optional padding
                                  child: DropdownButton<String>(
                                    value: typeFilterSelection,
                                    hint: Text('Type'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        typeFilterSelection =
                                            newValue; // Update the selected value
                                      });
                                    },
                                    items: <String>['Quiz', 'Essay', 'Code']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Padding(
                                  //filter dropdown for subject
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0), // Optional padding
                                  child: DropdownButton<String>(
                                    value: typeFilterSelection,
                                    hint: Text('Subject'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        typeFilterSelection =
                                            newValue; // Update the selected value
                                      });
                                    },
                                    items: <String>[
                                      'Math',
                                      'Chemistry',
                                      'Biology',
                                      'Computer Science',
                                      'Literature',
                                      'History',
                                      'Language Arts',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Padding(
                                  //filter dropdown for status
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0), // Optional padding
                                  child: DropdownButton<String>(
                                    value: typeFilterSelection,
                                    hint: Text('Status'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        typeFilterSelection =
                                            newValue; // Update the selected value
                                      });
                                    },
                                    items: <String>[
                                      'In-progress',
                                      'Completed',
                                      'Not Submitted',
                                      'Not Finalized',
                                      'Submitted',
                                      'Finalized',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(width: 20),
                                CircleAvatar(
                                  backgroundColor: Colors
                                      .deepPurple[200], // Background color
                                  child: IconButton(
                                    icon: Icon(Icons.search),
                                    color: Colors.deepPurple,
                                    onPressed: () {
                                      // Action to perform when the icon is pressed
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
  }
}

