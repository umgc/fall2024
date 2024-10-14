import '../Api/moodle_api_singleton.dart';
import 'package:image_network/image_network.dart';
import '../controller/beans.dart';
import 'package:flutter/material.dart';

class EditQuestions extends StatefulWidget {
  @override
  State<EditQuestions> createState() => _EditQuestionsState();
}

class _EditQuestionsState extends State<EditQuestions> {
  late Quiz myQuiz;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // temporary code to load the quiz from the sample XML
    myQuiz = Quiz.fromXmlString(sampleXML);
    myQuiz.name = "My Quiz";
    myQuiz.description = "This is a quiz about the Pythagorean Theorem.";
  }

  @override
  Widget build(BuildContext context) {
    var userprofileurl = MoodleApiSingleton().moodleProfileImage!;
    
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text('Learning Lens - Edit Questions'),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: () {
                // Add your action here, like navigating to a new page
                print("Profile image clicked!");
                // Navigator.push(...);
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // color: Colors.white, //remove this when you add image.
                  ),
                  child: ImageNetwork(
                      image: userprofileurl, height: 100, width: 100),
                ),
              ),
            ),
          ),
        ],
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
                final question = myQuiz.questionList[index];
                return Dismissible(
                  key: Key(question.toString()),
                  background: Container(
                    color: Colors.green,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Icon(Icons.favorite),
                      ),
                    ),
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
                        myQuiz.questionList[index] =
                            question.copyWith(isFavorite: !question.isFavorite);
                      });
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
                onPressed: () async {
                  var result = await MoodleApiSingleton().getRubric('205');
                  print(result);
                },
                child: const Text('Get Rubric'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var result = await MoodleApiSingleton().addRandomQuestions('50', '22', '2');
                  print(result);
                },
                child: const Text('Add Random Questions'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var result = await MoodleApiSingleton().importQuizQuestions('2', myXML);
                  print(result);
                },
                child: const Text('Import Questions'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var result = await MoodleApiSingleton().createQuiz('2', 'Sunday Quiz', 'Sunday Quiz Intro');
                  print(result);
                },
                child: const Text('Create Quiz'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var result = await MoodleApiSingleton().createAssignnment('2', '2', 'Sunday Assignment', '2024-10-6', '2024-10-14', rubricDefinition, 'This is the description');
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
      <text>\$course\$/top/2112 Quiz Category</text>
    </category>
  </question>

  <!-- Multiple Choice Question -->
  <question type="multichoice">
    <name>
      <text>Multiple Choice Question</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[What is the capital of France?]]></text>
    </questiontext>
    <answer fraction="100">
      <text>Paris</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>London</text>
      <feedback>
        <text>Incorrect.</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>Rome</text>
      <feedback>
        <text>Incorrect.</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>Berlin</text>
      <feedback>
        <text>Incorrect.</text>
      </feedback>
    </answer>
  </question>

  <!-- True/False Question -->
  <question type="truefalse">
    <name>
      <text>True/False Question</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[The Earth is flat.]]></text>
    </questiontext>
    <answer fraction="0">
      <text>true</text>
      <feedback>
        <text>Incorrect.</text>
      </feedback>
    </answer>
    <answer fraction="100">
      <text>false</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
  </question>

  <!-- Short Answer Question -->
  <question type="shortanswer">
    <name>
      <text>Short Answer Question</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[What is the chemical symbol for water?]]></text>
    </questiontext>
    <answer fraction="100">
      <text>H2O</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
  </question>

  <!-- Matching Question -->
  <question type="matching">
    <name>
      <text>Matching Question</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[Match the countries to their capitals.]]></text>
    </questiontext>
    <subquestion format="html">
      <text><![CDATA[France]]></text>
      <answer>
        <text>Paris</text>
      </answer>
    </subquestion>
    <subquestion format="html">
      <text><![CDATA[Italy]]></text>
      <answer>
        <text>Rome</text>
      </answer>
    </subquestion>
  </question>

  <!-- Essay Question -->
  <question type="essay">
    <name>
      <text>Essay Question</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[Describe the impact of climate change on global weather patterns.]]></text>
    </questiontext>
    <graderinfo format="html">
      <text><![CDATA[Grading instructions for this question.]]></text>
    </graderinfo>
  </question>

  <!-- Numerical Question -->
  <question type="numerical">
    <name>
      <text>Numerical Question</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[What is the square root of 64?]]></text>
    </questiontext>
    <answer fraction="100">
      <text>8</text>
      <tolerance>0</tolerance>
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
