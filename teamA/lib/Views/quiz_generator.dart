

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
  final String helpText = "Choose a total number of questions equal to four or five times the number of students in the course to guarantee unique quizzes per student";
  _AssessmentState(this.userName);


 @override
  Widget build(BuildContext context) {
    return Scaffold ( 
      appBar: AppBar(title: Text('Create Assessment')),
      body: Form (
        child: Padding (
          padding: EdgeInsets.all(16),
          child: EntryForm ([
            ColumnEntry ('Assessment Details', 
              [
                RowEntry('Assessment Name', 'Please Enter a Valid Name', 'textentry', true, 100, 500, 10),
                RowEntry('Description', '', 'textentry', false, 100, 500, 10),
                RowEntry('Information Source', '', 'textentry', false, 100, 500, 10),
                RowEntry('Total Multiple Choice Questions', '', 'number', true, 100, 500, 10),
                RowEntry('Total True / False Questions', '', 'number', true, 100, 500, 10),
                RowEntry('Total Short Answer Questions', '', 'number', true, 100, 500, 10),
              ]),
              ColumnEntry('Help Text', [
                RowEntry('HelpText', helpText, 'string', false, 100, 500, 10),
                RowEntry('LLM Service Provider', 'OpenAI,LLAMA,Third Option', 'selectbox', false, 100, 500, 10),
                RowEntry('Submit', '', 'button', false, 100, 500, 10),
              ])
          ])
        )
      )
    );
  }
}