import 'package:flutter/material.dart';

import 'request_edit_screen.dart';
import 'view_timetable_screen.dart';

class LecturerHomeScreen extends StatelessWidget {
  const LecturerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const ViewTimetableScreen(role: 'lecturer')),
                );
              },
              child: const Text('View Timetable'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RequestEditScreen()),
                );
              },
              child: const Text('Request Timetable Edit'),
            ),
            // Additional buttons for other lecturer functionalities...
          ],
        ),
      ),
    );
  }
}
