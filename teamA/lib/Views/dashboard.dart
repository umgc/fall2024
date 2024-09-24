import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

final ColorScheme customColorScheme = ColorScheme(
  primary: Color(0xFF6A5A99), // Purple color as primary
  onPrimary: Color(0xFFFFFFFF), // White text on primary
  primaryContainer: Color(0xFFEDE6FF), // Light lavender
  onPrimaryContainer: Color(0xFF2D004A), // Dark purple
  secondary: Color(0xFF6A5A99), // Using similar purple as secondary
  onSecondary: Colors.white, // White on secondary
  background: Color(0xFFF5F5F5), // Light grey background
  onBackground: Colors.black, // Black text on background
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
      debugShowCheckedModeBanner: true, // Keeps the debug banner for now
      home: TeacherDashboard(),
      theme: ThemeData(
        colorScheme: customColorScheme, // Apply the custom color scheme
        useMaterial3: true, // If you want to use Material 3 design
      ),
      title: 'Learning Lens',
    );
  }
}

class TeacherDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Lens'),
        backgroundColor: Theme.of(context)
            .colorScheme
            .primaryContainer, // Use primary container color
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
            onPressed: () {
              // Handle profile/account actions here
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context)
          .colorScheme
          .background, // Use background color from scheme
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Large screen (desktop or large tablet)
            return _buildDesktopLayout(context);
          } else {
            // Small screen (mobile)
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  // Desktop layout
  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Teacher Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 40), // Space between the title and buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Teacher can view available courses here.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildDashboardButton(
                        context, 'Courses', 150), // Smaller button
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  children: [
                    Text(
                      'Teacher creates/views assessments.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildDashboardButton(
                        context, 'Assessments', 180), // Larger middle button
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  children: [
                    Text(
                      'Teacher can view, grade, and create essays.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildDashboardButton(
                        context, 'Essays', 150), // Smaller button
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Mobile layout
  Widget _buildMobileLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Teacher Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 20), // Space between the title and buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'View available courses.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildDashboardButton(
                        context, 'Courses', 120), // Smaller for mobile
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    Text(
                      'Create or view assessments.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildDashboardButton(context, 'Assessments',
                        140), // Adjust button size for mobile
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    Text(
                      'View or grade essays.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildDashboardButton(
                        context, 'Essays', 120), // Adjust for mobile
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build circular buttons
  Widget _buildDashboardButton(
      BuildContext context, String title, double size) {
    return Container(
      height: size, // Dynamic size based on parameter
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white, // Outer white border color
        boxShadow: [
          BoxShadow(
            color: Colors.grey[500]!, // Medium grey shadow around white border
            offset: Offset(4, 4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(10), // Space for white border
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context)
              .colorScheme
              .primary, // Inner purple circle using primary color
          boxShadow: [
            BoxShadow(
              color: Colors.grey[600]!, // Grey shadow for inner circle
              offset: Offset(4, 4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // Add button functionality here
          },
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            backgroundColor: Colors.transparent,
            padding:
                EdgeInsets.all(24), // Transparent to show purple background
            shadowColor: Colors.transparent, // No additional shadow
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary, // Use onPrimary for text color
            ),
          ),
        ),
      ),
    );
  }
}
