import 'package:flutter/material.dart';
import '../src/utils/contact_display.dart';
import 'calendar_screen.dart';

class HomeScreenContentCaregiver extends StatefulWidget {
  const HomeScreenContentCaregiver({super.key});

  @override
  _HomeScreenContentCareGiverState createState() =>
      _HomeScreenContentCareGiverState();
}

class _HomeScreenContentCareGiverState
    extends State<HomeScreenContentCaregiver> {
  Widget _currentScreen =
      const HomeScreenContentCaregiverBody(); // Start with the home content

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

class HomeScreenContentCaregiverBody extends StatelessWidget {
  const HomeScreenContentCaregiverBody({super.key});

  @override
  Widget build(BuildContext context) {
    double iconSize = 65;
    _HomeScreenContentCareGiverState homeScreenState =
        context.findAncestorStateOfType<_HomeScreenContentCareGiverState>()!;

    return Container(
      color: Colors.transparent, // Set container background to transparent
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 140, 16.0, 25),
            child: Text(
              'Empowering you to assist with memory needs. Pick a feature to continue!',
              style: TextStyle(
                fontSize: 22.0,
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
                  icon: Icon(Icons.calendar_view_month,
                      size: iconSize, color: Colors.white),
                  text: 'Calendar',
                  screen: CalendarPage(),
                ),
                _buildElevatedButton(
                  homeScreenState: homeScreenState,
                  icon: Icon(Icons.analytics,
                      size: iconSize, color: Colors.white),
                  text: 'Analytics',
                  screen: ContactDisplay(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElevatedButton({
    required _HomeScreenContentCareGiverState homeScreenState,
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
