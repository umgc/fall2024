import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

final ColorScheme customColorScheme = ColorScheme(
  primary: Color(0xFF6A5A99), // Purple color as primary
  onPrimary: Color(0xFFFFFFFF), // White text on primary
  primaryContainer: Color(0xFFEDE6FF), // Light lavender
  onPrimaryContainer: Color(0xFF2D004A), // Dark purple
  secondary: Color(0xFF6A5A99), // Using similar purple as secondary
  onSecondary: Colors.white, // Black text on background
  surface: Color(0xFFFFFFFF), // White surface color
  onSurface: Colors.black, // Black text on surface
  error: Colors.red, // Error color red
  onError: Colors.white, // White on error
  brightness: Brightness.light, // Light mode
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CourseList(),
      theme: ThemeData(
        colorScheme: customColorScheme,
        useMaterial3: true,
      ),
      title: 'Learning Lens',
    );
  }
}

class CourseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primaryContainer, // Use primary container color
              elevation: 0,
              flexibleSpace: SafeArea(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      //to do something once pressed
                    },
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Learning Lens',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.person),
                    onPressed: () {
                      // to do something once pressed
                    },
                  ),
                ],
              )),
            ),
            body: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Course List',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  FilledButton(
                      onPressed: () {
                        // to do something once pressed
                      },
                      child: Text('Course 1'),
                      style: ButtonStyle(
                          minimumSize: WidgetStatePropertyAll(Size(375, 75)),
                          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ))),
                  FilledButton(
                      onPressed: () {
                        // to do something once pressed
                      },
                      child: Text('Course 2'),
                      style: ButtonStyle(
                          minimumSize: WidgetStatePropertyAll(Size(375, 75)),
                          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ))),
                  FilledButton(
                      onPressed: () {
                        // to do something once pressed
                      },
                      child: Text('Course 3'),
                      style: ButtonStyle(
                          minimumSize: WidgetStatePropertyAll(Size(375, 75)),
                          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ))),
                  FilledButton(
                      onPressed: () {
                        // to do something once pressed
                      },
                      child: Text('Course 4'),
                      style: ButtonStyle(
                          minimumSize: WidgetStatePropertyAll(Size(375, 75)),
                          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ))),
                ])));
  }
}
