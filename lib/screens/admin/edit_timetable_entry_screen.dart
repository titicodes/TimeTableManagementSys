import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class EditTimetableEntryScreen extends StatefulWidget {
  final DocumentSnapshot document;

  const EditTimetableEntryScreen({super.key, required this.document});

  @override
  _EditTimetableEntryScreenState createState() =>
      _EditTimetableEntryScreenState();
}

class _EditTimetableEntryScreenState extends State<EditTimetableEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _courseCodeController;
  late TextEditingController _dayController;
  late TextEditingController _venueController;
  late TextEditingController _lecturerController;

  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _courseCodeController =
        TextEditingController(text: widget.document['courseCode']);
    _dayController = TextEditingController(text: widget.document['day']);
    _venueController = TextEditingController(text: widget.document['venue']);
    _lecturerController =
        TextEditingController(text: widget.document['lecturer']);

    // Parse time strings into TimeOfDay
    _fromTime = _parseTime(widget.document['timeFrom']);
    _toTime = _parseTime(widget.document['timeTo']);

    // Initialize the local notifications plugin
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    _courseCodeController.dispose();
    _dayController.dispose();
    _venueController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String time) {
    final format = RegExp(r'(\d+):(\d+)\s*(AM|PM)');
    final match = format.firstMatch(time);

    if (match != null) {
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3);

      if (period == 'PM' && hour != 12) {
        return TimeOfDay(hour: hour + 12, minute: minute);
      } else if (period == 'AM' && hour == 12) {
        return TimeOfDay(hour: 0, minute: minute);
      } else {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    // Default fallback in case parsing fails
    return TimeOfDay.now();
  }

  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFromTime ? _fromTime! : _toTime!,
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          _fromTime = picked;
        } else {
          _toTime = picked;
        }
      });
    }
  }

  Future<void> _sendTimetableUpdateNotification() async {
    await FirebaseMessaging.instance.subscribeToTopic('timetable_updates');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'timetable_updates_channel', // Channel ID
      'Timetable Updates', // Channel name
      channelDescription:
          'This channel is used for timetable update notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Timetable Updated',
      'The timetable has been updated. Check the latest schedule.',
      platformChannelSpecifics,
    );
  }

  void _updateTimetableEntry() async {
    if (_formKey.currentState!.validate()) {
      String courseCode = _courseCodeController.text.trim();
      String day = _dayController.text.trim();
      String timeFrom = _fromTime?.format(context) ?? '';
      String timeTo = _toTime?.format(context) ?? '';
      String venue = _venueController.text.trim();
      String lecturer = _lecturerController.text.trim();

      if (courseCode.isNotEmpty &&
          day.isNotEmpty &&
          timeFrom.isNotEmpty &&
          timeTo.isNotEmpty &&
          venue.isNotEmpty &&
          lecturer.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('timetables')
            .doc(widget.document.id)
            .update({
          'courseCode': courseCode,
          'day': day,
          'timeFrom': timeFrom,
          'timeTo': timeTo,
          'venue': venue,
          'lecturer': lecturer,
        });

        // Trigger the notification after update
        await _sendTimetableUpdateNotification();

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timetable entry updated')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Timetable Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _courseCodeController,
                decoration: const InputDecoration(labelText: 'Course Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the course code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _dayController,
                decoration: const InputDecoration(labelText: 'Day'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the day';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context, true),
                      child: Text(
                        _fromTime == null
                            ? 'Select From Time'
                            : 'From: ${_fromTime!.format(context)}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context, false),
                      child: Text(
                        _toTime == null
                            ? 'Select To Time'
                            : 'To: ${_toTime!.format(context)}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Venue'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the venue';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _lecturerController,
                decoration: const InputDecoration(labelText: 'Lecturer'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the lecturer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _updateTimetableEntry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Update Timetable Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
