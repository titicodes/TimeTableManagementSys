import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTimetableEntryScreen extends StatefulWidget {
  const AddTimetableEntryScreen({super.key});

  @override
  _AddTimetableEntryScreenState createState() => _AddTimetableEntryScreenState();
}

class _AddTimetableEntryScreenState extends State<AddTimetableEntryScreen> {
  final _courseController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _venueController = TextEditingController();

  void _addEntry() async {
    String course = _courseController.text.trim();
    String date = _dateController.text.trim();
    String time = _timeController.text.trim();
    String venue = _venueController.text.trim();

    // Check for conflicts before adding the entry
    bool conflict = await _checkForConflicts(date, time, venue);
    if (conflict) {
      // Show an alert dialog or message if a conflict is detected
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Conflict Detected'),
            content: const Text('Another class is scheduled at this time and venue.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Add the entry to Firestore
    await FirebaseFirestore.instance.collection('timetable').add({
      'course': course,
      'date': date,
      'time': time,
      'venue': venue,
    });

    Navigator.pop(context); // Go back to the timetable screen
  }

  Future<bool> _checkForConflicts(String date, String time, String venue) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('timetable')
        .where('date', isEqualTo: date)
        .where('time', isEqualTo: time)
        .where('venue', isEqualTo: venue)
        .get();

    return result.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Timetable Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(labelText: 'Course'),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date (e.g., 22/08/2024)'),
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Time (e.g., 12:00 PM)'),
            ),
            TextField(
              controller: _venueController,
              decoration: const InputDecoration(labelText: 'Venue'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addEntry,
              child: const Text('Add Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
