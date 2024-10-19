import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learninglens_app/Api/llm/prompt_engine.dart';
import '../Controller/beans.dart';
import 'edit_questions.dart';
import 'package:llm_api_modules/openai_api.dart';
import 'package:llm_api_modules/claudeai_api.dart';



class CreateAssessment extends StatefulWidget {

  static TextEditingController nameController = TextEditingController();
  static TextEditingController descriptionController = TextEditingController();
  static TextEditingController subjectController = TextEditingController();
  static TextEditingController sourceController = TextEditingController();
  static TextEditingController multipleChoiceController = TextEditingController();
  static TextEditingController trueFalseController = TextEditingController();
  static TextEditingController shortAnswerController = TextEditingController();
  static TextEditingController topicController = TextEditingController();
  CreateAssessment();
  
  @override
  State createState() {
    return _AssessmentState();
  }
}


class _AssessmentState extends State<CreateAssessment> {
  double paddingHeight = 16.0, paddingWidth=32;
  bool isAdvancedModeOnGetFromGlobalVarsLater = false;
  final _formKey = GlobalKey<FormState>();
  String? selectedLLM, selectedSubject;
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
                        isAdvancedModeOnGetFromGlobalVarsLater ? 
                          TextEntry._('Question Subject', true, CreateAssessment.subjectController) :
                          DropdownButtonFormField<String>(
                          value: selectedSubject,
                          decoration: const InputDecoration(labelText: "Select Subject"),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSubject = newValue;
                            });
                          },
                          items: ['Math', 'Science', 'Language Arts', 'Social Studies', 'Health', 'Art', 'Music'].map((String value) {
                                  return DropdownMenuItem(value: value, child: Text(value),);
                                }).toList(),
                        ),
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
                        DropdownButtonFormField<String>(
                          value: selectedLLM,
                          decoration: const InputDecoration(labelText: "Select Model"),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedLLM = newValue;
                            });
                          },
                          items: ['ChatGPT', 'CLAUDE', 'Perplexity'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList()
                        ),
                        SizedBox(height: paddingHeight),
                        SubmitButton._(selectedSubject, selectedLLM,
                                        { "name" : CreateAssessment.nameController, 
                                          "description" : CreateAssessment.descriptionController,
                                          "subject" : CreateAssessment.subjectController,
                                          "multipleChoice" : CreateAssessment.multipleChoiceController,
                                          "trueFalse" :  CreateAssessment.trueFalseController,
                                          "shortAns" : CreateAssessment.shortAnswerController
                                        },
                                        _formKey,
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
  final String? selectedSubject, selectedLLM;
  final Map<String, TextEditingController> fields;
  final GlobalKey<FormState> formKey;
  final BuildContext context;
  final openapikey = dotenv.env['openai_apikey']?? 'default_openai_api_key';
  final claudapikey = dotenv.env['claudeai_apikey']?? 'default_claud_api_key';
  SubmitButton._(this.selectedSubject,
                 this.selectedLLM,
                 this.fields,
                 this.formKey,
                 this.context);

  Future<void> _submitToLLM() async {
    if(formKey.currentState!.validate()) {
      AssignmentForm af = AssignmentForm(
        questionType: QuestionType.shortanswer, //Potentially not necessary? Need to see about essay generator
        subject: selectedSubject != null ? selectedSubject.toString() :  fields['subject']!.text, 
        topic: fields['description']!.text, 
        gradeLevel: 'Sophomore', // Get these programatically?
        title: fields['name']!.text,
        trueFalseCount: int.parse(fields['trueFalse']!.text),
        shortAnswerCount: int.parse(fields['shortAns']!.text),
        multipleChoiceCount: int.parse(fields['multipleChoice']!.text),
        maximumGrade: 100
      );

      final aiModel;
      if (selectedLLM == 'ChatGPT') {
        aiModel = OpenAiLLM(openapikey);
      } else if (selectedLLM == 'CLAUDE') {
        aiModel = ClaudeAiAPI(claudapikey);
      } else {
        aiModel = OpenAiLLM(''); // Awaiting perplexity implementation
        //aiModel = PerplexityAPI(String.fromEnvironment('perplexity_apikey'));
      }
      var result = await aiModel.postToLlm(PromptEngine.generatePrompt(af));
      if (result.isNotEmpty) {
       Navigator.push(context, MaterialPageRoute(builder: (context) => EditQuestions(result)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _submitToLLM, child: Text("Submit"));
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