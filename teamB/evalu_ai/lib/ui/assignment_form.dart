// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intelligrade/api/llm/openai_api.dart';
import 'package:intelligrade/controller/model/beans.dart';
import 'package:intelligrade/ui/custom_navigation_bar.dart';
import 'package:intelligrade/ui/dashboard_page.dart';
import 'package:intelligrade/ui/generated_questions.dart';
//import 'package:intelligrade/api/llm/openai_api.dart';
import 'package:intelligrade/api/llm/prompt_engine.dart';
import 'package:intelligrade/ui/header.dart';

class CreateAssignmentScreen extends StatelessWidget {
  const CreateAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
    return Scaffold(
      appBar: const AppHeader(
        title: "Create Assignment",
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Row(
          children: [
            Container(
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
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: AssignmentQuizForm(),
                      ),
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

class AssignmentQuizForm extends StatefulWidget {

  static TextEditingController nameController = TextEditingController();
  static TextEditingController descriptionController = TextEditingController();
  static TextEditingController subjectController = TextEditingController();
  static TextEditingController multipleChoiceController = TextEditingController();
  static TextEditingController trueFalseController = TextEditingController();
  static TextEditingController shortAnswerController = TextEditingController();
  static TextEditingController topicController = TextEditingController();
  
  @override
  State createState() {
    return _AssignmentQuizFormState();
  }
}

class _AssignmentQuizFormState extends State<AssignmentQuizForm> {
  String _selectedType = 'Quiz';
  String _selectedSubject = 'Math';
  String _selectedDifficulty = 'Medium';
  String selectedLLM = 'OpenAI';

  // final TextEditingController _titleController = TextEditingController();
  // final TextEditingController _descriptionController = TextEditingController();
  // final TextEditingController _multipleChoiceController = TextEditingController(text: '');
  // final TextEditingController _trueFalseController = TextEditingController(text: '');
  // final TextEditingController _shortAnswerController = TextEditingController(text: '');

  final _formKey = GlobalKey<FormState>();

    // State variable for showing the loading spinner
  bool _isLoading = false;

  void generateQuiz(Map<String, TextEditingController> fields) {
    if (_formKey.currentState!.validate()) {
      AssignmentForm af = AssignmentForm(
          subject: _selectedSubject != null ? _selectedSubject.toString() :  fields['subject']!.text, 
          topic: fields['description']!.text, 
          gradeLevel: "University",
          title: fields['name']!.text,
          trueFalseCount: int.parse(fields['trueFalse']!.text),
          shortAnswerCount: int.parse(fields['shortAns']!.text),
          multipleChoiceCount: int.parse(fields['multipleChoice']!.text),
          maximumGrade: 100
        );
        print('Before Generate Questiona from AI');
        generateQuestionsFromAI(af);
    }
  }

  Future<void> generateQuestionsFromAI(AssignmentForm af) async {
      final openApiKey = dotenv.env['OPENAI_API_KEY']?? 'default_openai_api_key';
      final claudApiKey = dotenv.env['CLAUDE_API_KEY']?? 'default_claude_api_key';
      final String perplexityApiKey = dotenv.env['PERPLEXITY_API_KEY']?? 'default_perplexity_api_key';
      try {
        setState((){_isLoading=true;});
        final aiModel;

        aiModel = OpenAiLLM(openApiKey);

        print('Before to the Post to the LLM');
        var result = await aiModel.postToLlm(PromptEngine.generatePrompt(af));
        if (result.isNotEmpty) {
          setState(() {_isLoading=false;});
          Navigator.push(context, MaterialPageRoute(builder: (context) => GeneratedQuestionsPage(result)));
        }
      }
      catch (e) {
        print("Failure sending request to LLM: $e");
        setState(() {_isLoading=false;});
      }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFormField('Assignment Title', 'Type name', controller: AssignmentQuizForm.nameController),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Type', ['Quiz', 'Exam', 'Assignment'], _selectedType, (value) => setState(() => _selectedType = value!))),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDropdown('Subject', ['Math', 'Chemistry', 'Biology', 'Computer Science', 'Literature', 'History', 'Language Arts'], _selectedSubject, (value) => setState(() => _selectedSubject = value!))),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Difficulty', style: TextStyle(color: Color(0xFF939798), fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildDifficultyOption('High'),
                  const SizedBox(width: 20),
                  _buildDifficultyOption('Medium'),
                  const SizedBox(width: 20),
                  _buildDifficultyOption('Low'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildNumberInput('Number of Multiple Choice Questions', '0', controller: AssignmentQuizForm.multipleChoiceController),
                        const SizedBox(height: 15),
                        _buildNumberInput('Number of True/False Questions', '0', controller: AssignmentQuizForm.trueFalseController),
                        const SizedBox(height: 15),
                        _buildNumberInput('Number of Short Answer Questions', '0', controller: AssignmentQuizForm.shortAnswerController),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 7,
                    child: _buildTextFormField('Description', 'Enter assignment description', maxLines: 10, controller: AssignmentQuizForm.descriptionController),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      generateQuiz(
                          { "name" : AssignmentQuizForm.nameController, 
                            "description" : AssignmentQuizForm.descriptionController,
                            "subject" : AssignmentQuizForm.subjectController,
                            "multipleChoice" : AssignmentQuizForm.multipleChoiceController,
                            "trueFalse" :  AssignmentQuizForm.trueFalseController,
                            "shortAns" : AssignmentQuizForm.shortAnswerController
                          });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7D6CE2),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text('Generate'),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () {
                      // Navigate back to the dashboard page without saving any results
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DashBoardPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFC1C3C5),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isLoading)
          Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildTextFormField(String label, String hintText, {int maxLines = 1, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF939798), fontSize: 14)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFFC1C3C5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFF7D6CE2)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selectedItem, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF939798), fontSize: 14)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: selectedItem,
          items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFFC1C3C5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFF7D6CE2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyOption(String difficulty) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDifficulty = difficulty;
          });
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: _selectedDifficulty == difficulty ? const Color(0xFF7D6CE2) : const Color(0xFFF4F6F9),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: _selectedDifficulty == difficulty ? const Color(0xFF7D6CE2) : const Color(0xFFC1C3C5),
            ),
          ),
          child: Center(
            child: Text(difficulty, style: TextStyle(color: _selectedDifficulty == difficulty ? Colors.white : const Color(0xFF717377))),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberInput(String label, String hintText, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF939798), fontSize: 14)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFFC1C3C5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFF7D6CE2)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }
}