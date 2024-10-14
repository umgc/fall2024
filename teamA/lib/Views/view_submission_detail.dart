import 'dart:convert';
import 'package:flutter/material.dart';
import '../Controller/beans.dart';
import '../Api/moodle_api_singleton.dart';
import 'dart:math';

class SubmissionDetail extends StatefulWidget {
  final Participant participant;
  final Submission submission;
  final String courseId;

  SubmissionDetail(
      {required this.participant,
      required this.submission,
      required this.courseId});

  @override
  SubmissionDetailState createState() => SubmissionDetailState();
}

class SubmissionDetailState extends State<SubmissionDetail> {
  MoodleRubric? rubric;
  List? scores;
  bool isLoading = true;
  String errorMessage = '';
  Map<int, int> selectedLevels = {}; // Map to store selected levels
  Map<int, String> remarks = {}; // Map to store remarks
  Map<int, TextEditingController> remarkControllers = {}; // Controllers for each remark

  @override
  void initState() {
    super.initState();
    fetchRubric();
  }

  Future<void> fetchRubric() async {
    int? contextId = await MoodleApiSingleton().getContextId(widget.submission.assignmentId, widget.courseId);
    if (contextId != null) {
      var fetchedRubric = await MoodleApiSingleton().getRubric(widget.submission.assignmentId.toString());
      var submissionScores = await MoodleApiSingleton().getRubricGrades(widget.submission.assignmentId, widget.participant.id);

      setState(() {
        rubric = fetchedRubric;
        scores = submissionScores;
        // Populate selectedLevels and remarks from submissionScores
        for (var score in scores!) {
          selectedLevels[score['criterionid']] = score['levelid'];
          remarks[score['criterionid']] = score['remark'] ?? '';
          remarkControllers[score['criterionid']] = TextEditingController(text: remarks[score['criterionid']]);
        }
        isLoading = false;
      });

      if (fetchedRubric == null) {
        setState(() {
          errorMessage = 'No rubric available for this assignment.';
        });
      }
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to retrieve context ID for the assignment.';
      });
    }
  }

  // Save updated submission scores and remarks as JSON
  void saveSubmissionScores() {
    List<Map<String, dynamic>> updatedScores = [];
    selectedLevels.forEach((criterionid, levelid) {
      updatedScores.add({
        'criterionid': criterionid,
        'levelid': levelid,
        'remark': remarks[criterionid] ?? ''
      });
    });

    String jsonScores = jsonEncode(updatedScores);
    print('Updated Submission Scores and Remarks: $jsonScores');
    // Handle further actions like saving to a database or API here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submission Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User ID
                    Text(
                      widget.participant.fullname,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),

                    // Status
                    Text(
                      'Status: ${widget.submission.status}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),

                    // Submission Time
                    Text(
                      'Submitted on: ${widget.submission.submissionTime.toLocal()}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),

                    // Online Text
                    Text(
                      'Online Text:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    widget.submission.onlineText.isNotEmpty
                        ? Text(
                            widget.submission.onlineText,
                            style: TextStyle(fontSize: 16),
                          )
                        : Text(
                            'No content provided.',
                            style: TextStyle(
                                fontSize: 16, fontStyle: FontStyle.italic),
                          ),
                    SizedBox(height: 16),

                    // Rubric Section
                    rubric != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rubric:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),

                              // Rubric table (replace rubricTable with new table)
                              buildInteractiveRubricTable(),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: saveSubmissionScores,
                                child: Text('Save'),
                              ),
                            ],
                          )
                        : errorMessage.isNotEmpty
                            ? Text(
                                errorMessage,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.red),
                              )
                            : Text(
                                'No rubric available.',
                                style: TextStyle(
                                    fontSize: 16, fontStyle: FontStyle.italic),
                              ),
                  ],
                ),
              ),
            ),
    );
  }

// Interactive rubric table with dynamic width expansion
Widget buildInteractiveRubricTable() {
  if (rubric == null) return Container(); // No rubric, return an empty container

  List<TableRow> tableRows = [];

  // First row: Header row with scores and remarks
  tableRows.add(
    TableRow(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      children: [
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Criteria',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        ...rubric!.criteria.first.levels.map((level) {
          return TableCell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '${level.score} pts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Remarks',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // Add rows for each criterion
  for (var criterion in rubric!.criteria) {
    tableRows.add(
      TableRow(
        children: [
          // Criterion description
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(criterion.description),
            ),
          ),
          // Level definitions (clickable cells)
          ...criterion.levels.map((level) {
            bool isSelected =
                selectedLevels[criterion.id] == level.id; // Check if level is selected
            return TableCell(
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedLevels[criterion.id] = level.id;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  color: isSelected
                      ? Colors.blue.withOpacity(0.5)
                      : Colors.transparent,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(level.description),
                  ),
                ),
              ),
            );
          }).toList(),
          // Editable remark field
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: remarkControllers[criterion.id],
                onChanged: (text) {
                  remarks[criterion.id] = text;
                },
                decoration: InputDecoration(
                  hintText: 'Enter remark',
                  border: OutlineInputBorder(), // Optional: adds a border around the field
                ),
                minLines: 1, // Minimum number of lines to show
                maxLines: 5, // Maximum number of lines to show
              ),
            ),
          ),
        ],
      ),
    );
  }

  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      // Set a minWidth (e.g., 600px), but make sure it's less than or equal to the available maxWidth
      double minWidth = 800;
      double tableWidth = max(minWidth, constraints.maxWidth);

      return SingleChildScrollView(
        scrollDirection: Axis.vertical, // Enable vertical scrolling
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enable horizontal scrolling
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: tableWidth), // Safely set minWidth
            child: Table(
              border: TableBorder.all(
                  color: Colors.black, width: 1.0), // Outer border for the table
              defaultColumnWidth: IntrinsicColumnWidth(),
              children: tableRows,
            ),
          ),
        ),
      );
    },
  );
}

}
