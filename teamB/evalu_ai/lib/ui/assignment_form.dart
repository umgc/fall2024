// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:intelligrade/ui/custom_navigation_bar.dart';
import 'package:intelligrade/ui/dashboard_page.dart';
import 'package:intelligrade/ui/generated_questions.dart';
import 'package:intelligrade/api/llm/openai_api.dart';
import 'package:intelligrade/ui/header.dart';

void main() {
  runApp(
    const MaterialApp(
      home: CreateAssignmentScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class CreateAssignmentScreen extends StatelessWidget {
  const CreateAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int selectedIndex =
        ModalRoute.of(context)?.settings.arguments as int? ?? 0; //capture index for nav bar
    return Scaffold(
      appBar: const AppHeader(
        title: "Create Assignment", //maybe change
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
                        child: AssignmentForm(),
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

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1E171A1F),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Create Assignment',
            style: TextStyle(
              color: Color(0xFFA096E4),
              fontSize: 19,
              fontWeight: FontWeight.w400,
            ),
          ),
          InkWell(
            onTap: () {
              // Navigate to the dashboard page when the profile icon is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashBoardPage(savedAssignments: [],)),
              );
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/user_avatar.png'),
            ),
          ),
        ],
      ),
    );
  }
}

class AssignmentForm extends StatefulWidget {
  const AssignmentForm({super.key});

  @override
  _AssignmentFormState createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<AssignmentForm> {
  String _selectedType = 'Quiz';
  String _selectedSubject = 'Math';
  String _selectedDifficulty = 'Medium';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _multipleChoiceController = TextEditingController(text: '');
  final TextEditingController _trueFalseController = TextEditingController(text: '');
  final TextEditingController _shortAnswerController = TextEditingController(text: '');

  final _formKey = GlobalKey<FormState>();

  // State variable for showing the loading spinner
  bool _isLoading = false;

  Future<void> generateQuestionsFromAI() async {
    if (_formKey.currentState!.validate()) {
      // Collect form data
      String assignmentTitle = _titleController.text;
      String assignmentType = _selectedType;
      String subject = _selectedSubject;
      String difficulty = _selectedDifficulty;
      String description = _descriptionController.text;
      int numMultipleChoice = int.parse(_multipleChoiceController.text);
      int numTrueFalse = int.parse(_trueFalseController.text);
      int numShortAnswer = int.parse(_shortAnswerController.text);

      // Create OpenAiLLM instance with your API key
      const apiKey = ' '; // Replace with your actual OpenAI API key
      final openAiLLM = OpenAiLLM(apiKey);

      // Create the query prompt
      String queryPrompt = '''
      Generate a $assignmentType on the subject of $subject. 
      Difficulty: $difficulty. 
      Number of Multiple Choice: $numMultipleChoice, 
      True/False: $numTrueFalse, 
      Short Answer: $numShortAnswer. 
      Description: $description.
      ''';

      // Show loading spinner
      setState(() {
        _isLoading = true;
      });

      try {
        // Call the AI to generate questions
        String generatedQuestions = await openAiLLM.queryAI(queryPrompt);

        // Split the generated questions into a list (assuming they are separated by newlines)
        List<String> questionList = generatedQuestions.split('\n');  // Adjust the delimiter based on your AI's response

        // Navigate to a new page to view the generated questions
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GeneratedQuestionsPage(
              generatedQuestions: questionList, 
              assignmentTitle: assignmentTitle, 
              subject: subject, 
              type: assignmentType, 
              ),
          ),
        );
      } finally {
        // Hide loading spinner
        setState(() {
          _isLoading = false;
        });
      }
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
              _buildTextFormField('Assignment Title', 'Type name', controller: _titleController),
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
                        _buildNumberInput('Number of Multiple Choice Questions', '0', controller: _multipleChoiceController),
                        const SizedBox(height: 15),
                        _buildNumberInput('Number of True/False Questions', '0', controller: _trueFalseController),
                        const SizedBox(height: 15),
                        _buildNumberInput('Number of Short Answer Questions', '0', controller: _shortAnswerController),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 7,
                    child: _buildTextFormField('Description', 'Enter assignment description', maxLines: 10, controller: _descriptionController),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: generateQuestionsFromAI,
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
                        MaterialPageRoute(builder: (context) => const DashBoardPage(savedAssignments: [],)),
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