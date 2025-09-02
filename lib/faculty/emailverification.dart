import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'facultydashboard.dart'; // <-- Import your dashboard screen

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start auto-check every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification(autoCheck: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerification({bool autoCheck = false}) async {
    if (_isChecking) return; // Prevent multiple checks at once
    setState(() => _isChecking = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        Fluttertoast.showToast(msg: "Email verified successfully!");
        _timer?.cancel(); // Stop auto-checking

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => facultydashboard()),
          );
        }
      } else if (!autoCheck) {
        Fluttertoast.showToast(msg: "Email is not verified yet.");
      }
    } catch (e) {
      if (!autoCheck) {
        Fluttertoast.showToast(msg: "Error checking verification: $e");
      }
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        Fluttertoast.showToast(msg: "Verification email sent successfully!");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error sending email: $e");
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Verify Email",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/email.json', height: 150),
              const SizedBox(height: 20),
              Text(
                "A verification email has been sent. Please verify before proceeding.",
                style: GoogleFonts.poppins(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _isChecking ? null : () => _checkEmailVerification(),
                icon: _isChecking
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_circle, color: Colors.white),
                label: Text("Check Verification Now",
                    style: GoogleFonts.poppins(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _isResending ? null : _resendVerificationEmail,
                icon: _isResending
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.email, color: Colors.white),
                label: Text("Resend Verification Email",
                    style: GoogleFonts.poppins(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              const SizedBox(height: 20),

              TextButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel, color: Colors.white),
                label: const Text("Cancel",
                    style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
