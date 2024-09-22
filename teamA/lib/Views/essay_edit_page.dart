import 'package:flutter/material.dart';
import 'package:editable/editable.dart';

class EssayEditPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _EssayEditPageState createState() => _EssayEditPageState();
}

class _EssayEditPageState extends State<EssayEditPage> {
//row data
  List rows = [
    {
      "name": 'Thesis Statement',
      "date": 'Clear, strong thesis; clearly states position on dress code.',
      "month": 'Thesis is present but may lack clarity or strength.',
      "status": 'Thesis is unclear or missing.'
    },
    {
      "name": 'Argument Development',
      "date": 'Well-developed arguments with strong evidence and examples.',
      "month": 'Arguments are present but may lack depth or sufficient evidence.',
      "status": 'Weak arguments; little to no evidence or examples provided.'
    },
    {
      "name": 'Organization',
      "date": 'Logical structure; clear introduction, body, and conclusion.',
      "month": 'Structure is present but may be unclear or disorganized in parts.',
      "status": 'Lacks clear organization; difficult to follow.'
    },
    {
      "name": 'Counterarguments',
      "date": 'Effectively addresses counterarguments and refutes them.',
      "month": 'Mentions counterarguments but does not fully address or refute them.',
      "status": 'Fails to recognize or address counterarguments.'
    },
  ];
//Headers or Columns
  List headers = [
    {"title": 'Criteria', 'index': 1, 'key': 'name'},
    {"title": '3 - Exemplary', 'index': 2, 'key': 'date'},
    {"title": '2 - Proficient', 'index': 3, 'key': 'month'},
    {"title": '1 - Needs Improvement', 'index': 4, 'key': 'status'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Essay Rubric"),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Finish and Assign'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigate to the Essay Assignment Page')));
            },
          ),
      ]),
      body: Row(
        children: [
          Editable(
                    tdEditableMaxLines: 100,
                    trHeight: 100,
                    columnRatio: .9/headers.length, //sets width of each column as a ratio of total number of columsn
                    columns: headers,
                    rows: rows,
                    showCreateButton: true,
                    tdStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                    showSaveIcon: true,
                    //  borderColor: Colors.grey.shade300,
                    borderColor: Theme.of(context).colorScheme.primaryContainer,
                    onSubmitted: (value) {
                      //new line
                      print(value); //you can grab this data to store anywhere
                    }),
        ],
      ),
          );
    
  }
}
