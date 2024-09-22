// Tests CogniOpen significant object screen

import 'package:cogniopenapp/ui/significant_objects_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('W-4: significant object screen loads correctly ',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SignificantObjectScreen(), //Significant Object Screen
    ));

    //Camera text
    expect(find.text('Camera', skipOffstage: false), findsOneWidget);

    //Upload image text
    expect(find.text(' Upload Image', skipOffstage: false), findsOneWidget);

    //screen name
    expect(find.text('Significant Objects'), findsOneWidget);
  });
}
