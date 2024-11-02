// home_view.dart
import 'package:flutter/material.dart';
import '../src/utils/contact_display.dart';
import 'calendar_screen.dart';
import 'audio_screen.dart';
import '../src/utils/sos_permissions.dart'; // Import SOS permissions utility

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  Widget _currentScreen = const HomeScreenContentBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _currentScreen,
    );
  }

  // Method to change the current screen
  void _setCurrentScreen(Widget screen) {
    setState(() {
      _currentScreen = screen;
    });
  }
}

class HomeScreenContentBody extends StatelessWidget {
  const HomeScreenContentBody({super.key});

  @override
  Widget build(BuildContext context) {
    final homeScreenState =
        context.findAncestorStateOfType<_HomeScreenContentState>()!;
    const iconSize = 65.0;

    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 140, 16.0, 25),
            child: Text(
              'Helping you remember the important things.\nChoose a feature to get started!',
              style: TextStyle(fontSize: 22.0, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 1.3,
              padding: const EdgeInsets.all(26.0),
              children: [
                _buildFeatureButton(
                  context: context,
                  homeScreenState: homeScreenState,
                  icon: Icons.mic_rounded,
                  label: 'Record Audio',
                  destinationScreen: const AudioScreen(),
                  iconSize: iconSize,
                ),
                _buildFeatureButton(
                  context: context,
                  homeScreenState: homeScreenState,
                  icon: Icons.book,
                  label: 'History',
                  destinationScreen: const HomeScreenContent(),
                  iconSize: iconSize,
                ),
                _buildFeatureButton(
                  context: context,
                  homeScreenState: homeScreenState,
                  icon: Icons.calendar_view_month,
                  label: 'Calendar',
                  destinationScreen: const CalendarPage(),
                  iconSize: iconSize,
                ),
                _buildFeatureButton(
                  context: context,
                  homeScreenState: homeScreenState,
                  icon: Icons.contact_emergency,
                  label: 'Emergency Contacts',
                  destinationScreen: const ContactDisplay(),
                  iconSize: iconSize,
                ),
                _buildSosButton(
                  context: context,
                  homeScreenState: homeScreenState,
                  iconSize: iconSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a feature button
  Widget _buildFeatureButton({
    required BuildContext context,
    required _HomeScreenContentState homeScreenState,
    required IconData icon,
    required String label,
    required Widget destinationScreen,
    required double iconSize,
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
        homeScreenState._setCurrentScreen(destinationScreen);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: Colors.white),
          const SizedBox(height: 10.0),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Helper method to build the SOS button
  Widget _buildSosButton({
    required BuildContext context,
    required _HomeScreenContentState homeScreenState,
    required double iconSize,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.red.withAlpha(200),
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        sendSosSms(context); // Calls the SOS function from sos_permissions.dart
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_rounded, size: iconSize, color: Colors.white),
          const SizedBox(height: 10.0),
          const Text(
            'SOS',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
