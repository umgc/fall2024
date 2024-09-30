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

  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Login'),
      backgroundColor: Colors.deepPurple[200],
      leading: const Icon(Icons.computer_outlined),
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10), // Adjusted padding for better layout
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center row contents
        children: <Widget>[
          // Image on the left
          const Image(
            image: NetworkImage(
                'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?q=80&w=2922&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
            width: 400,
            height: 500,
          ),
          const SizedBox(width: 100), // Add some space between the image and the form
          // Login form on the right
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center form contents vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Align fields to the left
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey, // Border color
                                width: 1, // Border width
                              ),
                              borderRadius:
                                  BorderRadius.circular(10), // Circular border
                            ),//look here
                            padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                  'Welcome to EvaluAI!',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Please enter your Moodle credentials.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
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
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    } else {
                      _showLoginFailedDialog();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.deepPurple[200]), // Change button color
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                  child: const Text('Proceed without Moodle'),
                ),
                      ],
                    ),        
                ),//look here
              ],
            ),
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
