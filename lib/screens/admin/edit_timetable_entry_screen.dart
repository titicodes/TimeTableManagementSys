import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class EditTimetableEntryScreen extends StatefulWidget {
  final DocumentSnapshot document;

  const EditTimetableEntryScreen({super.key, required this.document});

  @override
  _EditTimetableEntryScreenState createState() =>
      _EditTimetableEntryScreenState();
}

class _EditTimetableEntryScreenState extends State<EditTimetableEntryScreen> {
  late TextEditingController _courseController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _venueController;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _courseController = TextEditingController(text: widget.document['course']);
    _dateController = TextEditingController(text: widget.document['date']);
    _timeController = TextEditingController(text: widget.document['time']);
    _venueController = TextEditingController(text: widget.document['venue']);
    
    if (!kIsWeb) {
      // Initialize the local notifications plugin only on mobile platforms
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      flutterLocalNotificationsPlugin!.initialize(initializationSettings);
    }
  }

  void _updateTimetable() async {
    String course = _courseController.text.trim();
    String date = _dateController.text.trim();
    String time = _timeController.text.trim();
    String venue = _venueController.text.trim();

    if (course.isNotEmpty &&
        date.isNotEmpty &&
        time.isNotEmpty &&
        venue.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('timetables')
          .doc(widget.document.id)
          .update({
        'course': course,
        'date': date,
        'time': time,
        'venue': venue,
      });

      if (!kIsWeb) {
        // Trigger a local notification to simulate notifying users only on mobile
        _triggerNotification();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Timetable updated and notification sent')),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  void _triggerNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'timetable_updates_channel', // Channel ID
      'Timetable Updates', // Channel Name
      channelDescription: 'This channel is used for timetable update notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin?.show(
      0, // Notification ID
      'Timetable Updated', // Notification Title
      'A new timetable update has been made.', // Notification Body
      platformChannelSpecifics,
      payload: 'timetable_updates', // Optional payload for the notification
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Timetable Entry'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(labelText: 'Course'),
            ),
            TextField(
              controller: _dateController,
              decoration:
                  const InputDecoration(labelText: 'Date (e.g., 22/08/2024)'),
            ),
            TextField(
              controller: _timeController,
              decoration:
                  const InputDecoration(labelText: 'Time (e.g., 12:00 PM)'),
            ),
            TextField(
              controller: _venueController,
              decoration: const InputDecoration(labelText: 'Venue'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateTimetable,
              child: const Text('Update Entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
