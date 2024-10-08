import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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

  Widget _buildCalendar() {
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
