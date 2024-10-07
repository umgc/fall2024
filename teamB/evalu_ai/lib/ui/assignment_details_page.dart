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
  Quiz quiz = new Quiz(); //will hold the quiz object passed into the page
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                            summaryIsSelected = true;
                          },
                          child: const Text('Summary'),
                        ),
                        TextButton(
                          onPressed: () {
                            summaryIsSelected = false;
                          },
                          child: const Text('Submissions'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
