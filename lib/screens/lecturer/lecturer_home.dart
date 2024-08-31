import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timetable_management_system/screens/profile_screen.dart';
import 'lecturer_request_status.dart';
import 'view_timetable_screen.dart';
import 'package:timetable_management_system/screens/login_screen.dart';

class LecturerHomeScreen extends StatefulWidget {
  const LecturerHomeScreen({Key? key}) : super(key: key);

  @override
  _LecturerHomeScreenState createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    LecturerTimetableScreen(), // Timetable management screen
    LecturerRequestStatusScreen(),
    ProfileScreen(),
    // Profile management screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text('Lecturer Dashboard'),
        centerTitle: true,
        //backgroundColor: Colors.blueAccent,
        elevation: 4,
        automaticallyImplyLeading: false, // Remove leading icon
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Timetable',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Request Edit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(color: Colors.black54),
        onTap: _onItemTapped,
        elevation: 8,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add any action if needed
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
