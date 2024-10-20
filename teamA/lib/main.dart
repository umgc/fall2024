import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learninglens_app/Views/assessments_view.dart';
import 'Views/login_page.dart';
import 'Views/dashboard.dart';
import 'Views/send_essay_to_moodle.dart';
import 'Views/essay_generation.dart';
import 'Views/quiz_generator.dart';
import 'Views/edit_questions.dart';

void main() async {
  await dotenv.load();
  runApp(LoginApp());
}

//click and drag for intuitiveness
class CustomScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

//below is an app builder, leave it here for now
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Learning Lens",
      home: DevLaunch(),
      theme: ThemeData(
        useMaterial3: true,
        //colors will be handled later
      ),
      scrollBehavior: CustomScrollBehavior(),
      routes: {
        'LoginPage': (context) => LoginApp(),
        // '/EssayEditPage': (context) => EssayEditPage(jsonData),
        // '/Content': (context) => ViewCourseContents(),
        '/EssayGenerationPage': (context) =>
            EssayGeneration(title: 'Essay Generation'),
        '/QuizGenerationPage': (context) => CreateAssessment(),
        '/EditQuestions': (context) => EditQuestions(''),
        // '/create': (context) => const CreatePage(),
        '/dashboard': (context) => TeacherDashboard(),
        '/send_essay_to_moodle': (context) => EssayAssignmentSettings(''),
        '/assessments': (context) => AssessmentsView(),
        // '/viewExams': (context) => const ViewExamPage(),
        // '/settings': (context) => Setting(themeModeNotifier: _themeModeNotifier)
      },
    );
  }
}

class DevLaunch extends StatefulWidget {
  @override
  State createState() {
    return _DevLaunch();
  }
}

class _DevLaunch extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Dev Launch Page')),
        body: Column(children: [
          ElevatedButton(
              child: const Text('Login'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginApp()),
                );
              }),
          // ElevatedButton(
          //     child: const Text('Open Edit Essay'),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => EssayEditPage(jsonData)),
          //       );
          //     }),
          // ElevatedButton(
          //     child: const Text('Open Contents Carousel'),
          //     onPressed: () async {
          //       if (MoodleApiSingleton().isLoggedIn()){
          //         MainController().selectCourse(0);
          //       }
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => ViewCourseContents()),
          //       );
          //     }),
          ElevatedButton(
              child: const Text('Open Essay Generation'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EssayGeneration(title: 'Essay Generation')),
                );
              }),
          ElevatedButton(
              child: const Text('Teacher Dashboard'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeacherDashboard()),
                );
              }),
          ElevatedButton(
              child: const Text('Send essay to Moodle'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EssayAssignmentSettings(tempRubricXML)),
                );
              }),
          ElevatedButton(
            child: const Text('Quiz Generator'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateAssessment()));
            },
          ),
          ElevatedButton(
            child: const Text('Edit Questions'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditQuestions('')));
            },
          ),
          ElevatedButton(
              child: const Text('View Quizzes'),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AssessmentsView()));
              })
        ]));
  }

  final jsonData = '''
{
    "criteria": [
      {
        "description": "Content",
        "levels": [
          {"definition": "Excellent", "score": 5},
          {"definition": "Good", "score": 3},
          {"definition": "Poor", "score": 1}
        ]
      },
      {
        "description": "Clarity",
        "levels": [
          {"definition": "Very Clear", "score": 5},
          {"definition": "Somewhat Clear", "score": 3},
          {"definition": "Unclear", "score": 1}
        ]
      }
    ]
  }
''';

  final tempRubricXML = '''
  {
    "criteria": [
      {
        "description": "Grammar and Mechanics",
        "levels": [
          { "score": 1, "definition": "Major errors in every sentence" },
          { "score": 2, "definition": "Severe errors that obscure meaning" },
          { "score": 3, "definition": "Many errors that make the essay difficult to understand" },
          { "score": 4, "definition": "Frequent errors that sometimes interfere with understanding" },
          { "score": 5, "definition": "Some errors that occasionally distract the reader" },
          { "score": 6, "definition": "Few minor errors that do not interfere with meaning" },
          { "score": 7, "definition": "No errors in grammar or mechanics" }
        ]
      },
      {
        "description": "Supporting Arguments",
        "levels": [
          { "score": 1, "definition": "No clear or logical arguments presented" },
          { "score": 2, "definition": "Arguments are poorly developed and lack support" },
          { "score": 3, "definition": "Few arguments are clear or supported" },
          { "score": 4, "definition": "Arguments are unclear or lack sufficient support" },
          { "score": 5, "definition": "Some arguments are supported, but others lack clarity or evidence" },
          { "score": 6, "definition": "Most arguments are clear and well-supported" },
          { "score": 7, "definition": "All arguments are clear, logical, and well-supported with evidence" }
        ]
      },
      {
        "description": "Organization",
        "levels": [
          { "score": 1, "definition": "No organization or structure" },
          { "score": 2, "definition": "Essay is poorly organized and difficult to follow" },
          { "score": 3, "definition": "Essay lacks clear structure and transitions" },
          { "score": 4, "definition": "Organization is present but inconsistent or weak" },
          { "score": 5, "definition": "Essay is generally organized, but some parts are confusing" },
          { "score": 6, "definition": "Essay is mostly well-organized, with few issues in flow" },
          { "score": 7, "definition": "Essay is very well-organized, with clear transitions and structure" }
        ]
      },
      {
        "description": "Use of Evidence",
        "levels": [
          { "score": 1, "definition": "No evidence provided" },
          { "score": 2, "definition": "Evidence is mostly irrelevant or incorrect" },
          { "score": 3, "definition": "Minimal evidence provided to support claims" },
          { "score": 4, "definition": "Some evidence is provided but lacks relevance or depth" },
          { "score": 5, "definition": "Evidence is used but inconsistently or insufficiently" },
          { "score": 6, "definition": "Good use of evidence with occasional gaps" },
          { "score": 7, "definition": "Excellent use of relevant evidence to support claims" }
        ]
      }
    ]
  }
''';
}
