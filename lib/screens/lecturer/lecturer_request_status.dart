import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LecturerRequestStatusScreen extends StatelessWidget {
  const LecturerRequestStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String lecturerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Edit Requests'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('edit_requests')
            .where('lecturerId', isEqualTo: lecturerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text('No requests found'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text('Course: ${request['course'] ?? 'N/A'}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Day: ${request['day'] ?? 'N/A'}'),
                      Text('From: ${request['timeFrom'] ?? 'N/A'}'),
                      Text('To: ${request['timeTo'] ?? 'N/A'}'),
                      Text('Venue: ${request['venue'] ?? 'N/A'}'),
                      Text('Status: ${request['status'] ?? 'N/A'}'),
                      if (request['adminComments'] != null)
                        Text('Admin Comments: ${request['adminComments']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
