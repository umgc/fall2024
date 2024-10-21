import 'dart:convert';
import 'package:flutter/material.dart';

class EssayGrader extends StatefulWidget {
  final String gradeJson;

  EssayGrader(this.gradeJson);

  @override
  EssayGraderState createState() => EssayGraderState();
}

class EssayGraderState extends State<EssayGrader> {
  List headers = [];
  List rows = [];

  @override
  void initState() {
    super.initState();
    populateHeadersAndRows(); // Populate table with data from GradeJSON
  }

  // Function to populate headers and rows for rubric display
  void populateHeadersAndRows() {
    try {
      Map<String, dynamic> jsonData = jsonDecode(widget.gradeJson);
      List<dynamic> rubricCriteria = jsonData['rubric_criteria'];

      // Define headers: Criterion Description, Levels, Remarks
      headers = [
        {"title": 'Criteria', 'index': 1, 'key': 'name'}, // Criteria header
      ];

      // Check levels and add level score headers
      if (rubricCriteria.isNotEmpty && rubricCriteria[0]['levels'] != null) {
        List<dynamic> levels = rubricCriteria[0]['levels'];
        for (int i = 0; i < levels.length; i++) {
          headers.add({
            "title": 'Score ${levels[i]['score']}', // Score as header title
            'index': i + 2,
            'key': 'level_$i',
          });
        }
      }

      // Add Remarks column
      headers.add({
        "title": 'Remarks', // Remarks column
        'index': headers.length + 1,
        'key': 'remarks',
      });

      // Populate rows with criteria descriptions, level details, and remarks
      rows = rubricCriteria.map((criterion) {
        Map<String, dynamic> row = {
          "name": criterion['description'], // Criterion description
        };

        // Loop through levels and add score and definition
        List<dynamic> levels = criterion['levels'];
        for (int i = 0; i < levels.length; i++) {
          bool isChosen = levels[i]['chosen'] == true;
          row['level_$i'] = {
            'definition': levels[i]['definition'],
            'chosen': isChosen
          };
        }

        // Add remarks
        row['remarks'] = criterion['remarks'] ?? '';

        return row;
      }).toList();
    } catch (e) {
      debugPrint('Error parsing grade JSON: $e');
    }

    setState(() {});
  }

  // Custom Widget to build rubric table
  Widget buildRubricTable() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Table(
        defaultColumnWidth: IntrinsicColumnWidth(),
        border: TableBorder.all(),
        children: [
          // Build headers (without borders)
          TableRow(children: [
            for (var header in headers)
              _buildTableCell(header['title'],
                  isHeader: true, hasBorder: false),
          ]),
          // Build rows
          for (var row in rows)
            TableRow(children: [
              _buildTableCell(row['name'],
                  hasBorder: false), // Criterion Description (no border)
              for (int i = 0; i < headers.length - 2; i++)
                _buildTableCell(
                  row['level_$i']['definition'], // Level Definition
                  isChosen: row['level_$i']
                      ['chosen'], // Check if level is chosen
                  isScoreColumn: true, // Only apply borders for score columns
                ),
              _buildTableCell(row['remarks'],
                  hasBorder: false), // Remarks (no border)
            ]),
        ],
      ),
    );
  }

  // Custom TableCell builder with optional green border if chosen is true for score columns only
  Widget _buildTableCell(String text,
      {bool isChosen = false,
      bool isHeader = false,
      bool isScoreColumn = false,
      bool hasBorder = true}) {
    return Container(
      decoration: BoxDecoration(
        border: hasBorder && isScoreColumn
            ? Border.all(
                color: isChosen
                    ? Colors.green
                    : Colors.black, // Green border if chosen, black otherwise
                width: 2.0,
              )
            : Border.all(
                color: Colors
                    .transparent), // No border for non-score columns and headers
      ),
      alignment: Alignment.center, // Center align text
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.visible, // Allow text to expand
        softWrap: true, // Enable text wrapping
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Essay Grader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection:
              Axis.horizontal, // Allow horizontal scrolling for wide tables
          child: Column(
            children: [
              Text(
                'Rubric',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              buildRubricTable(), // Display the rubric table here
            ],
          ),
        ),
      ),
    );
  }
}
