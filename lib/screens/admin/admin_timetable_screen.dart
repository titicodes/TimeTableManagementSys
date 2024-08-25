import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTimetableScreen extends StatelessWidget {
  const AdminTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Management'),
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
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to edit screen with doc.id
                  },
                ),
                onLongPress: () {
                  // Allow the admin to delete the entry
                  _deleteTimetableEntry(doc.id);
                },
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Navigate to a screen for adding a new timetable entry
        },
      ),
    );
  }

  void _deleteTimetableEntry(String id) {
    FirebaseFirestore.instance.collection('timetable').doc(id).delete();
  }
}
