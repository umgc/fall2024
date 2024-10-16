import 'package:flutter/material.dart';
import '../Controller/beans.dart';
import '../Api/moodle_api_singleton.dart';

class SubmissionDetail extends StatefulWidget {
  final Submission submission;
  final int assignmentId;
  final String courseId;

  SubmissionDetail(
      {required this.submission,
      required this.assignmentId,
      required this.courseId});

  @override
  SubmissionDetailState createState() => SubmissionDetailState();
}

class SubmissionDetailState extends State<SubmissionDetail> {
  MoodleRubric? rubric;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchRubric();
  }

  Future<void> fetchRubric() async {
    // Fetch context ID
    int? contextId = await MoodleApiSingleton()
        .getContextId(widget.assignmentId, widget.courseId);
    if (contextId != null) {
      var fetchedRubric = await MoodleApiSingleton()
          .getRubric(widget.assignmentId.toString());

      setState(() {
        rubric = fetchedRubric;
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
                      'User ID: ${widget.submission.userid}',
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

                              // Rubric table
                              rubricTable(),
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

// Method to create the rubric table
  Widget rubricTable() {
    //Get unique scores from all criteria
    Set<int> uniqueScores = {};
    rubric!.criteria.forEach((criterion) {
      criterion.levels.forEach((level) {
        uniqueScores.add(level.score);
      });
    });

    // Sort the scores so they appear in ascending order in the table
    List<int> sortedScores = uniqueScores.toList()..sort();

    List<TableRow> tableRows = [];

    // First row: Header row with contrasting color
    tableRows.add(
      TableRow(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer),
        children: [
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Criterion',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
          ),
          ...sortedScores.map((score) {
            return TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.center, // Center align the text
                  child: Text(
                    '$score pt',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );

    // Step 3: Add rows for each criterion
    rubric!.criteria.forEach((criterion) {
      tableRows.add(
        TableRow(
          children: [
            // First column (criterion description) with contrasting color
            TableCell(
              child: Container(
                padding: EdgeInsets.all(8.0),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  criterion.description,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            // Add cells for each score
            ...sortedScores.map((score) {
              String? levelDescription = criterion.levels
                  .firstWhere((level) => level.score == score,
                      orElse: () => Level(description: '', score: score))
                  .description;

              return TableCell(
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer), // Add cell border
                  ),
                  child: Align(
                    alignment: Alignment.center, // Center align the text
                    child: Text(
                      levelDescription.isNotEmpty ? levelDescription : '-',
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      );
    });

    // Step 4: Return the Table widget with borders
    return Table(
      border: TableBorder.all(
          color: Colors.black, width: 1.0), // Outer border for the table
      children: tableRows,
    );
  }
}
