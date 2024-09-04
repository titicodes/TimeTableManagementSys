import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timetable_management_system/firebase_options.dart';
import 'package:timetable_management_system/screens/admin/admin_home.dart';
import 'package:timetable_management_system/screens/admin/admin_manage_request_screen.dart';
import 'package:timetable_management_system/screens/login_screen.dart';
import 'package:timetable_management_system/screens/signup_screen.dart';
import 'package:timetable_management_system/screens/scan_qr_code_screen.dart';
import 'package:timetable_management_system/screens/generate_qr_code_screen.dart';
import 'screens/lecturer/lecturer_home.dart';
import 'screens/students/student_home.dart';
import 'screens/lecturer/lecturer_request_status.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permissions
  await requestNotificationPermissions();

  // Initialize local notifications
  await setupFlutterNotifications();

// Call this after initializing Flutter notifications
  listenToForegroundMessages();

  runApp(const MyApp());
}

void listenToForegroundMessages() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'timetable_updates_channel',
            'Timetable Updates',
            channelDescription:
                'This channel is used for timetable update notifications.',
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });
}

Future<void> requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

Future<void> setupFlutterNotifications() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'timetable_updates_channel', // Channel ID
    'Timetable Updates', // Channel name
    description: 'This channel is used for timetable update notifications.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      const InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

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
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const AuthChecker(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/adminHome': (context) => const AdminHomeScreen(),
        '/lecturerHome': (context) => const LecturerHomeScreen(),
        '/studentHome': (context) => const StudentHomeScreen(),
        '/scanQRCode': (context) => const ScanQRCodeScreen(),
        '/generateQRCode': (context) => const GenerateQRCodeScreen(),
        '/lecturerRequestStatus': (context) =>
            const LecturerRequestStatusScreen(),
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
              body: Center(child: CircularProgressIndicator()));
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
                    body: Center(child: CircularProgressIndicator()));
              } else if (roleSnapshot.hasData && roleSnapshot.data != null) {
                final role = roleSnapshot.data!.get('role');
                if (role == 'admin') {
                  return const AdminHomeScreen();
                } else if (role == 'lecturer') {
                  return const LecturerHomeScreen();
                } else if (role == 'student') {
                  return const StudentHomeScreen();
                } else {
                  return const LoginScreen();
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
