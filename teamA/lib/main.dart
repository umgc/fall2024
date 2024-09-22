import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'course_content.dart';

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
      home: ViewCourseContents('Test Course'),
      theme: ThemeData(
        useMaterial3: true,
        //colors will be handled later
      ),
      scrollBehavior: CustomScrollBehavior(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/grading': (context) => const GradingPage(),
        '/create': (context) => const CreatePage(),
        '/viewExams': (context) => const ViewExamPage(),
        '/settings': (context) => Setting(themeModeNotifier: _themeModeNotifier)
      },
    );
  }
}
