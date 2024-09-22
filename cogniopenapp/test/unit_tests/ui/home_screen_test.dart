// Tests CogniOpen home screen

import 'package:cogniopenapp/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('W-1: Tests that the application home page loads correctly.', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    await tester.pump();

    // Verify application's title
    expect(find.text('CogniOpen', skipOffstage: false), findsOneWidget);

    // Verify the task buttons are visible
    expect(find.widgetWithText(ElevatedButton, "Virtual Assistant", skipOffstage: false), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, "Gallery", skipOffstage: false), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, "Object Search", skipOffstage: false), findsOneWidget);
    final audioRecordingButtonFinder = find.widgetWithText(ElevatedButton, "Record Audio", skipOffstage: false);
    expect(audioRecordingButtonFinder, findsOneWidget);
    await tester.ensureVisible(audioRecordingButtonFinder);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, "Location", skipOffstage: false), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, "Tour Guide", skipOffstage: false), findsOneWidget);
  });
}
