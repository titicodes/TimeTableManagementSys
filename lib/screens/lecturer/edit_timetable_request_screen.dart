import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTimetableRequestScreen extends StatefulWidget {
  final DocumentSnapshot? document;

  const EditTimetableRequestScreen({Key? key, this.document}) : super(key: key);

  @override
  _EditTimetableRequestScreenState createState() => _EditTimetableRequestScreenState();
}

class _EditTimetableRequestScreenState extends State<EditTimetableRequestScreen> {
  late TextEditingController _courseController;
  late TextEditingController _dateController;
  late TextEditingController _timeFromController;
    late TextEditingController _timeToController;
  late TextEditingController _venueController;

  @override
  void initState() {
    super.initState();

    // Initialize the text controllers with the current values from the document
    _courseController = TextEditingController(text: widget.document?['courseCode']);
    _dateController = TextEditingController(text: widget.document?['day']);
    _timeFromController = TextEditingController(text: widget.document?['timeFrom']);
     _timeToController = TextEditingController(text: widget.document?['timeTo']);
    _venueController = TextEditingController(text: widget.document?['venue']);
  }

  void _requestUpdate() async {
    String course = _courseController.text.trim();
    String date = _dateController.text.trim();
     String timeTo = _timeToController.text.trim();
    String timeFrom = _timeFromController.text.trim();
    String venue = _venueController.text.trim();

    if (course.isNotEmpty && date.isNotEmpty && timeFrom.isNotEmpty && venue.isNotEmpty && timeTo.isNotEmpty) {
      // Add the update request to Firestore, potentially in a separate collection
      await FirebaseFirestore.instance.collection('timetable_requests').add({
        'course': course,
        'day': date,
        'timeTo': timeTo,
        'timeFrom': timeFrom,
        'venue': venue,
        'status': 'Pending', // Example field to track the request status
        'requestedBy': FirebaseAuth.instance.currentUser?.uid,
      });
      Navigator.pop(context); // Go back to the previous screen after submitting the request
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable change request submitted')),
      );
    } else {
      // Show a message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Timetable Change'),
       // backgroundColor: Colors.blueAccent,
       automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(labelText: 'Course Code'),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Day (e.g., 22/08/2024)'),
            ),
            TextField(
              controller: _timeFromController,
              decoration: const InputDecoration(labelText: 'From (e.g., 12:00 PM)'),
            ),
            TextField(
              controller: _timeFromController,
              decoration: const InputDecoration(labelText: 'To (e.g., 12:00 PM)'),
            ),
            TextField(
              controller: _venueController,
              decoration: const InputDecoration(labelText: 'Venue'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
