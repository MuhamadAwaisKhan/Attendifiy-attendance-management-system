import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class checkstatusleave extends StatefulWidget {
  String uid;

  checkstatusleave({super.key, required this.uid});

  @override
  State<checkstatusleave> createState() => _checkstatusleaveState();
}

class _checkstatusleaveState extends State<checkstatusleave> {
  final _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getStatusRequests() {
    return _firestore
        .collection('leave_requests')
        .where('userId', isEqualTo: widget.uid)

        .orderBy('requestedAt', descending: true)
        .snapshots();
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
      body: StreamBuilder(
          stream: getStatusRequests(), builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: Colors.blue),);
        }
        var requests = snapshot.data!.docs;
        if (requests.isEmpty) {
          return Center(child: Text("No leave requests found",
            style: GoogleFonts.poppins(fontSize: 16),),);
        }
        return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var requestdata = requests[index];
              return Card(
                  child: ListTile(
                    title: Text("Reason: ${requestdata['reason']}",
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w500)),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [ 

                        Text("Status: ${requestdata['status']}",
                            style: GoogleFonts.poppins()),

                        Text(
                          requestdata['notificationMessage'] != null
                              ? requestdata['notificationMessage'].toString()
                              : 'N/A',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),

                  )
              );
              });
      }),

    );
  }
}
