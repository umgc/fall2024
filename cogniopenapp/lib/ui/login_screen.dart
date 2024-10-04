// ignore_for_file: avoid_print, prefer_const_constructors

/*
Author: Eyerusalme (Jerry)
*/
import 'package:cogniopenapp/src/utils/permission_manager.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'registration_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Authentication instance removed

  @override
  Widget build(BuildContext context) {
    PermissionManager.checkIfLocationServiceIsActive(
        context); // Check to ensure location is enabled for tracking and media enhancement
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/icons/app_icon.png',
                          height: 80, width: 80),
                      const SizedBox(height: 20),
                      Text(
                        "ClearMind",
                        style: TextStyle(
                          color: Colors.blueGrey[900],
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Have an account? ',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            )),
                        Icon(Icons.vpn_key,
                            color: Colors.blueGrey[800], size: 22.0),
                        Text('  Log in Here',
                            style: TextStyle(
                                color: Colors.blueGrey[800], fontSize: 16)),
                      ],
                    ),
                  ),
                  SizedBox(height: 35),
                  Text(
                    "New here? We're glad to have you! \n \n Come along with us as we prioritize memory care and cognitive health.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey[600],
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegistrationScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 40, 121, 158)),
                    child: Text(
                      'Create Account',
                      selectionColor: Colors.black38,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text(
                      'HomeScreen(Test)',
                      selectionColor: Colors.black87,
                    ), // This is for testing purpose
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
