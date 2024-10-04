// Added (import 'dart:convert') for handling data encoding
import 'dart:convert';
import 'package:flutter/material.dart';

class AssignmentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assignment Submissions',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            // M3 color scheme with a seed color: purple
            seedColor: Colors.purple),
        // Enable Material 3
        useMaterial3: true,
      ),
      // Hides the debug banner
      debugShowCheckedModeBanner: false,
      home: AssignmentPage(),
    );
  }
}

class AssignmentPage extends StatefulWidget {
  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  final List<Map<String, dynamic>> submissions = [
    {
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'john.doe@example.com',
      'status': 'Submitted for grading',
      'lastModified': 'Tuesday, 09 September 2024, 10:27 PM',
      'comment': 'I think this book was interesting.',
      'finalGrade': 'A', // Final grade A
      'feedback': 'Good analysis, great job!', // Feedback comments
    },
    {
      'firstName': 'John',
      'lastName': 'Doe Jr',
      'email': 'john.doejr@example.com',
      'status': 'No submission',
      'lastModified': '-',
      'comment': '-',
      'finalGrade': '-', // No submission means no final grade from Teacher
      'feedback': '-', // No submission means no feedback from Teacher
    }
  ];

  //
  String selectedFirstNameFilter = 'All';

  String selectedLastNameFilter = 'All';

  List<String> alphabet = [
    'All',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z'
  ];

  List<bool> isCheckedList = List.generate(2, (index) => false);

  //  Download All Submissions Logic
  // Converts all submissions to JSON format and prints the result, simulating a download action.
  void _downloadAllSubmissions() {
    final allSubmissions = jsonEncode(submissions);
    print("Download initiated: $allSubmissions");
    // Simulate downloading all submission data
  }

  // Grading Submissions Logic
  // Assigns a grade to a submission if it is not already graded, otherwise notifies that the submission is already graded.
  void _gradeSubmission(int index) {
    if (submissions[index]['finalGrade'] == '-') {
      setState(() {
        submissions[index]['finalGrade'] = 'A'; // Example grading
      });
      print(
          "Graded submission for ${submissions[index]['firstName']} with grade A");
    } else {
      print("Submission by ${submissions[index]['firstName']} already graded.");
    }
  }

//
  // Editing Submissions Logic
  // Updates the comment for a submission if the submission is available for editing.
  void _editSubmission(int index) {
    if (submissions[index]['status'] != 'No submission') {
      setState(() {
        submissions[index]['comment'] =

            // This is used for submission edit
            'Updated comment for the submission.';
      });
      print("Edited submission for ${submissions[index]['firstName']}");
    } else {
      print("No submission to edit for ${submissions[index]['firstName']}");
    }
  }

//
  // Sending Submissions to Moodle Logic
  // Simulates sending the submission to Moodle if it exists, using the provided Moodle link.
  void _sendToMoodle(int index) {
    if (submissions[index]['status'] != 'No submission') {
      print(
          "Sending submission for ${submissions[index]['firstName']} to Moodle...");
      print(
          // This adds Moodle link
          "Moodle link: https://www.swen670moodle.site/");
      print("Submission sent to Moodle successfully!");
    } else {
      print("No submission to send for ${submissions[index]['firstName']}");
//
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text("View Essay Submission: George Orwell's 1984"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
              // Download submission logic

              onPressed: _downloadAllSubmissions,
              icon: Icon(Icons.download, color: colorScheme.onSecondary),
              label: Text("Download All Submissions",
                  style: TextStyle(color: colorScheme.onSecondary)),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Name Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('First name: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: alphabet.map((letter) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFirstNameFilter = letter;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: selectedFirstNameFilter == letter
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              border: Border.all(color: colorScheme.primary),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              letter,
                              style: TextStyle(
                                color: selectedFirstNameFilter == letter
                                    ? colorScheme.onPrimary
                                    : colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Last Name Filter Bar
          //
          Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
            child: Row(
              children: [
                Text('Last name: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: alphabet.map((letter) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedLastNameFilter = letter;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: selectedLastNameFilter == letter
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              border: Border.all(color: colorScheme.primary),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              letter,
                              style: TextStyle(
                                color: selectedLastNameFilter == letter
                                    ? colorScheme.onPrimary
                                    : colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Submissions added
          Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
            child: Text(
              "Submissions:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Submissions List
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Display 2 items in a row
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio:
                    2.3, // Adjusted to give more vertical space for buttons
              ),
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final submission = submissions[index];
                final firstNameInitial =
                    submission['firstName'][0].toUpperCase();
                final lastNameInitial = submission['lastName'][0].toUpperCase();

                if ((selectedFirstNameFilter != 'All' &&
                        firstNameInitial != selectedFirstNameFilter) ||
                    (selectedLastNameFilter != 'All' &&
                        lastNameInitial != selectedLastNameFilter)) {
                  // Hide if it doesn't match the filter
                  //
                  return Container();
                }

                bool isGradeAvailable = submission['finalGrade'] != '-';
                bool isSubmissionAvailable =
                    submission['status'] != 'No submission';

                return Card(
                  color: colorScheme.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: isCheckedList[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  isCheckedList[index] = value!;
                                });
                              },
                            ),
                            CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                submission['firstName'][0],
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '${submission['firstName']} ${submission['lastName']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Email: ${submission['email']}',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant)),
                        SizedBox(height: 8),
                        Text('Status: ${submission['status']}',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant)),
                        SizedBox(height: 8),
                        Text('Last modified: ${submission['lastModified']}',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant)),
                        SizedBox(height: 8),
                        Text('Final Grade: ${submission['finalGrade']}',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant)),
                        SizedBox(height: 8),
                        Text('Feedback: ${submission['feedback']}',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant)),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                side: BorderSide(color: colorScheme.primary),
                              ),
                              onPressed: isGradeAvailable
                                  ? () {
                                      // Adds grade submission logic
                                      //
                                      _gradeSubmission(index);
                                    }
                                  : null,
                              child: Text('Grade'),
                            ),
                            if (isSubmissionAvailable || isGradeAvailable)
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  side: BorderSide(color: colorScheme.primary),
                                ),
                                onPressed: () {
                                  //
                                  //Adds edit submission logic
                                  //
                                  _editSubmission(index);
                                },
                                child: Text('Edit'),
                              ),
                            if (isSubmissionAvailable || isGradeAvailable)
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  side: BorderSide(color: colorScheme.primary),
                                ),
                                onPressed: () {
                                  //
                                  // Adds Moodle link
                                  //
                                  _sendToMoodle(index);
                                },
                                child: Text('Send to Moodle'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
