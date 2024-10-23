import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _currentDate = DateTime(2024, 10); // Starting from October 2024

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar - ${DateFormat.yMMMM().format(_currentDate)}'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _previousMonth,
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: _nextMonth,
          ),
        ],
      ),
      body: _buildCalendar(),
    );
  }

  saveReminder(String reminderText, String frequency) {
    print("testing value of $reminderText");
    int? value = 0;
    value = int.tryParse(reminderText);
    String title1 = "";
    String content1 = "";

    if (frequency == "select day") {
      if (value != null) {
        title1 = "Alert Saved";
        content1 = "You will be reminded of text every $reminderText";
      } else if (value == null) {
        title1 = "Alert Not Saved";
        content1 = "Please type a number between 1 and 31";
      }
    } else {
      title1 = "Alert Saved";
      content1 = "You will be reminded of $reminderText every $frequency";
    }
    Widget btnOK = TextButton(
        onPressed: () {
          saveReminderToFile(reminderText, frequency);
          Navigator.of(context).pop();
        },
        child: Text("Close"));

    AlertDialog message = AlertDialog(
      title: Text(title1),
      titleTextStyle: TextStyle(color: Colors.black),
      contentTextStyle: TextStyle(color: Colors.black),
      content: Text(content1),
      actions: [
        // Widget btn=TextButton(child: Text("")
        btnOK,
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return message;
        });
  }

  saveReminderToFile(String reminderName, String reminderfrequency) async {
    final local = await SharedPreferences.getInstance();
    local.setString("reminderText", reminderName);
    local.setString("frequency", reminderfrequency);
    print("Save Data");
  }

  loadReminder() async {
    final local = await SharedPreferences.getInstance();
    String? reminderName = "", reminderfrequency = "";
    DateTime currentDate = DateTime.now();
    print("Current Day: " + currentDate.day.toString());
    print("Current Month: " + currentDate.month.toString());
    print("Current Year: " + currentDate.year.toString());
    reminderName = local.getString("reminderText");
    reminderfrequency = local.getString("frequency");
    if (reminderfrequency != null &&
        reminderfrequency.contains("day") == true) {
      create_Alert(reminderName);
    }
     else if (reminderfrequency != null &&
        reminderfrequency.contains("month") == true&&(currentDate.day==1 || currentDate.day==28)) {
create_Alert(reminderName);
        }
//         else if (reminderfrequency != null &&
//         reminderfrequency.contains("month") == true&&(currentDate.day==1 || currentDate.day==28)) {
// create_Alert(reminderName);
//         }
    print("Save Data");
  }

  create_Alert(String? text) {
    int? option = 1;
    final TextEditingController reminderName = TextEditingController();
    String? chosenDay;
    Widget btnOK = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("Close"));

    Widget remDayText = TextField(
      readOnly: true,
      cursorColor: Colors.white,
      style: TextStyle(color: Colors.black),
    );

    AlertDialog message = AlertDialog(
      titleTextStyle: TextStyle(color: Colors.black),
      contentTextStyle: TextStyle(color: Colors.black),
      title: Text("Alert"),
      content: Text(text!),
      actions: [
        // Widget btn=TextButton(child: Text(""),
        remDayText,
        btnOK,
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return message;
        });
  }

  createAlert() {
    int? option = 1;
    final TextEditingController reminderName = TextEditingController();
    final TextEditingController selectDayName = TextEditingController();
    final TextEditingController textcontroller = TextEditingController();
    String? chosenDay;
    Widget btnOK = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("Close"));
    Widget btnOKDay = TextButton(
        onPressed: () {
          saveReminder(textcontroller.text, "day");
        },
        child: Text("OK"));
    Widget btnSelectDay = TextButton(
        onPressed: () {
          saveReminder(reminderName.text, "select day");
        },
        child: Text("OK"));
    Widget btnOKMonth = TextButton(
        onPressed: () {
          saveReminder(textcontroller.text, "month");
        },
        child: Text("OK"));
    Widget btnDayText = TextField(
      decoration: InputDecoration(hintText: "Remind Every Day"),
      cursorColor: Colors.white,
      style: TextStyle(color: Colors.black),
    );
    Radio(
      value: 2,
      groupValue: option,
      onChanged: (value) {
        setState(() {
          option = value!;
        });
      },
    );

    Radio(
      value: 2,
      groupValue: option,
      onChanged: (value) {
        setState(() {
          option = value!;
        });
      },
    );
    Radio(
      value: 3,
      groupValue: option,
      onChanged: (value) {
        setState(() {
          option = value!;
        });
      },
    );
    Widget btnSelectDayText = TextFormField(
      decoration: InputDecoration(hintText: "Remind On Specific Day"),
      cursorColor: Colors.white,
      style: TextStyle(color: Colors.black),
      controller: selectDayName,
    );
    Widget remDayText = TextField(
      readOnly: true,
      decoration: InputDecoration(hintText: "Remind Every Day"),
      cursorColor: Colors.white,
      style: TextStyle(color: Colors.black),
    );
    Widget remMonthText = TextField(
      readOnly: true,
      decoration: InputDecoration(hintText: "Remind Every Month"),
      cursorColor: Colors.white,
      style: TextStyle(color: Colors.black),
    );
    Widget txtbox = TextFormField(
        controller: textcontroller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(labelText: "Create Reminder"));
    Widget txtSelectDayBox = TextFormField(
        controller: reminderName,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(labelText: "Enter Selected Day"));
    AlertDialog message = AlertDialog(
      title: Text("createAlert"),
      content: Text("Message"),
      actions: [
        // Widget btn=TextButton(child: Text(""),
        txtbox,
        remDayText,
        btnOKDay,

        remMonthText,
        btnOKMonth,
        btnSelectDayText,
        txtSelectDayBox,
        btnSelectDay,
        btnOK,
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return message;
        });
  }

  Widget _buildCalendar() {
    loadReminder();
    int daysInMonth =
        DateUtils.getDaysInMonth(_currentDate.year, _currentDate.month);
    int firstDayOfWeek =
        DateTime(_currentDate.year, _currentDate.month, 1).weekday;

    List<Widget> dayButtons = [];

    // Add empty containers for days before the 1st of the month
    for (int i = 1; i < firstDayOfWeek; i++) {
      dayButtons.add(Container());
    }

    // Add buttons for each day in the month
    for (int day = 1; day <= daysInMonth; day++) {
      dayButtons.add(
        ElevatedButton(
          onPressed: () {
            // TODO: Fill in on click method for each day button
            createAlert();
          },
          child: Text('$day'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildDayHeaders(),
          Table(
            children: _buildCalendarRows(dayButtons),
          ),
        ],
      ),
    );
  }

  // Build a row of day headers (Mon, Tue, etc.)
  Widget _buildDayHeaders() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        return Expanded(
          child: Center(
            child: Text(
              DateFormat.E().format(DateTime(2024, 10, index + 1)),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }

  // Create rows of calendar buttons
  List<TableRow> _buildCalendarRows(List<Widget> dayButtons) {
    List<TableRow> rows = [];
    int buttonsInRow = 7;
    int totalButtons = dayButtons.length;
    int rowCount = (totalButtons / buttonsInRow).ceil();

    for (int i = 0; i < rowCount; i++) {
      rows.add(
        TableRow(
          children: List.generate(buttonsInRow, (index) {
            int buttonIndex = i * buttonsInRow + index;
            return buttonIndex < totalButtons
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: dayButtons[buttonIndex],
                  )
                : Container(); // Fill remaining slots with empty containers
          }),
        ),
      );
    }

    return rows;
  }

  // Go to the previous month
  void _previousMonth() {
    setState(() {
      if (_currentDate.year > 2024 || _currentDate.month > 1) {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      }
    });
  }

  // Go to the next month (limit to 20 years)
  void _nextMonth() {
    setState(() {
      if (_currentDate.year < 2044 ||
          (_currentDate.year == 2044 && _currentDate.month < 12)) {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      }
    });
  }
}
