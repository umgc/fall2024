import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettings {
  static final ValueNotifier<String> backgroundPath = ValueNotifier<String>(
    "assets/images/background.jpg",
  );

  static Future<void> loadBackgroundPath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPath = prefs.getString('backgroundPath');
    if (savedPath != null) {
      backgroundPath.value = savedPath;
    }
  }

  static Future<void> setBackgroundPath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('backgroundPath', path);
    backgroundPath.value = path;
  }
}
