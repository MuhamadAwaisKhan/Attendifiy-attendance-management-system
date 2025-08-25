import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class LeaveApprovalScreen extends StatelessWidget {
  const LeaveApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;

    Stream<QuerySnapshot> getPendingRequests() {
      return _firestore
          .collection('leave_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('requestedAt', descending: true)
          .snapshots();
    }

    Future<void> updateLeaveStatus(String requestId, String status) async {
      var requestDoc =
      await _firestore.collection('leave_requests').doc(requestId).get();
      String userId = requestDoc['userId'];
      DateTime leaveDate = (requestDoc['date'] as Timestamp).toDate();

      // Notification message
      String message = status == "approved"
          ? "Your leave for ${DateFormat('dd-MM-yyyy').format(leaveDate)} has been approved."
          : "Your leave for ${DateFormat('dd-MM-yyyy').format(leaveDate)} has been rejected.";

      // Update leave request
      await _firestore.collection('leave_requests').doc(requestId).update({
        'status': status,
        'reviewedAt': Timestamp.now(),
        'notificationMessage': message,
      });

      // Mark Attendance
      String attendanceStatus =
      status == "approved" ? "Approved Leave" : "Absent";

      await _firestore.collection('attendance').add({
        'userId': userId,
        'date': DateFormat('yyyy-MM-dd').format(leaveDate),
        'status': attendanceStatus,
        'markedAt': Timestamp.now(),
      });
    }

    Future<Map<String, int>> getAttendanceCounts(String userId) async {
      var snapshot = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .get();

      int present = 0;
      int absent = 0;
      int approvedLeave = 0;

      for (var doc in snapshot.docs) {
        String status = doc['status'];
        if (status == "Present") {
          present++;
        } else if (status == "Absent") {
          absent++;
        } else if (status == "Approved Leave") {
          approvedLeave++;
        }
      }

      return {
        'present': present,
        'absent': absent,
        'approvedLeave': approvedLeave,
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Approve Leaves',
          style: GoogleFonts.poppins(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getPendingRequests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          var requests = snapshot.data!.docs;
          if (requests.isEmpty) {
            return Center(
              child: Text("No pending requests",
                  style: GoogleFonts.poppins(fontSize: 16)),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var requestData = requests[index];
              String userId = requestData['userId'];
              DateTime leaveDate =
              (requestData['date'] as Timestamp).toDate();

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                          title: Text("Loading user info...",
                              style: GoogleFonts.poppins())),
                    );
                  }

                  var userData =
                  userSnapshot.data!.data() as Map<String, dynamic>?;

                  return FutureBuilder<Map<String, int>>(
                    future: getAttendanceCounts(userId),
                    builder: (context, attendanceSnapshot) {
                      var counts = attendanceSnapshot.data ?? {
                        'present': 0,
                        'absent': 0,
                        'approvedLeave': 0
                      };

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text("Reason: ${requestData['reason']}",
                              style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name: ${userData?['name'] ?? 'N/A'}",
                                  style: GoogleFonts.poppins()),
                              Text("Reg No: ${userData?['regno'] ?? 'N/A'}",
                                  style: GoogleFonts.poppins()),
                              Text("Email: ${userData?['email'] ?? 'N/A'}",
                                  style: GoogleFonts.poppins()),
                              Text(
                                  "Date: ${DateFormat('dd-MM-yyyy').format(leaveDate)}",
                                  style: GoogleFonts.poppins()),

                              // Show counts here
                              const SizedBox(height: 4),
                              Text("Present: ${counts['present']}",
                                  style: GoogleFonts.poppins(
                                      color: Colors.green)),
                              Text("Absent: ${counts['absent']}",
                                  style: GoogleFonts.poppins(
                                      color: Colors.red)),
                              Text("Approved Leaves: ${counts['approvedLeave']}",
                                  style: GoogleFonts.poppins(
                                      color: Colors.orange)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                const Icon(Icons.check, color: Colors.green),
                                onPressed: () => updateLeaveStatus(
                                    requestData.id, "approved"),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => updateLeaveStatus(
                                    requestData.id, "rejected"),
                              ),
                            ],
                          ),
                        ),
                      );
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
