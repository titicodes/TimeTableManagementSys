import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTimetableEntryScreen extends StatefulWidget {
  const AddTimetableEntryScreen({super.key});

  @override
  _AddTimetableEntryScreenState createState() =>
      _AddTimetableEntryScreenState();
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

    if (course.isEmpty || date.isEmpty || time.isEmpty || venue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields.'),
      ));
      return;
    }

    // Add the entry to Firestore
    await FirebaseFirestore.instance.collection('timetables').add({
      'course': course,
      'date': date,
      'time': time,
      'venue': venue,
    });

    Navigator.pop(context); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Timetable Entry'),
        backgroundColor: Colors.blueAccent, // AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_courseController, 'Course'),
              const SizedBox(height: 16.0),
              _buildTextField(_dateController, 'Date (e.g., 22/08/2024)'),
              const SizedBox(height: 16.0),
              _buildTextField(_timeController, 'Time (e.g., 12:00 PM)'),
              const SizedBox(height: 16.0),
              _buildTextField(_venueController, 'Venue'),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _addEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Button color
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Add Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
