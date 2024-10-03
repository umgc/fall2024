import 'package:cogniopenapp/src/database/model/media_type.dart';
import 'package:cogniopenapp/src/utils/permission_manager.dart';
import 'package:cogniopenapp/ui/assistant_screen.dart';
import 'package:cogniopenapp/ui/home_screen.dart';
import 'package:cogniopenapp/ui/settings_screen.dart';
import 'package:cogniopenapp/ui/significant_objects_screen.dart';
import 'package:cogniopenapp/ui/video_screen.dart';
import 'package:flutter/material.dart';

class UiUtils {
  static IconData getMediaIconData(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.audio:
        return Icons.chat;
      case MediaType.photo:
        return Icons.photo;
      case MediaType.video:
        return Icons.video_camera_back;
      default:
        throw Exception('Unsupported media type: $mediaType');
    }
  }

  static BottomNavigationBar createBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
        elevation: 0.0,
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Color(0x00ffffff),
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
            label: 'Virtual Assistant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_camera_back),
            label: 'Video',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (int index) {
          // Handle navigation bar item taps
          if (index == 0) {
            // Navigate to Gallery screen
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          } else if (index == 1) {
            // Navigate to Search screen
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AssistantScreen()));
          } else if (index == 2) {
            if (PermissionManager.attemptToShowVideoScreen(context)) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VideoScreen()),
              );
            }
          } else if (index == 3) {
            // Navigate to Gallery screen
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsScreen()));
          }
        });
  }
}
