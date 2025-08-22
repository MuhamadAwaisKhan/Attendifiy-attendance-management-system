import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ViewAttendance extends StatelessWidget {
  const ViewAttendance({super.key});

  getAttendance() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return CircularProgressIndicator();

    return FirebaseFirestore.instance
        .collection('attendance')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .snapshots();
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Attendance History",
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getAttendance(),
        builder: (context, snapshot) {
          // Loading shimmer
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  highlightColor: Colors.grey.shade100,
                  baseColor: Colors.grey.shade300,
                  child: ListTile(
                    leading: Container(
                      height: 50,
                      width: 50,
                      color: Colors.white,
                    ),
                    title: Container(height: 20, color: Colors.white),
                    subtitle: Container(height: 20, color: Colors.white),
                  ),
                );
              },
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // No records
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No attendance records found"));
          }

          // Show attendance list
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final markedAt = data['markedAt'] as Timestamp?;
              final formattedTime = markedAt != null
                  ? formatTimestamp(markedAt)
                  : "No time available";

              return ListTile(
                leading: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(color: Colors.white),
                  ),
                  alignment: Alignment.center,
                ),
                title: Center(
                  child: Text(
                    data['status'],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                subtitle: Text(
                  "Date: ${data['date']} \nMarked at: $formattedTime",
                  style: GoogleFonts.poppins(fontSize: 15),
                ),
                trailing: Icon(
                  data['status'] == "Present"
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: data['status'] == "Present"
                      ? Colors.green
                      : Colors.red,
                  size: 30,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
