// ignore_for_file: avoid_print, prefer_const_constructors

/*
Author: Eyerusalme (Jerry)
*/
import 'package:clearassistapp/src/utils/permission_manager.dart';
import 'package:clearassistapp/ui/home_screen_new_user.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
//import 'registration_screen.dart';
import 'home_screen.dart';
//import 'home_screen_content-new-user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _authenticateWithAllMethods() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
      );

      if (didAuthenticate) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed!')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

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
              color: const Color.fromARGB(255, 240, 240, 240),
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
                  // Logo and App Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/app_icon.png',
                        height: 90,
                        width: 90,
                        color: Colors.indigo[900],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "ClearAssist",
                        style: TextStyle(
                          color: Colors.indigo[900],
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  Text(
                    "Welcome! \n We're glad to have you!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Come along with us as we prioritize memory care and cognitive health.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 40),
                  GestureDetector(
                    onTap: _authenticateWithAllMethods,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(225, 26, 34, 126),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Have an account? ',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              )),
                          Icon(Icons.vpn_key, color: Colors.white, size: 22.0),
                          Text('  Log in Here',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeScreenNewUser()),
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(225, 26, 34, 126),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('New Here? ',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              )),
                          Icon(Icons.add_reaction_rounded,
                              color: Colors.white, size: 22.0),
                          Text('  Create an Account',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),

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
                      style: TextStyle(color: Colors.indigo[900]),
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
