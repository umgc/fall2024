import 'package:flutter/material.dart';
import '/controller/main_controller.dart';
import '/Views/dashboard.dart';

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
          content:
              const Text("Incorrect username or password. Please try again."),
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
          if (constraints.maxWidth < 350) {
            // Small screen (less than 350px) - Switch to vertical layout
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
                        'assets/login_image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 246,
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          border: const OutlineInputBorder(),
                          fillColor: colorScheme.surface,
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 246,
                      child: TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          border: const OutlineInputBorder(),
                          fillColor: colorScheme.surface,
                          filled: true,
                        ),
                        obscureText: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 246,
                      child: TextField(
                        controller: _moodleURLController,
                        decoration: InputDecoration(
                          labelText: 'Moodle URL',
                          hintText: 'https://moodle.example.com',
                          border: const OutlineInputBorder(),
                          fillColor: colorScheme.surface,
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 246,
                      child: ElevatedButton(
                        onPressed: () async {
                          var wasSuccessful =
                              await LoginScreen.controller.loginToMoodle(
                            _usernameController.text,
                            _passwordController.text,
                            _moodleURLController.text,
                          );
                          if (wasSuccessful) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TeacherDashboard()),
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
          } else {
            // Normal screen size - Default layout (Row layout)
            return Container(
              color: colorScheme.primaryContainer,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: SizedBox(
                          height: 234,
                          width: 180, // Reduced width to avoid overflow
                          child: Image.asset(
                            'assets/login_image.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth *
                                  0.6, // Relative sizing for text fields
                              child: TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  hintText: 'Enter your username',
                                  border: const OutlineInputBorder(),
                                  fillColor: colorScheme.surface,
                                  filled: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: constraints.maxWidth *
                                  0.6, // Relative sizing for text fields
                              child: TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  border: const OutlineInputBorder(),
                                  fillColor: colorScheme.surface,
                                  filled: true,
                                ),
                                obscureText: true,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: constraints.maxWidth *
                                  0.6, // Relative sizing for text fields
                              child: TextField(
                                controller: _moodleURLController,
                                decoration: InputDecoration(
                                  labelText: 'Moodle URL',
                                  hintText: 'https://moodle.example.com',
                                  border: const OutlineInputBorder(),
                                  fillColor: colorScheme.surface,
                                  filled: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: constraints.maxWidth *
                                  0.6, // Relative sizing for buttons
                              child: ElevatedButton(
                                onPressed: () async {
                                  var wasSuccessful = await LoginScreen
                                      .controller
                                      .loginToMoodle(
                                    _usernameController.text,
                                    _passwordController.text,
                                    _moodleURLController.text,
                                  );
                                  if (wasSuccessful) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TeacherDashboard()),
                                    );
                                  } else {
                                    _showLoginFailedDialog();
                                  }
                                },
                                child: const Text('Login'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        },
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


