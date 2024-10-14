import 'package:xml/xml.dart';
import 'dart:typed_data';

// Tags and attributes used in Moodle XML. Useful for preventing typos.
class XmlConsts 
{
  // Quiz tags
  static const quiz = 'quiz';
  static const question = 'question';
  static const name = 'name';
  static const description = 'description';
  static const type = 'type';
  static const text = 'text';
  static const questiontext = 'questiontext';
  static const format = 'format';
  static const answer = 'answer';
  static const fraction = 'fraction';
  static const feedback = 'feedback';
  static const generalfeedback = 'generalfeedback';
  static const attachmentsrequired = 'attachmentsrequired';
  static const responseformat = 'responseformat';
  static const responserequired = 'responserequired';
  static const defaultgrade = 'defaultgrade';
  static const responsetemplate = 'responsetemplate';
  static const graderinfo = 'graderinfo';
  static const promptUsed = 'promptused';

  // Essay Rubric Tags
  static const rubric = 'rubric';
  static const title = 'title';
  static const subject = 'subject';
  static const gradeLevel = 'gradeLevel';
  static const maxPoints = 'maxPoints';
  static const criteria = 'criteria';
  static const points = 'points';

  // not tags but useful constants
  static const multichoice = 'multichoice';
  static const truefalse = 'truefalse';
  static const shortanswer = 'shortanswer';
  static const essay = 'essay';
  static const html = 'html';
}

// A generated rubric containing criteria for an essay prompt.
class Rubric 
{
  String title;
  String subject;
  String gradeLevel;
  int maxPoints;
  List<RubricCriteria> criteriaList;

  Rubric({
    required this.title,
    required this.subject,
    required this.gradeLevel,
    required this.maxPoints,
    required this.criteriaList,
  });

  // Factory constructor to create a Rubric from XML
  factory Rubric.fromXmlString(String xmlStr) 
  {
    final document = XmlDocument.parse(xmlStr);
    final rubricElement = document.getElement(XmlConsts.rubric);

    return Rubric(
      title: rubricElement?.getElement(XmlConsts.title)?.innerText ?? 'Untitled',
      subject: rubricElement?.getElement(XmlConsts.subject)?.innerText ?? 'Unknown',
      gradeLevel: rubricElement?.getElement(XmlConsts.gradeLevel)?.innerText ?? 'Unknown',
      maxPoints: int.parse(rubricElement?.getElement(XmlConsts.maxPoints)?.innerText ?? '0'),
      criteriaList: rubricElement
          ?.findElements(XmlConsts.criteria)
          .map((e) => RubricCriteria.fromXml(e))
          .toList() ?? [],
    );
  }

    // Convert the Rubric object to an XML string
  String toXmlString() {
    final builder = XmlBuilder();
    builder.element(XmlConsts.rubric, nest: () {
      builder.element(XmlConsts.title, nest: title);
      builder.element(XmlConsts.subject, nest: subject);
      builder.element(XmlConsts.gradeLevel, nest: gradeLevel);
      builder.element(XmlConsts.maxPoints, nest: maxPoints.toString());

      for (var criteria in criteriaList) {
        builder.element(XmlConsts.criteria, nest: criteria.toXml);
      }
    });
    return builder.buildDocument().toXmlString(pretty: true);
  }

  @override
  String toString() {
    return toXmlString();
  }
}

// Specific Rubric Criteria
class RubricCriteria 
{
  String description;
  int points;
  String feedback;

  RubricCriteria({
    required this.description,
    required this.points,
    this.feedback = '',
  });

  // Factory constructor to create criteria from XML
  factory RubricCriteria.fromXml(XmlElement criteriaElement) 
  {
    return RubricCriteria(
      description: criteriaElement.getElement(XmlConsts.description)?.innerText ?? 'Unknown',
      points: int.parse(criteriaElement.getElement(XmlConsts.points)?.innerText ?? '0'),
      feedback: criteriaElement.getElement(XmlConsts.feedback)?.innerText ?? '',
    );
  }

  // Convert the criteria to XML format
  void toXml(XmlBuilder builder) 
  {
    builder.element(XmlConsts.description, nest: description);
    builder.element(XmlConsts.points, nest: points.toString());
    builder.element(XmlConsts.feedback, nest: feedback);
  }

  @override
  String toString() {
    final builder = XmlBuilder();
    toXml(builder);
    return builder.buildFragment().toXmlString();
  }
class Essay {
  //todo more vars as needed (like the Rubric for starters)
  String? name;
  String? description;

  Essay({this.name,this.description});
}

// A Moodle quiz containing a list of questions.
class Quiz {
  String? name; // quiz name - optional.
  String? description; // quiz description - optional.
  List<Question> questionList = <Question>[]; // list of questions on the quiz.
  String? promptUsed;

  // Constructor with all optional params.
  Quiz({this.name, this.description, List<Question>? questionList})
      : questionList = questionList ?? [];

  // XML factory constructor using XML string
  factory Quiz.fromXmlString(String xmlStr) {
    Quiz quiz = Quiz();
    final document = XmlDocument.parse(xmlStr);
    final quizElement = document.getElement(XmlConsts.quiz);

    quiz.name = quizElement
        ?.getElement(XmlConsts.name)
        ?.getElement(XmlConsts.text)
        ?.innerText;

    quiz.description =
        quizElement!.getElement(XmlConsts.description)?.innerText;

    for (XmlElement questionElement
        in quizElement.findElements(XmlConsts.question)) {
      if (questionElement.getAttribute(XmlConsts.type) == 'category') {
        continue; // Skip category type questions
      }
      quiz.questionList.add(Question.fromXml(questionElement));
    }
    quiz.promptUsed = quizElement.getElement(XmlConsts.promptUsed)?.innerText;
    return quiz;
  }

  @override
  String toString() {
    final sb = StringBuffer();
    sb.write('Quiz Name: $name\n');
    sb.write('Quiz Description: $description\n\n');
    for (var i = 1; i <= questionList.length; i++) {
      sb.write('Q$i: ');
      sb.write(questionList[i - 1].toString());
      sb.write('\n\n');
    }
    return sb.toString();
  }
}

// Abstract class that represents a single question.
class Question {



  Question copyWith({String? name, List? answerList, String? type, String? questionText, bool? isFavorite}) =>
      Question(name: this.name, answerList: this.answerList,type: this.type, questionText: this.questionText, isFavorite: isFavorite ?? this.isFavorite);



  String name; // question name - required.
  String type; // question type (multichoice, truefalse, shortanswer, essay) - required.
  String questionText; // question text - required.
  String? generalFeedback;
  String? defaultGrade;
  String? responseFormat;
  String? responseRequired;
  String? attachmentsRequired;
  String? responseTemplate;
  String? graderInfo;
  final bool isFavorite;
  // String description;
  List<Answer> answerList =
      <Answer>[]; // list of answers. Not needed for essay.

  // Simple constructor.
  Question({
    required this.name,
    required this.type,
    required this.questionText,
    this.generalFeedback,
    this.defaultGrade,
    this.responseFormat,
    this.responseRequired,
    this.attachmentsRequired,
    this.responseTemplate,
    this.graderInfo,
    this.isFavorite = false,
    List<Answer>? answerList,
  }) : answerList = answerList ?? [];

  // XML factory constructor
  factory Question.fromXml(XmlElement questionElement) {
    Question question = Question(
      name: questionElement
              .getElement(XmlConsts.name)
              ?.getElement(XmlConsts.text)
              ?.innerText ??
          'UNKNOWN',
      type: questionElement.getAttribute(XmlConsts.type) ?? XmlConsts.essay,
      questionText: questionElement
              .getElement(XmlConsts.questiontext)
              ?.getElement(XmlConsts.text)
              ?.innerText ??
          'UNKNOWN',
      generalFeedback: questionElement
              .getElement(XmlConsts.generalfeedback)
              ?.getElement(XmlConsts.text)
              ?.innerText,
      defaultGrade: questionElement.getElement(XmlConsts.defaultgrade)?.innerText,
      responseFormat: questionElement.getElement(XmlConsts.responseformat)?.innerText,
      responseRequired: questionElement.getElement(XmlConsts.responserequired)?.innerText,
      attachmentsRequired: questionElement.getElement(XmlConsts.attachmentsrequired)?.innerText,
      responseTemplate: questionElement.getElement(XmlConsts.responsetemplate)?.innerText,
      graderInfo: questionElement.getElement(XmlConsts.graderinfo)?.getElement(XmlConsts.text)?.innerText,
    );

    for (XmlElement answerElement
        in questionElement.findElements(XmlConsts.answer).toList()) {
      question.answerList.add(Answer.fromXml(answerElement));
    }
    return question;
  }


// Question copyWith({
//    String? name
//   }){
//      return Question(name: name ?? this.name, type: type, questionText: questionText, isFavorite: isFavorite ?? isFavorite,);
//  }

  @override
  String toString() {
    final sb = StringBuffer();
    sb.write('$name\n$questionText');
    int charcode = 'A'.codeUnitAt(0);
    for (Answer answer in answerList) {
      String letter = String.fromCharCode(charcode);
      String answerStr = answer.toString();
      sb.write('\n  $letter. $answerStr');
      charcode++;
    }
    return sb.toString();
  }
}

// A single answer for a Question object. Used by all question types except for essay.
class Answer {
  String answerText; // Multiple choice text - required
  String fraction; // Point value from 0 (incorrect) to 100 (correct) - required
  String? feedbackText; // Feedback for the choice - optional

  // Simple constructor. Feedback param is optional.
  Answer(this.answerText, this.fraction, [this.feedbackText]);

  // XML factory constructor
  factory Answer.fromXml(XmlElement answerElement) {
    return Answer(
        answerElement.getElement(XmlConsts.text)?.innerText ?? 'UNKNOWN',
        answerElement.getAttribute(XmlConsts.fraction) ?? '100',
        answerElement
            .getElement(XmlConsts.feedback)
            ?.getElement(XmlConsts.text)
            ?.innerText);
  }

  @override
  String toString() {
    final sb = StringBuffer();
    sb.write(answerText);
    sb.write('  <= ($fraction%)');
    if (feedbackText != null) {
      sb.write(' - $feedbackText');
    }
    return sb.toString();
  }
}

// Represents a course in Moodle.
class Course {
  int id;
  String shortName;
  String fullName;

  // Barebones constructor.
  Course(this.id, this.shortName, this.fullName);

  // Json factory constructor.
  factory Course.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'shortname': String shortName,
        'fullname': String fullName,
      } =>
        Course(id, shortName, fullName),
      _ => throw const FormatException('Failed to load course from json.'),
    };
  }
}

enum QuestionType {
  multichoice(displayName: 'Multiple Choice', xmlName: 'multichoice'),
  truefalse(displayName: 'True/False', xmlName: 'truefalse'),
  shortanswer(displayName: 'Short Answers', xmlName: 'shortanswer'),
  essay(displayName: 'Essay', xmlName: 'essay'),
  coding(displayName: 'Coding', xmlName: 'essay');

  final String displayName;
  final String xmlName;

  const QuestionType({required this.displayName, required this.xmlName});
}

// Object to pass user-specified parameters to LLM API.
class AssignmentForm {
  QuestionType questionType;
  String? gradingCriteria;
  String subject;
  String topic;
  String gradeLevel;
  int maximumGrade;
  int? assignmentCount;
  int questionCount;
  String? codingLanguage;
  String title;

  AssignmentForm(
      {required this.questionType,
      required this.subject,
      required this.topic,
      required this.gradeLevel,
      required this.title,
      required this.questionCount,
      required this.maximumGrade,
      this.assignmentCount,
      this.gradingCriteria,
      this.codingLanguage});
}

// Helper bean class for file uploading.
class FileNameAndBytes {
  final String filename;
  final Uint8List bytes;

  FileNameAndBytes(this.filename, this.bytes);

  @override
  String toString() {
    return "$filename: ${bytes.lengthInBytes} bytes";
  }
}
