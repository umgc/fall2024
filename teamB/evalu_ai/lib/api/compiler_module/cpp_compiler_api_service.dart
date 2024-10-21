import 'package:http/http.dart' as http;
import 'dart:convert';

// A class representing a file with its name and byte content.
class FileNameAndBytes {
  final String filename;
  final List<int> bytes;

  FileNameAndBytes({required this.filename, required this.bytes});
}

// Static class to access the C++ compiler service.
class CompilerApiService {
  static const baseUrl = 'http://18.222.224.35:8000';
  static const compileUrl = '$baseUrl/compile/cpp';

  // Submits student files and instructor test file to the C++ compiler.
  // The test file is run, and output is returned as a string.
  static Future<String> compileAndGrade(List<FileNameAndBytes> studentFiles) async {
    var request = http.MultipartRequest('POST', Uri.parse(compileUrl));

    // Attach files to the request
    for (var file in studentFiles) {
      request.files.add(http.MultipartFile.fromBytes(
        'files', 
        file.bytes,
        filename: file.filename,
      ));
    }

    // Send the request to the server
    var response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    } else {
      throw Exception('Failed to compile and run C++ code');
    }
  }
}