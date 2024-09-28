import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'Views/dashboard.dart';
import 'Views/essay_edit_page.dart';
import 'Views/course_content.dart';
import 'Views/essay_generation.dart';
import 'Views/quiz_generator.dart';

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
      title: "Test App",
      home: DevLaunch(),
      theme: ThemeData(
        useMaterial3: true,
        //colors will be handled later
      ),
      scrollBehavior: CustomScrollBehavior(),
      routes: {
        '/EssayEditPage': (context) => EssayEditPage(),
        '/Content': (context) => ViewCourseContents('Test Course'),
        '/EssayGenerationPage': (context) => EssayGeneration(title: 'Essay Generation'),
        '/QuizGenerationPage': (context) => quiz_generator('Tester'),
        // '/create': (context) => const CreatePage(),
        '/dashboard': (context) => TeacherDashboard(),
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
              child: const Text('Open Edit Essay'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EssayEditPage()),
                );
              }),
          ElevatedButton(
              child: const Text('Open Contents Carousel'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewCourseContents("Test Course")),
                );
              }),
          ElevatedButton(
              child: const Text('Open Essay Generation'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EssayGeneration(title: 'Essay Generation')),
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
            ElevatedButton (
              child: const Text('Quiz Generator'),
              onPressed: () {
                Navigator.push( 
                  context, 
                  MaterialPageRoute(builder: (context) => quiz_generator())
                )
              },
            )
              child: const Text('Open Essay Generator'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateAssessment("Johnny Test")),
                  );
            })
        ]));
  }
}
