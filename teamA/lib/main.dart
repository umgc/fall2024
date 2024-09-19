import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'course_content.dart';

void main() {
  runApp(MyApp());
}

//click and drag for intuitiveness
class CustomScrollBehavior extends ScrollBehavior{
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
      home: ViewCourseContents(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple)
      ),
      scrollBehavior: CustomScrollBehavior(),
    );
  }
}
