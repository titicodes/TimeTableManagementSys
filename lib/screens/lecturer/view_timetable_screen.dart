import 'package:firebase_auth/firebase_auth.dart';
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
        automaticallyImplyLeading: false,
       // backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('timetables').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final timetables = snapshot.data!.docs;

          if (timetables.isEmpty) {
            return const Center(
              child: Text('No timetable available',
                  style: TextStyle(fontSize: 18)),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Course Code')),
                DataColumn(label: Text('Day')),
                DataColumn(label: Text('From')),
                DataColumn(label: Text('To')),
                DataColumn(label: Text('Venue')),
                DataColumn(label: Text('Lecturer')),
                DataColumn(label: Text('Actions')),
              ],
              rows: timetables.map((timetable) {
                return DataRow(cells: [
                  DataCell(Text(timetable['courseCode'] ?? 'N/A')),
                  DataCell(Text(timetable['day'] ?? 'N/A')),
                  DataCell(Text(timetable['timeFrom'] ?? 'N/A')),
                  DataCell(Text(timetable['timeTo'] ?? 'N/A')),
                  DataCell(Text(timetable['venue'] ?? 'N/A')),
                  DataCell(Text(timetable['lecturer'] ?? 'N/A')),
                  DataCell(IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () {
                      _requestEdit(context, timetable);
                    },
                  )),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _requestEdit(BuildContext context, DocumentSnapshot timetable) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController courseController =
            TextEditingController(text: timetable['course']);
        TextEditingController dayController =
            TextEditingController(text: timetable['day']);
        TextEditingController timeFromController =
            TextEditingController(text: timetable['timeFrom']);
        TextEditingController timeToController =
            TextEditingController(text: timetable['timeTo']);
        TextEditingController venueController =
            TextEditingController(text: timetable['venue']);
        TextEditingController lecturerController =
            TextEditingController(text: timetable['lecturer']);

        return AlertDialog(
          title: const Text('Request Timetable Edit',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: courseController,
                  decoration: const InputDecoration(labelText: 'Course Code'),
                ),
                TextField(
                  controller: dayController,
                  decoration: const InputDecoration(labelText: 'Day'),
                ),
                TextField(
                  controller: timeFromController,
                  decoration: const InputDecoration(labelText: 'From'),
                ),
                TextField(
                  controller: timeToController,
                  decoration: const InputDecoration(labelText: 'To'),
                ),
                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(labelText: 'Venue'),
                ),
                TextField(
                  controller: lecturerController,
                  decoration: const InputDecoration(labelText: 'Lecturer'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Submit Request'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('edit_requests')
                    .add({
                  'timetableId': timetable.id,
                  'course': courseController.text,
                  'day': dayController.text,
                  'timeFrom': timeFromController.text,
                  'timeTo': timeToController.text,
                  'venue': venueController.text,
                  'lecturer': lecturerController.text,
                  'lecturerId': FirebaseAuth.instance.currentUser?.uid,
                  'status': 'pending',
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit request submitted')),
                );

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
