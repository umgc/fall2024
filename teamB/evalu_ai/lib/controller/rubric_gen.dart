import 'package:flutter/material.dart';

//App that constructs the table widget
class TableApp extends StatelessWidget {
  const TableApp(this.tableData, this.headerData);

  final List<Map<String, String>> tableData;
  final List<String> headerData;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Editable Table',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Rubric'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: EditableTable(tableData: tableData, headerData: headerData),
          ),
        ),
      ),
    );
  }
}

//Object that creates editable table rows
class EditableTable extends StatefulWidget {
  final List<Map<String, String>> tableData;
  final List<String> headerData;

  EditableTable({required this.tableData, required this.headerData});

  @override
  _EditableTableState createState() => _EditableTableState();
}

class _EditableTableState extends State<EditableTable> {
  late List<Map<String, TextEditingController>> controllers;

  @override
  void initState() {
    super.initState();
    // Create controllers for each cell in the table except the first column
    controllers = widget.tableData.map((row) {
      return row.map((key, value) {
        return MapEntry(key, TextEditingController(text: value));
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: _buildTableRows(),
    );
  }

  // Function to build the table rows dynamically
  List<TableRow> _buildTableRows() {
    List<TableRow> rows = [];

    // Add table header row dynamically based on column headers
    rows.add(
      TableRow(
        children: widget.headerData.map((header) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(header,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );

    // Add rows dynamically based on data
    for (var i = 0; i < widget.tableData.length; i++) {
      rows.add(
        TableRow(
          children: widget.headerData.map((header) {
            // If it is the first column, display it as static text
            if (header == widget.headerData.first) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.tableData[i][header] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
              );
            }
            // For other columns, make them editable
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controllers[i][header],
                onChanged: (value) {
                  widget.tableData[i][header] = value; // Update the data
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null, // This allows the text field to wrap and expand
                minLines: 1, // Minimum number of lines the field should show
              ),
            );
          }).toList(),
        ),
      );
    }
    return rows;
  }

  @override
  void dispose() {
    // Dispose of all controllers when the widget is disposed
    for (var row in controllers) {
      for (var controller in row.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}
