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
    );
  }
}

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

            // Forgot Password Link
            TextButton(
              onPressed: () {
                // Add logic to handle password recovery if needed
                print('Forgot Password clicked');
              },
              child: Text(
                'Forgot your Password?',
                style: TextStyle(
                    color: colorScheme
                        // Link text color based on onPrimaryContainer
                        .onPrimaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
