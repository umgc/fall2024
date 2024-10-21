import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '/controller/model/beans.dart';

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
        await http.post(Uri.parse(baseURL + serverUrl), body: {
      'wstoken': _userToken,
      'wsfunction': 'core_webservice_get_site_info',
      'moodlewsrestformat': 'json',
    });
    if (userinforesponse.statusCode != 200) {
      throw HttpException(userinforesponse.body);
    }
    moodleCourses = await getCourses();
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

  // ********************************************************************************************************************
  // Get list of courses the user is enrolled in.
  // ********************************************************************************************************************

  Future<List<Course>> getCourses() async {
    if (_userToken == null) throw StateError('User not logged in to Moodle');
    // var moodleURL = MoodleApiSingleton().moodleURL;
    final response = await http.post(
        Uri.parse(moodleURL + serverUrl
            // '$moodleURL$serverUrl$_userToken$jsonFormat&wsfunction=core_course_get_enrolled_courses_by_timeline_classification&classification=inprogress'
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

  Future<List<Assignment>> getAssignments(int? courseID) async {
    if (_userToken == null) throw StateError('User not logged in to Moodle');

    // URL of the Moodle server
    final response = await http.post(Uri.parse(moodleURL + serverUrl), body: {
      'wstoken': _userToken,
      'wsfunction': 'mod_assign_get_assignments',
      'moodlewsrestformat': 'json',
    });

    if (response.statusCode != 200) {
      throw HttpException(response.body);
    }

    List<dynamic>? decodedJson = (jsonDecode(response.body) as Map<String,dynamic>)['courses'];
    if (decodedJson == null){
      return [];
    }

    List<Assignment> results = [];
    for (int i = 0; i < decodedJson.length; i++){
      if (courseID == null || decodedJson[i]['id'] == courseID){
        for (Map<String,dynamic> a in decodedJson[i]['assignments']){
          results.insert(results.length, Assignment.fromJson(a));
        }
      }
    }
    return results;
  }

    Future<bool> setRubricGrades(int assignmentId, int userId, String jsonGrades) async {
    if (_userToken == null) throw StateError('User not logged in to Moodle');
    try {
      final response = await http.post(
        Uri.parse(moodleURL + serverUrl),
        body: {
          'wstoken': _userToken,
          'wsfunction': 'local_learninglens_write_rubric_grades',
          'moodlewsrestformat': 'json',
          'assignmentid': assignmentId.toString(),
          'userid': userId.toString(),
          'rubricgrades': jsonGrades,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to load grades. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      print('Error fetching grades: $e');
      print('StackTrace: $stackTrace');
      return false;
    }
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

  Future<String> addRandomQuestions(
      String categoryid, String quizid, String numquestions) async {
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

  Future<Map<String, dynamic>?> importQuizQuestions(
      String courseid, String quizXml) async {
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

  Future<List<Quiz>> getQuizzes(int? courseID) async {
    if (_userToken == null) throw StateError('User not logged in to Moodle');

    // URL of the Moodle server
    final response = await http.post(Uri.parse(moodleURL + serverUrl), body: {
      'wstoken': _userToken,
      'wsfunction': 'mod_quiz_get_quizzes_by_courses',
      'moodlewsrestformat': 'json',
    });

    if (response.statusCode != 200) {
      throw HttpException(response.body);
    }

    List<dynamic>? decodedJson = (jsonDecode(response.body) as Map<String,dynamic>)['quizzes'];
    print(decodedJson);
    if (decodedJson == null){
      return [];
    }

    List<Quiz> results = [];
    for (int i = 0; i < decodedJson.length; i++){
      if (courseID == null || decodedJson[i]['course'] == courseID){
        results.insert(results.length, Quiz(name: decodedJson[i]['name'],description: decodedJson[i]['intro'],id: decodedJson[i]['id']));
      }
    }
    return results;
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
