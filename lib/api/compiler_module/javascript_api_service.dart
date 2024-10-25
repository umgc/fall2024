import 'package:http/http.dart' as http;
import 'package:intelligrade/controller/model/beans.dart';

// Static class to access compiler service.
class JavascriptCompilerApiService {
  static const port = '3001';
  static const baseUrl = 'http://18.222.224.35:$port';
  static const compileUrl = '$baseUrl/compile/js';

  // Submits student files and instructor test file to the compiler. The test
  // file is run and output is returned.
  static Future<String> compileAndGrade(List<FileNameAndBytes> studentFiles) async {
    final request = http.MultipartRequest('POST', Uri.parse(compileUrl));
    request.headers['x-api-key'] = 'evaluAIteamB';
    for (FileNameAndBytes file in studentFiles) {
      String commonFileName = file.filename.substring(file.filename.indexOf('_') + 1);
      request.files.add(http.MultipartFile.fromBytes(commonFileName, file.bytes, filename: file.filename));
    }
    final streamedResponse = await request.send();
    return await streamedResponse.stream.bytesToString();
  }
}