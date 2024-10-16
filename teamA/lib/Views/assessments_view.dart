import "package:flutter/material.dart";
import "package:learninglens_app/Api/moodle_api_singleton.dart";
import "package:learninglens_app/Controller/beans.dart";
import "package:learninglens_app/content_carousel.dart";


//The Page
class AssessmentsView extends StatefulWidget{
  AssessmentsView();

  @override
  State createState(){
    return _AssessmentsState();
  }
}

class _AssessmentsState extends State{


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:[
            Text('All Quizzes', style: TextStyle(fontSize: 64)),
            ContentCarousel('assessment', getAllQuizzes()),
            CreateButton('assessment')
          ]
        )
      )
    );
  }
}

//Helper function that pulls the quizzes from all the user's courses
List<Quiz>? getAllQuizzes(){
  List<Quiz>? result;
  for (Course c in MoodleApiSingleton().moodleCourses ?? []){
    result = (result ?? []) + (c.quizzes ?? []);
  }
  if (result == []){
    return null;
  }
  return result;
}
