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
        title: const Text(
          'Manage Timetable',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        // backgroundColor: Colors.blueAccent,
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

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Enable horizontal scrolling
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
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () =>
                              _editTimetableEntry(context, timetable),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteTimetableEntry(timetable.id),
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
