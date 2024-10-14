// Tests CogniOpen Profile Screen

import 'package:cogniopenapp/ui/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Tests that the application profile page loads correctly.', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pumpAndSettle();
    await tester.pump();

    // Verify application's title
    expect(find.text('Profile', skipOffstage: false), findsOneWidget);

    // Verify the task buttons are visible
    expect(find.widgetWithText(TextFormField, "First Name",skipOffstage: false), findsOneWidget); 
    expect(find.widgetWithText(TextFormField, "Last Name",skipOffstage: false), findsOneWidget); 
    expect(find.widgetWithText(TextFormField, "Email Address",skipOffstage: false), findsOneWidget); 
    expect(find.widgetWithText(TextFormField, "Phone Number",skipOffstage: false), findsOneWidget); 
    expect(find.widgetWithText(TextFormField, "Emergency First Name",skipOffstage: false), findsOneWidget); 
    expect(find.widgetWithText(TextFormField, "Emergency Last Name",skipOffstage: false), findsOneWidget); 
    expect(find.widgetWithText(TextFormField, "Emergency Phone Number",skipOffstage: false), findsOneWidget);
  });
}
