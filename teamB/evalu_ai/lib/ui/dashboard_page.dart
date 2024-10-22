import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intelligrade/ui/header.dart';
import 'package:intelligrade/ui/custom_navigation_bar.dart';

import 'package:intelligrade/controller/main_controller.dart';
import 'package:intelligrade/controller/model/beans.dart';

import '../controller/html_converter.dart';

class DashBoardPage extends StatefulWidget {
  final List<Map<String, dynamic>> savedAssignments; // Store the saved quizzes

  const DashBoardPage({super.key, required this.savedAssignments});
  static MainController controller = MainController();

  @override
  _DashBoardPageState createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  Future<void> _checkUserLoginStatus() async {
    _isUserLoggedIn = await DashBoardPage.controller.isUserLoggedIn();
    setState(() {});
  }

  void _showQuizDetails(Map<String, dynamic> quiz) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(quiz['title']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${quiz['title']}'),
                Text('Subject: ${quiz['subject']}'),
                Text('Type: ${quiz['type']}'),
                Text('Number of Questions: ${quiz['numQuestions']}'),
                Text('Status: ${quiz['status']}'),
                Text('Date Created: ${quiz['dateCreated']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              onPressed: () {
                Navigator.of(context).pop();
                _editQuiz(quiz);
              },
            ),
          ],
        );
      },
    );
  }

  void _editQuiz(Map<String, dynamic> quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignmentDetailsPage(assignment: quiz),
      ),
    );
  }

  // Function to handle the delete button
  void _deleteQuiz(Map<String, dynamic> quiz) async {
    final bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this assignment?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        widget.savedAssignments.remove(quiz); // Remove the assignment from the list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex =
        ModalRoute.of(context)?.settings.arguments as int? ?? 0;

    return Scaffold(
      appBar: const AppHeader(title: "Dashboard"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: <Widget>[
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
              widget.savedAssignments.isEmpty
                  ? Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No saved assignments yet.'),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/create');
                            },
                            child: const Text('Create Assignment'),
                          ),
                        ],
                      ),
                    )
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: widget.savedAssignments.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final assignment = widget.savedAssignments[index];

                                  return Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      title: Text('Title: ${assignment['title']}'),
                                      subtitle: Text(
                                          'Subject: ${assignment['subject']} | Type: ${assignment['type']} | # of Questions: ${assignment['numQuestions']}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _editQuiz(assignment); // Navigate to edit quiz
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              _deleteQuiz(assignment); // Prompt for deletion
                                            },
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        _showQuizDetails(assignment);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class AssignmentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> assignment;

  const AssignmentDetailsPage({required this.assignment, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${assignment['title']}')),
      body: ListView.builder(
        itemCount: assignment['questions'].length,
        itemBuilder: (context, index) {
          return ListTile(
            title: TextField(
              controller: TextEditingController(text: assignment['questions'][index]),
              onChanged: (value) {
                assignment['questions'][index] = value;
              },
              decoration: InputDecoration(labelText: 'Question ${index + 1}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle saving the edited questions back to the dashboard or storage
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
