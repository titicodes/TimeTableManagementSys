import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:timetable_management_system/firebase_options.dart';
import 'package:timetable_management_system/screens/admin/admin_home.dart';
import 'package:timetable_management_system/screens/students/student_home.dart';

import 'screens/admin/admin_manage_users.dart';
import 'screens/generate_qr_code_screen.dart';
import 'screens/lecturer/lecturer_home.dart';
import 'screens/login_screen.dart';
import 'screens/scan_qr_code_screen.dart';
import 'screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetable Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(), // Set the home screen to the login screen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/adminHome': (context) => const AdminHomeScreen(),
        '/lecturerHome': (context) => const LecturerHomeScreen(),
        '/studentHome': (context) => const StudentHomeScreen(),
        '/generateQRCode': (context) => const GenerateQRCodeScreen(),
        '/scanQRCode': (context) => const ScanQRCodeScreen(),
        '/adminManageUsers': (context) => const AdminManageUsersScreen(),
      },
    );
  }
}
