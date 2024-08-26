import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddTimetableEntryScreen extends StatefulWidget {
  const AddTimetableEntryScreen({super.key});

  @override
  _AddTimetableEntryScreenState createState() => _AddTimetableEntryScreenState();
}

class _AddTimetableEntryScreenState extends State<AddTimetableEntryScreen> {
  final _courseController = TextEditingController();
  final _lecturerController = TextEditingController();
  final _venueController = TextEditingController();
  final _levelController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  void _addEntry() async {
    String course = _courseController.text.trim();
    String lecturer = _lecturerController.text.trim();
    String venue = _venueController.text.trim();
    String level = _levelController.text.trim();

    if (_selectedDate == null || _selectedTime == null) {
      // Show an alert dialog or message if the date or time is not selected
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Incomplete Entry'),
            content: const Text('Please select both a date and time.'),
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

    String date = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    String time = _selectedTime!.format(context);

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
    await FirebaseFirestore.instance.collection('timetables').add({
      'course': course,
      'lecturer': lecturer,
      'date': date,
      'time': time,
      'venue': venue,
      'level': level,
    });

    Navigator.pop(context); // Go back to the previous screen
  }

  Future<bool> _checkForConflicts(String date, String time, String venue) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('timetables')
        .where('date', isEqualTo: date)
        .where('time', isEqualTo: time)
        .where('venue', isEqualTo: venue)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
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
            TextFormField(
              controller: _courseController,
              decoration: const InputDecoration(labelText: 'Course'),
            ),
            TextFormField(
              controller: _lecturerController,
              decoration: const InputDecoration(labelText: 'Lecturer'),
            ),
            TextFormField(
              controller: _venueController,
              decoration: const InputDecoration(labelText: 'Venue'),
            ),
            TextFormField(
              controller: _levelController,
              decoration: const InputDecoration(labelText: 'Level (e.g., 100, 200)'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Pick Date'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime == null
                        ? 'Select Time'
                        : 'Time: ${_selectedTime!.format(context)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: const Text('Pick Time'),
                ),
              ],
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
