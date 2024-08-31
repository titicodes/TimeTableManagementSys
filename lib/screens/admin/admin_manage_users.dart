import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminManageUsersScreen extends StatefulWidget {
  const AdminManageUsersScreen({super.key});

  @override
  _AdminManageUsersScreenState createState() => _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState extends State<AdminManageUsersScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  String _selectedRole = 'lecturer'; // Default role
  bool _isLoading = true;
  List<DocumentSnapshot> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _createUser() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': _emailController.text.trim(),
          'fullName': _nameController.text.trim(),
          'dob': _dobController.text.trim(),
          'role': _selectedRole,
        });

        // Clear the form fields
        _emailController.clear();
        _passwordController.clear();
        _nameController.clear();
        _dobController.clear();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User created successfully!'),
        ));

        _fetchUsers(); // Refresh user list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to create user: ${e.toString()}'),
      ));
    }
  }

  void _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    setState(() {
      _users = snapshot.docs;
      _isLoading = false;
    });
  }

  void _deleteUser(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    _fetchUsers(); // Refresh the list after deletion
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_passwordController, 'Password',
                  obscureText: true),
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_dobController, 'Date of Birth (YYYY-MM-DD)'),
              const SizedBox(height: 16.0),
              _buildRoleDropdown(),
              const SizedBox(height: 20), // Space before button
              _buildCreateUserButton(),
              const SizedBox(height: 30), // Space before user list
              _isLoading
                  ? const CircularProgressIndicator()
                  : _users.isEmpty
                      ? const Text('No users found')
                      : _buildUserList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Select Role',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      items: const [
        DropdownMenuItem(value: 'lecturer', child: Text('Lecturer')),
        DropdownMenuItem(value: 'student', child: Text('Student')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedRole = value!;
        });
      },
      isExpanded: true, // Makes dropdown full width
    );
  }

  Widget _buildCreateUserButton() {
    return ElevatedButton(
      onPressed: _createUser,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        minimumSize: const Size(double.infinity, 50), // Full width
        backgroundColor: Colors.blueAccent,
      ),
      child: const Text('Create User'),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        var user = _users[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(user['email'][0].toUpperCase()),
          ),
          title: Text(user['fullName'] ?? 'N/A'), // Corrected field name
          subtitle: Text(
            'Email: ${user['email'] ?? 'N/A'}\n'
            'Role: ${user['role'] ?? 'N/A'}\n'
            'DOB: ${user['dob'] ?? 'N/A'}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmationDialog(user.id);
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(userId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
