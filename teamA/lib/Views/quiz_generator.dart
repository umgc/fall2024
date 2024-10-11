// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learninglens_app/Controller/beans.dart';
import 'package:learninglens_app/Views/edit_questions.dart';
import 'package:learninglens_app/api/llm/prompt_engine.dart';


class CreateAssessment extends StatefulWidget {

  final String userName;
  static TextEditingController nameController = TextEditingController();
  static TextEditingController descriptionController = TextEditingController();
  static TextEditingController sourceController = TextEditingController();
  static TextEditingController multipleChoiceController = TextEditingController();
  static TextEditingController trueFalseController = TextEditingController();
  static TextEditingController shortAnswerController = TextEditingController();
  static TextEditingController topicController = TextEditingController();
  CreateAssessment(this.userName);

  @override
  State createState() {
    return _AssessmentState();
  }
}


class _AssessmentState extends State<CreateAssessment> {
  double paddingHeight = 16.0, paddingWidth=32;
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
                        TextEntry._('Assessment Name', true, CreateAssessment.nameController),
                        SizedBox(height: paddingHeight),
                        TextEntry._('Description', false, CreateAssessment.descriptionController, isTextArea: true,),
                        SizedBox(height: paddingHeight),
                        TextEntry._('Question Topic', true, CreateAssessment.topicController),
                        SizedBox(height: paddingHeight),
                        TextEntry._('Question Source', false, CreateAssessment.sourceController),
                        SizedBox(height: paddingHeight),
                        NumberEntry._('Total Multiple Choice Questions', true, CreateAssessment.multipleChoiceController),
                        SizedBox(height: paddingHeight),
                        NumberEntry._('Total True / False Questions', true, CreateAssessment.trueFalseController),
                        SizedBox(height: paddingHeight),
                        NumberEntry._('Total Short Answer Questions', true, CreateAssessment.shortAnswerController)
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
                        LLMSelectorDropdown(
                          selectedLLM: 'ChatGPT',
                          onChanged: (newValue) {},
                        ),
                        SizedBox(height: paddingHeight),
                        SubmitButton._('Submit', {"name" : CreateAssessment.nameController, 
                                                  "description" : CreateAssessment.descriptionController,
                                                  "topic" : CreateAssessment.topicController,
                                                  "multipleChoice" : CreateAssessment.multipleChoiceController,
                                                  "trueFalse" :  CreateAssessment.trueFalseController,
                                                  "shortAns" : CreateAssessment.shortAnswerController,}, _formKey,
                                                  context)
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
  final Map<String, TextEditingController> fields;
  final GlobalKey<FormState> formKey;
  final BuildContext context;

  SubmitButton._(this.buttonText, this.fields, this.formKey, this.context);

  Future<void> _submitToLLM() async {
    if(formKey.currentState!.validate()) {
      AssignmentForm af = AssignmentForm(
      questionType: QuestionType.shortanswer, //Potentially not necessary? Need to see about essay generator
      subject: 'Algebra', // Get these programatically?
      topic: fields['topic']!.text, 
      gradeLevel: 'Sophomore', // Get these programatically?
      title: fields['name']!.text,
      trueFalseCount: int.parse(fields['trueFalse']!.text),
      shortAnswerCount: int.parse(fields['shortAns']!.text),
      multipleChoiceCount: int.parse(fields['multipleChoice']!.text),
      maximumGrade: 100);
      print(PromptEngine.generatePrompt(af));

      // if (await File("J:\\Users\\Conor Moore\\Downloads\\UMGC\\fall2024\\teamA\\lib\\TestFiles\\allThree.xml").exists()) {
      //   File('J:\\Users\\Conor Moore\\Downloads\\UMGC\\fall2024\\teamA\\lib\\TestFiles\\allThree.xml').readAsString().then((String fileContents) {
      //     Navigator.push(context, MaterialPageRoute(builder: (context) => EditQuestions(fileContents)));
      //   });
      // } else {
      //   print("No file boss");
      // }

      String tempXML = '''<?xml version="1.0" encoding="UTF-8"?>
<quiz>
    <question type="category">
        <category>
        <text>Pythagorean Theorem</text>
        </category>
    </question>
    <question type="truefalse">
        <name>
            <text>Question 1</text>
        </name>
        <questiontext format="html">
            <text>The Pythagorean Theorem states that in a right triangle, the square of the length of the hypotenuse is equal to the sum of the squares of the lengths of the other two sides.</text>
        </questiontext>
        <answer fraction="100">
            <text>True</text>
            <feedback>
                <text>Correct! This is the definition of the Pythagorean Theorem.</text>
            </feedback>
        </answer>
        <answer fraction="0">
            <text>False</text>
            <feedback>
                <text>Incorrect. This statement is indeed true.</text>
            </feedback>
        </answer>
    </question>
    <question type="truefalse">
        <name>
            <text>Question 2</text>
        </name>
        <questiontext format="html">
            <text>In a right triangle, the Pythagorean Theorem can only be applied if the triangle is isosceles.</text>
        </questiontext>
        <answer fraction="0">
            <text>True</text>
            <feedback>
                <text>Incorrect. The Pythagorean Theorem applies to all right triangles, not just isosceles ones.</text>
            </feedback>
        </answer>
        <answer fraction="100">
            <text>False</text>
            <feedback>
                <text>Correct! The theorem applies to any right triangle.</text>
            </feedback>
        </answer>
    </question>
    <question type="truefalse">
        <name>
            <text>Question 3</text>
        </name>
        <questiontext format="html">
            <text>The lengths of the sides of a right triangle can be represented by the formula a² + b² = c², where c is the hypotenuse.</text>
        </questiontext>
        <answer fraction="100">
            <text>True</text>
            <feedback>
                <text>Correct! This is the Pythagorean theorem representation.</text>
            </feedback>
        </answer>
        <answer fraction="0">
            <text>False</text>
            <feedback>
                <text>Incorrect. This statement accurately describes the theorem.</text>
            </feedback>
        </answer>
    </question>
    <question type="truefalse">
        <name>
            <text>Question 4</text>
        </name>
        <questiontext format="html">
            <text>The Pythagorean Theorem is applicable only in three-dimensional geometry.</text>
        </questiontext>
        <answer fraction="0">
            <text>True</text>
            <feedback>
                <text>Incorrect. The Pythagorean Theorem is specific to two-dimensional right triangles.</text>
            </feedback>
        </answer>
        <answer fraction="100">
            <text>False</text>
            <feedback>
                <text>Correct! It is applicable only in two dimensions.</text>
            </feedback>
        </answer>
    </question>
    <question type="multichoice">
        <name>
            <text>Question 5</text>
        </name>
        <questiontext format="html">
            <text>Which of the following is the correct equation according to the Pythagorean Theorem?</text>
        </questiontext>
        <answer fraction="100">
            <text>a² + b² = c²</text>
            <feedback>
                <text>Correct! This is the fundamental equation of the Pythagorean Theorem.</text>
            </feedback>
        </answer>
        <answer fraction="0">
            <text>a² - b² = c²</text>
            <feedback>
                <text>Incorrect. This is not the correct application of the theorem.</text>
            </feedback>
        </answer>
        <answer fraction="0">
            <text>c² = a + b</text>
            <feedback>
                <text>Incorrect. This does not represent the Pythagorean Theorem.</text>
            </feedback>
        </answer>
        <answer fraction="0">
            <text>a + b = c</text>
            <feedback>
                <text>Incorrect. This does not describe the relationship between the sides of a right triangle.</text>
            </feedback>
        </answer>
    </question>
    <question type="multichoice">
        <name>
            <text>Question 6</text>
        </name>
        <questiontext format="html">
            <text>If a right triangle has legs of lengths 3 and 4, what is the length of the hypotenuse?</text>
        </questiontext>
        <answer fraction="100">
            <text>5</text>
            <feedback>
                <text>Correct! Using the Pythagorean Theorem: 3² + 4² = 9 + 16 = 25, so c = √25 = 5.</text>
            </feedback>
        </answer>
        <answer fraction="0">
            <text>7</text>
            <feedback>
                <text>Incorrect. This does not follow from the theorem.</text>
            </feedback>
        </answer>
        <answer fraction="0">
            <text>6</text>
            <feedback>
                <text>Incorrect. This is not the correct calculation based on the theorem.</text>
            </feedback>
        </answer>
        <answer fraction="0">
            <text>8</text>
            <feedback>
                <text>Incorrect. This does not represent the hypotenuse length.</text>
            </feedback>
        </answer>
    </question>
    <question type="shortanswer">
        <name>
            <text>Question 7</text>
        </name>
        <questiontext format="html">
            <text>What is the Pythagorean Theorem used for in mathematics?</text>
        </questiontext>
        <answer>
            <text>To calculate the length of a side in a right triangle</text>
            <feedback>
                <text>Correct! The theorem is used to find unknown side lengths in right triangles.</text>
            </feedback>
        </answer>
    </question>
</quiz>
''';
      Navigator.push(context, MaterialPageRoute(builder: (context) => EditQuestions(tempXML)));
    }
  }

  bool _evaluateInputs() {
    formKey.currentState!.validate();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _submitToLLM, child: Text(buttonText));
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

class LLMSelectorDropdown extends StatelessWidget {

  final String selectedLLM;
  final ValueChanged<String?> onChanged;

  LLMSelectorDropdown({
    Key? key,
    required this.selectedLLM,
    required this.onChanged
  }) : super(key : key);

  void _handleValueChanged(String? newValue) {
    onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: "Select Model"),
      value: selectedLLM,
      items: ['ChatGPT', 'LLAMA', 'Perplexity'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: _handleValueChanged,
    );
  }

}