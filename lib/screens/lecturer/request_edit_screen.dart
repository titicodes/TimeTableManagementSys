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
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _courseController,
                    decoration: InputDecoration(
                      labelText: 'Course',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: 'Reason for Request',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    maxLines: 3, // Allow multiple lines for the reason
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: _submitRequest,
                    child: const Text('Submit Request',
                        style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
