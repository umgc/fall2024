import 'package:flutter/material.dart';
import 'package:intelligrade/controller/main_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static MainController controller = MainController();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.deepPurple[200],
        leading: Icon(Icons.computer_outlined),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 500, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?q=80&w=2922&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                    width: 400,
                    height: 400,
              ),
            Text(
              'Welcome to EvaluAI!',
              style: TextStyle(
                fontSize: 24
              )
            ),
            const SizedBox(height: 40.0),
            Text(
              'Please enter your Moodle credentials.'
            ),
            const SizedBox(height: 26.0),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                var wasSuccessful = await LoginPage.controller.loginToMoodle(
                  _usernameController.text,
                  _passwordController.text,
                );
                if (wasSuccessful) {
                  Navigator.pushReplacementNamed(context, '/viewExams');
                } else {
                  _showLoginFailedDialog();
                }
              },
              child: const Text('Login'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.deepPurple[200]),
                ),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/viewExams');
              },
              child: const Text('Proceed without Moodle'),
            ),
          ],
        ),
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
