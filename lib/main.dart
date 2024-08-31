import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timetable_management_system/firebase_options.dart';
import 'package:timetable_management_system/screens/admin/admin_home.dart';
import 'package:timetable_management_system/screens/login_screen.dart';
import 'package:timetable_management_system/screens/signup_screen.dart';
import 'package:timetable_management_system/screens/scan_qr_code_screen.dart';
import 'package:timetable_management_system/screens/generate_qr_code_screen.dart';
import 'screens/admin/admin_manage_request_screen.dart';
import 'screens/admin/admin_manage_users.dart';
import 'screens/lecturer/lecturer_home.dart';
import 'screens/lecturer/lecturer_request_status.dart';
import 'screens/students/student_home.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create Notification Channel
  createNotificationChannel(flutterLocalNotificationsPlugin);

  runApp(const MyApp());
}

void createNotificationChannel(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'timetable_updates_channel', // Channel ID
    'Timetable Updates', // Channel name
    description: 'This channel is used for timetable update notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
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
      debugShowCheckedModeBanner: false,
      home:
          const AuthChecker(), // Check user authentication status // Default route on startup
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/adminHome': (context) => const AdminHomeScreen(),
        '/lecturerHome': (context) => const LecturerHomeScreen(),
        '/studentHome': (context) => const StudentHomeScreen(),
        '/scanQRCode': (context) => const ScanQRCodeScreen(),
        '/generateQRCode': (context) => const GenerateQRCodeScreen(),
        //'/adminManageUsers': (context) => const AdminManageUsersScreen(),
        //'/adminManageRequests': (context) => const AdminManageRequestsScreen(),
        '/lecturerRequestStatus': (context) =>
            const LecturerRequestStatusScreen(),
        // Add more routes as needed
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          User? user = snapshot.data;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (roleSnapshot.hasData && roleSnapshot.data != null) {
                final role = roleSnapshot.data!.get('role');
                if (role == 'admin') {
                  return const AdminHomeScreen();
                } else if (role == 'lecturer') {
                  return const LecturerHomeScreen();
                } else if (role == 'student') {
                  return const StudentHomeScreen();
                } else {
                  return const LoginScreen(); // Fallback in case of unexpected role
                }
              } else {
                return const LoginScreen();
              }
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
