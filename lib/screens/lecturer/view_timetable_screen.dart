import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LecturerTimetableScreen extends StatelessWidget {
  const LecturerTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Timetable'),
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
            itemCount: timetables.length,
            itemBuilder: (context, index) {
              final timetable = timetables[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(timetable['courseName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lecturer: ${timetable['lecturer']}'),
                      Text('Time: ${timetable['time']}'),
                      Text('Venue: ${timetable['venue']}'),
                      Text('Day: ${timetable['day']}'),
                    ],
                  ),
                  // If lecturers are allowed to edit their timetable
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Implement edit functionality here if required
                    },
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
