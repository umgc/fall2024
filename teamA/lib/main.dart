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


void main() async{
  await dotenv.load();
  runApp(MyApp());
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
      home: LoginApp(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark
        //colors will be handled later
      ),
      scrollBehavior: CustomScrollBehavior(),
      routes: {
        'LoginPage': (context) => LoginApp(),
        // '/EssayEditPage': (context) => EssayEditPage(jsonData),
        // '/Content': (context) => ViewCourseContents(),
        '/EssayGenerationPage': (context) => EssayGeneration(title: 'Essay Generation'),
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
          // ElevatedButton(
          //     child: const Text('Send essay to Moodle'),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => EssayAssignmentSettings(tempRubricXML)),
          //       );
          //     }),
          ElevatedButton(
            child: const Text('Quiz Generator'),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateAssessment()));
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
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssessmentsView())
              );
            }
          )
        ]));
  }

} 