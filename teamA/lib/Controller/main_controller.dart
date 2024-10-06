import 'package:flutter/foundation.dart';
import '../Api/moodle_api_singleton.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/Controller/beans.dart';

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
  List<Course> courses = [];
  Course? selectedCourse;
  List<Quiz>? quizzes;
  List<Essay>? essays;

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

  Future<List<Course>> getCourses() async 
  {
    if (courses != []){
      return courses;
    }
    var moodleApi = MoodleApiSingleton();
    try {
      courses = await moodleApi.getCourses();
      if (courses.isNotEmpty) {
        courses.removeAt(
            0); // first course is always "Moodle" - no need to show it
      }
      return courses;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return [];
    }
  }

  Future<bool> isUserLoggedIn() async 
  {
    return isLoggedIn;
  }

  void selectCourse(int index){
    if (index < courses.length){
      selectedCourse = courses[index];
    }
  }

  Course? getSelectedCourse(){
    return selectedCourse;
  }

  List<Quiz>? getQuizzes(){
    return quizzes;
  }

  List<Essay>? getEssays(){
    return essays;
  }
}
