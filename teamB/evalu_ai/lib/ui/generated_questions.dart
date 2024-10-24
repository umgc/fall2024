import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intelligrade/controller/model/beans.dart';
import 'package:intelligrade/ui/assignment_form.dart';
//import 'package:intelligrade/ui/dashboard_page.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';
import 'package:intelligrade/api/llm/openai_api.dart';
//import 'package:intelligrade/ui/custom_navigation_bar.dart';
//import 'package:intelligrade/ui/header.dart';
import 'package:intelligrade/ui/send_quiz_to_moodle.dart';

class GeneratedQuestionsPage extends StatefulWidget {
  final String questionXML;

  GeneratedQuestionsPage(this.questionXML);

  @override
  _GeneratedQuestionsPageState createState() => _GeneratedQuestionsPageState();
}

class _GeneratedQuestionsPageState extends State<GeneratedQuestionsPage> {
  late Quiz myQuiz;
  final TextEditingController _textController = TextEditingController();
  var apikey = dotenv.env['OPENAI_API_KEY'];
  late OpenAiLLM openai;
  bool _isLoading = false;

  String subject = AssignmentQuizForm.descriptionController.text;
  String topic = AssignmentQuizForm.topicController.text;
  late String promptstart;

  @override
  void initState() {
    super.initState();
    myQuiz = Quiz.fromXmlString(widget.questionXML);
    if (apikey != null) {
      openai = OpenAiLLM(apikey!);
    } else {
      // Handle the case where the API key is null
      throw Exception('API key is not set in the environment variables');
    }
    myQuiz.name = AssignmentQuizForm.nameController.text;
    myQuiz.description = AssignmentQuizForm.descriptionController.text;

    promptstart =
        'Create a question that is compatible with Moodle XML import. Be a bit creative in how you design the question and answers, making sure it is engaging but still on the subject of $subject and related to $topic. Make sure the XML specification is included, and the question is wrapped in the quiz XML element required by Moodle. Each answer should have feedback that fits the Moodle XML format, and avoid using HTML elements within a CDATA field. The quiz should be challenging and thought-provoking, but appropriate for high school students who speak English. The quesiton typ shoud be ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: Text('Edit Questions'),
),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Prompt: ${myQuiz.promptUsed}',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: myQuiz.questionList.length,
              itemBuilder: (context, index) {
                var question = myQuiz.questionList[index];
                return Dismissible(
                  key: Key(question.toString()),
                  background: Stack(
                    children: [
                      Container(
                        color: Colors.green,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Icon(Icons.favorite),
                          ),
                        ),
                      ),
                      if (_isLoading)
                        Center(
                          child:
                              CircularProgressIndicator(), // Spinner behind the item
                        ),
                    ],
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(Icons.delete),
                      ),
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      setState(() {
                        _isLoading = true;
                      });
                      var result = await openai
                          // .postToLlm(promptstart + question.toString());
                          .postToLlm(promptstart + question.type.toString());

                      setState(() {
                        _isLoading = false; // Stop showing the spinner
                      });

                      if (result.isNotEmpty) {
                        setState(() {
                          //replace the old question with the new one from the api call
                          question = Quiz.fromXmlString(result).questionList[0];
                          question.setName = 'Question ${index + 1}';
                          myQuiz.questionList[index] = question.copyWith(
                              isFavorite: !question.isFavorite);
                        });
                      }
                      return false;
                    } else {
                      bool delete = true;
                      final snackbarController =
                          ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Deleted $Question'),
                          action: SnackBarAction(
                              label: 'Undo', onPressed: () => delete = false),
                        ),
                      );
                      await snackbarController.closed;
                      return delete;
                    }
                  },
                  onDismissed: (_) {
                    setState(() {
                      myQuiz.questionList.removeAt(index);
                    });
                  },
                  child: ListTile(
                    title: Text(question.toString()),
                    tileColor: (index.isEven)
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.secondaryContainer,
                    textColor: (index.isEven)
                        ? Theme.of(context).colorScheme.onSecondary
                        : Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizMoodle(quiz: myQuiz)
                    ),
                  );
                },
                child: const Text('Send to Moodle Set up'),
              ),
            
            ],
          )
        ],
      ),
    );
  }
}