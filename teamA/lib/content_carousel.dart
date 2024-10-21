import 'package:flutter/material.dart';
import 'package:learninglens_app/Views/essay_generation.dart';
import 'package:learninglens_app/Views/quiz_generator.dart';
import 'package:learninglens_app/Views/view_quiz.dart';
import 'package:learninglens_app/Views/view_submissions.dart';
import "Controller/beans.dart";

//Provides a carousel of either assessments, essays, or submission
class ContentCarousel extends StatefulWidget{
  final String type;
  final List? children;
  final int? courseId;

  ContentCarousel(this.type, this.children, {this.courseId});

  @override
  State<ContentCarousel> createState() {
    return _ContentState(type, children, courseId ?? 0);
  }
}

//State of the carousel (allows for filtering in the future)
class _ContentState extends State<ContentCarousel>{
  final String type;
  //original list of content
  final List<Widget> _children;
  //filtered list to be shown
  var children = <Widget>[];
  final int courseId;
  _ContentState._(this.type,this._children,this.courseId){
    children = _children;
  }
  
  factory _ContentState(String type, List? input, int? courseId){ {
    //generate the full list of cards
    if (type == "assessment"){
      return _ContentState._(type, CarouselCard.fromQuizzes(input) ?? [Text('There are no generated quizzes that match the requirements.', style: TextStyle(fontSize: 32))], courseId ?? 0);
    }
    else if (type == 'essay'){
      return _ContentState._(type, CarouselCard.fromEssays(input) ?? [Text('This are no generated essays that match the requirements.', style: TextStyle(fontSize: 32))], courseId ?? 0);
    }
    //todo: add submission type
    else {
      return _ContentState._(type, [Text('Invalid type input.')], courseId ?? 0);
    }
  }
  }
  //todo filtering features

  @override
  Widget build(BuildContext context){
    //For empty contents, we don't build a carousel
    if (_children.length == 1 && _children[0].runtimeType == Text){
      return Padding(
        padding: EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 400),
          child: Center(
            child: _children[0]
          )
        )
      );
    }

    else{
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300), //testing width
          child: CarouselView(
            backgroundColor: Theme.of(context).primaryColor,
            itemExtent: 400,
            shrinkExtent: 250,
            onTap: (value) {
              if (type == 'assessment'){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewQuiz(quizId: (children[value] as CarouselCard).id),
                  ),
                );
              }
              else if (type == 'essay'){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubmissionList(assignmentId: (children[value] as CarouselCard).id, courseId: courseId.toString()
                  ),
                )
                );
              }
            },

            children: children,
          )
        )
      );
    }
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
  final int id;
  final int? courseId;

  CarouselCard(this.title, this.information, this.type, this.id, {this.courseId});

  static CarouselCard fromQuiz(Quiz input){
    return CarouselCard(input.name ?? "Unnamed Quiz", input.description?.replaceAll(RegExp(r"<[^>]*>"),"") ?? '', 'assessment', input.id ?? 0);
  }

  static List<CarouselCard>? fromQuizzes(List? input){
    if (input == null){
      return null;
    }
    List<CarouselCard> output = [];
    for (Object c in input){
      if (c is Quiz){
        output.insert(output.length, fromQuiz(c));
      }
    }
    return output;
  }

  static CarouselCard fromEssay(Assignment input){
    return CarouselCard(input.name, input.description.replaceAll(RegExp(r"<[^>]*>"),""), 'essay', input.id ?? 0, courseId: input.courseId);
  }

  static List<CarouselCard>? fromEssays(List? input){
    if (input == null){
      return null;
    }
    List<CarouselCard> output = [];
    for (Object c in input){
      if (c is Assignment){
        output.insert(output.length, fromEssay(c));
      }
    }
    return output;
  }

@override
Widget build(BuildContext context) {
  return Card(
    color: Theme.of(context).cardColor,
    elevation: 2,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(information),
        ),
        Spacer(),  // Pushes the buttons to the bottom
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: cardButtons(context),
        // ),
      ],
    ),
  );
}



// Row cardButtons(BuildContext context) {
//   if (type == 'assessment') {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         OutlinedButton(
//           onPressed: () {
//             // Add navigation logic here
//           },
//           child: Text('Edit Assessment'),
//         ),
//         OutlinedButton(
//           onPressed: () {
//             // Add navigation logic here
//           },
//           child: Text('Edit Questions'),
//         ),
//       ],
//     );
//   } else if (type == 'essay') {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         OutlinedButton(
//           onPressed: () {
//             // Navigator logic for editing the assignment
//           },
//           child: Text('Edit Assignment'),
//         ),
//         OutlinedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => SubmissionList(assignmentId: id, courseId: courseId.toString()),
//               ),
//             );
//           },
//           child: Text('View Submissions'),
//         ),
//       ],
//     );
//   } else {
//     return Row();  // Empty row for default case
//   }
// }


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
      onPressed: () {
        MaterialPageRoute? route;
        if (type == 'assessment'){
          route = MaterialPageRoute(builder: (context) => CreateAssessment());
        }
        else if (type == 'essay'){
          route = MaterialPageRoute(builder:(context) => EssayGeneration(title: 'New Essay'));
        }
        if (route != null){
          Navigator.push(context, route);
        }
      }, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.add), 
          Text(text)],
      )
    );
  }
}
