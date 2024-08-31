import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminManageRequestsScreen extends StatelessWidget {
  const AdminManageRequestsScreen({super.key});

  void _approveRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('edit_requests')
        .doc(requestId)
        .update({'status': 'approved'});

    // Optionally, you could add a notification to the lecturer here
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
