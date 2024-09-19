import 'package:flutter/material.dart';
import 'content_carousel.dart';

//What we need:
//Two carousels, one for essays and the other for assessments.
//Additional information and buttons appear when a card is clicked.
//The essay cards have two buttons leading to submissions and assignment editing pages.
//The assessment cards have a button leading to the assessment editing page.
//Two buttons below that lead to the create essay and create assessment pages.

//Main Page
class ViewCourseContents extends StatelessWidget {
  //todo: figure out how to do the super.key and define a internal var
  //also: vertical scroll
  const ViewCourseContents({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Navigator is //todo')),
      body: 
        Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Insert Course Name Here', style: TextStyle(fontSize: 64),),
          ContentCarousel('assessment'),
          ContentCarousel('essay'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [CreateButton('assessment'), CreateButton('essay')]
          )
        ],
      )
    );
  }
}
