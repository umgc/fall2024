import 'package:cogniopenapp/src/camera_manager.dart';
import 'package:cogniopenapp/src/data_service.dart';
import 'package:cogniopenapp/src/s3_connection.dart';
import 'package:cogniopenapp/src/utils/directory_manager.dart';
import 'package:cogniopenapp/src/utils/logger.dart';
import 'package:cogniopenapp/src/utils/permission_manager.dart';
import 'package:cogniopenapp/ui/home_screen.dart';
import 'package:cogniopenapp/ui/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  initializeLogging();
  await dotenv.load(fileName: ".env");
  await DirectoryManager.instance.initializeDirectories();
  await DataService.instance.initializeData();
  initializeData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClearAssist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: Theme.of(context).textTheme.copyWith(
          // Body text styles
          bodySmall: TextStyle(color: Colors.white),   // Small body text
          bodyMedium: TextStyle(color: Colors.white),  // Medium body text
          bodyLarge: TextStyle(color: Colors.white),   // Large body text

          // Display text styles (headings)
          displayLarge: TextStyle(color: Colors.white),   // Large display text (H1)
          displayMedium: TextStyle(color: Colors.white),  // Medium display text (H2)
          displaySmall: TextStyle(color: Colors.white),   // Small display text (H3)

          // Headline text styles
          headlineLarge: TextStyle(color: Colors.white),   // Large headline (H1 equivalent)
          headlineMedium: TextStyle(color: Colors.white),  // Medium headline (H2 equivalent)
          headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),   // Small headline (H3 equivalent)

          // Title text styles
          titleLarge: TextStyle(color: Colors.white),   // Large title (T1 equivalent)
          titleMedium: TextStyle(color: Colors.white),  // Medium title (T2 equivalent)
          titleSmall: TextStyle(color: Colors.white),   // Small title (T3 equivalent)

          // Label text styles (for buttons or smaller elements)
          labelLarge: TextStyle(color: Colors.white),   // Large label
          labelMedium: TextStyle(color: Colors.white),  // Medium label
          labelSmall: TextStyle(color: Colors.white),   // Small label
        ),
      ),
      initialRoute: '/loginScreen', // the initial screen when the app starts
      routes: {
        '/loginScreen': (context) => const LoginScreen(),
        '/homeScreen': (context) => const HomeScreen(),
        // You can add other routes as needed
      },
    );
  }
}

// These are all singleton objects and should be initialized at the beginning
void initializeData() async {
  //initialize backend services
  // ignore: unused_local_variable
  S3Bucket s3 = S3Bucket();
  CameraManager cm = CameraManager();
  await PermissionManager.requestInitialPermissions();
  await cm.initializeCamera();
}
