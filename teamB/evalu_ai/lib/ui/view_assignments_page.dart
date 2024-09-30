// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intelligrade/controller/html_converter.dart';
import 'package:intelligrade/controller/main_controller.dart';
import 'package:intelligrade/controller/model/beans.dart'
    show AssignmentForm, Course, QuestionType, Quiz;
import 'package:intelligrade/ui/header.dart';
import 'package:intelligrade/ui/custom_navigation_bar.dart';

class ViewAssignmentsPage extends StatefulWidget {
  const ViewAssignmentsPage({super.key});

  static MainController controller = MainController();

  @override
  _ViewAssignmentsPage createState() => _ViewAssignmentsPage();
}

class _ViewAssignmentsPage extends State<ViewAssignmentsPage> {
  List<Quiz?> quizzes = []; // Initialize as an empty list
  bool _isUserLoggedIn = false;
  String? typeFilterSelection;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
    _checkUserLoginStatus();
  }

  Future<void> _fetchQuizzes() async {
    try {
      quizzes = ViewAssignmentsPage.controller.listAllAssessments();
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching quizzes: $e');
      }
      quizzes = [];
    }
  }

  Future<void> _checkUserLoginStatus() async {
    _isUserLoggedIn = await ViewAssignmentsPage.controller.isUserLoggedIn();
    setState(() {});
  }

  void _showQuizDetails(Quiz quiz) {
    List<int> selectedQuestions = [];
    bool regenerateMode = false;
    bool isRegenerating = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(quiz.name ?? 'Quiz Details'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          label: const Text('Edit'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _editQuiz(quiz);
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh, color: Colors.black),
                          label: const Text('Regenerate Questions'),
                          onPressed: !regenerateMode
                              ? () {
                                  setState(() {
                                    regenerateMode = true;
                                  });
                                }
                              : selectedQuestions.isEmpty
                                  ? null
                                  : () async {
                                      setState(() {
                                        isRegenerating = true;
                                      });
                                      bool result = await ViewAssignmentsPage
                                          .controller
                                          .regenerateQuestions(
                                              selectedQuestions, quiz);
                                      setState(() {
                                        isRegenerating = false;
                                        regenerateMode = false;
                                        selectedQuestions.clear();
                                      });
                                      if (result) {
                                        _fetchQuizzes(); // Refresh quiz list
                                        Navigator.of(context).pop();
                                        _showQuizDetails(quiz);
                                      }
                                    },
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                                    (Set<WidgetState> states) {
                              if (states.contains(WidgetState.disabled)) {
                                return const Color.fromARGB(255, 220, 220, 220);
                              }
                              return const Color.fromARGB(255, 212, 236, 255);
                            }),
                          ),
                        ),
                        if (regenerateMode) const SizedBox(width: 8),
                        if (regenerateMode)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.cancel, color: Colors.black),
                            label: const Text('Cancel Regenerate'),
                            onPressed: () {
                              setState(() {
                                regenerateMode = false;
                                selectedQuestions.clear();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 124, 115),
                            ),
                          ),
                      ],
                    ),
                    if (regenerateMode)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Select questions to regenerate:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    for (int i = 0; i < quiz.questionList.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (regenerateMode)
                                  Checkbox(
                                    value: selectedQuestions.contains(i),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedQuestions.add(i);
                                        } else {
                                          selectedQuestions.remove(i);
                                        }
                                      });
                                    },
                                  ),
                                Expanded(
                                  child: Text(
                                    'Question ${i + 1}: ${HtmlConverter.convert(quiz.questionList[i].questionText)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (isRegenerating &&
                                    selectedQuestions.contains(i))
                                  const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            for (int j = 0;
                                j < quiz.questionList[i].answerList.length;
                                j++)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '${String.fromCharCode('a'.codeUnitAt(0) + j)}) ${quiz.questionList[i].answerList[j].answerText}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: quiz.questionList[i].answerList[j]
                                                  .fraction ==
                                              '100'
                                          ? Colors.green
                                          : Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
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
              ],
            );
          },
        );
      },
    );
  }

  void _editQuiz(Quiz quiz) async {
    List<List<TextEditingController>> controllers =
        quiz.questionList.map((question) {
      List<TextEditingController> questionControllers = [
        TextEditingController(text: question.questionText)
      ];
      questionControllers.addAll(question.answerList
          .map((answer) => TextEditingController(text: answer.answerText))
          .toList());
      return questionControllers;
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Quiz'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...controllers.asMap().entries.map((entry) {
                  int questionIndex = entry.key;
                  List<TextEditingController> controllersForQuestion =
                      entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controllersForQuestion[0],
                        decoration: InputDecoration(
                            labelText: 'Edit question ${questionIndex + 1}'),
                        onChanged: (text) {
                          quiz.questionList[questionIndex].questionText = text;
                        },
                      ),
                      ...controllersForQuestion
                          .sublist(1)
                          .asMap()
                          .entries
                          .map((answerEntry) {
                        int answerIndex = answerEntry.key;
                        TextEditingController controller = answerEntry.value;

                        return TextField(
                          controller: controller,
                          decoration: InputDecoration(
                              labelText:
                                  'Edit answer ${String.fromCharCode('a'.codeUnitAt(0) + answerIndex)}'),
                          onChanged: (text) {
                            quiz.questionList[questionIndex]
                                .answerList[answerIndex].answerText = text;
                          },
                        );
                      }),
                      const SizedBox(height: 20),
                    ],
                  );
                }),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                try {
                  ViewAssignmentsPage.controller.updateFileLocally(quiz);
                  _fetchQuizzes(); // Refresh quiz list
                  Navigator.of(context).pop();
                  _showQuizDetails(quiz);
                } catch (e) {
                  if (kDebugMode) {
                    print('Error updating quiz: $e');
                  }
                }
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _showQuizDetails(quiz);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteQuiz(String filename) async {
    final bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this quiz?'),
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
      try {
        ViewAssignmentsPage.controller.deleteLocalFile(filename);
        _fetchQuizzes(); // Refresh quiz list
      } catch (e) {
        if (kDebugMode) {
          print('Error deleting quiz: $e');
        }
      }
    }
  }

  void _downloadQuiz(Quiz quiz, bool includeAnswers) async {
    try {
      await ViewAssignmentsPage.controller
          .downloadAssessmentAsPdf(quiz.name ?? '', includeAnswers);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz downloaded successfully')),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading quiz: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error downloading quiz')),
      );
    }
  }

  Future<void> _postQuizToMoodle(Quiz quiz) async {
    try {
      List<Course> courses = await ViewAssignmentsPage.controller.getCourses();
      String? selectedCourseId = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Moodle Course To Post To'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: courses.map((course) {
                  return ListTile(
                    title: Text(course.fullName),
                    onTap: () {
                      Navigator.of(context).pop(course.id.toString());
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );

      if (selectedCourseId != null) {
        await ViewAssignmentsPage.controller
            .postAssessmentToMoodle(quiz, selectedCourseId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz posted to Moodle successfully')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error posting quiz to Moodle: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error posting quiz to Moodle')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex =
        ModalRoute.of(context)?.settings.arguments as int? ?? 0;
    return Scaffold(
        appBar: const AppHeader(
          title: "View Assignments",
        ),
        body: LayoutBuilder(builder: (context, constraints) {
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
              quizzes.isEmpty
                  ? Expanded(
                      child: Column(
                        //mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black, // Border color
                                width: 1, // Border width
                              ),
                              borderRadius:
                                  BorderRadius.circular(60), // Circular border
                            ),
                            padding: EdgeInsets.all(
                                16), // Padding inside the container
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: Row(
                                      // ignore: prefer_const_literals_to_create_immutables
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            //onChanged: //_handleSearch,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(50),
                                              ),
                                              hintText: "Search",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Padding(
                                  //filter dropdown types
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0), // Optional padding
                                  child: DropdownButton<String>(
                                    value: typeFilterSelection,
                                    hint: Text('Type'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        typeFilterSelection =
                                            newValue; // Update the selected value
                                      });
                                    },
                                    items: <String>['Quiz', 'Essay', 'Code']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Padding(
                                  //filter dropdown for subject
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0), // Optional padding
                                  child: DropdownButton<String>(
                                    value: typeFilterSelection,
                                    hint: Text('Subject'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        typeFilterSelection =
                                            newValue; // Update the selected value
                                      });
                                    },
                                    items: <String>[
                                      'Math',
                                      'Chemistry',
                                      'Biology',
                                      'Computer Science',
                                      'Literature',
                                      'History',
                                      'Language Arts',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Padding(
                                  //filter dropdown for status
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0), // Optional padding
                                  child: DropdownButton<String>(
                                    value: typeFilterSelection,
                                    hint: Text('Status'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        typeFilterSelection =
                                            newValue; // Update the selected value
                                      });
                                    },
                                    items: <String>[
                                      'In-progress',
                                      'Completed',
                                      'Not Submitted',
                                      'Not Finalized',
                                      'Submitted',
                                      'Finalized',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(width: 20),
                                CircleAvatar(
                                  backgroundColor: Colors
                                      .deepPurple[200], // Background color
                                  child: IconButton(
                                    icon: Icon(Icons.search),
                                    color: Colors.deepPurple,
                                    onPressed: () {
                                      // Action to perform when the icon is pressed
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 300),
                          const Text('No saved exams yet.'),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/create');
                            },
                            child: const Text('Create Exam'),
                          ),
                          const SizedBox(height: 400),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: quizzes.length,
                              itemBuilder: (BuildContext context, int index) {
                                Quiz quiz = quizzes[index] ?? Quiz();
                                return Card(
                                  elevation: 4,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(quiz.name ?? 'Unnamed Quiz'),
                                    subtitle: Text(
                                        quiz.description ?? 'No description'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Tooltip(
                                          message: _isUserLoggedIn
                                              ? 'Post to Moodle'
                                              : 'Login to Moodle to be able to post exams',
                                          child: IconButton(
                                            icon: const Icon(Icons.upload,
                                                color: Colors.green),
                                            onPressed: _isUserLoggedIn
                                                ? () => _postQuizToMoodle(quiz)
                                                : null,
                                          ),
                                        ),
                                        Tooltip(
                                          message: 'Download as pdf',
                                          child: PopupMenuButton<bool>(
                                            icon: const Icon(Icons.download,
                                                color: Colors.blue),
                                            tooltip: '',
                                            onSelected: (bool includeAnswers) {
                                              _downloadQuiz(
                                                  quiz, includeAnswers);
                                            },
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry<bool>>[
                                              const PopupMenuItem<bool>(
                                                value: true,
                                                child: Text(
                                                    'Download with Answers'),
                                              ),
                                              const PopupMenuItem<bool>(
                                                value: false,
                                                child: Text(
                                                    'Download without Answers'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Tooltip(
                                          message: 'Delete',
                                          child: IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              _deleteQuiz(quiz.name ?? '');
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    onTap: () {
                                      _showQuizDetails(quiz);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          );
        }));
  }
}
