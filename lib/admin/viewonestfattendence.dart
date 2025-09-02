import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class viewonestdattendanceadmin extends StatefulWidget {
  String userid;
  String name;
  String regno;


  viewonestdattendanceadmin({super.key, required this.userid, required this.name, required this.regno});

  @override
  State<viewonestdattendanceadmin> createState() =>
      _viewonestdattendanceadminState();
}

class _viewonestdattendanceadminState extends State<viewonestdattendanceadmin> {
  String _selectedFilter = 'All';
  DateTime? _singleDate;
  DateTimeRange? _selectedDateRange;


// Single date picker
  Future<void> _selectSingleDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _singleDate ?? DateTime.now(),
      firstDate: DateTime(2023, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light()
              .copyWith(
            colorScheme:
            ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface:
              Colors.black,
            ),
            dialogBackgroundColor:
            Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _singleDate = picked;
        _selectedDateRange = null; // clear range if single date selected
      });
    }
  }

// Range picker
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(Duration(days: 7)),
            end: DateTime.now(),),
            builder: (context, child) {
              return Theme(
                data: ThemeData.light()
                    .copyWith(
                  colorScheme:
                  ColorScheme.light(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    onSurface:
                    Colors.black,
                  ),
                  dialogBackgroundColor:
                  Colors.white,
                ),
                child: child!,
              );
            },

    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _singleDate = null; // clear single date if range selected
      });
    }
  }

  getAttendance() {
    Query query = FirebaseFirestore.instance
        .collection('attendance')
        .where('userId', isEqualTo: widget.userid)
        .orderBy('date', descending: true);

    // Apply status filter
    if (_selectedFilter != 'All') {
      query = query.where('status', isEqualTo: _selectedFilter);
    }
    // Single Date filter
    if (_singleDate != null) {
      String selectedDate = DateFormat('dd-MM-yyyy').format(_singleDate!);
      query = query.where('date', isEqualTo: selectedDate);
    }

    // Date Range filter
    if (_selectedDateRange != null) {
      String from = DateFormat('dd-MM-yyyy').format(_selectedDateRange!.start);
      String to = DateFormat('dd-MM-yyyy').format(_selectedDateRange!.end);
      query = query.where('date', isGreaterThanOrEqualTo: from)
          .where('date', isLessThanOrEqualTo: to);
    }
    // // Apply date search if provided


    return query.snapshots();
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('hh:mm a').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _singleDate = null;
    _selectedDateRange = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              "${widget.name}",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
SizedBox(
  height: 5,
),
          Text(
            "Reg no:  ${ widget.regno}",
              style: GoogleFonts.poppins(
                // fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
          ),
            SizedBox(
              height: 5,
            ),

          ],
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
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
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                 SizedBox(height: 16),
                Container(
                  height: 70,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _selectSingleDate(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: Text(
                            _singleDate == null
                                ? "Select Date"
                                : DateFormat('yyyy-MM-dd').format(_singleDate!),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _selectDateRange(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: Text(
                            _selectedDateRange == null
                                ? "Calender"
                                : "${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)} → ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _singleDate = null;
                            _selectedDateRange = null;

                          });
                        },
                      )
                    ],
                  ),
                ),


              ],
            ),
          ),

          // Attendance List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getAttendance(), // your query stream
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(child: Text('No attendance records found'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final attendanceData = data.data() as Map<String, dynamic>;
                    final markedAt = attendanceData['markedAt'] as Timestamp?;
                    final formattedTime = markedAt != null
                        ? DateFormat('hh:mm a').format(markedAt.toDate())
                        : "No time available";

                    Color statusColor;
                    switch (attendanceData['status']) {
                      case 'Present':
                        statusColor = Colors.green;
                        break;
                      case 'Absent':
                        statusColor = Colors.red;
                        break;
                      case 'Approved Leave':
                        statusColor = Colors.orange;
                        break;
                      default:
                        statusColor = Colors.grey;
                    }

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text("${index + 1}", style: TextStyle(color: Colors.white)),
                        ),
                        title: Text(
                          attendanceData['status'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date: ${attendanceData['date']}"),
                            Text("Time: $formattedTime"),
                          ],
                        ),
                        
                        trailing: SizedBox(
                          width: 96, // enough for two icons
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Edit Button
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.green),
                                onPressed: () {
                                  String currentStatus = attendanceData['status'];
                                  String newStatus = currentStatus;

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Edit Attendance",
                                            style: GoogleFonts.poppins(
                                                fontSize: 15, fontWeight: FontWeight.bold)),
                                        content: DropdownButtonFormField<String>(
                                          value: currentStatus,
                                          items: ['Present', 'Absent']
                                              .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status),
                                          ))
                                              .toList(),
                                          onChanged: (value) {
                                            newStatus = value!;
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
                                        actions: [
                                          TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: Text("Cancel",style: GoogleFonts.poppins(color: Colors.red),)),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                            ),
                                            onPressed: () async {
                                              try {
                                                await data.reference.update({
                                                  'status': newStatus,
                                                  'markedAt': Timestamp.now(),
                                                });
                                                Navigator.of(context).pop();
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                    content: Text('Attendance updated successfully')));
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Error: $e')));
                                              }
                                            },

                                            child: Text("Update",style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),

                              // Delete Button
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  try {
                                    await data.reference.delete();
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Attendance deleted successfully')));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error deleting: $e')));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          String? newStatus;
          DateTime? selectedDate;

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    // titlePadding: EdgeInsets.all(16),
                    title: Text(
                      "Add Attendance",
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status Dropdown
                        DropdownButtonFormField<String>(
                          value: newStatus,
                          hint: Text("Select Status",style: GoogleFonts.poppins(
                            color: Colors.grey
                          ),),
                          isExpanded: true,
                          items: ['Present', 'Absent',]
                              .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              newStatus = value!;
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
                        SizedBox(height: 16),

                        // Date Picker Button
                        SizedBox(
                          width: 230,
                          child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          ),
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                cancelText: "Cancel",
                                confirmText: "Confirm",
// calendarDelegate:  GregorianCalendarDelegate(),
//                                 currentDate: selectedDate,
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2023, 1),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light()
                                        .copyWith(
                                      colorScheme:
                                      ColorScheme.light(
                                        primary: Colors.blue,
                                        onPrimary: Colors.white,
                                        onSurface:
                                        Colors.black,
                                      ),
                                      dialogBackgroundColor:
                                      Colors.white,
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: Text(selectedDate == null
                                ? "Select Date"
                                : DateFormat('yyyy-MM-dd').format(selectedDate!),style: GoogleFonts.poppins(
                              color: Colors.white
                            ),),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text("Cancel",style: GoogleFonts.poppins(color: Colors.red),)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () async {
                          if (newStatus == null || selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Please select status and date')));
                            return;
                          }

                          try {
                            await FirebaseFirestore.instance
                                .collection('attendance')
                                .add({
                              'status': newStatus,
                              'userId': widget.userid,
                              'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
                              'markedAt': Timestamp.now(),
                            });

                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Attendance added successfully')));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')));
                          }
                        },
                        child: Text("Add",style: GoogleFonts.poppins(color: Colors.white),),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
  // @override
  // void dispose() {
  //   _dateController.dispose();
  //   super.dispose();
  // }
}
