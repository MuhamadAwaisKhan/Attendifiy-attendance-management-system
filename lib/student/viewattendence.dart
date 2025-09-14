import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ViewAttendance extends StatefulWidget {
  const ViewAttendance({super.key});

  @override
  State<ViewAttendance> createState() => _ViewAttendanceState();
}

class _ViewAttendanceState extends State<ViewAttendance> {
  String _selectedFilter = 'All';
  // String _searchDate = '';
  // final TextEditingController _dateController = TextEditingController();

  getAttendance() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return CircularProgressIndicator();

    Query query = FirebaseFirestore.instance
        .collection('attendance')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: false);

    // Apply status filter
    if (_selectedFilter != 'All') {
      query = query.where('status', isEqualTo: _selectedFilter);
    }

    // // Apply date search if provided
    // if (_searchDate.isNotEmpty) {
    //   query = query.where('date', isEqualTo: _searchDate);
    // }

    return query.snapshots();
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('hh:mm a').format(dateTime);
  }

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime.now(),
  //   );
  //
  //   if (picked != null) {
  //     setState(() {
  //       _searchDate = DateFormat('yyyy-MM-dd').format(picked);
  //       _dateController.text = DateFormat('dd MM yyyy').format(picked);
  //     });
  //   }
  // }
  //
  // void _clearSearch() {
  //   setState(() {
  //     _searchDate = '';
  //     _dateController.clear();
  //   });
  // }

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
      body: Column(
        children: [
          // Filter and Search Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Status Filter
                Row(
                  children: [
                    Text(
                      "Filter by:",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          value: _selectedFilter,
                          items: ['All', 'Present', 'Absent', 'Approved Leave']
                              .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value!;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),

                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 16),
                //
                // // Date Search
                // Row(
                //   children: [
                //     Expanded(
                //       child: TextFormField(
                //         controller: _dateController,
                //         decoration: InputDecoration(
                //           labelText: "Search by date",
                //           border: OutlineInputBorder(
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           focusedBorder: OutlineInputBorder(
                //             borderSide: BorderSide(color: Colors.blue),
                //           ),
                //           contentPadding: EdgeInsets.symmetric(horizontal: 12),
                //           suffixIconConstraints: BoxConstraints(
                //             minWidth: 60,
                //           ),
                //           suffixIcon: IconButton(
                //             icon: Icon(Icons.calendar_today,color: Colors.blue,),
                //             onPressed: () => _selectDate(context),
                //           ),
                //         ),
                //         readOnly: true,
                //         onTap: () => _selectDate(context),
                //       ),
                //     ),
                //     if (_searchDate.isNotEmpty)
                //       IconButton(
                //         icon: Icon(Icons.clear),
                //         onPressed: _clearSearch,
                //         tooltip: 'Clear search',
                //       ),
                //   ],
                // ),
              ],
            ),
          ),

          // Attendance List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getAttendance(),
              builder: (context, snapshot) {
                // Loading shimmer
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        highlightColor: Colors.grey.shade100,
                        baseColor: Colors.grey.shade300,
                        child: ListTile(
                          leading: Container(
                            height: 40,
                            width: 40,
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          // _searchDate.isNotEmpty
                          //     ? "No records found for selected date"
                          //     :
                        "No attendance records found",
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        // if (_searchDate.isNotEmpty)
                        //   TextButton(
                        //     onPressed: _clearSearch,
                        //     child: Text("Clear search"),
                        //   ),
                      ],
                    ),
                  );
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

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          data['status'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: data['status'] == "Present"
                                ? Colors.green
                                : data['status'] == "Absent"
                                ? Colors.red
                                : Colors.orange,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date: ${data['date']}"),
                            Text("Time: $formattedTime"),
                          ],
                        ),
                        trailing: Icon(
                          data['status'] == "Present"
                              ? Icons.check_circle
                              : data['status'] == "Absent"
                              ? Icons.cancel
                              : Icons.access_time,
                          color: data['status'] == "Present"
                              ? Colors.green
                              : data['status'] == "Absent"
                              ? Colors.red
                              : Colors.orange,
                          size: 30,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // void dispose() {
  //   _dateController.dispose();
  //   super.dispose();
  // }
}