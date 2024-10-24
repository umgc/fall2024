import 'package:flutter/material.dart';
import 'package:editable/editable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../../api/llm/openai_api.dart';
import 'send_essay_to_moodle.dart'; // Import for JSON encoding

class EssayEditor extends StatefulWidget {
  final dynamic jsonData;
  const EssayEditor(this.jsonData, {super.key});
  @override
  EssayEditorState createState() => EssayEditorState(); // Public State class
}

class EssayEditorState extends State<EssayEditor> {
  // JSON data to be used
  late dynamic jsonData;
  final openApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  dynamic essayPrompt;

  // Variables to track the button state
  bool isAssigning = false;

  // Convert JSON to rows compatible with Editable
  List rows = [];

  // Headers or Columns
  List headers = [];

  @override
  void initState() {
    super.initState();
    jsonData = widget.jsonData;
    populateHeadersAndRows();
  }

  // Function to query selected AI to generate a rubric
  Future<dynamic> genPromptFromRubric(String inputs) async {
    String queryPrompt = '''
       I am building a program that creates essay prompts when provided with an assignment rubric. I will provide you with the assignment's rubric that will be formatted like this:
        {
            "criteria": [
                {
                    "description": #CriteriaName,
                    "levels": [
                        { "definition": #CriteriaDef, "score": #ScoreValue },
                    ]
                }
          ]
        }
        #CriteriaName represents the name of the criteria.
        #CriteriaDef represents a detailed description of what meeting that criteria would look like for each scale value.
        #ScoreValue represents the score.

        You must reply only with a 2 sentence essay prompt.
        Here is the rubric:
        $inputs
      ''';

    essayPrompt = await OpenAiLLM(openApiKey).postToLlm(queryPrompt);
    essayPrompt = essayPrompt.replaceAll('```', '').trim();
    return essayPrompt;
  }

  // Function to dynamically populate headers and rows based on JSON data
  void populateHeadersAndRows() {
    // Step 1: Build headers dynamically based on the number of levels in the first criterion
    List<dynamic> levels =
        List<dynamic>.from(jsonData['criteria']![0]['levels'] as List);
    headers = [
      {"title": 'Criteria', 'index': 1, 'key': 'name'},
    ];

    for (int i = 0; i < levels.length; i++) {
      headers.add({
        "title": '${levels[i]['score']}',
        'index': i + 2,
        'key': 'level_$i'
      });
    }

    // Step 2: Build rows by mapping each criterion and its levels dynamically
    rows = (jsonData['criteria'] ?? []).map((criterion) {
      Map<String, dynamic> row = {
        "name": criterion['description'],
      };

      for (int i = 0; i < (criterion['levels'] as List).length; i++) {
        row['level_$i'] = (criterion['levels'] as List)[i]['definition'];
      }

      return row;
    }).toList();

    setState(
        () {}); // Ensure the UI is updated after populating headers and rows
  }

  /// Create a Key for EditableState
  final _editableKey = GlobalKey<EditableState>();

  /// Merge edits into the original jsonData and return updated JSON
  String getUpdatedJson() {
    List editedRows = _editableKey.currentState!.editedRows;

    // Apply the edits to the original jsonData
    for (var editedRow in editedRows) {
      int rowIndex = editedRow['row'];
      var originalCriterion = jsonData['criteria']?[rowIndex];

      // For each edited level, update the corresponding level in the original data
      editedRow.forEach((key, value) {
        if (key != 'row' && key.startsWith('level_')) {
          int levelIndex = int.parse(key.split('_')[1]);
          (originalCriterion as Map<String, dynamic>)['levels']?[levelIndex]
              ['definition'] = value;
        }
      });
    }

    // Convert the updated jsonData back to the required format and return it
    Map<String, dynamic> updatedData = {"criteria": jsonData['criteria']};
    return jsonEncode(updatedData); // Return the JSON as a string
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Essay Rubric"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Editable(
              key: _editableKey,
              tdEditableMaxLines: 100,
              trHeight: 100,
              columnRatio: .9 / headers.length, // sets width of each column
              columns: headers,
              rows: rows,
              showCreateButton: false,
              tdStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              showSaveIcon: false, // Hide row save icons
              onSubmitted: (value) {
                print(
                    'onsubmitted: $value'); // You can grab this data to store anywhere
              },
            ),
          ),
          const SizedBox(
              height: 20), // Add some space between table and buttons
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom:
                    100.0), // Adds 16 pixels padding to left, right, and bottom
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Align buttons to the center
              children: [
                ElevatedButton(
                  onPressed: () {
                    String updatedJson = getUpdatedJson();
                    print('Saved data: $updatedJson');
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Table data saved!')));
                  },
                  child: const Text('Save All Changes'),
                ),
                const SizedBox(width: 16), // Add some space between the buttons
                ElevatedButton(
                  onPressed: isAssigning
                      ? null
                      : () async {
                          setState(() {
                            isAssigning =
                                true; // Disable the button and change the text
                          });

                          String updatedJson = getUpdatedJson();
                          await genPromptFromRubric(updatedJson)
                              .then((dynamic results) {
                            print(results);
                            // Navigate to the Essay Assignment Settings page with the updated JSON
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => EssayAssignmentSettings(
                                    updatedJson, results)));
                          });

                          setState(() {
                            isAssigning =
                                false; // Re-enable the button and reset the text
                          });
                        },
                  child:
                      Text(isAssigning ? 'Assigning...' : 'Finish and Assign'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
