// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intelligrade/controller/html_converter.dart';
import 'package:intelligrade/controller/main_controller.dart';
import 'package:intelligrade/controller/model/beans.dart'
    show AssignmentForm, Course, QuestionType, Quiz;
import 'package:intelligrade/ui/header.dart';
import 'package:intelligrade/ui/custom_navigation_bar.dart';

class AssignmentDetailsPage extends StatefulWidget {
  const AssignmentDetailsPage({super.key});

  static MainController controller = MainController();

  @override
  _AssignmentDetailsPage createState() => _AssignmentDetailsPage();
}

/*
  My initial thoughts are that when a quiz is selected, pass the selected quiz 
  as an object to this page which will use the assignment data to populate
  the required fields.
*/

class _AssignmentDetailsPage extends State<AssignmentDetailsPage> {
  Quiz quiz = Quiz(); //will hold the quiz object passed into the page
  bool summaryIsSelected = true;

  @override
  void initState() {
    super.initState();
  }

  /*
    May need other methods to retrieve the data from the quiz
  */

  @override
  Widget build(BuildContext context) {
    final int selectedIndex =
        ModalRoute.of(context)?.settings.arguments as int? ?? 0;
    return Scaffold(
      appBar: const AppHeader(title: "Assignment Details"),
      body: LayoutBuilder(builder: (context, constraints) {
        return Row(
          //over arching page row
          children: <Widget>[
            Container(
              //for the nav bar
              width: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueGrey,
                  width: 0.5,
                ),
              ),
              child: CustomNavigationBar(selectedIndex: selectedIndex),
            ),
            Expanded(
              //for the remainder of the page
              child: Column(
                //remaining page data
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Container(
                    width: 1150,
                    height: 60,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        spreadRadius: 3,
                      )
                    ]),
                    child: Row(
                      //row for the assignemnt header
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          //title column
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Exam Title'),
                            Text(
                                'Biology 101 Midterm'), //placeholder, will be the data from quiz
                          ],
                        ),
                        Column(
                          //subject column
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Subject'),
                            Text(
                                'Biology'), //placeholder, will be the data from quiz
                          ],
                        ),
                        Column(
                          //number of questions column
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Number of Questions'),
                            Text(
                                '30'), //placeholder, will be the data from quiz
                          ],
                        ),
                        Column(
                          //Date column
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date Created'),
                            Text(
                                'May 23, 2024'), //placeholder, will be the data from quiz
                          ],
                        ),
                      ],
                    ), //row for the assignemnt header,
                  ), //container for the row so it takes the whole page
                  SizedBox(height: 10),
                  Container(
                    child: Row(
                      children: [
                        SizedBox(width: 30),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              summaryIsSelected =
                                  true; // Update to show Summary
                            });
                          },
                          child: const Text('Summary'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              summaryIsSelected =
                                  false; // Update to show Submissions
                            });
                          },
                          child: const Text('Submissions'),
                        ),
                        !summaryIsSelected
                            ? Container(
                                child: Row(
                                children: [
                                  SizedBox(width: 850),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('Assign Student'),
                                  ),
                                ],
                              ))
                            : SizedBox(width: 500)
                      ],
                    ),
                  ),
                  summaryIsSelected
                      ? Container(
                          //outer container for the assignment content
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blueGrey,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                //container for the content header
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.5,
                                ))),
                                child: Row(
                                  //header row
                                  children: [
                                    SizedBox(width: 60),
                                    Text("Question"),
                                    SizedBox(width: 700),
                                    Text("Type"),
                                  ],
                                ),
                              ),
                              Container(
                                //first question
                                //container for the content header
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.5,
                                ))),
                                child: Row(
                                  //header row
                                  children: [
                                    SizedBox(width: 60),
                                    Text("What is 2 + 2?"),
                                    SizedBox(width: 650),
                                    Text("Multiple Choice"),
                                    SizedBox(width: 100),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.edit_rounded)),
                                    SizedBox(width: 30),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.delete)),
                                  ],
                                ),
                              ),
                              Container(
                                //first question
                                //container for the content header
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.5,
                                ))),
                                child: Row(
                                  //header row
                                  children: [
                                    SizedBox(width: 60),
                                    Text("Who wrote the constitution?"),
                                    SizedBox(width: 570),
                                    Text("Short Answer"),
                                    SizedBox(width: 100),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.edit_rounded)),
                                    SizedBox(width: 30),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.delete)),
                                  ],
                                ),
                              ),
                              Container(
                                //first question
                                //container for the content header
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.5,
                                ))),
                                child: Row(
                                  //header row
                                  children: [
                                    SizedBox(width: 60),
                                    Text(
                                        "Does the moon revolve around the earth?"),
                                    SizedBox(width: 500),
                                    Text("True/False"),
                                    SizedBox(width: 100),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.edit_rounded)),
                                    SizedBox(width: 30),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.delete)),
                                  ],
                                ),
                              ),
                              Container(
                                //first question
                                //container for the content header
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.5,
                                ))),
                                child: Row(
                                  //header row
                                  children: [
                                    SizedBox(width: 60),
                                    Text(
                                        "Is the absence of evidence the evidence of abscence?"),
                                    SizedBox(width: 420),
                                    Text("True/False"),
                                    SizedBox(width: 100),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.edit_rounded)),
                                    SizedBox(width: 30),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.delete)),
                                  ],
                                ),
                              ),
                              Container(
                                //first question
                                //container for the content header
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.5,
                                ))),
                                child: Row(
                                  //header row
                                  children: [
                                    SizedBox(width: 60),
                                    Text("What is 2 + 2?"),
                                    SizedBox(width: 650),
                                    Text("Multiple Choice"),
                                    SizedBox(width: 100),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.edit_rounded)),
                                    SizedBox(width: 30),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.delete)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          //outer container for the assignment content
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blueGrey,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                //container for the content header
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.5,
                                ))),
                                child: Row(
                                  //header row
                                  children: [
                                    SizedBox(width: 60),
                                    Text("NAME"),
                                    SizedBox(width: 160),
                                    Text("USERNAME"),
                                    SizedBox(width: 160),
                                    Text("EMAIL"),
                                    SizedBox(width: 160),
                                    Text("STATUS"),
                                    SizedBox(width: 100),
                                    Text("GRADE"),
                                  ],
                                ),
                              ),
                              Container(
                                //first question
                                //container for the content header
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.5,
                                ))),
                                child: Row(
                                  //header row
                                  children: [
                                    SizedBox(width: 60),
                                    Text(
                                      "Matthew Martinez",
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.left,
                                      textWidthBasis: TextWidthBasis.parent,
                                    ),
                                    SizedBox(width: 90),
                                    Text("mmartinez1997"),
                                    SizedBox(width: 90),
                                    Text("mmartinez1997@gmail.com"),
                                    SizedBox(width: 60),
                                    Text(
                                        "Not Finalized"), //May need to style more
                                    SizedBox(width: 110),
                                    Text("32%"),
                                    SizedBox(width: 50),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text("Edit Grade"),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                //first question
                                //container for the content header
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.5,
                                ))),
                                child: Row(
                                  //header row
                                  children: [
                                    SizedBox(width: 60),
                                    Text(
                                      "Mariah White",
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.left,
                                      textWidthBasis: TextWidthBasis.parent,
                                    ),
                                    SizedBox(width: 120),
                                    Text("mariah_white"),
                                    SizedBox(width: 110),
                                    Text("mariah_white@gmail.com"),
                                    SizedBox(width: 70),
                                    Text(
                                        "Not Submitted"), //May need to style more
                                    SizedBox(width: 110),
                                    Text("NG"),
                                    SizedBox(width: 50),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text("Edit Grade"),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                //first question
                                //container for the content header
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.5,
                                ))),
                                child: Row(
                                  //header row
                                  children: [
                                    SizedBox(width: 60),
                                    Text(
                                      "Caleb Jones",
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.left,
                                      textWidthBasis: TextWidthBasis.parent,
                                    ),
                                    SizedBox(width: 130),
                                    Text("calebjones"),
                                    SizedBox(width: 110),
                                    Text("calebjones8@gmail.com"),
                                    SizedBox(width: 100),
                                    Text("Finalized"), //May need to style more
                                    SizedBox(width: 110),
                                    Text("93%"),
                                    SizedBox(width: 70),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text("Edit Grade"),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                //first question
                                //container for the content header
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.5,
                                ))),
                                child: Row(
                                  //header row
                                  children: [
                                    SizedBox(width: 60),
                                    Text(
                                      "Devante Young",
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.left,
                                      textWidthBasis: TextWidthBasis.parent,
                                    ),
                                    SizedBox(width: 110),
                                    Text("dY9283"),
                                    SizedBox(width: 140),
                                    Text("dY9283@gmail.com"),
                                    SizedBox(width: 112),
                                    Text("Finalized"), //May need to style more
                                    SizedBox(width: 110),
                                    Text("82%"),
                                    SizedBox(width: 80),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text("Edit Grade"),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                //first question
                                //container for the content header
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.5,
                                ))),
                                child: Row(
                                  //header row
                                  children: [
                                    SizedBox(width: 60),
                                    Text(
                                      "Samuel Ross",
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.left,
                                      textWidthBasis: TextWidthBasis.parent,
                                    ),
                                    SizedBox(width: 120),
                                    Text("samRoss"),
                                    SizedBox(width: 110),
                                    Text("samRoss258@gmail.com"),
                                    SizedBox(width: 90),
                                    Text(
                                        "Not Finalized"), //May need to style more
                                    SizedBox(width: 110),
                                    Text("77%"),
                                    SizedBox(width: 65),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text("Edit Grade"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
