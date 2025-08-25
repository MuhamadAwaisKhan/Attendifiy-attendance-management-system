import 'package:attendencesystem/admin/viewonestfattendence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FullRecord extends StatefulWidget {
  final String name, regno, email, profileImage, id;

  FullRecord({
    super.key,
    required this.id,
    required this.name,
    required this.regno,
    required this.email,
    required this.profileImage,
  });

  @override
  State<FullRecord> createState() => _FullRecordState();
}
final _firestore = FirebaseFirestore.instance;

String getGrade(int presentDays) {
  if (presentDays >= 26) {
    return "A";
  } else if (presentDays >= 20) {
    return "B";
  } else if (presentDays >= 15) {
    return "C";
  } else if (presentDays >= 10) {
    return "D";
  } else {
    return "F";
  }
}

Future<String> getUserGrade(String userId) async {
  var snapshot = await FirebaseFirestore.instance
      .collection('attendance')
      .where('userId', isEqualTo: userId)
      .get();

  int present = 0;
  for (var doc in snapshot.docs) {
    if (doc['status'] == "Present") {
      present++;
    }
  }

  return getGrade(present); // Use grading logic
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
class _FullRecordState extends State<FullRecord> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'User Details',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue,
          centerTitle: true,
        ),
        backgroundColor: Colors.blue.shade50,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 60,
                backgroundImage: widget.profileImage.isNotEmpty
                    ? NetworkImage(widget.profileImage)
                    : null,
                child: widget.profileImage.isEmpty
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
                backgroundColor: Colors.blue,
              ),
              const SizedBox(height: 20),

              // User Name Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(
                    'Name',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(widget.name, style: GoogleFonts.poppins()),
                ),
              ),
              const SizedBox(height: 10),

              // Registration Number Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.badge, color: Colors.blue),
                  title: Text(
                    'Registration Number',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(widget.regno, style: GoogleFonts.poppins()),
                ),
              ),
              const SizedBox(height: 10),

              // Email Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: Text(
                    'Email',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(widget.email, style: GoogleFonts.poppins()),
                ),
              ),

              SizedBox(height: 10),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.class_, color: Colors.blue),
                  title: Text(
                    'Attendance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_sharp),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => viewonestdattendanceadmin(
                          userid: widget.id,
                          name: widget.name,
                          regno: widget.regno,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              FutureBuilder<Map<String, int>>(
                future: getAttendanceCounts(widget.id),
                builder: (context, attendanceSnapshot) {
                  var counts = attendanceSnapshot.data ?? {
                    'present': 0,
                    'absent': 0,
                    'approvedLeave': 0
                  };

                  String grade = getGrade(counts['present']!);

                  return Card(
                    child: ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 18),
                              SizedBox(width: 5),
                              Text("Present: ${counts['present']}", style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.red, size: 18),
                              SizedBox(width: 5),
                              Text("Absent: ${counts['absent']}", style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.beach_access, color: Colors.orange, size: 18),
                              SizedBox(width: 5),
                              Text("Approved Leave: ${counts['approvedLeave']}", style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.grade, color: Colors.blue, size: 18),
                              SizedBox(width: 5),
                              Text("Grade: $grade",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )

            ],
          ),
        ),
      ),
    );
  }
}
