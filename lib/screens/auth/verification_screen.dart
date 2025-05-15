// ✅ Verification.dart

import 'package:flutter/material.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Verification extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const Verification({required this.verificationId, required this.phoneNumber, Key? key}) : super(key: key);

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  String _code = '';
  bool _isLoading = false;

  void verifyOTP() async {
    if (_code.length < 6) return;
    setState(() => _isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, '/profile');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid code: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Enter the 6-digit code sent to your phone", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              VerificationCode(
                length: 6,
                textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                underlineColor: Colors.black,
                keyboardType: TextInputType.number,
                onCompleted: (value) => _code = value,
                onEditing: (value) {},
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: verifyOTP,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verify", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

