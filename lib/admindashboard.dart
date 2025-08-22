import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Provider/authprovider.dart';
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("Admin Dashboard"),
        actions: [
          IconButton(onPressed: (){
            context.read<AuthProvider>().logout(context);
          }, icon: Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // navigate to all students' attendance list
              },
              icon: Icon(Icons.people),
              label: Text("View All Attendance"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // view & approve/reject leave requests
              },
              icon: Icon(Icons.request_page),
              label: Text("Manage Leave Requests"),
            ),
          ],
        ),
      ),
    );
  }
}
