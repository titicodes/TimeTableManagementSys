import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LecturerTimetableScreen extends StatelessWidget {
  const LecturerTimetableScreen({super.key});

  void _requestEdit(BuildContext context, DocumentSnapshot timetable) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController courseController =
            TextEditingController(text: timetable['courseCode']);
        TextEditingController dayController =
            TextEditingController(text: timetable['day']);
        TextEditingController fromTimeController =
            TextEditingController(text: timetable['timeFrom']);
        TextEditingController toTimeController =
            TextEditingController(text: timetable['timeTo']);
        TextEditingController venueController =
            TextEditingController(text: timetable['venue']);

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
                  controller: fromTimeController,
                  decoration: const InputDecoration(labelText: 'From Time'),
                ),
                TextField(
                  controller: toTimeController,
                  decoration: const InputDecoration(labelText: 'To Time'),
                ),
                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(labelText: 'Venue'),
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
                  'courseCode': courseController.text,
                  'day': dayController.text,
                  'timeFrom': fromTimeController.text,
                  'timeTo': toTimeController.text,
                  'venue': venueController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Timetable'),
        centerTitle: true,
       // backgroundColor: Colors.blueAccent,
       automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('timetables').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: timetables.length,
              itemBuilder: (context, index) {
                final timetable = timetables[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      timetable['courseCode'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Day: ${timetable['day']}',
                              style: TextStyle(color: Colors.grey[700])),
                          Text('From Time: ${timetable['timeFrom']}',
                              style: TextStyle(color: Colors.grey[700])),
                          Text('To Time: ${timetable['timeTo']}',
                              style: TextStyle(color: Colors.grey[700])),
                          Text('Venue: ${timetable['venue']}',
                              style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () {
                        _requestEdit(context, timetable);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
