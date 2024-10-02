import 'package:flutter/material.dart';
import '/controller/main_controller.dart';
import '../Controller/beans.dart';
import '../Views/dashboard.dart';

class LoginApp extends StatelessWidget 
{

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
    );
  }
}

class LoginScreen extends StatefulWidget 
{
  const LoginScreen({Key? key}) : super(key: key);
  static MainController controller = MainController();

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
{
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showLoginFailedDialog() 
  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login Failed"),
          content: const Text("Incorrect username or password. Please try again."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
                hintText: 'https://moodle.example.com',
                border: const OutlineInputBorder(),

                // Input field background
                fillColor: colorScheme.surface,
                filled: true,
              ),
            ),
            const SizedBox(height: 32),

            // Login Button
            ElevatedButton(
              onPressed: () async {
                var wasSuccessful = await LoginScreen.controller.loginToMoodle(_usernameController.text, _passwordController.text);
                if (wasSuccessful) 
                {
                  List<Course> courses = await MainController().getCourses();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TeacherDashboard())
                  );
                } else {
                  _showLoginFailedDialog();
                }
              },
              child: const Text('Login'),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() 
  {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
