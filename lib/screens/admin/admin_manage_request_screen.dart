import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Define this globally or pass it from where it's initialized.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class AdminManageRequestsScreen extends StatelessWidget {
  const AdminManageRequestsScreen({super.key});

  // Function to show a local notification to the lecturer
  Future<void> _showLocalNotification(String status) async {
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
      'Timetable Edit Request $status',
      'Your request to edit the timetable has been $status.',
      platformChannelSpecifics,
    );
  }

  void _approveRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('edit_requests')
        .doc(requestId)
        .update({'status': 'approved'});

    // Show local notification to the lecturer
    await _showLocalNotification('approved');
  }

  void _declineRequest(BuildContext context, String requestId) async {
    TextEditingController commentsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Decline Request'),
          content: TextField(
            controller: commentsController,
            decoration: const InputDecoration(labelText: 'Comments'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('edit_requests')
                    .doc(requestId)
                    .update({
                  'status': 'declined',
                  'adminComments': commentsController.text,
                });

                // Show local notification to the lecturer
                await _showLocalNotification('declined');

                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Decline'),
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
        title: const Text('Manage Edit Requests'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('edit_requests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text('No requests found'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text('Course: ${request['courseCode'] ?? 'N/A'}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reason: ${request['reason'] ?? 'N/A'}'),
                      Text('Status: ${request['status'] ?? 'N/A'}'),
                      if (request['adminComments'] != null)
                        Text('Admin Comments: ${request['adminComments']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approveRequest(request.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _declineRequest(context, request.id),
                      ),
                    ],
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
