import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTimetableEntryScreen extends StatefulWidget {
  const AddTimetableEntryScreen({super.key});

  @override
  _AddTimetableEntryScreenState createState() =>
      _AddTimetableEntryScreenState();
}

class _AddTimetableEntryScreenState extends State<AddTimetableEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedLevel;
  String? _selectedCourseCode;
  String? _selectedDay;
  TimeOfDay? _selectedFromTime;
  TimeOfDay? _selectedToTime;
  String? _selectedVenue;
  String? _selectedLecturer;

  final List<Map<String, dynamic>> _timetableEntries = [];

  final List<String> _levels = ['100', '200', '300', '400', '500'];
  final List<String> _courseCodes = ['CSC101', 'MTH101', 'PHY101'];
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];
  final List<String> _venues = ['Hall A', 'Hall B', 'Lab 1'];
  final List<String> _lecturers = ['Dr. Smith', 'Prof. Johnson', 'Dr. Doe'];

  void _addTimetableEntry() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _timetableEntries.add({
          'level': _selectedLevel,
          'courseCode': _selectedCourseCode,
          'day': _selectedDay,
          'timeFrom': _selectedFromTime?.format(context),
          'timeTo': _selectedToTime?.format(context),
          'venue': _selectedVenue,
          'lecturer': _selectedLecturer,
        });
      });

      // Clear selections after adding
      _selectedCourseCode = null;
      _selectedDay = null;
      _selectedFromTime = null;
      _selectedToTime = null;
      _selectedVenue = null;
      _selectedLecturer = null;
    }
  }

  Future<void> _selectTime(BuildContext context,
      {required bool isFromTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          _selectedFromTime = picked;
        } else {
          _selectedToTime = picked;
        }
      });
    }
  }

  void _submitTimetable() async {
    for (var entry in _timetableEntries) {
      await FirebaseFirestore.instance.collection('timetables').add(entry);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timetable submitted successfully!')),
    );

    setState(() {
      _timetableEntries.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Timetable Entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(labelText: 'Select Level'),
                items: _levels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a level' : null,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedCourseCode,
                decoration: const InputDecoration(labelText: 'Course Code'),
                items: _courseCodes.map((code) {
                  return DropdownMenuItem(value: code, child: Text(code));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCourseCode = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a course code' : null,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedDay,
                decoration: const InputDecoration(labelText: 'Day'),
                items: _days.map((day) {
                  return DropdownMenuItem(value: day, child: Text(day));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDay = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a day' : null,
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context, isFromTime: true),
                      child: Text(_selectedFromTime == null
                          ? 'From Time'
                          : _selectedFromTime!.format(context)),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context, isFromTime: false),
                      child: Text(_selectedToTime == null
                          ? 'To Time'
                          : _selectedToTime!.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedVenue,
                decoration: const InputDecoration(labelText: 'Venue'),
                items: _venues.map((venue) {
                  return DropdownMenuItem(value: venue, child: Text(venue));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVenue = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a venue' : null,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedLecturer,
                decoration: const InputDecoration(labelText: 'Lecturer'),
                items: _lecturers.map((lecturer) {
                  return DropdownMenuItem(
                      value: lecturer, child: Text(lecturer));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLecturer = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a lecturer' : null,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _addTimetableEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Add Entry', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 30.0),
              _timetableEntries.isEmpty
                  ? const Text('No timetable entries added yet.')
                  : DataTable(
                      columns: const [
                        DataColumn(label: Text('Course Code')),
                        DataColumn(label: Text('Day')),
                        DataColumn(label: Text('From')),
                        DataColumn(label: Text('To')),
                        DataColumn(label: Text('Venue')),
                        DataColumn(label: Text('Lecturer')),
                      ],
                      rows: _timetableEntries.map((entry) {
                        return DataRow(cells: [
                          DataCell(Text(entry['courseCode'])),
                          DataCell(Text(entry['day'])),
                          DataCell(Text(entry['timeFrom'] ?? 'N/A')),
                          DataCell(Text(entry['timeTo'] ?? 'N/A')),
                          DataCell(Text(entry['venue'])),
                          DataCell(Text(entry['lecturer'])),
                        ]);
                      }).toList(),
                    ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _submitTimetable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Submit Timetable',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
