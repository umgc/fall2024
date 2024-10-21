import 'package:flutter/material.dart';
import 'package:learninglens_app/Controller/beans.dart';
import '/Controller/main_controller.dart';
import '../content_carousel.dart';

//What we need:
//Two carousels, one for essays and the other for assessments.
//Additional information and buttons appear when a card is clicked.
//The essay cards have two buttons leading to submissions and assignment editing pages.
//The assessment cards have a button leading to the assessment editing page.
//Two buttons below that lead to the create essay and create assessment pages.

//Main Page
class ViewCourseContents extends StatefulWidget {
  final Course theCourse;
  ViewCourseContents(this.theCourse);

  @override
  State createState() {
    return _CourseState();
  }
}

class _CourseState extends State<ViewCourseContents> {
  late final String courseName;

  @override
  void initState() {
    super.initState();
    courseName = widget.theCourse.fullName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Navigator is //todo')),
        body: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              courseName,
              style: TextStyle(fontSize: 64),
            ),
            // ContentCarousel('assessment', MainController().selectedCourse?.quizzes),
            // ContentCarousel('essay', MainController().selectedCourse?.essays),
            ContentCarousel('assessment', widget.theCourse.quizzes, courseId: widget.theCourse.id),
            ContentCarousel('essay', widget.theCourse.essays, courseId: widget.theCourse.id),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [CreateButton('assessment'), CreateButton('essay')])
          ],
        )));
  }
}
