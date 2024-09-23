import 'package:flutter/material.dart';

void main() {
  runApp(const CourseList());
}

class CourseList extends StatelessWidget {
  const CourseList({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Courses List'),
        ),
      ),
    );
  }
}
