// Tests CogniOpen Registration Screen

import 'package:cogniopenapp/ui/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Tests that the application registration page loads correctly.', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));
    await tester.pumpAndSettle();
    await tester.pump();

    // Verify application's title
    expect(find.text('Registration', skipOffstage: false), findsOneWidget);

    // Verify the task buttons are visible
    expect(find.widgetWithText(TextFormField, "First Name", skipOffstage: false), findsOneWidget);
    expect(find.widgetWithText(TextFormField, "Last Name", skipOffstage: false), findsOneWidget);
    expect(find.widgetWithText(TextFormField, "Email Address", skipOffstage: false), findsOneWidget);
  });
}
