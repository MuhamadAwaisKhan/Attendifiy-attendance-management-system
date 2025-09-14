import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class LeaveApprovalScreen extends StatelessWidget {
  const LeaveApprovalScreen({super.key});

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// 🔹 Stream of pending leave requests
  Stream<QuerySnapshot> getPendingRequests() {
    return _firestore
        .collection('leave_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .snapshots();
  }

  /// 🔹 Approve/Reject leave + mark attendance + store notification message
  Future<void> updateLeaveStatus(
      BuildContext context, String requestId, String status) async {
    try {
      var requestDoc =
      await _firestore.collection('leave_requests').doc(requestId).get();
      if (!requestDoc.exists) return;

      String userId = requestDoc['userId'];
      DateTime leaveDate = (requestDoc['date'] as Timestamp).toDate();

      // Message to be stored
      String message = status == "approved"
          ? "✅ Your leave for ${DateFormat('dd-MM-yyyy').format(leaveDate)} has been approved."
          : "❌ Your leave for ${DateFormat('dd-MM-yyyy').format(leaveDate)} has been rejected.";

      // Update leave request
      await FirebaseFirestore.instance
          .collection('leave_requests')
          .doc(requestId)
          .update({
        'status': status, // "approved" or "rejected"
        'reviewedAt': Timestamp.now(),
        'notificationMessage': status == "approved"
            ? "Your leave has been approved ✅"
            : "Your leave has been rejected ❌",
        'notified': false, // 🔹 Important → student will listen for this
      });


      // Mark attendance
      await _firestore.collection('attendance').add({
        'userId': userId,
        'date': DateFormat('dd-MM-yyyy').format(leaveDate),
        'status': status == "approved" ? "Approved Leave" : "Absent",
        'markedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Leave ${status.toUpperCase()} successfully"),
          backgroundColor: status == "approved" ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// 🔹 Attendance counts for a student
  Future<Map<String, int>> getAttendanceCounts(String userId) async {
    var snapshot = await _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .get();

    int present = 0, absent = 0, approvedLeave = 0;

    for (var doc in snapshot.docs) {
      switch (doc['status']) {
        case "Present":
          present++;
          break;
        case "Absent":
          absent++;
          break;
        case "Approved Leave":
          approvedLeave++;
          break;
      }
    }

    return {
      'present': present,
      'absent': absent,
      'approvedLeave': approvedLeave,
    };
  }

  /// 🔹 Build card for each request
  Widget buildRequestCard(BuildContext context, QueryDocumentSnapshot requestData,
      Map<String, dynamic> userData, Map<String, int> counts) {
    DateTime leaveDate = (requestData['date'] as Timestamp).toDate();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Reason: ${requestData['reason']}",
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text("Name: ${userData['name'] ?? 'N/A'}",
                style: GoogleFonts.poppins()),
            Text("Reg No: ${userData['regno'] ?? 'N/A'}",
                style: GoogleFonts.poppins()),
            Text("Email: ${userData['email'] ?? 'N/A'}",
                style: GoogleFonts.poppins()),
            Text("Date: ${DateFormat('dd-MM-yyyy').format(leaveDate)}",
                style: GoogleFonts.poppins()),

            const SizedBox(height: 8),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Chip(
                      label: Text("Present: ${counts['present']}",
                          style: GoogleFonts.poppins(color: Colors.white)),
                      backgroundColor: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Chip(
                      label: Text("Absent: ${counts['absent']}",
                          style: GoogleFonts.poppins(color: Colors.white)),
                      backgroundColor: Colors.red,
                    ),
                    const SizedBox(width: 6),

                  ],
                ),
                Chip(
                  label: Text("Leaves: ${counts['approvedLeave']}",
                      style: GoogleFonts.poppins(color: Colors.white)),
                  backgroundColor: Colors.orange,
                ),
              ],
            ),
            const Divider(height: 20),

            // 🔹 Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(100, 40)),
                  onPressed: () =>
                      updateLeaveStatus(context, requestData.id, "approved"),
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: Text("Approve",
                      style: GoogleFonts.poppins(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(100, 40)),
                  onPressed: () =>
                      updateLeaveStatus(context, requestData.id, "rejected"),
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  label: Text("Reject",
                      style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approve Leaves',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getPendingRequests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
          }

          var requests = snapshot.data!.docs;
          if (requests.isEmpty) {
            return Center(
              child: Text("✅ No pending requests",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var requestData = requests[index];
              String userId = requestData['userId'];

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>? ?? {};

                  return FutureBuilder<Map<String, int>>(
                    future: getAttendanceCounts(userId),
                    builder: (context, attendanceSnapshot) {
                      if (!attendanceSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      return buildRequestCard(
                          context, requestData, userData, attendanceSnapshot.data!);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
