import 'package:flutter/material.dart';
import 'package:namer_app/Views/essay_edit_page.dart';

//Provides a carousel of either assessments, essays, or submission
class ContentCarousel extends StatefulWidget{
  final String type;

  ContentCarousel(this.type);

  @override
  State<ContentCarousel> createState() {
    return _ContentState(type);
  }
}

//State of the carousel (allows for filtering in the future)
class _ContentState extends State<ContentCarousel>{
  final String type;
  //original list of content
  final List<Widget> _children;
  //filtered list to be shown
  var children = <Widget>[];

  _ContentState._(this.type,this._children){
    children = _children;
  }
  
  factory _ContentState(String type) {
    //generate the full list of cards
    //todo: do this via the Moodle API
    if (type == "assessment"){
      return _ContentState._(type, [CarouselCard('Real Test','Test Information\nWould Go\nHere','assessment'), CarouselCard('Real Test 2','Test Information\nWould Go\nHere','assessment'), CarouselCard('Real Test3','Test Information\nWould Go\nHere','assessment'), CarouselCard('Real Test4','Test Information\nWould Go\nHere','assessment'), CarouselCard('Real Test5','Test Information\nWould Go\nHere','assessment')]);
    }
    else if (type == 'essay'){
      return _ContentState._(type, [CarouselCard('Real Essay','Test Information\nWould Go\nHere','essay'), CarouselCard('Real Test 2','Test Information\nWould Go\nHere','essay'), CarouselCard('Real Test3','Test Information\nWould Go\nHere','essay'), CarouselCard('Real Test4','Test Information\nWould Go\nHere','essay'), CarouselCard('Real Test5','Test Information\nWould Go\nHere','essay')]);
    }
    //todo: add submission type
    else {
      return _ContentState._(type, [Text('Invalid type input.')]);
    }
  }

  //todo filtering features

  @override
  Widget build(BuildContext context){
    
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 400), //testing width
      child: CarouselView(
        backgroundColor: Theme.of(context).primaryColor,
        itemExtent: 600,
        shrinkExtent: 350,
        children: children
      )
    );
  }
}

//Cards for the Carousel
class CarouselCard extends StatelessWidget{
  //assignment name
  final String title;
  //assignment information (may want to get a specific format, need to look into the various settings for each)
  final String information;
  //acceptable types: assessment, essay, submission
  final String type;

  CarouselCard(this.title, this.information, this.type);

  @override
  StatelessWidget build(BuildContext context){
    return Card.filled(
      color: Theme.of(context).primaryColor,
      child: Scaffold(
        body: Column(
          children:[
            Center(
              child: Text(title)
            ),
            Text(information)
          ]
        ),
        bottomNavigationBar: cardButtons(context)
      )
    );
  }

  Row cardButtons(BuildContext context){
    if (type == 'assessment'){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [OutlinedButton(onPressed:() {
          //will navigate to this assessment's edit screen
        }, child: Text('Edit Assessment'))]
      );
    }
    else if (type == 'essay'){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [OutlinedButton(onPressed:() {
          //will navigate to this assignment's edit screen
        }, child: Text('Edit Assignment')),
        OutlinedButton(onPressed:() {
          //will navigate to this assignment's submissions screen
        }, child: Text('View Submissions')),]
      );
    }
    //todo submission card
    else {//default to an empty row
      return Row();
    }
  }
}

//buttons navigating to the create pages
class CreateButton extends StatelessWidget{
  //todo: maybe autofill filter information into the assignment creation settings?
  final String filters = '';
  //acceptable types: assessment, essay
  final String type;
  final String text;

  CreateButton._(this.type, this.text);

  factory CreateButton(String type){
    if (type == "assessment"){
      return CreateButton._(type,"Create New Assessment");
    }
    else if (type == "essay"){
      return CreateButton._(type,"Create New Essay Assignment");
    }
    else{
      return CreateButton._(type,"");
    }
  }

  @override
  Widget build(BuildContext context){
    return OutlinedButton(
      onPressed: () {}, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.add), 
          Text(text)],
      )
    );
  }
}
