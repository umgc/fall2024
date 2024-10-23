import "package:flutter/material.dart";
import "package:learninglens_app/Api/moodle_api_singleton.dart";
import "package:learninglens_app/Controller/beans.dart";
import "package:learninglens_app/content_carousel.dart";


//The Page
class EssaysView extends StatefulWidget{
  EssaysView();

  @override
  State createState(){
    return _EssaysState();
  }
}

class _EssaysState extends State{


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:[
            Text('All Essays', style: TextStyle(fontSize: 64)),
            ContentCarousel('essay', getAllEssays()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:[CreateButton('essay')]
            )
          ]
        )
      )
    );
  }
}

//Helper function that pulls the essays from all the user's courses
List<Assignment>? getAllEssays(){
  List<Assignment>? result;
  for (Course c in MoodleApiSingleton().moodleCourses ?? []){
    result = (result ?? []) + (c.essays ?? []);
  }
  if (result == []){
    return null;
  }
  return result;
}
