import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '/Controller/beans.dart';

// Singleton class for Moodle API access.
class MoodleApiSingleton {
  // Constants for Moodle API.
  static const serverUrl = '/webservice/rest/server.php';
  static const jsonFormat = '&moodlewsrestformat=json';
  static const errorKey = 'error';

  // The singleton instance.
  static final MoodleApiSingleton _instance = MoodleApiSingleton._internal();

  // User token is stored here.
  String? _userToken;
  // User info
  String moodleURL = '';
  String? moodleUserName;
  String? moodleFirstName;
  String? moodleLastName;
  String? moodleSiteName;
  String? moodleFullName;
  String? moodleProfileImage;
  List<Course>? moodleCourses;

  // Singleton accessor.
  factory MoodleApiSingleton() {
    return _instance;
  }

  // Internal constructor.
  MoodleApiSingleton._internal();

  // Check if user has logged in (if singleton has a token).
  bool isLoggedIn() {
    return _userToken != null;
  }

  // Log in to Moodle and retrieve the user token. Throws HttpException if login failed.
  Future<void> login(String username, String password, String baseURL) async {
    final response = await http.get(Uri.parse(
        '$baseURL/login/token.php?username=$username&password=$password&service=moodle_mobile_app'));
    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw HttpException(response.body);
    } else if (data.containsKey(errorKey)) {
      throw HttpException(data[errorKey]);
    }
    _userToken = data['token'];
    moodleURL = baseURL;

    //get user info
    final userinforesponse =
        await http.post(Uri.parse(baseURL + serverUrl), 
        body: {
      'wstoken': _userToken,
      'wsfunction': 'core_webservice_get_site_info',
      'moodlewsrestformat': 'json',
    });
    if (userinforesponse.statusCode != 200) {
      throw HttpException(userinforesponse.body);
    }
    moodleCourses = await getUserCourses();
    Map<String, dynamic> userData = jsonDecode(userinforesponse.body);
    moodleUserName = userData['username'];
    moodleFirstName = userData['firstname'];
    moodleLastName = userData['lastname'];
    moodleSiteName = userData['sitename'];
    moodleFullName = userData['fullname'];
    moodleProfileImage = userData['userpictureurl'];
    
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
              // results.insert(results.length, Essay(name: name, description: description));
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

  // ********************************************************************************************************************
  // Get list of courses the user is enrolled in.
  // ********************************************************************************************************************

  Future<List<Course>> getUserCourses() async {
    if (_userToken == null) throw StateError('User not logged in to Moodle');
    // var moodleURL = MoodleApiSingleton().moodleURL;
    final response = await http.post(
        Uri.parse(moodleURL + serverUrl
            ),
        body: {
          'wstoken': _userToken,
          'wsfunction':
              'core_course_get_enrolled_courses_by_timeline_classification',
          'classification': 'inprogress',
          'moodlewsrestformat': 'json',
        });
    if (response.statusCode != 200) {
      throw HttpException(response.body);
    }

    var decodedJson = jsonDecode(response.body);
    // Check if the response is a list or a map containing a list
    List<Course> courses;
    if (decodedJson is List) {
      // If the response is directly a list
      courses = decodedJson.map((i) => Course.fromJson(i)).toList();
    } else if (decodedJson is Map<String, dynamic>) {
      // If the response is a map containing a list of courses
      var courseList = decodedJson['courses'] as List<dynamic>;
      courses = courseList.map((i) => Course.fromJson(i)).toList();
    } else {
      throw StateError('Unexpected response format');
    }
    return courses;
  }

  // ********************************************************************************************************************
  // Get list of assignments for a course. Throws HttpException if request fails.
  // ********************************************************************************************************************

  Future<List> getRubric(String assignmentid) async {
    if (_userToken == null) throw StateError('User not logged in to Moodle');
    final response = await http.post(
      Uri.parse(moodleURL + serverUrl),
      body: {
        'wstoken': _userToken,
        'wsfunction': 'local_learninglens_get_rubric',
        'moodlewsrestformat': 'json',
        'assignmentid': assignmentid,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      print('Response: $responseData');
      return responseData;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return [];
    }
  }

  // ********************************************************************************************************************
  // Add random questions to the specified quiz using learninglens plugin.
  // ********************************************************************************************************************

  Future<String> addRandomQuestions(String categoryid, String quizid, String numquestions) async {
    if (_userToken == null) throw StateError('User not logged in to Moodle');
    final response = await http.post(
      Uri.parse(moodleURL + serverUrl),
      body: {
        'wstoken': _userToken,
        'wsfunction': 'local_learninglens_add_type_randoms_to_quiz',
        'moodlewsrestformat': 'json',
        'categoryid': categoryid,
        'quizid': quizid,
        'numquestions': numquestions,
      },
    );
    if (response.statusCode == 200) {
      try {
        if (response.body == 'true' || response.body == 'false') {
          final String responseData = (response.body == 'true').toString();
          print('Boolean Response: $responseData');
          return responseData;
        } else {
          // If it's not a boolean, assume it's JSON
          final Map<String, dynamic> responseData = json.decode(response.body);
          print('Response: $responseData');
          return responseData['status'];
        }
      } catch (e) {
        print('Error parsing response: $e');
        return e.toString();
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return 'Request failed with status: ${response.statusCode}.';
    }
  }

  // ********************************************************************************************************************
  // Import XML quiz questions into the specified course using learninglens plugin.
  // ******************************************************************************************************************** 

  Future<Map<String, dynamic>?> importQuizQuestions(String courseid, String quizXml) async {
    if (_userToken == null) throw StateError('User not logged in to Moodle');
    try {
      final response = await http.post(
        Uri.parse(moodleURL + serverUrl),
        body: {
          'wstoken': _userToken,
          'wsfunction': 'local_learninglens_import_questions',
          'moodlewsrestformat': 'json',
          'courseid': courseid,
          'questionxml': quizXml,
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Response: $responseData');
        return responseData;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // ********************************************************************************************************************
  // Create a new quiz in the specified course using learninglens plugin.
  // ********************************************************************************************************************

  Future<Map<String, dynamic>?> createQuiz(
      String courseid, String quizname, String quizintro) async {
    if (_userToken == null) throw StateError('User not logged in to Moodle');
    // const String url = 'webservice/rest/server.php';
    try {
      final response = await http.post(
        Uri.parse(moodleURL + serverUrl),
        body: {
          'wstoken': _userToken,
          'wsfunction': 'local_learninglens_create_quiz',
          'moodlewsrestformat': 'json',
          'courseid': courseid,
          'name': quizname,
          'intro': quizintro,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Response: $responseData');
        return responseData;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  // ********************************************************************************************************************
  // Create a new assignment with optional rubric JSON in the specified course using learninglens plugin.
  // ********************************************************************************************************************

  Future<Map<String, dynamic>?> createAssignnment(
      String courseid,
      String sectionid,
      String assignmentName,
      String startdate,
      String enddate,
      String rubricJson,
      String description) async {
    if (_userToken == null) throw StateError('User not logged in to Moodle');
    try {
      final response = await http.post(
        Uri.parse(moodleURL + serverUrl),
        body: {
          'wstoken': _userToken,
          'wsfunction': 'local_learninglens_create_assignment',
          'moodlewsrestformat': 'json',
          'courseid': courseid,
          'sectionid': sectionid,
          'assignmentName': assignmentName,
          'startdate': startdate,
          'enddate': enddate,
          'rubricJson': rubricJson,
          'description': description,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Response: $responseData');
        return responseData;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return null;
      }
    } catch (e) {
      print('Error occurred');
      return null;
    }
  }
}
