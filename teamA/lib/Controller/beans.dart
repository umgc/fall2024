import 'package:xml/xml.dart';
import 'dart:typed_data';

// Tags and attributes used in Moodle XML. Useful for preventing typos.
class XmlConsts {
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


  // not tags but useful constants
  static const multichoice = 'multichoice';
  static const truefalse = 'truefalse';
  static const shortanswer = 'shortanswer';
  static const essay = 'essay';
  static const html = 'html';
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

  set setName(String newname) {
    name = newname;
  }

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
  int trueFalseCount;
  int shortAnswerCount;
  int multipleChoiceCount;
  String? codingLanguage;
  String title;

  AssignmentForm(
      {required this.questionType,
      required this.subject,
      required this.topic,
      required this.gradeLevel,
      required this.title,
      required this.trueFalseCount,
      required this.shortAnswerCount,
      required this.multipleChoiceCount,
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

class Assignment {
  final int id;
  final String name;
  final String description;
  final DateTime? dueDate;
  final DateTime? allowsubmissionsfromdate;
  final DateTime? cutoffDate;
  final bool isDraft;
  final int maxAttempts;
  final int gradingStatus; // Can use an enum to represent status like "graded", "notgraded"
  final int courseId;

  final List<SubmissionWithGrade>? submissionsWithGrades;

  Assignment({
    required this.id,
    required this.name,
    required this.description,
    this.dueDate,
    this.allowsubmissionsfromdate,
    this.cutoffDate,
    required this.isDraft,
    required this.maxAttempts,
    required this.gradingStatus,
    required this.courseId,
    this.submissionsWithGrades,
  });

  // Factory method to create an Assignment object from a JSON response
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Untitled',
      description: json['description'] ?? '',
      dueDate: json['duedate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['duedate'] * 1000)
          : null,
      allowsubmissionsfromdate: json['allowsubmissionsfromdate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['allowsubmissionsfromdate'] * 1000)
          : null,
      cutoffDate: json['cutoffdate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['cutoffdate'] * 1000)
          : null,
      isDraft: json['submissiondrafts'] == 1, // boolean conversion
      maxAttempts: json['maxattempts'] ?? 0,
      gradingStatus: json['gradingstatus'] ?? 0,
      courseId: json['course'] ?? 0,

    );
  }

  // Convert the Assignment object back to JSON (useful for POST requests or local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'duedate': dueDate?.millisecondsSinceEpoch,
      'allowsubmissionsfromdate': allowsubmissionsfromdate?.millisecondsSinceEpoch,
      'cutoffdate': cutoffDate?.millisecondsSinceEpoch,
      'submissiondrafts': isDraft ? 1 : 0,
      'maxattempts': maxAttempts,
      'gradingstatus': gradingStatus,
      'course': courseId,

    };
  }
}

class Submission {
  final int id;
  final int userid;
  final String status;
  final DateTime submissionTime;
  final DateTime? modificationTime;
  final int attemptNumber;
  final int groupId;
  final String gradingStatus;
  final String onlineText;
  final String comments;
  final int assignmentId; // Added field

  Submission({
    required this.id,
    required this.userid,
    required this.status,
    required this.submissionTime,
    this.modificationTime,
    required this.attemptNumber,
    required this.groupId,
    required this.gradingStatus,
    required this.onlineText,
    required this.comments,
    required this.assignmentId,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    String onlineText = '';
    String comments = '';

    // Debug: Print entire submission JSON
    // ignore: avoid_print
    print('Processing submission: ${json.toString()}');
    int assignmentId = json['assignmentid'] ?? 0;
     Map<String, dynamic> submission = json['submission'] ?? {};

    if (submission['plugins'] != null && submission['plugins'] is List) {
      for (var plugin in submission['plugins']) {
        // Extract 'onlineText'
        if (plugin['type'] != null &&
            plugin['type'].toString().toLowerCase() == 'onlinetext') {
          var editorFields = plugin['editorfields'];
          if (editorFields != null &&
              editorFields is List &&
              editorFields.isNotEmpty) {
            for (var field in editorFields) {
              if (field['name'] != null &&
                  field['name'].toString().toLowerCase() == 'onlinetext') {
                onlineText = field['text'] ?? '';
                print('Extracted onlineText: $onlineText');
                break; // Exit loop once the correct field is found
              }
            }
          }
        }

        // Extract 'comments'
        if (plugin['type'] != null &&
            plugin['type'].toString().toLowerCase() == 'comments') {
          var editorFields = plugin['editorfields'];
          if (editorFields != null &&
              editorFields is List &&
              editorFields.isNotEmpty) {
            for (var field in editorFields) {
              if (field['name'] != null &&
                  field['name'].toString().toLowerCase() == 'comments') {
                comments = field['text'] ?? '';
                print('Extracted comments: $comments');
                break; // Exit loop once the correct field is found
              }
            }
          }
        }
      }
    } else {
      print('No plugins found in submission.');
    }

    return Submission(
      id: submission['id'] ?? 0,
      userid: submission['userid'] ?? 0,
      status: submission['status'] ?? '',
      submissionTime: submission['timecreated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(submission['timecreated'] * 1000)
          : DateTime.fromMillisecondsSinceEpoch(0),
      modificationTime: submission['timemodified'] != null
          ? DateTime.fromMillisecondsSinceEpoch(submission['timemodified'] * 1000)
          : null,
      attemptNumber: submission['attemptnumber'] ?? 0,
      groupId: submission['groupid'] ?? 0,
      gradingStatus: submission['gradingstatus'] ?? '',
      onlineText: onlineText,
      comments: comments,
      assignmentId: assignmentId
    );
  }
}

class Participant {
  final int id;
  final String username;
  final String fullname;
  final List<String> roles;

  Participant({
    required this.id,
    required this.username,
    required this.fullname,
    required this.roles,
  });

  // Factory constructor for creating a new Participant instance from a JSON map
  factory Participant.fromJson(Map<String, dynamic> json) {
    // Convert roles if they exist, and map them from the 'roles' field in the JSON
    List<String> rolesList = [];
    if (json['roles'] != null) {
      rolesList = (json['roles'] as List<dynamic>)
          .map((role) => role['shortname'] as String)
          .toList();
    }

    return Participant(
      id: json['id'] as int,
      username: json['username'] as String,
      fullname: json['fullname'] as String,
      roles: rolesList,
    );
  }
}

class Rubric {
  final String title;
  final List<Criterion> criteria;

  Rubric({required this.title, required this.criteria});

  factory Rubric.fromJson(Map<String, dynamic> json) {
    var criteriaList = (json['rubric_criteria'] as List)
        .map((c) => Criterion.fromJson(c))
        .toList();

    return Rubric(
      title: json['criteria_title'] ?? 'Rubric',
      criteria: criteriaList,
    );
  }
}

class Criterion {
  final String description;
  final List<Level> levels;

  Criterion({required this.description, required this.levels});

  factory Criterion.fromJson(Map<String, dynamic> json) {
    var levelsList = (json['levels'] as List)
        .map((l) => Level.fromJson(l))
        .toList();

    return Criterion(
      description: json['description'] ?? '',
      levels: levelsList,
    );
  }
}

class Level {
  final String description;
  final int score;

  Level({required this.description, required this.score});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      description: json['definition'] ?? '',
      score: json['score'] ?? 0,
    );
  }
}

class Grade {
  final int id;
  final int userid;
  final double grade;  // Convert from string in the JSON
  final int grader;
  final DateTime timecreated;
  final DateTime timemodified;

  Grade({
    required this.id,
    required this.userid,
    required this.grade,
    required this.grader,
    required this.timecreated,
    required this.timemodified,
  });

  // Parse grade JSON
  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] ?? 0,
      userid: json['userid'] ?? 0,
      // Parsing the grade as a double from a string
      grade: json['grade'] != null ? double.parse(json['grade']) : 0.0,
      grader: json['grader'] ?? 0,
      timecreated: DateTime.fromMillisecondsSinceEpoch(json['timecreated'] * 1000),
      timemodified: DateTime.fromMillisecondsSinceEpoch(json['timemodified'] * 1000),
    );
  }
}

class SubmissionWithGrade {
  final Submission submission;
  final Grade? grade;

  SubmissionWithGrade({
    required this.submission,
    this.grade,
  });
}
