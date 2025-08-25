import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MarkLeaveScreen extends StatefulWidget {
  final String userId;

  const MarkLeaveScreen({super.key, required this.userId});

  @override
  _MarkLeaveScreenState createState() => _MarkLeaveScreenState();
}

class _MarkLeaveScreenState extends State<MarkLeaveScreen> {
  DateTime _selectedDate = DateTime.now();
  final _reasonController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> sendLeaveRequest(String userId, DateTime date, String reason) async {
    try {
      Timestamp ts = Timestamp.fromDate(date);

      // Check if a leave request already exists for this user & date
      var existingRequest = await _firestore
          .collection('leave_requests')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: ts)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw Exception("You have already requested leave for this date");
      }

      // Add new leave request
      await _firestore.collection('leave_requests').add({
        'userId': userId,
        'date': ts,
        'reason': reason,
        'status': 'pending', // pending, approved, rejected
        'requestedAt': Timestamp.now(),
      });
      Navigator.pop(context);
      print("Leave request submitted successfully");
    } catch (e) {
      print("Error submitting leave request: $e");
      rethrow; // Pass error back to UI if you want to show a Snackbar/Alert
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text('Mark Leave',style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.white,
      ),),
      backgroundColor: Colors.blue,
      centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Select Date:',style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
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
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Text(_selectedDate == null
                    ? "Select Date"
                    : DateFormat('dd-MM-yyyy').format(_selectedDate),style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white
                ),),            ),
            ),
            UIHelper.customTextField(
              controller: _reasonController,
              label: "Reason",
            ),
            const SizedBox(height: 16),
            UIHelper.customButton(onPressed: ()async {
              try {
                await sendLeaveRequest(widget.userId, _selectedDate, _reasonController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Leave request submitted successfully")),

                  );

              } on Exception catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              }

            }, text: "Send Request",width: 270),
          ],
        ),
      ),
    );
  }
}
