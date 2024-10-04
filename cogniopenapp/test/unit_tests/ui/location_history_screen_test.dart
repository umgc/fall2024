// Tests CogniOpen significant object screen

import 'package:cogniopenapp/ui/location_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('W-5: location history screen loads correctly ',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: LocationHistoryScreen(), //Location History Screen
    ));

    //screen name
    expect(find.text('Location History', skipOffstage: false), findsOneWidget);
  });
}
