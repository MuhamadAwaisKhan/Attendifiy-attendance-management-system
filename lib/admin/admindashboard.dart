import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:attendencesystem/admin/viewallstudentattendance.dart';
import 'package:attendencesystem/admin/viewrecord.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../faculty/loginpagefaculty.dart';
import '../service/notificationservice.dart';
import '../student/loginpage.dart';
import 'leaveapprovalscreenadmin.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _listenToLeaveRequests(); // 🔔 start listening when admin logs in
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLoggedIn", false);
      String? role = prefs.getString("side");
      await prefs.clear();

      if (role == "faculty") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreenfaculty()),
              (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  /// 🔔 Listen for NEW leave requests
  void _listenToLeaveRequests() {
    FirebaseFirestore.instance
        .collection('leave_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final data = docChange.doc.data()!;
          final userId = data['userId'];
          final date = (data['date'] as Timestamp).toDate();

          // 👇 Lookup student details
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get()
              .then((userDoc) {
            final studentregno = userDoc['regno']; // or whatever field you store
            NotificationService.showNotification(
              "New Leave Request",
              "Student $studentregno requested leave for ${DateFormat('dd-MM-yyyy').format(date)}",
            );
          });
        }
      }
    });
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
                  child: Text("No", style: GoogleFonts.poppins(color: Colors.red)),
                ),
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Yes", style: GoogleFonts.poppins(color: Colors.white)),
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
            "Admin Dashboard",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 0),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              onPressed: () => logout(context),
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UIHelper.customButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => viewrecord()));
                  },
                  text: "Students",
                  icon: Icons.person,
                  width: 260,
                ),
                const SizedBox(height: 20),
                UIHelper.customButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => viewallstdattendanceadmin()));
                  },
                  text: "View All Attendance",
                  icon: Icons.person,
                  width: 260,
                ),
                const SizedBox(height: 20),
                UIHelper.customButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveApprovalScreen()));
                  },
                  text: "Manage Leave Request",
                  icon: Icons.request_page,
                  width: 260,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
