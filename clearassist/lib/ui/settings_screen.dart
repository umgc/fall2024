// ignore_for_file: avoid_print, prefer_const_constructors

// Author: Selam Biru
// Edited by: Ben Sutter
// Refactored for Settings Screen with matching app style

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'global_settings.dart';

class SettingsScreen extends StatefulWidget {
  void onThemeChanged(String theme) {
    String newBackgroundPath;

    if (theme == "Blue") {
      newBackgroundPath = "assets/images/background.jpg";
    } else if (theme == "Pink") {
      newBackgroundPath = "assets/images/pink_background.png";
    } else {
      newBackgroundPath = "assets/images/grey_background.jpg";
    }

    GlobalSettings.setBackgroundPath(newBackgroundPath); // Update global path
  }

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  final bool _darkModeEnabled = false;
  final String _selectedLanguage = 'English';
  bool _locationAccess = false;
  String _selectedTheme = 'Blue'; // Added to manage theme selection

  @override
  void initState() {
    super.initState();
    _listenForPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _buildSettingsCard(
              icon: Icons.notifications,
              title: 'Enable Notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),
            // const Divider(color: Colors.black54, height: 25, thickness: 2),
            // _buildSettingsCard(
            //   icon: Icons.language,
            //   title: 'Language',
            //   trailing: DropdownButton<String>(
            //     value: _selectedLanguage,
            //     dropdownColor: Colors.deepPurple,
            //     style: Theme.of(context).textTheme.bodyMedium,
            //     items: ['English', 'Spanish', 'French']
            //         .map<DropdownMenuItem<String>>(
            //             (String value) => DropdownMenuItem<String>(
            //                   value: value,
            //                   child: Text(value),
            //                 ))
            //         .toList(),
            //     onChanged: (String? newValue) {
            //       setState(() {
            //         _selectedLanguage = newValue!;
            //       });
            //     },
            //   ),
            // ),
            const Divider(color: Colors.black54, height: 25, thickness: 2),
            _buildSettingsCard(
              icon: Icons.palette,
              title: 'App Theme Color', // Theme setting added
              trailing: DropdownButton<String>(
                value: _selectedTheme,
                dropdownColor: Colors.deepPurple,
                style: Theme.of(context).textTheme.bodyMedium,
                items: ['Blue', 'Pink', 'Grey']
                    .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTheme = newValue!;
                    _applyTheme(_selectedTheme); // Apply theme change
                  });
                  setState(() {});
                },
              ),
            ),
            const Divider(color: Colors.black54, height: 25, thickness: 2),
            _buildSettingsCard(
              icon: Icons.location_on,
              title: 'Location Access',
              trailing: Switch(
                value: _locationAccess,
                onChanged: (value) {
                  setState(() {
                    _locationAccess = value;
                  });
                  _requestLocationPermission();
                },
              ),
            ),
            const Divider(color: Colors.black54, height: 25, thickness: 2),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: _showAboutDialog,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.info, size: 24, color: Colors.white),
                    SizedBox(width: 10),
                    Text('About'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
      {required IconData icon,
      required String title,
      required Widget trailing}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: trailing,
    );
  }

  void _listenForPermissionStatus() async {
    final status = await Permission.location.isGranted;
    setState(() => _locationAccess = status);
  }

  void _requestLocationPermission() async {
    if (_locationAccess) {
      await Permission.location.request();
    }
  }

  void _applyTheme(String selectedTheme) {
    widget.onThemeChanged(selectedTheme); // Pass selected theme to parent
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Can\'t Remember Things App',
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset(
        'assets/icons/app_icon.png', // Update with your app icon
        height: 50,
        width: 50,
      ),
      children: [
        Text('Help you remember all the things.'),
      ],
    );
  }
}
