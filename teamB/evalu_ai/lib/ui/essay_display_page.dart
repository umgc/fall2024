import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';
import '/controller/model/beans.dart';
import 'view_submissions.dart';

class EssayManagerPage extends StatefulWidget {
  @override
  EssayManagerPageState createState() => EssayManagerPageState();
}

class EssayManagerPageState extends State<EssayManagerPage> {
  Course? selectedCourse;
  List<Course> courses = [];
  List<Assignment> assignments = [];

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      List<Course>? courseList = MoodleApiSingleton().moodleCourses;
      setState(() {
        courses = courseList ?? [];
        selectedCourse = null;
      });
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      setState(() {
        selectedCourse = null;
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
        selectedCourse = null;
      });
    }
  }

  bool containsHtmlTags(String text) {
    return RegExp(r"<[^>]*>").hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Essay Assignments'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Courses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            DropdownButton<Course>(
              value: selectedCourse,
              hint: Text('Select a Course'),
              onChanged: (Course? newValue) {
                setState(() {
                  refreshCourses();
                  selectedCourse = newValue;
                  assignments = selectedCourse!.essays!;
                  assignments.removeWhere((item) => item.name.contains('Code'));
                });
              },
              items: courses.map<DropdownMenuItem<Course>>((Course course) {
                return DropdownMenuItem<Course>(
                  value: course,
                  child: Text(course.fullName),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Expanded(
              child: selectedCourse == null
                  ? Center(
                      child:
                          Text('Please select a course to view assignments.'),
                    )
                  : ListView.builder(
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {
                        Assignment assignment = assignments[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
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
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                          SizedBox(height: 5),
                                          containsHtmlTags(
                                                  assignment.description)
                                              ? Html(
                                                  data: assignment.description)
                                              : Text(assignment.description),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SubmissionList(
                                              assignmentId:
                                                  assignment.id!.toInt(),
                                              courseId:
                                                  selectedCourse!.id.toString(),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text('View Submissions'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
