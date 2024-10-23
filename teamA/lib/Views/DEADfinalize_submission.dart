import 'package:flutter/material.dart';
import 'dart:convert';

void main() => runApp(RubricApp());

class RubricApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RubricScreen(),
    );
  }
}

class RubricScreen extends StatefulWidget {
  @override
  _RubricScreenState createState() => _RubricScreenState();
}

class _RubricScreenState extends State<RubricScreen> {
  // Rubric definition data (mock data)
  final rubric = [
    {
      'id': 52,
      'description': 'Content',
      'levels': [
        {'id': 157, 'score': 1, 'definition': 'Poor'},
        {'id': 156, 'score': 3, 'definition': 'Good'},
        {'id': 155, 'score': 5, 'definition': 'Excellent'}
      ]
    },
    {
      'id': 53,
      'description': 'Clarity',
      'levels': [
        {'id': 160, 'score': 1, 'definition': 'Unclear'},
        {'id': 159, 'score': 3, 'definition': 'Somewhat Clear'},
        {'id': 158, 'score': 5, 'definition': 'Very Clear'}
      ]
    }
  ];

  // Assignment submission scores (mock data)
  List<Map<String, dynamic>> submissionScores = [
    {'criterionid': 52, 'levelid': 156, 'remark': 'Done with mirrors.'},
    {'criterionid': 53, 'levelid': 158, 'remark': 'Rocks.'}
  ];

  // State management for selected levels (initially set based on submissionScores)
  Map<int, int> selectedLevels = {};

  @override
  void initState() {
    super.initState();
    // Initialize selected levels from submission scores
    for (var score in submissionScores) {
      selectedLevels[score['criterionid']] = score['levelid'];
    }
  }

  // Save updated submission scores as JSON
  void saveSubmissionScores() {
    List<Map<String, dynamic>> updatedScores = [];
    selectedLevels.forEach((criterionid, levelid) {
      updatedScores.add({'criterionid': criterionid, 'levelid': levelid});
    });

    String jsonScores = jsonEncode(updatedScores);
    print('Updated Submission Scores: $jsonScores');
    // You can handle further actions like saving to a database or API here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editable Rubric'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Rubric Table
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(2), // Wider column for criteria
              },
              children: [
                // First Row: Empty cell followed by levels (scores)
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Criteria',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                   for (var level in (rubric.first['levels'] as List<dynamic>?) ?? []) 
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Score ${level['score']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                // Rows for each criterion
                for (var criterion in rubric)
                  TableRow(
                    children: [
                      // Criterion description
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(criterion['description'] as String),
                        ),
                      ),
                      // Level definitions (clickable cells)
                      for (var level in (criterion['levels'] as List<dynamic>? ?? []))
                        TableCell(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedLevels[criterion['id'] as int] = level['id'] as int;
                              });
                            },
                            child: Container(
                              color: selectedLevels[criterion['id']] == level['id']
                                  ? Colors.blue.withOpacity(0.5)
                                  : Colors.transparent,
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                level['definition'],
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveSubmissionScores,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
