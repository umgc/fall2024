import 'package:flutter/foundation.dart';
import '../Api/moodle_api_singleton.dart';
import '../Controller/beans.dart';

class MainController 
{
  // Singleton instance
  static final MainController _instance = MainController._internal();
  // Singleton accessor
  factory MainController() 
  {
    return _instance;
  }
  // Internal constructor
  MainController._internal();
  static bool isLoggedIn = false;
  final ValueNotifier<bool> isUserLoggedInNotifier = ValueNotifier(false);
  Course? selectedCourse;


  Future<bool> loginToMoodle(String username, String password, String moodleURL) async 
  {
    var moodleApi = MoodleApiSingleton();
    try 
    {
      await moodleApi.login(username, password, moodleURL);
      isLoggedIn = true;
      return true;
    } catch (e) 
    {
      if (kDebugMode) 
      {
        print(e);
      }
      isLoggedIn = false;
      return false;
    }
  }

  void logoutFromMoodle() 
  {
    var moodleApi = MoodleApiSingleton();
    moodleApi.logout();
    isLoggedIn = false;
  }

  Future<bool> isUserLoggedIn() async 
  {
    return isLoggedIn;
  }

  bool selectCourse(int index) {
    var api = MoodleApiSingleton();
    if (index < (api.moodleCourses?.length ?? 0)){
      selectedCourse = api.moodleCourses?[index];
      return true;
    }
    return false;
  }
}
