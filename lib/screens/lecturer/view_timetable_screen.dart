import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewTimetableScreen extends StatelessWidget {
  final String role;

  const ViewTimetableScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('timetable').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['course']),
                subtitle: Text(
                    'Date: ${doc['date']}, Time: ${doc['time']}, Venue: ${doc['venue']}'),
                // Customize based on role
                trailing: role == 'lecturer'
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Handle edit request
                        },
                      )
                    : null,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
