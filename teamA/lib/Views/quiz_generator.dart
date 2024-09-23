

import 'package:flutter/material.dart';

class CreateAssessment extends StatefulWidget {

  final String userName;
  
  CreateAssessment(this.userName);

  @override
  State createState() {
    return _AssessmentState(userName);
  }
}

class _AssessmentState extends State {
  final String userName;

  _AssessmentState(this.userName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Assessment')),
      body: SingleChildScrollView(
        child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Assessment Details", style: TextStyle(fontSize: 64),),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Assessment Name'
                  ),
                )
              ],
            )
          ],
        )
      )
    );
  }
}