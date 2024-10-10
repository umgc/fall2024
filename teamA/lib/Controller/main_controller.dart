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

  Future<bool> updateCourses() async 
  {
    var moodleApi = MoodleApiSingleton();
    try {
      // courses = await moodleApi.getCourses();
      courses = await moodleApi.getUserCourses();
      if (courses.isNotEmpty) {
        courses.removeAt(
            0); // first course is always "Moodle" - no need to show it
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      courses = [];
      return false;
    }
  }

  Future<bool> isUserLoggedIn() async 
  {
    return isLoggedIn;
  }

  Future<bool> selectCourse(int index) async{
    if (index < courses.length){
      selectedCourse = courses[index];
    }
    setQuizzes();
    setEssays();
    return true;
  }

  Course? getSelectedCourse(){
    return selectedCourse;
  }

  void setQuizzes() async{
    quizzes = await MoodleApiSingleton().getQuizzes(selectedCourse?.id);
  }

  void setEssays() async{
    essays = await MoodleApiSingleton().getEssays(selectedCourse?.id);
  }
}
