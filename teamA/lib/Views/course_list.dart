import 'package:flutter/material.dart';
import 'package:namer_app/main.dart';

// This is the course list UI

class CourseList extends StatelessWidget {
  const CourseList({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primaryContainer, // Use primary container color
              elevation: 0,
              flexibleSpace: SafeArea(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DevLaunch()),
                      );
                      //to do something once pressed
                    },
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Learning Lens',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
              child: Align(
                  alignment: Alignment.center,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Course List',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: 300,
                          height: 150,
                          child: Expanded(
                              child: ElevatedButton(
                            onPressed: () {
                              //Button onPressed Action
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Color(0xFF6A5A99)),
                                minimumSize:
                                    WidgetStatePropertyAll(Size(250, 5)),
                                shape: WidgetStatePropertyAll<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                )),
                            child: ListTile(
                              title: Text(
                                'Course 1',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Course ID',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: 300,
                          height: 150,
                          child: Expanded(
                              child: ElevatedButton(
                            onPressed: () {
                              //Button onPressed Action
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Color(0xFF6A5A99)),
                                minimumSize:
                                    WidgetStatePropertyAll(Size(250, 5)),
                                shape: WidgetStatePropertyAll<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                )),
                            child: ListTile(
                              title: Text(
                                'Course 2',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Course ID',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: 300,
                          height: 150,
                          child: Expanded(
                              child: ElevatedButton(
                            onPressed: () {
                              //Button onPressed Action
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Color(0xFF6A5A99)),
                                minimumSize:
                                    WidgetStatePropertyAll(Size(250, 5)),
                                shape: WidgetStatePropertyAll<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                )),
                            child: ListTile(
                              title: Text(
                                'Course 3',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Course ID',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: 300,
                          height: 150,
                          child: Expanded(
                              child: ElevatedButton(
                            onPressed: () {
                              //Button onPressed Action
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Color(0xFF6A5A99)),
                                minimumSize:
                                    WidgetStatePropertyAll(Size(250, 5)),
                                shape: WidgetStatePropertyAll<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                )),
                            child: ListTile(
                              title: Text(
                                'Course 4',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Course ID',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )),
                        ),
                      ])),
            )));
  }
}
