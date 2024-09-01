import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AddTimetableEntryScreen extends StatefulWidget {
  const AddTimetableEntryScreen({super.key});

  @override
  _AddTimetableEntryScreenState createState() =>
      _AddTimetableEntryScreenState();
}

class _AddTimetableEntryScreenState extends State<AddTimetableEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _timetableEntries = [];

  String? _selectedLevel;
  String? _selectedDay;
  TimeOfDay? _selectedFromTime;
  TimeOfDay? _selectedToTime;
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _lecturerController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();

  final List<String> _levels = ['100', '200', '300', '400', '500'];
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];

  @override
  void initState() {
    super.initState();
    requestPermission(); // Request notification permission on init
  }

  Future<void> requestPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void _addTimetableEntry() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _timetableEntries.add({
          'level': _selectedLevel,
          'courseCode': _courseCodeController.text.trim(),
          'day': _selectedDay,
          'timeFrom': _selectedFromTime?.format(context),
          'timeTo': _selectedToTime?.format(context),
          'venue': _venueController.text.trim(),
          'lecturer': _lecturerController.text.trim(),
        });
      });
      _clearFormFields();
    }
  }

  void _clearFormFields() {
    _courseCodeController.clear();
    _selectedDay = null;
    _selectedLevel = null;
    _selectedFromTime = null;
    _selectedToTime = null;
    _venueController.clear();
    _lecturerController.clear();
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

  Future<void> _sendNotification(String topic, String message) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    await FirebaseFirestore.instance.collection('notifications').add({
      'topic': topic,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _submitTimetable() async {
    try {
      for (var entry in _timetableEntries) {
        await FirebaseFirestore.instance.collection('timetables').add(entry);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable submitted successfully!')),
      );

      setState(() {
        _timetableEntries.clear();
      });

      // Send notifications
      await _sendNotification(
          'timetable_students', 'A new timetable has been updated.');
      await _sendNotification(
          'timetable_lecturers', 'A new timetable has been updated.');
    } catch (e) {
      print("Error submitting timetable: $e");
    }
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
              _buildDropdownField('Select Level', _levels, (value) {
                setState(() {
                  _selectedLevel = value;
                });
              }, (value) => value == null ? 'Please select a level' : null),
              const SizedBox(height: 16.0),
              _buildTextField(_courseCodeController, 'Course Code',
                  'Please enter a course code'),
              const SizedBox(height: 16.0),
              _buildDropdownField('Day', _days, (value) {
                setState(() {
                  _selectedDay = value;
                });
              }, (value) => value == null ? 'Please select a day' : null),
              const SizedBox(height: 16.0),
              _buildTimePickerButtons(),
              const SizedBox(height: 16.0),
              _buildTextField(
                  _venueController, 'Venue', 'Please enter a venue'),
              const SizedBox(height: 16.0),
              _buildTextField(_lecturerController, 'Lecturer',
                  'Please enter a lecturer name'),
              const SizedBox(height: 20.0),
              _buildAddEntryButton(),
              const SizedBox(height: 30.0),
              _buildTimetableDataTable(),
              const SizedBox(height: 20.0),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items,
      ValueChanged<String?> onChanged, FormFieldValidator<String?> validator) {
    return DropdownButtonFormField<String>(
      value: _selectedLevel,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String errorMessage) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? errorMessage : null,
    );
  }

  Widget _buildTimePickerButtons() {
    return Row(
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
    );
  }

  Widget _buildAddEntryButton() {
    return ElevatedButton(
      onPressed: _addTimetableEntry,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: const Text('Add Entry', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildTimetableDataTable() {
    return _timetableEntries.isEmpty
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
          );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitTimetable,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: const Text('Submit Timetable', style: TextStyle(fontSize: 16)),
    );
  }
}
