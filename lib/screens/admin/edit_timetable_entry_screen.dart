import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTimetableEntryScreen extends StatefulWidget {
  final DocumentSnapshot document;

  const EditTimetableEntryScreen({super.key, required this.document});

  @override
  _EditTimetableEntryScreenState createState() =>
      _EditTimetableEntryScreenState();
}

class _EditTimetableEntryScreenState extends State<EditTimetableEntryScreen> {
  late TextEditingController _courseController;
  late TextEditingController _dayController;
  late TextEditingController _timeFromController;
  late TextEditingController _timeToController;
  late TextEditingController _venueController;
  late TextEditingController _lecturerController;

  @override
  void initState() {
    super.initState();
    _courseController =
        TextEditingController(text: widget.document['courseCode']);
    _dayController = TextEditingController(text: widget.document['day']);
    _timeFromController =
        TextEditingController(text: widget.document['timeFrom']);
    _timeToController = TextEditingController(text: widget.document['timeTo']);
    _venueController = TextEditingController(text: widget.document['venue']);
    _lecturerController =
        TextEditingController(text: widget.document['lecturer']);
  }

  void _updateTimetable() async {
    await FirebaseFirestore.instance
        .collection('timetables')
        .doc(widget.document.id)
        .update({
      'courseCode': _courseController.text,
      'day': _dayController.text,
      'timeFrom': _timeFromController.text,
      'timeTo': _timeToController.text,
      'venue': _venueController.text,
      'lecturer': _lecturerController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timetable updated successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Timetable Entry'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_courseController, 'Course Code'),
              const SizedBox(height: 16.0),
              _buildTextField(_dayController, 'Day (e.g., Monday)'),
              const SizedBox(height: 16.0),
              _buildTextField(_timeFromController, 'Time (e.g., 12:00 PM)'),
              const SizedBox(height: 16.0),
              _buildTextField(_venueController, 'Venue'),
              const SizedBox(height: 16.0),
              _buildTextField(_lecturerController, 'Lecturer'),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _updateTimetable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child:
                    const Text('Update Entry', style: TextStyle(fontSize: 16)),
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
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}
