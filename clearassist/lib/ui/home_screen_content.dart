import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ui/audio_screen.dart';
import '../ui/calendar_screen.dart';
import '../src/utils/sos_permissions.dart'; // Updated SOS permissions utility
import '../ui/emergency_contacts_screen.dart';

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

  // Method to change the displayed screen
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
                  destinationScreen: SelectEmergencyContactsScreen(),
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

  // Helper method to create a feature button
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

  // Create the SOS button with permission checks and confirmation dialog.
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
      onPressed: () async {
        bool permissionsGranted = await checkAndRequestPermissions(context);
        if (!permissionsGranted) return;

        bool confirmed = await _showSosConfirmationDialog(context);
        if (confirmed) {
          await _sendSosMessage(context);
        }
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

  // Shows a confirmation dialog before initiating the SOS action.
  Future<bool> _showSosConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Confirm SOS Activation',
                style: TextStyle(color: Colors.black),
              ),
              content: const Text(
                'Are you sure you want to send an SOS message?',
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Send SOS',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Sends the SOS message and provides feedback to the user.
  Future<void> _sendSosMessage(BuildContext context) async {
    try {
      await sendSosSms(
          context); // Initiate the SOS functionality from sos_permissions.dart.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("SOS message sent successfully!")),
      );
    } catch (e) {
      print("Error sending SOS message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send SOS message.")),
      );
    }
  }
}
