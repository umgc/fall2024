import 'package:flutter/material.dart';
import 'package:editable/editable.dart';
import 'dart:convert';
import 'send_essay_to_moodle.dart'; // Import for JSON encoding

class EssayEditor extends StatefulWidget {
  final dynamic jsonData;
  const EssayEditor(this.jsonData);
  @override
  EssayEditorState createState() => EssayEditorState(); // Public State class
}

class EssayEditorState extends State<EssayEditor> {
  // JSON data to be used
  late dynamic jsonData;

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
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Finish and Assign'),
            onPressed: () {
              String updatedJson = getUpdatedJson();
              // Navigate to the Essay Assignment Settings page with the updated JSON
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EssayAssignmentSettings(updatedJson)));
              print(
                  updatedJson); // You can now see the updated JSON in the console
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Navigate to the Essay Assignment Page')));
            },
          ),
        ],
      ),
      body: Row(
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
              showSaveIcon: true,
              onRowSaved: (value) {
                print('rowsaved $value');
              },
              borderColor: Theme.of(context).colorScheme.primaryContainer,
              onSubmitted: (value) {
                print(
                    'onsubmitted: $value'); // You can grab this data to store anywhere
              },
            ),
          ),
        ],
      ),
    );
  }
}