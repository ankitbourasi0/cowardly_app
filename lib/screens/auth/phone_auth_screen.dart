import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String verificationId = '';

  void verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        // Navigate to home screen
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle errors
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        setState(() {
          verificationId = verId;
        });
      },
    );
  }

  void signInWithOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpController.text.trim(),
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    // Navigate to home screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone Authentication')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone Number')),
            ElevatedButton(onPressed: verifyPhone, child: Text('Verify')),
            TextField(controller: otpController, decoration: InputDecoration(labelText: 'OTP')),
            ElevatedButton(onPressed: signInWithOTP, child: Text('Sign In')),
          ],
        ),
      ),
    );
  }
}
