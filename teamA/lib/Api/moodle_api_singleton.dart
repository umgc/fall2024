import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:namer_app/Controller/beans.dart';

// Singleton class for Moodle API access.
class MoodleApiSingleton 
{
  static const baseUrl = 'https://www.swen670moodle.site';
  static const serverUrl = '$baseUrl/webservice/rest/server.php?wstoken=';
  static const jsonFormat = '&moodlewsrestformat=json';
  static const errorKey = 'error';

  // The singleton instance.
  static final MoodleApiSingleton _instance = MoodleApiSingleton._internal();

  // User token is stored here.
  String? _userToken;

  // Singleton accessor.
  factory MoodleApiSingleton() {
    return _instance;
  }

  // Internal constructor.
  MoodleApiSingleton._internal();

  // Check if user has logged in (if singleton has a token).
  bool isLoggedIn() {
    return _userToken == null;
  }

  // Log in to Moodle and retrieve the user token. Throws HttpException if login failed.
  Future<void> login(String username, String password) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/login/token.php?username=$username&password=$password&service=moodle_mobile_app'
    ));
    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw HttpException(response.body);
    } else if (data.containsKey(errorKey)) {
      throw HttpException(data[errorKey]);
    }
    _userToken = data['token'];
  }

  // Log out of Moodle by deleting the stored user token.
  void logout() {
    _userToken = null;
  }

  // Get list of courses.
  Future<List<Course>> getCourses() async {
    if (_userToken == null) throw StateError('User not logged in to Moodle');

    final response = await http.get(Uri.parse(
        '$serverUrl$_userToken$jsonFormat&wsfunction=core_course_get_courses'
    ));
    if (response.statusCode != 200) {
      throw HttpException(response.body);
    }
    List<Course> courses = (jsonDecode(response.body) as List).map((i) => Course.fromJson(i)).toList();
    return courses;
  }

  // Import XML quiz into the specified course. Returns a list of IDs for newly imported questions.
  Future<void> importQuiz(String courseid, String quizXml) async {
    if (_userToken == null) throw StateError('User not logged in to Moodle');

    final http.Response response = await http.post(Uri.parse(
      '$serverUrl$_userToken$jsonFormat&wsfunction=local_quizgen_import_questions&courseid=$courseid&questionxml=$quizXml'
    ));
    if (response.statusCode != 200) {
      throw HttpException(response.body);
    }
    if (response.body.contains('error')) {
      throw HttpException(response.body);
    }
  }

  // Gets the contents of the specified course.
  Future<List> getCourseContents(int courseID) async {
    if (_userToken == null) throw StateError('User not logged in to Moodle');
    // Make the request.
    final http.Response response = await http.get(Uri.parse('$serverUrl$_userToken$jsonFormat&wsfunction=core_course_get_contents&courseid=$courseID'));
    if (response.statusCode != 200) {
      throw HttpException(response.body);
    }
    
    // Decode the JSON to get the wanted information.
    Map<String, dynamic> temp = jsonDecode(response.body) as Map<String, dynamic>;
    List results = [];
    temp.forEach((k,v) {
      if (v['modules'] != []){
        //todo method for converting from json or xml
        for (int i = 0; i < v['modules'].length; i++){
          // Collect important identifying information.
          Map<String, dynamic> module = v['modules'][i];
          // Skip modules that are not a quiz or assignment. //todo specific filter for app-created stuff
          if (module['modname'] == "quiz" || module['modname' == 'assign']){
            //todo check neccessity of an id for modules (personally think that's a 'probably')
            String name = module['name'];
            String description = '';
            if (module.containsKey('intro')){
              description = module['intro'];
            }
            if (module['modname'] == 'quiz'){
              results.insert(results.length, Quiz(name: name, description: description));
            }
            else{
              results.insert(results.length, Essay(name: name, description: description));
            }
          }
        }
      };
    });
    return results;
  }

  // Gets the contents of all courses.
  Future<List> getAllContents() async{
    // Collect all the course ids.
    List<Course> courses = await getCourses();
    List results = [];
    for (Course c in courses){
      results = results + await getCourseContents(c.id);
    }
    return results;
  }

  Future<List<Quiz>> getQuizzes(int? courseID) async {
    List contents;
    if (courseID != null){
      contents = await getCourseContents(courseID);
    }
    else{
      contents = await getAllContents();
    }
    List<Quiz> results = [];
    for (Object c in contents){
      if (c is Quiz){
        results.insert(results.length, c);
      }
    }
    return results;
  }
}