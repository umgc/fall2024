import 'package:clearassistapp/ui/reusable/custom_title.dart';
import 'package:clearassistapp/ui/settings_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen_content.dart';
import 'assistant_screen.dart';
import 'gallery_screen.dart';
import 'login_screen.dart'; // Import the login screen for navigation

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of pages to switch between with the bottom navigation bar
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreenContent(),
    AssistantScreen(),
    GalleryScreen(),
    SettingsScreen(),
  ];

  // Callback for changing the selected index
  void _onItemTapped(int index) {
    if (index == 4) {
      // If logout icon is tapped, show the logout dialog
      _showLogoutDialog(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: CustomTitle(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: PageStorage(
            bucket: PageStorageBucket(),
            child: _widgetOptions[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
          primaryColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
                bodyMedium: TextStyle(color: Colors.white),
                bodySmall: TextStyle(color: Colors.white),
                labelLarge: TextStyle(color: Colors.white),
                labelMedium: TextStyle(color: Colors.white),
                labelSmall: TextStyle(color: Colors.white),
              ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedLabelStyle: TextStyle(color: Colors.white),
          unselectedLabelStyle: TextStyle(color: Colors.white),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.white),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handshake_outlined, color: Colors.white),
              label: 'Virtual Assistant',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.image, color: Colors.white),
              label: 'Gallery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, color: Colors.white),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout, color: Colors.white), // Logout icon
              label: 'Logout',
            ),
          ],
        ),
      ),
    );
  }

  // Logout dialog method
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Customize the background color
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(20.0)), // Rounded corners
          ),
          title: Text(
            'Logout',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold), // Customize the title color
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
                color: Colors.black), // Customize the content text color
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(
                    color: Colors.deepPurple), // Customize button text color
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(
                    color: Colors.deepPurple), // Customize button text color
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacementNamed(context, '/loginScreen');
              },
            ),
          ],
        );
      },
    );
  }
}
