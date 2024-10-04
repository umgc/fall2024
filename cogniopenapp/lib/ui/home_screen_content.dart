import 'package:flutter/material.dart';
import 'assistant_screen.dart';
import 'gallery_screen.dart';
import 'response_screen.dart';
import 'audio_screen.dart';
import 'location_history_screen.dart';
import 'tour_screen.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = 65;
    return Container(
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
                  context: context,
                  icon: Icon(Icons.search, size: iconSize, color: Colors.white),
                  text: 'Object Search',
                  screen: ResponseScreen(),
                ),
                _buildElevatedButton(
                  context: context,
                  icon: Icon(Icons.mic_rounded, size: iconSize, color: Colors.white),
                  text: 'Record Audio',
                  screen: AudioScreen(),
                ),
                _buildElevatedButton(
                  context: context,
                  icon: Icon(Icons.location_history, size: iconSize, color: Colors.white),
                  text: 'Location',
                  screen: LocationHistoryScreen(),
                ),
                _buildElevatedButton(
                  context: context,
                  icon: Icon(Icons.flag, size: iconSize, color: Colors.white),
                  text: 'Tour Guide',
                  screen: TourScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElevatedButton({
    required BuildContext context,
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
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
