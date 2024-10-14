// Tests CogniOpen home screen
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:cogniopenapp/src/camera_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cogniopenapp/ui/video_screen.dart';
import '../../resources/fake_camera_manager.dart';
import '../../resources/fake_permission_handler.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    CameraPlatform.instance = MockCameraPlatform();
    PermissionHandlerPlatform.instance = MockPermissionHandlerPlatform();
    CameraManager cm = CameraManager();
    await cm.initializeCamera();
  });

  testWidgets('W-3: video screen loads correctly ',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: VideoScreen(), //Video Screen
    ));

    //Camera text
    expect(find.text('Camera'), findsOneWidget);

    //start video icon
    expect(find.byIcon(Icons.circle), findsOneWidget);
  }, skip: true);
}
