import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intelligrade/ui/header.dart';
import 'package:intelligrade/ui/custom_navigation_bar.dart';
import 'package:intelligrade/controller/main_controller.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';
import 'package:intelligrade/controller/model/beans.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});
  static MainController controller = MainController();

  @override
  _DashBoardPageState createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  List<Course> courses = [];
  List<Assignment> essays = [];
  List<Quiz> quizzes = [];
  var assignments = [];

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
      setState(() {});
    }
  }

  Future<void> fetchAssignments() async {
    try {
      for (var course in courses) {
        essays = [...?course.essays ?? []];
        quizzes = [...?course.quizzes ?? []];
        assignments = [...quizzes, ...essays];
      }
    } catch (e) {
      debugPrint('Error fetching assignments: $e');
      setState(() {});
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
      setState(() {});
    }
  }

  bool containsHtmlTags(String text) {
    return RegExp(r"<[^>]*>").hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex =
        ModalRoute.of(context)?.settings.arguments as int? ?? 0;

    return Scaffold(
      appBar: const AppHeader(
        title: "Dashboard",
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
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No saved exams yet.'),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/create');
                          },
                          child: const Text('Create Exam'),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: Center(
                      child: ListView.builder(
                        itemCount: (10), // Example limit for assignment display
                        itemBuilder: (context, index) {
                          var assignment = assignments[index];
                          if (assignment is Assignment) {
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
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
                                              SizedBox(width: 5),
                                              containsHtmlTags(assignment.name)
                                                  ? Html(data: assignment.name)
                                                  : Text(
                                                      assignment.name,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                              SizedBox(height: 5),
                                              containsHtmlTags(
                                                      assignment.description)
                                                  ? Html(
                                                      data: assignment
                                                          .description)
                                                  : Text(
                                                      assignment.description),
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
                                                'assignment': assignment,
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
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
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
                                              containsHtmlTags(assignment.name)
                                                  ? Html(data: assignment.name)
                                                  : Text(
                                                      assignment.name,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                              SizedBox(height: 5),
                                              containsHtmlTags(
                                                      assignment.description)
                                                  ? Html(
                                                      data: assignment
                                                          .description)
                                                  : Text(
                                                      assignment.description),
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
                                                'assignment': assignment,
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
                  ),
          ],
        );
      }),
    );
  }
}
