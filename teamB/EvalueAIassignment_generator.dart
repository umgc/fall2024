
// ignore_for_file: avoid_print

import 'package:flutter/material.dart'; // Importing the Flutter material package for UI components


// Functionalities
// Class representing a question
class Question {
  String name; // Name of the question
  String type; // Type of the question (e.g., multiple choice, true/false)
  String? questionText; // Text of the question
  String? questionType; // Type of question (e.g., multiple choice)
  List<String> options; // Options for multiple choice questions
  String? correctAnswer; // Correct answer for the question
  List<String> incorrectAnswers; // List of incorrect answers

  // Constructor to initialize a Question object
  Question({
    required this.name,
    required this.type,
    required this.questionText,
    required this.questionType,
    List<String>? options,
    required this.correctAnswer,
    List<String>? incorrectAnswers,
  })  : options = options ?? [], // Initialize options, default to empty list if null
        incorrectAnswers = incorrectAnswers ?? []; // Initialize incorrectAnswers, default to empty list if null

  // Method to set question text
  void setQuestionText(String text) {
    questionText = text; // Assign the new text to questionText
  }

  @override
  String toString() {
    // Returns a string representation of the Question object
    return 'Question(name: $name, type: $type, questionText: $questionText, questionType: $questionType, options: $options, correctAnswer: $correctAnswer)';
  }
}

// Class representing an assignment
class Assignment {
  String assignmentTitle; // Title of the assignment
  String assignmentType; // Type of the assignment (e.g., quiz, essay)
  String subject; // Subject of the assignment
  List<Question> questions; // List of questions in the assignment
  String difficulty; // Difficulty level of the assignment
  String description; // Description of the assignment

  // Constructor to initialize an Assignment object
  Assignment({
    required this.assignmentTitle,
    required this.assignmentType,
    required this.subject,
    List<Question>? questions,
    required this.difficulty,
    required this.description,
  }) : questions = questions ?? []; // Initialize questions, default to empty list if null

  // Method to set assignment title
  void setAssignmentTitle(String title) {
    assignmentTitle = title; // Assign the new title to assignmentTitle
  }

  // Method to set assignment type with validation
  void setAssignmentType(String type) {
    if (type == "quiz" || type == "code" || type == "essay") {
      assignmentType = type; // Assign the new type if valid
    } else {
      throw ArgumentError('Invalid assignment type. Choose "quiz", "code", or "essay".'); // Throw an error for invalid type
    }
  }
}

// Class for generating assignments
class AssignmentGenerator {
  Assignment? currentAssignment; // Holds the current assignment being generated

  // Method to generate an assignment
  void generateAssignment(
      String title,
      String type,
      String subject,
      List<Question> questions,
      String difficulty,
      String description,
      BuildContext context) {
    // Initialize the currentAssignment with provided details
    currentAssignment = Assignment(
      assignmentTitle: title,
      assignmentType: type,
      subject: subject,
      questions: questions,
      difficulty: difficulty,
      description: description,
    );

    // Show the generated assignment details in a dialog
    _showGeneratedAssignmentDialog(context);
  }

  void _showGeneratedAssignmentDialog(BuildContext context) {
    if (currentAssignment == null) return; // Return if no assignment exists

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Generated Assignment Questions'), // Title of the dialog
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Minimize the size of the column
              crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
              children: [
                for (var q in currentAssignment!.questions) // Iterate through questions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align to start
                    children: [
                      Text(q.questionText ?? '', style: const TextStyle(fontWeight: FontWeight.bold)), // Display question text
                      Text('Options: ${q.options.join(', ')}', style: const TextStyle(color: Colors.grey)), // Display options
                      Text('Correct Answer: ${q.correctAnswer}', style: const TextStyle(color: Colors.green)), // Display correct answer
                      if (q.incorrectAnswers.isNotEmpty) // Check if there are incorrect answers
                        Text('Incorrect Answers: ${q.incorrectAnswers.join(', ')}', style: const TextStyle(color: Colors.red)), // Display incorrect answers
                      const SizedBox(height: 10), // Space between questions
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _showEditAssignmentDialog(context); // Show edit dialog
              },
              child: const Text('Edit'), // Button to edit the assignment
            ),
            TextButton(
              onPressed: () {
                print('Assignment saved: ${currentAssignment!.assignmentTitle}'); // Save assignment action
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save'), // Button to save the assignment
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text('Close'), // Button to close the dialog
            ),
          ],
        );
      },
    );
  }

  void _showEditAssignmentDialog(BuildContext context) {
    if (currentAssignment == null) return; // Return if no assignment exists

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Assignment'), // Title of the edit dialog
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Minimize the size of the column
              children: currentAssignment!.questions.map((question) {
                // Create text fields for each question
                TextEditingController questionController = TextEditingController(text: question.questionText); // Controller for question text
                TextEditingController correctAnswerController = TextEditingController(text: question.correctAnswer); // Controller for correct answer
                TextEditingController optionsController = TextEditingController(text: question.options.join(', ')); // Controller for options

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align children to start
                  children: [
                    TextField(
                      controller: questionController, // Controller for question input
                      decoration: const InputDecoration(labelText: 'Question'), // Label for the question input
                      onChanged: (text) {
                        question.setQuestionText(text); // Update question text on change
                      },
                    ),
                    TextField(
                      controller: correctAnswerController, // Controller for correct answer input
                      decoration: const InputDecoration(labelText: 'Correct Answer'), // Label for the correct answer input
                      onChanged: (text) {
                        question.correctAnswer = text; // Update correct answer on change
                      },
                    ),
                    TextField(
                      controller: optionsController, // Controller for options input
                      decoration: const InputDecoration(labelText: 'Options (comma separated)'), // Label for options input
                      onChanged: (text) {
                        // Update options on change, split by comma and trim spaces
                        question.options = text.split(',').map((option) => option.trim()).toList();
                      },
                    ),
                    const SizedBox(height: 20), // Space between fields
                  ],
                );
              }).toList(), // Convert the list of widgets to a list
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the edit dialog
              },
              child: const Text('Done'), // Button to confirm changes
            ),
          ],
        );
      },
    );
  }
}