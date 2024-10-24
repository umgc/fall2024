import 'package:flutter/material.dart';
import 'home_screen_content_login_main.dart';

class HomeScreenLoginMain extends StatefulWidget {
  const HomeScreenLoginMain({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenLoginMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Extend the body behind the bottom navigation bar
      extendBodyBehindAppBar: true, // Extend the body behind the app bar
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor:
            Colors.transparent, // Transparent background for the app bar
        elevation: 0, // Remove shadow
      ),
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(child: HomeScreenContentLoginMain())),
    );
  }
}
