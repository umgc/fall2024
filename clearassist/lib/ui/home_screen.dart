import 'package:clearassistapp/ui/reusable/custom_title.dart';
import 'package:clearassistapp/ui/settings_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen_content.dart';
import 'assistant_screen.dart';
import 'gallery_screen.dart';

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
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Extend the body behind the bottom navigation bar
      extendBodyBehindAppBar: true, // Extend the body behind the app bar
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        backgroundColor:
            Colors.transparent, // Transparent background for the app bar
        elevation: 0, // Remove shadow
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
              bucket: PageStorageBucket(), // Store the state of the pages
              child: _widgetOptions[_selectedIndex], // Show the selected screen
            ),
          )),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // Background color for the BottomNavigationBar
          canvasColor: Colors.transparent,
          // Active icon/text color
          primaryColor: Colors.white,
          // Inactive icon/text color
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
          currentIndex: _selectedIndex, // Set the current index
          onTap: _onItemTapped, // Handle tab switching
          selectedLabelStyle: TextStyle(color: Colors.white),
          unselectedLabelStyle: TextStyle(color: Colors.white),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              backgroundColor: Color(0x00ffffff),
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
          ],
        ),
      ),
    );
  }
}
