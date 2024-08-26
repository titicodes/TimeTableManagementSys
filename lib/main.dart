import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timetable_management_system/firebase_options.dart';
import 'package:timetable_management_system/screens/admin/admin_home.dart';
import 'package:timetable_management_system/screens/login_screen.dart';
import 'package:timetable_management_system/screens/signup_screen.dart';
import 'package:timetable_management_system/screens/scan_qr_code_screen.dart';
import 'package:timetable_management_system/screens/generate_qr_code_screen.dart';

import 'screens/admin/admin_manage_users.dart';
import 'screens/lecturer/lecturer_home.dart';
import 'screens/students/student_home.dart';


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    // Initialization settings for Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

 const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    //iOS: initializationSettingsIOS,
  );


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

   await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle the notification tap
      if (response.payload != null) {
        print('Notification payload: ${response.payload}');
        // You can navigate to a specific screen based on the payload
      }
    },
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetable Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',  // Default route on startup
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/adminHome': (context) => const AdminHomeScreen(),
        '/lecturerHome': (context) => const LecturerHomeScreen(),
        '/studentHome': (context) => const StudentHomeScreen(),
        '/scanQRCode': (context) => const ScanQRCodeScreen(),
        '/generateQRCode': (context) => const GenerateQRCodeScreen(),
        '/adminManageUsers': (context) => const AdminManageUsersScreen(),
        // Add more routes as needed
      },
    );
  }
}
