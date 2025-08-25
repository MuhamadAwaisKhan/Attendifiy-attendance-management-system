import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:attendencesystem/admin/viewallstudentattendance.dart';
import 'package:attendencesystem/admin/viewrecord.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../Provider/authprovider.dart';
import 'leaveapprovalscreenadmin.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

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
            "Admin Dashboard",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: Icon(Icons.admin_panel_settings, color: Colors.white, size: 0),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              onPressed: () {
                context.read<AuthProvider>().logout(context); // ✅
              },
              icon: Icon(Icons.logout, color: Colors.white),
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
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>viewrecord()));
                  },
                  text: "Students",
                  icon: Icons.person,
                  width: 260,
                ),
                const SizedBox(height: 20),
                UIHelper.customButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>viewallstdattendanceadmin()));
                  },
                  text: "View All Attendance",
                  icon: Icons.person,
                  width: 260,
                ),
                const SizedBox(height: 20),
                UIHelper.customButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>LeaveApprovalScreen()));
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
