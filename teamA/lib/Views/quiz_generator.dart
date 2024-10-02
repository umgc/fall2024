

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/general_form.dart';
class CreateAssessment extends StatefulWidget {

  final String userName;
  
  CreateAssessment(this.userName);

  @override
  State createState() {
    return _AssessmentState();
  }
}


class _AssessmentState extends State<CreateAssessment> {
  double paddingHeight = 16.0, paddingWidth=32;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController multipleChoiceController = TextEditingController();
  TextEditingController trueFalseController = TextEditingController();
  TextEditingController shortAnswerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  _AssessmentState();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text('Learning Lens',
          style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
          key: _formKey,
          child:
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded (
                    flex: 2,
                    child: Column (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: paddingHeight),
                        TextEntry._('Assessment Name', true, nameController),
                        SizedBox(height: paddingHeight),
                        TextEntry._('Description', false, descriptionController, isTextArea: true,),
                        SizedBox(height: paddingHeight),
                        NumberEntry._('Total Multiple Choice Questions', true, multipleChoiceController),
                        SizedBox(height: paddingHeight),
                        NumberEntry._('Total True / False Questions', true, trueFalseController),
                        SizedBox(height: paddingHeight),
                        NumberEntry._('Total Short Answer Questions', true, shortAnswerController)
                      ],
                    )
                  ),
                  SizedBox(width: paddingWidth),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: paddingHeight),
                        Text("Choose a total number of questions equal to four or five times the number of students in the course to guarantee unique quizzes per student"),
                        SizedBox(height: paddingHeight),
                        LLMSelector._(),
                        SizedBox(height: paddingHeight),
                        SubmitButton._('Submit', [nameController, descriptionController, multipleChoiceController, trueFalseController, shortAnswerController], _formKey)
                      ],
                    ),
                  )
                ],
              ),
            ),
      )
    );
  }
}

class SubmitButton extends StatelessWidget {
  final String buttonText;
  final List<TextEditingController> fields;
  final GlobalKey<FormState> formKey;

  SubmitButton._(this.buttonText, this.fields, this.formKey);

  bool _evaluateInputs() {
    formKey.currentState!.validate();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _evaluateInputs, child: Text(buttonText));
  }
}


class NumberEntry extends StatelessWidget {
  final String title;
  final bool needsValidation;
  final TextEditingController controller;

  NumberEntry._(this.title, this.needsValidation, this.controller);


  @override
  Widget build(BuildContext context) {
    return TextFormField (
      controller: controller,
      inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
      validator: (value) {
        if (needsValidation && (value == null || value.isEmpty)) {
          controller.text = '0';
        } return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: title
      ),
      );
  }
}


class TextEntry extends StatelessWidget {
  final String title;
  final bool needsValidation, isTextArea;
  final TextEditingController controller;

  TextEntry._(this.title, this.needsValidation, this.controller, {this.isTextArea=false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (needsValidation && (value == null || value.isEmpty)) {
          return 'Please enter a value for $title';
        } return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: title
      ),
      maxLines: isTextArea ? 6 : 1,
    );
  }
}


class LLMSelector extends StatelessWidget {

  LLMSelector._();

  @override
  Widget build(BuildContext context) {
    List<String> dropdownValues = ['ChatGPT', 'LLAMA', 'Perplexity'];
    String dropdownValue = dropdownValues.first;
    return DropdownButton(
        onChanged: (String? value) {
          print("Dropdown Value Before: $dropdownValue");
          print("Value: $value");
          dropdownValue = value!;
          print("Dropdown Value After: $dropdownValue");
        },
        value: dropdownValue,
        items: dropdownValues.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String> (
            value: value,
            child: Text(value),
          );
        }).toList(),
      );
  }
}