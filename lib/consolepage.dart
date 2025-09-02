import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:attendencesystem/student/loginpage.dart';
import 'package:attendencesystem/faculty/loginpagefaculty.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class consolepage extends StatefulWidget {
  const consolepage({super.key});

  @override
  State<consolepage> createState() => _consolepageState();
}

class _consolepageState extends State<consolepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Console Page",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/customer.json',
            height: 200,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 20,),
          UIHelper.customButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
          }, text: "Student Console",width: 200),
          SizedBox(height: 10,),
          UIHelper.customButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreenfaculty()));

          }, text: "Faculty Console",width: 200),
        ],
      ),
    );
  }
}
