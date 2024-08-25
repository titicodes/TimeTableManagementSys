import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestEditScreen extends StatefulWidget {
  @override
  _RequestEditScreenState createState() => _RequestEditScreenState();
}

class _RequestEditScreenState extends State<RequestEditScreen> {
  final _courseController = TextEditingController();
  final _reasonController = TextEditingController();

  void _submitRequest() async {
    String course = _courseController.text.trim();
    String reason = _reasonController.text.trim();

    if (course.isEmpty || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields.'),
      ));
      return;
    }

    // Submit the request to Firestore (to be handled by Admin)
    await FirebaseFirestore.instance.collection('edit_requests').add({
      'course': course,
      'reason': reason,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Edit request submitted.'),
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Timetable Edit'),
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
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Reason for Request'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRequest,
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
