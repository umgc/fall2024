import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intelligrade/ui/send_quiz_to_moodle.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';
import 'package:intelligrade/controller/model/beans.dart';
import 'package:flutter/material.dart';
import 'package:intelligrade/api/llm/openai_api.dart';
import 'package:intelligrade/ui/assignment_form.dart';

class EditQuestions extends StatefulWidget {
  final String questionXML;

  EditQuestions(this.questionXML);

  @override
  EditQuestionsState createState() => EditQuestionsState();
}

class EditQuestionsState extends State<EditQuestions> {
  late Quiz myQuiz;
  final TextEditingController _textController = TextEditingController();
  var apikey = dotenv.env['openai_apikey'];
  late OpenAiLLM openai;
  bool _isLoading = false;

  String subject = "Math";
  String topic = "Differential Equations";
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
    myQuiz.name = "Test Quiz";
    myQuiz.description = "Test Description";

    promptstart =
        'Create a question that is compatible with Moodle XML import. Be a bit creative in how you design the question and answers, making sure it is engaging but still on the subject of $subject and related to $topic. Make sure the XML specification is included, and the question is wrapped in the quiz XML element required by Moodle. Each answer should have feedback that fits the Moodle XML format, and avoid using HTML elements within a CDATA field. The quiz should be challenging and thought-provoking, but appropriate for high school students who speak English. The quesiton typ shoud be ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: Text('Edit Questions')
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
              ElevatedButton(
                onPressed: () async {
                  var result = await MoodleApiSingleton().getRubric('205');
                  print(result);
                },
                child: const Text('Get Rubric'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var result = await MoodleApiSingleton()
                      .addRandomQuestions('50', '22', '2');
                  print(result);
                },
                child: const Text('Add Random Questions'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var result = await MoodleApiSingleton()
                      .importQuizQuestions('2', myXML);
                  print(result);
                },
                child: const Text('Import Questions'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var result = await MoodleApiSingleton()
                      .createQuiz('2', 'Sunday Quiz', 'Sunday Quiz Intro');
                  print(result);
                },
                child: const Text('Create Quiz'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var result = await MoodleApiSingleton().createAssignment(
                      '2',
                      '2',
                      'Sunday Assignment',
                      '2024-10-6',
                      '2024-10-14',
                      rubricDefinition,
                      'This is the description');
                  print(result);
                },
                child: const Text('Create Assignment'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

//debugging code for bottom row buttons and temp quiz information
String myXML = '''
<?xml version="1.0" encoding="UTF-8"?>
<quiz>

  <!-- Define the category for the questions -->
  <question type="category">
    <category>
      <text>\$course\$/top/Key Signature Quiz Category</text>
    </category>
  </question>

  <!-- Multiple Choice Question 1 -->
  <question type="multichoice">
    <name>
      <text>Multiple Choice Question 1</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[What is the key signature with one sharp?]]></text>
    </questiontext>
    <answer fraction="100">
      <text>G Major</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>D Major</text>
      <feedback>
        <text>Incorrect. D Major has two sharps.</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>A Major</text>
      <feedback>
        <text>Incorrect. A Major has three sharps.</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>E Major</text>
      <feedback>
        <text>Incorrect. E Major has four sharps.</text>
      </feedback>
    </answer>
  </question>

  <!-- Multiple Choice Question 2 -->
  <question type="multichoice">
    <name>
      <text>Multiple Choice Question 2</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[What is the key signature with two flats?]]></text>
    </questiontext>
    <answer fraction="100">
      <text>B♭ Major</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>E♭ Major</text>
      <feedback>
        <text>Incorrect. E♭ Major has three flats.</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>A♭ Major</text>
      <feedback>
        <text>Incorrect. A♭ Major has four flats.</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>F Major</text>
      <feedback>
        <text>Incorrect. F Major has one flat.</text>
      </feedback>
    </answer>
  </question>

  <!-- Multiple Choice Question 3 -->
  <question type="multichoice">
    <name>
      <text>Multiple Choice Question 3</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[Which key has no sharps or flats?]]></text>
    </questiontext>
    <answer fraction="100">
      <text>C Major</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>G Major</text>
      <feedback>
        <text>Incorrect. G Major has one sharp.</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>F Major</text>
      <feedback>
        <text>Incorrect. F Major has one flat.</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>D Major</text>
      <feedback>
        <text>Incorrect. D Major has two sharps.</text>
      </feedback>
    </answer>
  </question>

  <!-- Multiple Choice Question 4 -->
  <question type="multichoice">
    <name>
      <text>Multiple Choice Question 4</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[Which of the following keys has three sharps?]]></text>
    </questiontext>
    <answer fraction="100">
      <text>A Major</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>G Major</text>
      <feedback>
        <text>Incorrect. G Major has one sharp.</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>D Major</text>
      <feedback>
        <text>Incorrect. D Major has two sharps.</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>E Major</text>
      <feedback>
        <text>Incorrect. E Major has four sharps.</text>
      </feedback>
    </answer>
  </question>

  <!-- True/False Question 1 -->
  <question type="truefalse">
    <name>
      <text>True/False Question 1</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[C Major has no sharps or flats.]]></text>
    </questiontext>
    <answer fraction="100">
      <text>true</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>false</text>
      <feedback>
        <text>Incorrect. C Major has no accidentals.</text>
      </feedback>
    </answer>
  </question>

  <!-- True/False Question 2 -->
  <question type="truefalse">
    <name>
      <text>True/False Question 2</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[D Major has three sharps.]]></text>
    </questiontext>
    <answer fraction="0">
      <text>true</text>
      <feedback>
        <text>Incorrect. D Major has two sharps.</text>
      </feedback>
    </answer>
    <answer fraction="100">
      <text>false</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
  </question>

  <!-- True/False Question 3 -->
  <question type="truefalse">
    <name>
      <text>True/False Question 3</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[F Major has one flat.]]></text>
    </questiontext>
    <answer fraction="100">
      <text>true</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>false</text>
      <feedback>
        <text>Incorrect. F Major has one flat, which is B♭.</text>
      </feedback>
    </answer>
  </question>

  <!-- True/False Question 4 -->
  <question type="truefalse">
    <name>
      <text>True/False Question 4</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[E Major has five sharps.]]></text>
    </questiontext>
    <answer fraction="0">
      <text>true</text>
      <feedback>
        <text>Incorrect. E Major has four sharps.</text>
      </feedback>
    </answer>
    <answer fraction="100">
      <text>false</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
  </question>

  <!-- Short Answer Question 1 -->
  <question type="shortanswer">
    <name>
      <text>Short Answer Question 1</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[Name the key that has one flat.]]></text>
    </questiontext>
    <answer fraction="100">
      <text>F Major</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
  </question>

  <!-- Short Answer Question 2 -->
  <question type="shortanswer">
    <name>
      <text>Short Answer Question 2</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[Name the key that has three flats.]]></text>
    </questiontext>
    <answer fraction="100">
      <text>E♭ Major</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
  </question>

  <!-- Short Answer Question 3 -->
  <question type="shortanswer">
    <name>
      <text>Short Answer Question 3</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[What is the relative minor of C Major?]]></text>
    </questiontext>
    <answer fraction="100">
      <text>A minor</text>
      <feedback>
        <text>Correct! A minor is the relative minor of C Major.</text>
      </feedback>
    </answer>
  </question>

  <!-- Short Answer Question 4 -->
  <question type="shortanswer">
    <name>
      <text>Short Answer Question 4</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[Name the key that has five sharps.]]></text>
    </questiontext>
    <answer fraction="100">
      <text>B Major</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
  </question>
</quiz>
''';
String rubricDefinition = '''
{
    "criteria": [
        {
            "description": "Content",
            "levels": [
                { "definition": "Excellent", "score": 5 },
                { "definition": "Good", "score": 3 },
                { "definition": "Poor", "score": 1 }
            ]
        },
        {
            "description": "Clarity",
            "levels": [
                { "definition": "Very Clear", "score": 5 },
                { "definition": "Somewhat Clear", "score": 3 },
                { "definition": "Unclear", "score": 1 }
            ]
        }
    ]
}
''';
String sampleXML = '''
<?xml version="1.0" encoding="UTF-8"?>
<quiz>
    <promptused>Give me a quiz about the Pythagorean Theorem.</promptused>
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