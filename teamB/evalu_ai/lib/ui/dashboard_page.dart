import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intelligrade/ui/header.dart';
import 'package:intelligrade/ui/custom_navigation_bar.dart';
import 'package:intelligrade/controller/main_controller.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';
import 'package:intelligrade/controller/model/beans.dart';

import '../controller/html_converter.dart';
//look at the singleton file
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
        essays = [...selectedCourse!.essays!];
        quizzes = [...selectedCourse!.quizzes!];
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

  @override
  Widget build(BuildContext context) {
    final int selectedIndex =
        ModalRoute.of(context)?.settings.arguments as int? ??
            0; //capture index for nav bar
    return Scaffold(
        appBar: const AppHeader(
          title: "Dashboard", //maybe change
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
              (essays.isEmpty  && quizzes.isEmpty)
                  ? Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No saved exams yet.'),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/create');
                            },
                            child: const Text('Create Exam'),
                          ),
                        ],
                      ),
                    )
                  : Text("It Worked!"),//get the rest starting on line 93 of essay_display_page
            ],
          );
        }));
  }
}
