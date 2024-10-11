import 'package:flutter/material.dart';
import '../src/utils/contact_display.dart';
import 'calendar_screen.dart';
import 'assistant_screen.dart';
import 'gallery_screen.dart';
import 'response_screen.dart';
import 'audio_screen.dart';
import 'location_history_screen.dart';
import 'tour_screen.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  Widget _currentScreen =
      const HomeScreenContentBody(); // Start with the home content

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

class HomeScreenContentBody extends StatelessWidget {
  const HomeScreenContentBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = 65;
    _HomeScreenContentState homeScreenState =
        context.findAncestorStateOfType<_HomeScreenContentState>()!;

    return Container(
      color: Colors.transparent, // Set container background to transparent
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 140, 16.0, 25),
            child: Text(
              'Helping you remember the important things.\n Choose a feature to get started!',
              style: TextStyle(
                fontSize: 16.0,
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
                  icon: Icon(Icons.search, size: iconSize, color: Colors.white),
                  text: 'Object Search',
                  screen: ResponseScreen(),
                ),
                _buildElevatedButton(
                  homeScreenState: homeScreenState,
                  icon: Icon(Icons.mic_rounded,
                      size: iconSize, color: Colors.white),
                  text: 'Record Audio',
                  screen: AudioScreen(),
                ),
                _buildElevatedButton(
                  homeScreenState: homeScreenState,
                  icon: Icon(Icons.location_history,
                      size: iconSize, color: Colors.white),
                  text: 'Location',
                  screen: LocationHistoryScreen(),
                ),
                _buildElevatedButton(
                  homeScreenState: homeScreenState,
                  icon: Icon(Icons.flag, size: iconSize, color: Colors.white),
                  text: 'Tour Guide',
                  screen: TourScreen(),
                ),
                _buildElevatedButton(
                  homeScreenState: homeScreenState,
                  icon: Icon(Icons.calendar_view_month,
                      size: iconSize, color: Colors.white),
                  text: 'Calendar',
                  screen: CalendarPage(),
                ),
                _buildElevatedButton(
                  homeScreenState: homeScreenState,
                  icon: Icon(Icons.contact_emergency,
                      size: iconSize, color: Colors.white),
                  text: 'Emergency Contacts',
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
    required _HomeScreenContentState homeScreenState,
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
