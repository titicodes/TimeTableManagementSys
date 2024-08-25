import 'package:flutter/material.dart';

import 'add_timetable_entry_screen.dart';
import 'admin_manage_users.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddTimetableEntryScreen()),
                );
              },
              child: const Text('Add Timetable Entry'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminManageUsersScreen()),
                );
              },
              child: const Text('Manage Users'),
            ),
            // Additional buttons for other admin functionalities...
          ],
        ),
      ),
    );
  }
}
