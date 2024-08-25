import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanQRCodeScreen extends StatefulWidget {
  const ScanQRCodeScreen({super.key});

  @override
  _ScanQRCodeScreenState createState() => _ScanQRCodeScreenState();
}

class _ScanQRCodeScreenState extends State<ScanQRCodeScreen> {
  String _scanResult = '';

  Future<void> _scanQRCode() async {
    try {
      String scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);

      if (scanResult != '-1') {
        setState(() {
          _scanResult = scanResult;
        });

        _signInWithQRCode(scanResult);
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Failed to get the scan result.';
      });
    }
  }

  Future<void> _signInWithQRCode(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String role = userDoc['role'];

        // You can sign in the user and navigate them to their appropriate dashboard
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/adminHome');
        } else if (role == 'lecturer') {
          Navigator.pushReplacementNamed(context, '/lecturerHome');
        } else if (role == 'student') {
          Navigator.pushReplacementNamed(context, '/studentHome');
        }
      } else {
        // Handle the case where the user document does not exist
        setState(() {
          _scanResult = 'Invalid QR code.';
        });
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Error during sign-in: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Sign-In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _scanQRCode,
              child: const Text('Scan QR Code'),
            ),
            const SizedBox(height: 20),
            Text(_scanResult),
          ],
        ),
      ),
    );
  }
}
