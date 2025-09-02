import 'package:attendencesystem/faculty/courses.dart';
import 'package:attendencesystem/faculty/editprofilefaculty.dart';
import 'package:attendencesystem/faculty/loginpagefaculty.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../UIHelper/customwidgets.dart';
import '../service/authservice.dart';

class facultydashboard extends StatefulWidget {
  const facultydashboard({super.key});

  @override
  State<facultydashboard> createState() => _facultydashboardState();
}

class _facultydashboardState extends State<facultydashboard> {
  final _auth = FirebaseAuth.instance;
  String? selectedRole; // Changed to nullable String
  String? lastAttendanceStatus; // Added this variable
  bool isloading = false;
initState(){
  super.initState();
  autoMarkAbsent();
}
  /// ✅ Show Attendance Options
  Future<String?> showOptionBox(BuildContext context) async {
    String? dialogSelectedRole; // Local variable for the dialog

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Take Attendance",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    child: ListTile(
                      title: Text(
                        "Present ✅",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      leading: Radio<String>(
                        activeColor: Colors.green,
                        fillColor: MaterialStateProperty.all(Colors.green),
                        value: "Present",
                        groupValue: dialogSelectedRole,
                        onChanged: (value) {
                          setState(() {
                            dialogSelectedRole = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text(
                        "Absent ❌",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      leading: Radio<String>(
                        activeColor: Colors.red,
                        fillColor: MaterialStateProperty.all(Colors.red),
                        value: "Absent",
                        groupValue: dialogSelectedRole,
                        onChanged: (value) {
                          setState(() {
                            dialogSelectedRole = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () => Navigator.pop(context, dialogSelectedRole),
                  child: Text(
                    "OK",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);
    await prefs.remove("isLoggedIn");
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreenfaculty()),
    );
  }

  Future<void> markAttendance(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final uid = _auth.currentUser!.uid;
    final now = DateTime.now();
    final date = DateFormat('dd-MM-yyyy').format(now);

    // Define attendance marking window: 9:00 AM - 10:00 AM
    final startTime = DateTime(now.year, now.month, now.day, 8, 30); // 8:30 AM
    final endTime = DateTime(now.year, now.month, now.day, 10, 0); // 10:00 AM

    // Check if current time is within the allowed window
    if (now.isBefore(startTime) || now.isAfter(endTime)) {
      UIHelper.customalertbox(
        context,
        "Attendance can only be marked between 8:30 AM - 10:00 AM ⏰",
      );
      return;
    }

    try {
      final markRef = await firestore
          .collection('facultyattendance')
          .where('userId', isEqualTo: uid)
          .where('date', isEqualTo: date)
          .get();

      if (markRef.docs.isNotEmpty) {
        // Already marked
        UIHelper.customalertbox(
          context,
          "You have already marked attendance today!",
        );
      } else {
        // Show attendance status options
        final value = await showOptionBox(context);
        if (value != null && value.isNotEmpty) {
          setState(() {
            isloading = true;
          });

          try {
            await firestore.collection('facultyattendance').add({
              'userId': uid,
              "date": date,
              "status": value,
              "markedAt": FieldValue.serverTimestamp(),
            });

            setState(() {
              isloading = false;
              lastAttendanceStatus = value;
            });

            UIHelper.customalertbox(context, "Attendance marked as $value ✅");
          } catch (e) {
            setState(() {
              isloading = false;
            });
            UIHelper.customalertbox(context, "Error: $e");
          }
        }
      }
    } catch (e) {
      UIHelper.customalertbox(context, "Error: $e");
    }
  }
  Future<void> autoMarkAbsent() async {
    final firestore = FirebaseFirestore.instance;
    final today = DateTime.now();
    final date = DateFormat('dd-MM-yyyy').format(today);

    // Time window end: 10 AM
    final endTime = DateTime(today.year, today.month, today.day, 10, 0);

    if (DateTime.now().isAfter(endTime)) {
      final users = await firestore.collection('faculty').get();

      for (var user in users.docs) {
        final uid = user.id;

        // Check if attendance exists for this user
        final markRef = await firestore
            .collection('facultyattendance') // ✅ FIXED name
            .where('userId', isEqualTo: uid)
            .where('date', isEqualTo: date)
            .get();

        if (markRef.docs.isEmpty) {
          // Mark Absent only if no record exists
          await firestore.collection('facultyattendance').add({
            'userId': uid,
            'date': date,
            'status': 'Absent',
            'markedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Exit App",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              content: Text(
                "Do you really want to exit the app?",
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "No",
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    "Yes",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );

        // Return true if user confirmed exit, false otherwise
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Faculty Dashboard",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
          leading: const SizedBox(),
        ),
        body: Stack(
          children: [
            // StudentNotificationListener(), // 👈 This listens for notifications
            // if (isloading)
            //   const Center(
            //     child: CircularProgressIndicator(),
            //   ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UIHelper.customButton(
                    onPressed: () async {
                      bool check = await Authservice().authenticatelocally();
                      if (check) {
                        await markAttendance(context);
                      }
                    },
                    width: 240,
                    icon: Icons.check_circle,
                    text: "Mark Attendance",
                    isLoading: isloading, // Pass loading state to button
                  ),
                  const SizedBox(height: 20),
                  UIHelper.customButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CoursesScreen(),
                        ),
                      );
                    },
                    width: 240,
                    icon: Icons.golf_course_sharp,
                    text: "Courses",
                  ),
                  const SizedBox(height: 20),
                  UIHelper.customButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         MarkLeaveScreen(userId: _auth.currentUser!.uid),
                      //   ),
                      // );
                    },
                    width: 240,
                    icon: Icons.leave_bags_at_home,
                    text: "Mark Leave",
                  ),
                  const SizedBox(height: 20),
                  UIHelper.customButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => ViewAttendance()),
                      // );
                    },
                    width: 240,
                    icon: Icons.history,
                    text: "View Attendance",
                  ),
                  const SizedBox(height: 20),
                  UIHelper.customButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilefaculty(),
                        ),
                      );
                    },
                    width: 240,
                    icon: Icons.person,
                    text: "Edit Profile",
                  ),
                  const SizedBox(height: 20),
                  UIHelper.customButton(
                    onPressed: () async {
                      logout(context);
                    },
                    width: 240,
                    icon: Icons.logout,
                    text: "Logout",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
