import 'package:flutter/material.dart';
import 'package:learninglens_app/main.dart';
import '/controller/main_controller.dart';
import '../Views/dashboard.dart';

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning Lens Login',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple.shade200,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static MainController controller = MainController();

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _moodleURLController = TextEditingController();

  void _showLoginFailedDialog() {
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
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Learning Lens Application!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please, enter your username and password below and click Login to access the Dashboard.',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 200,
                    width: 210,
                    child: Image.asset(
                      'Assets/login_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: _usernameController,
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      colorScheme: colorScheme),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      obscureText: true,
                      colorScheme: colorScheme),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: _moodleURLController,
                      labelText: 'Moodle URL',
                      hintText: 'https://moodle.example.com',
                      colorScheme: colorScheme),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 246,
                    child: ElevatedButton(
                      onPressed: () async {
                        var wasSuccessful = await LoginScreen.controller.loginToMoodle(
                          _usernameController.text,
                          _passwordController.text,
                          _moodleURLController.text,
                        );
                        if (wasSuccessful) {
                          Navigator.push(
                            context,
                            //MaterialPageRoute(builder: (context) => TeacherDashboard()),
                            MaterialPageRoute(builder: (context) => DevLaunch())
                          );
                        } else {
                          _showLoginFailedDialog();
                        }
                      },
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to build TextFields to avoid repetition
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required ColorScheme colorScheme,
    bool obscureText = false,
  }) {
    return SizedBox(
      width: 246,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: const OutlineInputBorder(),
          fillColor: colorScheme.surface,
          filled: true,
        ),
        obscureText: obscureText,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
