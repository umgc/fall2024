import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

void main() {
  runApp(MyApp());
}

const ColorScheme customColorScheme = ColorScheme(
  primary: Color(0xFF6A5A99), // Purple color as primary
  onPrimary: Color(0xFFFFFFFF), // White text on primary
  primaryContainer: Color(0xFFEDE6FF), // Light lavender
  onPrimaryContainer: Color(0xFF2D004A), // Dark purple
  secondary: Color(0xFF6A5A99), // Using similar purple as secondary
  onSecondary: Colors.white, // Black text on background
  surface: Color(0xFFFFFFFF), // White surface color
  onSurface: Colors.black, // Black text on surface
  error: Colors.red, // Error color red
  onError: Colors.white, // White on error
  brightness: Brightness.light, // Light mode
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removed the debug banner
      home: EssayAssignmentSettings(),
      theme: ThemeData(
        colorScheme: customColorScheme, // Apply the custom color scheme
        useMaterial3: true, // Using Material 3 design
      ),
      title: 'Learning Lens',
    );
  }
}

class EssayAssignmentSettings extends StatefulWidget {
  @override
  _EssayAssignmentSettingsState createState() =>
      _EssayAssignmentSettingsState();
}

class _EssayAssignmentSettingsState extends State<EssayAssignmentSettings> {
  // Date selection variables
  String selectedDay = '01';
  String selectedMonth = 'January';
  String selectedYear = '2024';
  String selectedHour = '00';
  String selectedMinute = '00';

  List<String> days =
      List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  List<String> years = ['2023', '2024', '2025'];
  List<String> hours =
      List.generate(24, (index) => index.toString().padLeft(2, '0'));
  List<String> minutes =
      List.generate(60, (index) => index.toString().padLeft(2, '0'));

  TextEditingController _courseNameController = TextEditingController();
  TextEditingController _assignmentNameController = TextEditingController();

  // Quill Editor controller
  quill.QuillController _quillController = quill.QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Center the title in the AppBar
        title: Text('Learning Lens',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context)
            .colorScheme
            .primaryContainer, // Use primary container color
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title Centered Below the AppBar
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Send Essay to Moodle',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 32),

            // Course Name
            SectionTitle(title: 'General'),
            TextField(
              controller: _courseNameController,
              decoration: InputDecoration(
                labelText: 'Course name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Assignment Name
            TextField(
              controller: _assignmentNameController,
              decoration: InputDecoration(
                labelText: 'Assignment name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Description with Quill Rich Text Editor
            SectionTitle(title: 'Description'),
            Container(
              height: 300, // Increased height for better usability
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  quill.QuillToolbar.simple(
                    controller: _quillController,
                  ),
                  Expanded(
                    child: quill.QuillEditor(
                      controller: _quillController,
                      //  readOnly:false, // Enable editing
                      scrollController: ScrollController(),
                      focusNode: FocusNode(),
                      // autoFocus: false,
                      // expands: false,
                      // padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Availability
            SectionTitle(title: 'Availability'),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(value: true, onChanged: (value) {}),
                Text('Enable'),
                SizedBox(width: 10),
                _buildDropdown('Allow submissions from'),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(value: true, onChanged: (value) {}),
                Text('Enable'),
                SizedBox(width: 10),
                _buildDropdown('Due date'),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(value: true, onChanged: (value) {}),
                Text('Enable'),
                SizedBox(width: 10),
                _buildDropdown('Remind me to grade by'),
              ],
            ),
            SizedBox(height: 32),

            // Two Buttons at the Bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle Send to Moodle action
                  },
                  child: Text('Send to Moodle'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle Go Back to Edit Assignment action
                  },
                  child: Text('Go back to edit assignment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dropdown Builder
  Widget _buildDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Row(
          children: [
            _buildDropdownButton(days, selectedDay, (String? newValue) {
              setState(() {
                selectedDay = newValue!;
              });
            }),
            SizedBox(width: 8),
            _buildDropdownButton(months, selectedMonth, (String? newValue) {
              setState(() {
                selectedMonth = newValue!;
              });
            }),
            SizedBox(width: 8),
            _buildDropdownButton(years, selectedYear, (String? newValue) {
              setState(() {
                selectedYear = newValue!;
              });
            }),
            SizedBox(width: 8),
            _buildDropdownButton(hours, selectedHour, (String? newValue) {
              setState(() {
                selectedHour = newValue!;
              });
            }),
            SizedBox(width: 8),
            _buildDropdownButton(minutes, selectedMinute, (String? newValue) {
              setState(() {
                selectedMinute = newValue!;
              });
            }),
          ],
        ),
      ],
    );
  }

  // Dropdown Button Builder
  Widget _buildDropdownButton(List<String> items, String selectedValue,
      ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: selectedValue,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  // Section Title Widget
  Widget SectionTitle({required String title}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
