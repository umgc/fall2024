import 'package:clearassistapp/ui/registration_screen_cargiver.dart';
import 'package:flutter/material.dart';
import '../src/utils/contact_display.dart';
import 'calendar_screen.dart';
import 'assistant_screen.dart';
import 'gallery_screen.dart';
import 'audio_screen.dart';
import 'location_history_screen.dart';
import 'tour_screen.dart';
import 'registration_screen.dart';

class HomeScreenContentNewUser extends StatefulWidget {
  const HomeScreenContentNewUser({Key? key}) : super(key: key);

  @override
  _HomeScreenContentUserState createState() => _HomeScreenContentUserState();
}

class _HomeScreenContentUserState extends State<HomeScreenContentNewUser> {
  Widget _currentScreen =
      const HomeScreenContentNewUserBody(); // Start with the home content

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Set scaffold background to transparent
      body: _currentScreen,
    );
  }

  // Function to change the current screen
  void _setCurrentScreen(Widget screen) {
    setState(() {
      _currentScreen = screen;
    });
  }
}

class HomeScreenContentNewUserBody extends StatelessWidget {
  const HomeScreenContentNewUserBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = 65;
    _HomeScreenContentUserState homeScreenState =
        context.findAncestorStateOfType<_HomeScreenContentUserState>()!;

    return Container(
      color: Colors.transparent, // Set container background to transparent
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 140, 16.0, 25),
            child: Text(
              'Are you a Primary User or a Care Giver',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 1.30,
              padding: const EdgeInsets.all(26.0),
              children: [
                _buildElevatedButton(
                  homeScreenState: homeScreenState,
                  icon: Icon(Icons.person_2_sharp,
                      size: iconSize, color: Colors.white),
                  text: 'Primary User',
                  screen: RegistrationScreen(),
                ),
                _buildElevatedButton(
                  homeScreenState: homeScreenState,
                  icon: Icon(Icons.person_3_sharp,
                      size: iconSize, color: Colors.white),
                  text: 'Care Giver',
                  screen: RegistrationScreenCareGiver(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElevatedButton({
    required _HomeScreenContentUserState homeScreenState,
    required Icon icon,
    required String text,
    required Widget screen,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.transparent.withAlpha(75),
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        homeScreenState._setCurrentScreen(screen);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: 10.0),
          Text(
            text,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
