import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LecturerTimetableScreen extends StatelessWidget {
  const LecturerTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Timetable'),
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
            return const Center(
                child: Text('No timetable available',
                    style: TextStyle(fontSize: 18)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: timetables.length,
            itemBuilder: (context, index) {
              final timetable = timetables[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: Text(
                    timetable['courseName'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lecturer: ${timetable['lecturer']}',
                            style: TextStyle(color: Colors.grey[700])),
                        Text('Time: ${timetable['time']}',
                            style: TextStyle(color: Colors.grey[700])),
                        Text('Venue: ${timetable['venue']}',
                            style: TextStyle(color: Colors.grey[700])),
                        Text('Day: ${timetable['day']}',
                            style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    color: Colors.blueAccent,
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
