<<<<<<< HEAD
import 'package:flutter/material.dart';

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        // Enable Material 3, flutter
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          // The colorScheme generated from the seed color: purple
          seedColor: Colors.deepPurple.shade200,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
=======
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'Views/dashboard.dart';
import 'Views/essay_edit_page.dart';
import 'Views/course_content.dart';
import 'Views/send_essay_to_moodle.dart';
import 'Views/essay_generation.dart';
import 'Views/quiz_generator.dart';

void main() {
  runApp(MyApp());
}

//click and drag for intuitiveness
class CustomScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

//below is an app builder, leave it here for now
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Test App",
      home: DevLaunch(),
      theme: ThemeData(
        useMaterial3: true,
        //colors will be handled later
      ),
      scrollBehavior: CustomScrollBehavior(),
      routes: {
        '/EssayEditPage': (context) => EssayEditPage(),
        '/Content': (context) => ViewCourseContents('Test Course'),
        '/EssayGenerationPage': (context) =>
            EssayGeneration(title: 'Essay Generation'),
        '/QuizGenerationPage': (context) => CreateAssessment('Tester'),
        // '/create': (context) => const CreatePage(),
        '/dashboard': (context) => TeacherDashboard(),
        '/send_essay_to_moodle': (context) => EssayAssignmentSettings(),
        // '/viewExams': (context) => const ViewExamPage(),
        // '/settings': (context) => Setting(themeModeNotifier: _themeModeNotifier)
      },
>>>>>>> teamA
    );
  }
}

<<<<<<< HEAD
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Use background color from colorScheme

      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme

            // Use primaryContainer color for the AppBar
            .primaryContainer,
      ),
      body: Container(
        color: colorScheme

            // Use primaryContainer for the body background
            .primaryContainer,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Section
            Text(
              'Welcome to Learning Lens Application!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme

                    // Text color based on the primaryContainer contrast color
                    .onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Instruction Section
            Text(
              'Please, enter your username and password below and click Login, to access the Dashboard.',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme

                    // Text color for instructions
                    .onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Username Input
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
                border: const OutlineInputBorder(),

                // Input field background
                fillColor: colorScheme.surface,
                filled: true,
              ),
            ),
            const SizedBox(height: 16),

            // Password Input
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                border: const OutlineInputBorder(),

                // Input field background
                fillColor: colorScheme.surface,
                filled: true,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Moodle URL (optional if needed)
            TextField(
              decoration: InputDecoration(
                labelText: 'Moodle URL',
                hintText: 'https://www.swen670moodle.site/',
                border: const OutlineInputBorder(),

                // Input field background
                fillColor: colorScheme.surface,
                filled: true,
              ),
            ),
            const SizedBox(height: 32),

            // Login Button
            ElevatedButton(
              onPressed: () {
                // Add logic to handle login if needed
                print('Login button pressed');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: colorScheme

                    // Button text color based on onPrimary
                    .onPrimary,
                backgroundColor: colorScheme

                    // Button background color based on primary
                    .primary,
              ),
              child: const Text('Login'),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
=======
class DevLaunch extends StatefulWidget {
  @override
  State createState() {
    return _DevLaunch();
  }
}

class _DevLaunch extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Dev Launch Page')),
        body: Column(children: [
          ElevatedButton(
              child: const Text('Open Edit Essay'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EssayEditPage()),
                );
              }),
          ElevatedButton(
              child: const Text('Open Contents Carousel'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewCourseContents("Test Course")),
                );
              }),
          ElevatedButton(
              child: const Text('Open Essay Generation'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EssayGeneration(title: 'Essay Generation')),
                );
              }),
          ElevatedButton(
              child: const Text('Teacher Dashboard'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeacherDashboard()),
                );
              }),
          ElevatedButton(
              child: const Text('Send essay to Moodle'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EssayAssignmentSettings()),
                );
              }),
          ElevatedButton(
            child: const Text('Quiz Generator'),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateAssessment('Tester')));
            },
          )
        ]));
>>>>>>> teamA
  }
}
