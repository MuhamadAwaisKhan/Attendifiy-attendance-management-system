
import 'dart:async';

import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:attendencesystem/student/leaveuserscreen.dart';
import 'package:attendencesystem/student/viewattendence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/notificationservice.dart';
import 'loginpage.dart';
import 'checkleaveuserscreen.dart';
import 'editprofile.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final _auth = FirebaseAuth.instance;
  String? selectedRole;
  String? lastAttendanceStatus;
  bool isloading = false;
  StreamSubscription<QuerySnapshot>? _leaveSubscription;
  Set<String> _processedLeaveIds = {};

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _leaveSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService.initNotification();
      _setupStudentLeaveListener();
      print("✅ Notification system initialized");
    } catch (e) {
      print("❌ Error initializing notifications: $e");
    }
  }

  Future<void> _setupStudentLeaveListener() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ No user logged in");
      return;
    }

    print("👂 Setting up leave listener for user: ${user.uid}");

    _leaveSubscription?.cancel();

    _leaveSubscription = FirebaseFirestore.instance
        .collection('leave_requests')
        .where('userId', isEqualTo: user.uid)
        .where('status', whereIn: ['approved', 'rejected']) // only final decisions
        .where('notified', isEqualTo: false) // only unseen
        .snapshots()
        .listen((snapshot) async {
      print("📊 Received ${snapshot.docChanges.length} document changes");

      for (var change in snapshot.docChanges) {
        final data = change.doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final leaveId = change.doc.id;
        final status = (data['status'] ?? 'pending').toString().toLowerCase();

        String dateStr = "unknown date";
        if (data['date'] != null && data['date'] is Timestamp) {
          final leaveDate = (data['date'] as Timestamp).toDate();
          dateStr = DateFormat('dd-MM-yyyy').format(leaveDate);
        }

        // Show notification
        if (status == 'approved') {
          await NotificationService.showNotification(
            "Leave Approved",
            "Your leave for $dateStr was approved ✅",
          );
        } else if (status == 'rejected') {
          await NotificationService.showNotification(
            "Leave Rejected",
            "Your leave for $dateStr was rejected ❌",
          );
        }

        // 🔹 Mark as notified so it won't show again
        await FirebaseFirestore.instance
            .collection('leave_requests')
            .doc(leaveId)
            .update({'notified': true});
      }
    }, onError: (error) {
      print("❌ Error in leave listener: $error");
    });
  }
  Future<String?> showOptionBox(BuildContext context) async {
    String? dialogSelectedRole;

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
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
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
        UIHelper.customalertbox(
          context,
          "You have already marked attendance today!",
        );
        await NotificationService.showNotification(
          "Attendance Already Marked",
          "You already marked your attendance today.",
        );
      } else {
        final value = await showOptionBox(context);
        if (value != null && value.isNotEmpty) {
          setState(() {
            isloading = true;
          });

          try {
            await firestore.collection('attendance').add({
              'userId': uid,
              "date": date,
              "status": value,
              "markedAt": FieldValue.serverTimestamp(),
            });

            setState(() {
              isloading = false;
              lastAttendanceStatus = value;
            });

            await NotificationService.showNotification(
              "Attendance Marked",
              "You marked attendance as $value",
            );
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

        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Student Dashboard",
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
                    isLoading: isloading,
                  ),
                  const SizedBox(height: 20),
                  UIHelper.customButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CheckStatusLeave(uid: _auth.currentUser!.uid)));
                    },
                    width: 240,
                    icon: Icons.fact_check,
                    text: "Check Leave Status",
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
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