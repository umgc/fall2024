import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'Api/moodle_api_singleton.dart';
import 'Controller/main_controller.dart';
import 'Views/login_page.dart';
import 'Views/dashboard.dart';
import 'Views/essay_edit_page.dart';
import 'Views/course_content.dart';
import 'Views/send_essay_to_moodle.dart';
import 'Views/essay_generation.dart';
import 'Views/quiz_generator.dart';
import 'Views/edit_questions.dart';

void main() {
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
      home: DevLaunch(),
      theme: ThemeData(
        useMaterial3: true,
        //colors will be handled later
      ),
      scrollBehavior: CustomScrollBehavior(),
      routes: {
        'LoginPage': (context) => LoginApp(),
        '/EssayEditPage': (context) => EssayEditPage(),
        '/Content': (context) => ViewCourseContents(),
        '/EssayGenerationPage': (context) => EssayGeneration(title: 'Essay Generation'),
        '/QuizGenerationPage': (context) => CreateAssessment('Tester'),
        '/EditQuestions': (context) => EditQuestions(),
        // '/create': (context) => const CreatePage(),
        '/dashboard': (context) => TeacherDashboard(),
        '/send_essay_to_moodle': (context) => EssayAssignmentSettings(''),
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
          ElevatedButton(
              child: const Text('Open Edit Essay'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EssayEditPage()),
                );
              }),
          ElevatedButton(
              child: const Text('Open Contents Carousel'),
              onPressed: () async {
                MoodleApiSingleton api = MoodleApiSingleton();
                MainController main = MainController();
                //await api.login('insert test username', 'insert test pw', 'insert test url');
                await main.selectCourse(0);
                // Current issue: Haven't tested yet, need to make a dummy course for myself.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewCourseContents()),
                );
              }),
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
                      builder: (context) => EssayAssignmentSettings('')),
                );
              }),
          ElevatedButton(
            child: const Text('Quiz Generator'),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateAssessment('Tester')));
            },
          ),
          ElevatedButton(
            child: const Text('Edit Questions'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditQuestions()));
            },
          )
        ]));
  }
}
