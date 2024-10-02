import 'dart:convert';
import 'package:http/http.dart' as http;

const String moodleURL = 'http://localhost/moodle/';//replace with your moodle site


Future<String> loginAndGetToken(String username, String password) async {
  // const String loginUrl = 'https://www.swen670moodle.site/login/token.php';
  const String loginUrl = 'login/token.php';
  final response = await http.post(Uri.parse(
      '$moodleURL$loginUrl?username=$username&password=$password&service=moodle_mobile_app'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData.containsKey('token')) {
      return responseData['token'];
    } else {
      throw Exception('Failed to retrieve token: ${responseData['error']}');
    }
  } else {
    throw Exception('Login failed with status: ${response.statusCode}');
  }
}

void main() async {
  const String username = 'user'; // Replace with actual username
  const String password = 'password'; // Replace with actual password

  try {
    // Log in and retrieve the token
    final String token = await loginAndGetToken(username, password);
    print('Retrieved token: $token');

    // await getRubric(token);
    // await fetchGrades(16, token); //BROKEN; expects a an array list of assignmentIDs

    // myXML is sample quiz questions in XML format for import
    String myXML = '''
<?xml version="1.0" encoding="UTF-8"?>
<quiz>

  <!-- Define the category for the questions -->
  <question type="category">
    <category>
      <text>\$course\$/top/Downtown Quiz Category</text>
    </category>
  </question>

  <!-- Multiple Choice Question -->
  <question type="multichoice">
    <name>
      <text>Multiple Choice Question</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[What is the capital of France?]]></text>
    </questiontext>
    <answer fraction="100">
      <text>Paris</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>London</text>
      <feedback>
        <text>Incorrect.</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>Rome</text>
      <feedback>
        <text>Incorrect.</text>
      </feedback>
    </answer>
    <answer fraction="0">
      <text>Berlin</text>
      <feedback>
        <text>Incorrect.</text>
      </feedback>
    </answer>
  </question>

  <!-- True/False Question -->
  <question type="truefalse">
    <name>
      <text>True/False Question</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[The Earth is flat.]]></text>
    </questiontext>
    <answer fraction="0">
      <text>true</text>
      <feedback>
        <text>Incorrect.</text>
      </feedback>
    </answer>
    <answer fraction="100">
      <text>false</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
  </question>

  <!-- Short Answer Question -->
  <question type="shortanswer">
    <name>
      <text>Short Answer Question</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[What is the chemical symbol for water?]]></text>
    </questiontext>
    <answer fraction="100">
      <text>H2O</text>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
  </question>

  <!-- Matching Question -->
  <question type="matching">
    <name>
      <text>Matching Question</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[Match the countries to their capitals.]]></text>
    </questiontext>
    <subquestion format="html">
      <text><![CDATA[France]]></text>
      <answer>
        <text>Paris</text>
      </answer>
    </subquestion>
    <subquestion format="html">
      <text><![CDATA[Italy]]></text>
      <answer>
        <text>Rome</text>
      </answer>
    </subquestion>
  </question>

  <!-- Essay Question -->
  <question type="essay">
    <name>
      <text>Essay Question</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[Describe the impact of climate change on global weather patterns.]]></text>
    </questiontext>
    <graderinfo format="html">
      <text><![CDATA[Grading instructions for this question.]]></text>
    </graderinfo>
  </question>

  <!-- Numerical Question -->
  <question type="numerical">
    <name>
      <text>Numerical Question</text>
    </name>
    <questiontext format="html">
      <text><![CDATA[What is the square root of 64?]]></text>
    </questiontext>
    <answer fraction="100">
      <text>8</text>
      <tolerance>0</tolerance>
      <feedback>
        <text>Correct!</text>
      </feedback>
    </answer>
  </question>

</quiz>
''';
    //Import questions, create a quiz, and add random questions using that newly created quiz id and question category id
    //Make sure your question xml category matches the name of hte quiz to stay wihtin that question bank category
    Map<String, dynamic>? quizQuestions =
        await importQuizQuestions(token, '2', myXML);
    Map<String, dynamic>? quizData = await createQuiz(
        token,
        '2',
        'Downtown Quiz',
        'This is a quiz about downtown'); //match xml quiz category name
    await addRandomQuestions(token, quizQuestions!['categoryid'].toString(),
        quizData!['quizid'].toString(), '5');

    // await deleteQuiz(token);

    //rebricDefinition is sample rubric definition in JSON format for the create assignment method
    String rubricDefinition = '''
{
    "criteria": [
        {
            "description": "Content",
            "levels": [
                { "definition": "Excellent", "score": 5 },
                { "definition": "Good", "score": 3 },
                { "definition": "Poor", "score": 1 }
            ]
        },
        {
            "description": "Clarity",
            "levels": [
                { "definition": "Very Clear", "score": 5 },
                { "definition": "Somewhat Clear", "score": 3 },
                { "definition": "Unclear", "score": 1 }
            ]
        }
    ]
}
''';
    createAssignnment(token, '2', '1', 'Bojangles Assignment', '2022-12-01',
        '2022-12-31', rubricDefinition, 'This is a Bojangles assignment');

  } catch (e) {
    print('Error: $e');
  }
}

Future<void> getRubric(String token, String assignmentid) async {
  // const String url = 'https://www.swen670moodle.site/webservice/rest/server.php';
  const String url = 'webservice/rest/server.php';
  final response = await http.post(
    Uri.parse(moodleURL + url),
    body: {
      'wstoken': token,
      'wsfunction': 'local_learninglens_get_rubric',
      'moodlewsrestformat': 'json',
      'assignmentid': assignmentid,
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> responseData = json.decode(response.body);
    print('Response: $responseData');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}

Future<void> addRandomQuestions(
    String token, String categoryid, String quizid, String numquestions) async {
  // const String url = 'https://www.swen670moodle.site/webservice/rest/server.php';
  const String url = 'webservice/rest/server.php';
  final response = await http.post(
    Uri.parse(moodleURL + url),
    body: {
      'wstoken': token,
      'wsfunction': 'local_learninglens_add_type_randoms_to_quiz',
      'moodlewsrestformat': 'json',
      'categoryid': categoryid,
      'quizid': quizid,
      'numquestions': numquestions,
    },
  );

  if (response.statusCode == 200) {
    // Attempt to decode the response body
    try {
      // Check if the response is a boolean
      if (response.body == 'true' || response.body == 'false') {
        final bool responseData = response.body == 'true';
        print('Boolean Response: $responseData');
      } else {
        // If it's not a boolean, assume it's JSON
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Response: $responseData');
      }
    } catch (e) {
      // Handle any decoding errors
      print('Error parsing response: $e');
    }
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}

Future<Map<String, dynamic>?> importQuizQuestions(
    String token, String courseid, String quizXml) async {
  const String url = 'webservice/rest/server.php';
  try {
    final response = await http.post(
      Uri.parse(moodleURL + url),
      body: {
        'wstoken': token,
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

Future<Map<String, dynamic>?> createQuiz(
    String token, String courseid, String quizname, String quizintro) async {
  const String url = 'webservice/rest/server.php';
  try {
    final response = await http.post(
      Uri.parse(moodleURL + url),
      body: {
        'wstoken': token,
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
      return responseData; // Return the map with quiz data
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return null; // Return null if the request failed
    }
  } catch (e) {
    print('Error occurred: $e');
    return null; // Handle any other errors (network, parsing, etc.)
  }
}

Future<void> deleteQuiz(String token, String quizid) async {
  // const String url = 'https://www.swen670moodle.site/webservice/rest/server.php';
  const String url = 'webservice/rest/server.php';
  final response = await http.post(
    Uri.parse(moodleURL + url),
    body: {
      'wstoken': token,
      'wsfunction': 'local_learninglens_delete_quiz',
      'moodlewsrestformat': 'json',
      'quizid': quizid,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    print('Response: $responseData');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}

Future<Map<String, dynamic>?> createAssignnment(
    String token,
    String courseid,
    String sectinoid,
    String assignmentName,
    String startdate,
    String enddate,
    String rubricJson,
    String description) async {
  const String url = 'webservice/rest/server.php';
  try {
    final response = await http.post(
      Uri.parse(moodleURL + url),
      body: {
        'wstoken': token,
        'wsfunction': 'local_learninglens_create_assignment',
        'moodlewsrestformat': 'json',
        'courseid': courseid,
        'sectionid': sectinoid,
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

Future<void> fetchGrades(int assignmentId, String token) async {
  const baseUrl = 'webservice/rest/server.php';
  final queryParams = {
    'wsfunction': 'mod_assign_get_grades',
    'moodlewsrestformat': 'json',
    'assignid': assignmentId.toString(),
    'wstoken': token,
  };

  final url =
      Uri.parse(moodleURL + baseUrl).replace(queryParameters: queryParams);
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Process the grades and rubric details here
    print(data);
  } else {
    throw Exception('Failed to load grades');
  }
}
