import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:attendencesystem/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
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

    // Navigate to HomePage after 4 seconds
    Timer(const Duration(seconds: 9), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  LoginScreen()),
      );
    });
  }

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
          Image.network(
            "https://wpschoolpress.com/wp-content/uploads/2023/05/Attendance-Management-System.png",
            height: 150,
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

