

import 'package:flutter/material.dart';
import 'package:namer_app/general_form.dart';
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
    return Scaffold ( 
      appBar: AppBar(title: Text('Create Assessment')),
      body: Form (
        child: Padding (
          padding: EdgeInsets.all(16),
          child: Column (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [ColumnEntry ('Assessment Details', 
              [
                RowEntry('Assessment Name', 'Please Enter a Valid Name', 'string', true),
                RowEntry('Description', '', 'string', false),
                RowEntry('Total Multiple Choice Questions', '', 'number', true),
                RowEntry('Total True / False Questions', '', 'number', true),
                RowEntry('Total Short Answer Questions', '', 'number', true),
              ]),
              ColumnEntry('Help Text', [
                RowEntry('Test', '', 'string', false)
              ])
            ]
          )
        )
      )
    );
  }
}