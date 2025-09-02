import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:attendencesystem/admin/admindashboard.dart';
import 'package:attendencesystem/consolepage.dart';
import 'package:attendencesystem/faculty/facultydashboard.dart';
import 'package:attendencesystem/student/loginpage.dart';
import 'package:attendencesystem/student/stdhomescreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  Future<void> _startSplashTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    // Set timer: 9s first time, 4s otherwise
    int splashDuration = isFirstTime ? 4 : 3;

    // After first time, set isFirstTime = false
    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
    }

    Timer(Duration(seconds: splashDuration), () { checkLogin();
    });
  }
//? By Shared Preferences
  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool userlogin = prefs.getBool("isLoggedIn") ?? false;
    String? userrole = prefs.getString("role");

    if (userlogin) {
      // If logged in, go to respective dashboard
      if (userrole == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentDashboard()),
        );
      }
      else  if (userrole == 'faculty') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => facultydashboard()),
        );
      }
      else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      }
    } else {
      // If not logged in, go to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => consolepage()),
      );
    }
  }
     //? By Firebase Auth
  // Future<void> _checkUserRole() async {
  //   final auth = FirebaseAuth.instance;
  //   final user = auth.currentUser;
  //
  //   if (user != null) {
  //     final userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .get();
  //
  //     if (userDoc.exists) {
  //       final role = userDoc.data()?['role'];
  //
  //       if (role == 'student') {
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => StudentDashboard()),
  //         );
  //       } else if (role == 'admin') {
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => AdminDashboard()),
  //         );
  //       } else {
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => LoginScreen()),
  //         );
  //       }
  //     } else {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => LoginScreen()),
  //       );
  //     }
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => LoginScreen()),
  //     );
  //   }
  // }

  @override
  void dispose() {
    controller.dispose(); // prevent memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // splash bg color
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo
          CachedNetworkImage(
            imageUrl:
                "https://wpschoolpress.com/wp-content/uploads/2023/05/Attendance-Management-System.png",
            height: 150,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ), // Shows loader until image loads
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
            // If image fails to load
            fit: BoxFit.cover, // optional
          ),
          const SizedBox(height: 20),

          // App name
          Text(
            "ATTENDIFY",
            style: GoogleFonts.poppins(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),

          const SizedBox(height: 10),

          // Rotating text
          Container(
            height: 200,
            child: DefaultTextStyle(
              style: GoogleFonts.poppins(
                fontSize: 17.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  RotateAnimatedText('ATTENDANCE'),
                  RotateAnimatedText('MANAGEMENT'),
                  RotateAnimatedText('SYSTEM'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Loading animation
          SpinKitFadingCircle(
            color: Colors.blue, // changed from white (invisible on white bg)
            size: 50.0,
            controller: controller,
          ),
        ],
      ),
    );
  }
}
