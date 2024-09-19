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
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor:
            Colors.blue, // Set the scaffold background color
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue, // Set the AppBar background color
        ),
      ),
      debugShowCheckedModeBanner: false, // This disables the debug banner
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Title section (optional)
        //title: Text('Learning Lens'),
        backgroundColor:
            Colors.blue, // Ensures AppBar has the same color as the body
      ),
      body: Container(
        color: Colors.blue, // Set background color to blue
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
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // Instruction Section
            Text(
              'Please, enter your username and password below and click Login, to access the Dashboard.',
              style: TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),

            // Username Input
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Password Input
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),

            // Moodle URL (optional if needed)
            TextField(
              decoration: InputDecoration(
                labelText: 'Moodle URL',
                hintText: 'https://moodle.example.com',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),

            // Login Button
            ElevatedButton(
              onPressed: () {
                // Add logic to handle login if needed
                print('Login button pressed');
              },
              child: Text('Login'),
            ),

            SizedBox(height: 16),

            // Forgot Password Link
            TextButton(
              onPressed: () {
                // Add logic to handle password recovery if needed
                print('Forgot Password clicked');
              },
              child: Text(
                'Forgot your Password?',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
