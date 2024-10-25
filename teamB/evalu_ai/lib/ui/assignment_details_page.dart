// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';
import 'package:intelligrade/controller/main_controller.dart';
import 'package:intelligrade/controller/model/beans.dart';
import 'package:intelligrade/ui/header.dart';
import 'package:intelligrade/ui/custom_navigation_bar.dart';
import 'package:intelligrade/ui/view_submissions.dart';

class AssignmentDetailsPage extends StatefulWidget {
  final dynamic assignment;
  static var apiKey = dotenv.env['PERPLEXITY_API_KEY'] ?? '';
  
  const AssignmentDetailsPage({super.key, required this.assignment});

  static MainController controller = MainController();

  @override
  _AssignmentDetailsPage createState() => _AssignmentDetailsPage();
}

/*
  My initial thoughts are that when a quiz is selected, pass the selected quiz 
  as an object to this page which will use the assignment data to populate
  the required fields.
*/

class _AssignmentDetailsPage extends State<AssignmentDetailsPage> {
  bool summaryIsSelected = true;
  List<Course> courses = [];
  List<Assignment> essays = [];
  List<Quiz> quizzes = [];
  var assignments = [];
  int courseId = 0;

  

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

  Future<void> findCourse(int id) async {
    try {
      courses.forEach( (course) {
        course.essays?.forEach((assignment) {
          if(assignment.id == id) {
            courseId = course.id;
          }
        });
        course.quizzes?.forEach((quiz) {
          if(quiz.id == id) {
            courseId = course.id;
          }
        });
      });
    } catch (e) {
      debugPrint('Error getting course id: $e');
      setState(() {
      });
    }

  }

  /*
    May need other methods to retrieve the data from the quiz
  */

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final int selectedIndex = args['selectedIndex'] ?? 0;
    final dynamic assignment = args['assignment'];  
    int numQuestions;
    List questions = [];
    
    findCourse(assignment.id);

    if(assignment is Quiz) {
      numQuestions = assignment.questionList.length;
      questions = assignment.questionList;
    } else{
      numQuestions = 1;
    } 

    return Scaffold(
      appBar: const AppHeader(title: "Assignment Details"),
      body: LayoutBuilder(builder: (context, constraints) {
        return Row(
          //over arching page row
          children: <Widget>[
            Container(
              //for the nav bar
              width: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueGrey,
                  width: 0.5,
                ),
              ),
              child: CustomNavigationBar(selectedIndex: selectedIndex),
            ),
            Expanded(
              //for the remainder of the page
              child: Column(
                //remaining page data
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Container(
                    width: 1150,
                    height: 60,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        spreadRadius: 3,
                      )
                    ]),
                    child: Row(
                      //row for the assignemnt header
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          //title column
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Exam Title'),
                            Text(assignment.name), //placeholder, will be the data from quiz
                          ],
                        ),
                        Column(
                          //number of questions column
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Number of Questions'),
                            Text(numQuestions.toString()), //placeholder, will be the data from quiz
                          ],
                        ),
                      ],
                    ), //row for the assignemnt header,
                  ), //container for the row so it takes the whole page
                  SizedBox(height: 10),
                  Container(
                    child: Row(
                      children: [
                        SizedBox(width: 30),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              summaryIsSelected =
                                  true; // Update to show Summary
                            });
                          },
                          child: const Text('Summary'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SubmissionList(
                                                assignmentId:
                                                    assignment.id!.toInt(),
                                                courseId: courseId
                                                    .toString(),
                                              ),
                                            ),
                                          );
                          },
                          child: const Text('Submissions'),
                        ),
                        !summaryIsSelected
                            ? Container(
                                child: Row(
                                children: [
                                  SizedBox(width: 850),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('Assign Student'),
                                  ),
                                ],
                              ))
                            : SizedBox(width: 500)
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                     child: ListView.builder(
                      itemCount: (numQuestions),
                      itemBuilder: (context, index) {
                        Question question = Question(name: "null", type: "null", questionText: "no text"); 
                        if(assignment is Quiz) question = questions[index];
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
                                              question.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(question.type),
                                          ],
                                        ),
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
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
