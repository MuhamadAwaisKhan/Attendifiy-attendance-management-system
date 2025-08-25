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
    return Scaffold(
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
              context.read<AuthProvider>().logoutforadmin(context);
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
    );
  }
}
