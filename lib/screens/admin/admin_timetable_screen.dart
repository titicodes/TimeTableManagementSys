import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_timetable_entry_screen.dart';
class AdminTimetableScreen extends StatelessWidget {
  const AdminTimetableScreen({super.key});

  void _deleteTimetableEntry(String docId) {
    FirebaseFirestore.instance.collection('timetables').doc(docId).delete();
  }

  void _editTimetableEntry(BuildContext context, DocumentSnapshot document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTimetableEntryScreen(document: document),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Timetable'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('timetables').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final timetables = snapshot.data!.docs;

          if (timetables.isEmpty) {
            return const Center(child: Text('No timetable available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0), // Added padding for the ListView
            itemCount: timetables.length,
            itemBuilder: (context, index) {
              final timetable = timetables[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0), // Vertical margin for spacing
                elevation: 4, // Add elevation for a lifted effect
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0), // Padding inside the ListTile
                  title: Text(
                    timetable['course'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4), // Space between title and subtitle
                      Text('Date: ${timetable['date']}'),
                      Text('Time: ${timetable['time']}'),
                      Text('Venue: ${timetable['venue']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _editTimetableEntry(context, timetable),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteTimetableEntry(timetable.id),
                      ),
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