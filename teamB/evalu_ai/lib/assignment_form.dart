import 'package:flutter/material.dart';

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
    return const Scaffold(
      body: Column(
        children: [
          Header(),
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
              Navigator.pushNamed(context, '/user_profile');
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
  // ignore: library_private_types_in_public_api
  _AssignmentFormState createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<AssignmentForm> {
  String _selectedType = 'Quiz';
  String _selectedSubject = 'Usability Engineering 661';
  String _selectedDifficulty = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFormField('Assignment Title', 'Type name'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildDropdown('Type', ['Quiz', 'Exam', 'Homework'], _selectedType, (value) => setState(() => _selectedType = value!))),
              const SizedBox(width: 20),
              Expanded(child: _buildDropdown('Subject', ['Usability Engineering 661', 'Computer Science 101', 'Data Structures'], _selectedSubject, (value) => setState(() => _selectedSubject = value!))),
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
                    _buildNumberInput('Number of Multiple Choice Questions', '20'),
                    const SizedBox(height: 15),
                    _buildNumberInput('Number of True/False Questions', '10'),
                    const SizedBox(height: 15),
                    _buildNumberInput('Number of Short Answer Questions', '3'),
                    const SizedBox(height: 15),
                    _buildNumberInput('Number of Long Answer Questions', '1'),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 7,
                child: _buildTextFormField('Description', 'Enter assignment description', maxLines: 10),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement generate exam logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D6CE2),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Generate Exam'),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  // TODO: Implement cancel logic
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
    );
  }

  Widget _buildTextFormField(String label, String hintText, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8B8F96), fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 5),
        TextFormField(
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFFD7DADF)),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF939798), fontSize: 14)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyOption(String difficulty) {
    bool isSelected = _selectedDifficulty == difficulty;
    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = difficulty),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: isSelected ? const Color(0xFFAFB3BA) : const Color(0xFFB7BAC0),
          ),
          const SizedBox(width: 5),
          Text(
            difficulty,
            style: TextStyle(
              color: isSelected ? const Color(0xFFAFB3BA) : const Color(0xFFB7BAC0),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput(String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8B8F96), fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 5),
        TextFormField(
          initialValue: initialValue,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}