import 'package:flutter/material.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';
import '/controller/model/beans.dart';
import 'view_submissions.dart';
import '../controller/main_controller.dart';

class EssayManagerPage extends StatefulWidget {
  @override
  EssayManagerPageState createState() => EssayManagerPageState();
}

class EssayManagerPageState extends State<EssayManagerPage> {
  Course? selectedCourse; // Course object to handle selected course
  List<Course> courses = [];
  List<Assignment> assignments = [];

  @override
  void initState() {
    super.initState();
    MoodleApiSingleton().getCourses().then((result) {
      courses = result;
      selectedCourse = null;
      setState(() {});
    });
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
              onChanged: (newValue) {
                setState(() {
                  selectedCourse = newValue;
                  print(selectedCourse?.essays);
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SubmissionList(
                                                assignmentId:
                                                    assignment.id!.toInt(),
                                                courseId: selectedCourse!.id
                                                    .toString(),
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
                      )),
          ],
        ),
      ),
    );
  }
}
