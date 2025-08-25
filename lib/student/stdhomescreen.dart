import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:attendencesystem/student/leaveuserscreen.dart';
import 'package:attendencesystem/student/viewattendence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../service/studentnotificationlistener.dart';
import 'editprofile.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final _auth = FirebaseAuth.instance;
  String selectedRole = "";
  final formattedDate = "21-08-2025";

  /// ✅ Show Attendance Options
  Future showOptionBox(BuildContext context) {
    return showDialog(
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
                        groupValue: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
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
                        groupValue: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
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
                  onPressed: () => Navigator.pop(context, selectedRole),
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
  }

  Future<void> addDummyAttendanceData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final firestore = FirebaseFirestore.instance;
    final uid = user.uid;

    // Dummy dates in "dd-MM-yyyy" format
    List<String> dates = [
      "20-08-2025",
      "21-08-2025",
      "22-08-2025",
      "23-08-2025",
    ];

    for (String date in dates) {
      await firestore.collection('attendance').add({
        'userId': uid,
        'date': date,
        'status': date == "23-08-2025" ? "Absent" : "Present",
        'markedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> markAttendance(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final uid = _auth.currentUser!.uid;
    final today = DateTime.now();
    final date = DateFormat('dd-MM-yyyy').format(today);

    try {
      final markRef = await firestore
          .collection('attendance')
          .where('userId', isEqualTo: uid)
          .where('date', isEqualTo: date)
          .get();

      if (markRef.docs.isNotEmpty) {
        // 👇 Already marked, don't show dialog
        UIHelper.customalertbox(
          context,
          "You have already marked attendance today!",
        );
      } else {
        // 👇 Not marked yet → show options
        final value = await showOptionBox(context);
        if (value != null && value.isNotEmpty) {
          // Add new document to Firestore
          await firestore.collection('attendance').add({
            'userId': uid,
            "date": date,
            "status": value,
            "markedAt": FieldValue.serverTimestamp(),
          });

          UIHelper.customalertbox(context, "Attendance marked as $value ✅");
        }
      }
    } catch (e) {
      UIHelper.customalertbox(context, "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Student Dashboard",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading:  SizedBox(),
      ),
      body: Stack(
        children:[
          // StudentNotificationListener(), // 👈 This listens for notifications

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UIHelper.customButton(
                  onPressed: () async {
                    await markAttendance(context);
                  },
                  width: 240,
                  icon: Icons.check_circle,
                  text: "Mark Attendance",
                ),
                SizedBox(height: 20),
                UIHelper.customButton(
                  onPressed: () {
                    addDummyAttendanceData();
                  },
                  width: 240,
                  icon: Icons.leave_bags_at_home,
                  text: "Dummy attendence",
                ),
                SizedBox(height: 20),
                UIHelper.customButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MarkLeaveScreen(userId: _auth.currentUser!.uid),
                      ),
                    );
                  },
                  width: 240,
                  icon: Icons.leave_bags_at_home,
                  text: "Mark Leave",
                ),
                SizedBox(height: 20),
                UIHelper.customButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewAttendance()),
                    );
                  },
                  width: 240,
                  icon: Icons.history,
                  text: "View Attendance",
                ),
                SizedBox(height: 20),
                UIHelper.customButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile()),
                    );
                  },
                  width: 240,
                  icon: Icons.person,
                  text: "Edit Profile",
                ),
                SizedBox(height: 20),
                UIHelper.customButton(
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.pop(context);
                  },
                  width: 240,
                  icon: Icons.logout,
                  text: "Logout",
                ),
              ],
            ),
          ),

        ]
      ),
    );
  }
}
