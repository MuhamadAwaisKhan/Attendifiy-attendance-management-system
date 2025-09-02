import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckStatusLeave extends StatefulWidget {
  final String uid;

  const CheckStatusLeave({super.key, required this.uid});

  @override
  State<CheckStatusLeave> createState() => _CheckStatusLeaveState();
}

class _CheckStatusLeaveState extends State<CheckStatusLeave> {
  final _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getStatusRequests() {
    return _firestore
        .collection('leave_requests')
        .where('userId', isEqualTo: widget.uid)
        .orderBy('requestedAt', descending: true)
        .snapshots();
  }

  // Function to get status color & icon
  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Icons.check_circle;
      case "rejected":
        return Icons.cancel;
      default:
        return Icons.hourglass_top;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Check Leave Status",
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getStatusRequests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          var requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return Center(
              child: Text(
                "No leave requests found",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var requestData = requests[index];
              String status = requestData['status'] ?? 'Pending';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  leading: Icon(
                    getStatusIcon(status),
                    color: getStatusColor(status),
                    size: 30,
                  ),
                  title: Text(
                    "Reason: ${requestData['reason'] ?? 'N/A'}",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.info, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 5),
                          Text(
                            "Status: $status",
                            style: GoogleFonts.poppins(
                              color: getStatusColor(status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.message, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              requestData['notificationMessage'] ?? 'No message',
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
