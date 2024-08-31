import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentTimetableScreen extends StatelessWidget {
  const StudentTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Timetable'),
        automaticallyImplyLeading: false,
        centerTitle: true,
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
              ],
              rows: timetables.map((timetable) {
                return DataRow(cells: [
                  DataCell(Text(timetable['courseCode'] ?? 'N/A')),
                  DataCell(Text(timetable['day'] ?? 'N/A')),
                  DataCell(Text(timetable['timeFrom'] ?? 'N/A')),
                  DataCell(Text(timetable['timeTo'] ?? 'N/A')),
                  DataCell(Text(timetable['venue'] ?? 'N/A')),
                  DataCell(Text(timetable['lecturer'] ?? 'N/A')),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
