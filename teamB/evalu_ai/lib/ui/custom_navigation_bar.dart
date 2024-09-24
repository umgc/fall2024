import 'package:flutter/material.dart';
import 'package:intelligrade/controller/main_controller.dart';

class CustomNavigationBar extends StatefulWidget {
  // Change to StatefulWidget
  const CustomNavigationBar({Key? key}) : super(key: key);

  static MainController controller = MainController();

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _selectedIndex = 0; // Track the selected index

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _buildListTile(
          title: 'Dashboard',
          icon: Icons.auto_awesome_mosaic_outlined,
          index: 0,
        ),
        _buildListTile(
          title: 'Create Assignment',
          icon: Icons.assignment_add,
          index: 1,
        ),
        _buildListTile(
          title: 'View Assignment',
          icon: Icons.auto_awesome_motion_outlined,
          index: 2,
        ),
        _buildListTile(
          title: 'Chatbot Assistance',
          icon: Icons.chat_outlined,
          index: 3,
        ),
      ],
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required int index,
  }) {
    bool isSelected = _selectedIndex == index; // Check if this tile is selected

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      leading: Icon(
        icon,
        color: Colors.black, // Change icon color if selected
      ),
      tileColor: isSelected
          ? Colors.deepPurple[200]
          : null, // Change background color if selected
      onTap: () {
        setState(() {
          _selectedIndex = index; // Update the selected index
        });

        // Navigation logic based on selected item
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/dashboard');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/create');
            break;
          case 2:
            // Add navigation logic for View Assignment here
            break;
          case 3:
            // Add navigation logic for Chatbot Assistance here
            break;
        }
      },
    );
  }
}
