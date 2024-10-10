import 'package:flutter/material.dart';
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
  ViewCourseContents();

  @override
  State createState(){
    return _CourseState();
  }
}

class _CourseState extends State{
  final String courseName = MainController().getSelectedCourse()?.fullName ?? "Test Course";

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Navigator is //todo')),
      body: 
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(courseName, style: TextStyle(fontSize: 64),),
              ContentCarousel('assessment', MainController().quizzes),
              ContentCarousel('essay', MainController().essays),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [CreateButton('assessment'), CreateButton('essay')]
              )
            ],
          )
        )
    );
  }
}
