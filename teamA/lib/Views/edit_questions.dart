// import '../controller/xml_converter.dart';
import '../controller/beans.dart';
import 'package:flutter/material.dart';

class EditQuestions extends StatefulWidget {
  @override
  State<EditQuestions> createState() => _EditQuestionsState();
}

class _EditQuestionsState extends State<EditQuestions> {
  late Quiz myQuiz;

  @override
  void initState() {
    super.initState();
    //temporary code to load the quiz from the sample XML
    myQuiz = Quiz.fromXmlString(sampleXML);
    myQuiz.name = "My Quiz";
    myQuiz.description = "This is a quiz about the Pythagorean Theorem.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(title: Text('Edit Questions')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [],
          ),
          Expanded(
              flex: 1,
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: myQuiz.questionList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 150,
                    //   color: Colors.amber[colorCodes[index]],
                      child: Text('${myQuiz.questionList[index]}'),
                    );
                  })),
        ],
      ),
    );
  }
}

String sampleXML = '''
<?xml version="1.0" encoding="UTF-8"?>
<quiz>
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
