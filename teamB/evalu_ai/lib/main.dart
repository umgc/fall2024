import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intelligrade/ui/assignment_form.dart';
import 'package:intelligrade/ui/dashboard_page.dart';
import 'package:intelligrade/ui/generate_essay_page.dart';
import 'package:intelligrade/ui/login_page.dart';
import 'package:intelligrade/ui/setting_page.dart';
import 'package:intelligrade/ui/view_assignments_page.dart';
import 'package:intelligrade/ui/code_compiler.dart';
import 'ui/grade_essay_page.dart';



Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ValueNotifier<ThemeMode> _themeModeNotifier =
      ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Launching Page',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          home: const LoginPage(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/create': (context) => const CreateAssignmentScreen(), //CreatePage(),
            '/dashboard': (context) => const DashBoardPage(savedAssignments: [],),
            '/viewAssignments': (context) => const ViewAssignmentsPage(),
            '/assignemntDetails': (context) => const AssignmentDetailsPage(assignment: {},),
            '/generateEssay': (context) => const GenerateEssayPage(),
            '/gradeEssay': (context) => const GradeEssayPage(),
            '/compileCode': (context) => const CodeCompilerPage(),
            '/settings': (context) =>
                Setting(themeModeNotifier: _themeModeNotifier)
          },
        );
      },
    );
  }
}
