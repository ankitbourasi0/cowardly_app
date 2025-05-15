// ✅ RegisterWithPhoneNumber.dart

import 'package:animate_do/animate_do.dart';
import 'package:cowardly_app/screens/auth/verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterWithPhoneNumber extends StatefulWidget {
  const RegisterWithPhoneNumber({Key? key}) : super(key: key);

  @override
  State<RegisterWithPhoneNumber> createState() => _RegisterWithPhoneNumberState();
}

class _RegisterWithPhoneNumberState extends State<RegisterWithPhoneNumber> {
  final TextEditingController controller = TextEditingController();
  String _phoneNumber = '';
  bool _isLoading = false;

  void requestOTP() async {
    setState(() => _isLoading = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacementNamed(context, '/profile');
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Verification(verificationId: verificationId, phoneNumber: _phoneNumber)),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network('https://ouch-cdn2.icons8.com/n9XQxiCMz0_zpnfg9oldMbtSsG7X6NwZi_kLccbLOKw/rs:fit:392:392/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNDMv/MGE2N2YwYzMtMjQw/NC00MTFjLWE2MTct/ZDk5MTNiY2IzNGY0/LnN2Zw.png', fit: BoxFit.cover, width: 280),
              const SizedBox(height: 50),
              FadeInDown(child: Text('REGISTER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.grey.shade900))),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
                  child: Text('Enter your phone number to continue. We will send you an OTP to verify.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black.withOpacity(0.13)),
                    boxShadow: const [BoxShadow(color: Color(0xffeeeeee), blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Stack(
                    children: [
                      InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          _phoneNumber = number.phoneNumber ?? '';
                        },
                        selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.BOTTOM_SHEET),
                        textFieldController: controller,
                        formatInput: false,
                        maxLength: 10,
                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        cursorColor: Colors.black,
                        inputDecoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(bottom: 15, left: 0),
                          border: InputBorder.none,
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                        ),
                      ),
                      Positioned(left: 90, top: 8, bottom: 8, child: Container(height: 40, width: 1, color: Colors.black.withOpacity(0.13))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
              FadeInDown(
                delay: const Duration(milliseconds: 600),
                child: MaterialButton(
                  minWidth: double.infinity,
                  onPressed: _isLoading ? null : requestOTP,
                  color: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  child: _isLoading
                      ? const CircularProgressIndicator(backgroundColor: Colors.white, color: Colors.black, strokeWidth: 2)
                      : const Text("Request OTP", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              FadeInDown(
                delay: const Duration(milliseconds: 800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
                      child: const Text('Login', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
