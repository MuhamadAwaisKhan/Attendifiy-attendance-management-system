import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:attendencesystem/student/leaveuserscreen.dart';
import 'package:attendencesystem/student/viewattendence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loginpage.dart';
import 'checkleaveuserscreen.dart';
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
                 SizedBox(width: 20),
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
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);
    await prefs.remove("isLoggedIn");
    await prefs.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
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
    return WillPopScope(
      // onWillPop: () async => false,
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title:  Text("Exit App",style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),),
              content:  Text("Do you really want to exit the app?",style: GoogleFonts.poppins(),),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child:  Text("No",style: GoogleFonts.poppins(
                      color: Colors.red
                  )),
                ),
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () => Navigator.of(context).pop(true),
                  child:  Text("Yes",style: GoogleFonts.poppins(
                      color: Colors.white
                  )),
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
      Navigator.push(context, MaterialPageRoute(builder: (context)=>checkstatusleave(uid: _auth.currentUser!.uid,)));

                    },
                    width: 240,
                    icon: Icons.fact_check,
                    text: "Check Leave Status",
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
logout(context);
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
      ),
    );
  }
}
