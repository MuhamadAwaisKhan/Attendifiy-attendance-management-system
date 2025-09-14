import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../service/notificationservice.dart';

class MarkLeaveScreen extends StatefulWidget {
  final String userId;

  const MarkLeaveScreen({super.key, required this.userId});

  @override
  State<MarkLeaveScreen> createState() => _MarkLeaveScreenState();
}

class _MarkLeaveScreenState extends State<MarkLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Submit leave request
  Future<void> _submitLeaveRequest() async {
    try {
      final String formattedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);
      final Timestamp dateTimestamp = Timestamp.fromDate(_selectedDate);

      // ✅ 1. Check if attendance already marked
      final attendanceSnapshot = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: widget.userId)
          .where('date', isEqualTo: formattedDate)
          .get();

      if (attendanceSnapshot.docs.isNotEmpty) {
        return _showError(
          "Leave Request Denied",
          "Attendance already marked for $formattedDate. Leave not allowed.",
        );
      }

      // ✅ 2. Check if leave request already exists
      final leaveSnapshot = await _firestore
          .collection('leave_requests')
          .where('userId', isEqualTo: widget.userId)
          .where('date', isEqualTo: dateTimestamp)
          .get();

      if (leaveSnapshot.docs.isNotEmpty) {
        return _showError(
          "Leave Request Already Submitted",
          "You already requested leave for $formattedDate.",
        );
      }

      // ✅ 3. Submit leave request
      await _firestore.collection('leave_requests').add({
        'userId': widget.userId,
        'date': dateTimestamp,
        'reason': _reasonController.text.trim(),
        'status': 'pending', // pending, approved, rejected
        'requestedAt': Timestamp.now(),
      });

      await NotificationService.showNotification(
        "Leave Request Submitted",
        "Your leave request for $formattedDate has been submitted.",
      );

      if (mounted) Navigator.pop(context);

    } catch (e) {
      _showError("Leave Request Failed", "Error: ${e.toString()}");
    }
  }

  /// 🔹 Show error message & notification
  Future<void> _showError(String title, String message) async {
    await NotificationService.showNotification(title, message);
    if (mounted) {
      UIHelper.customalertbox(context, message);
    }
  }

  /// 🔹 Date Picker Widget
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mark Leave',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 Date Picker
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Date:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pickDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    DateFormat('dd-MM-yyyy').format(_selectedDate),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Reason Field
              UIHelper.customTextField(
                controller: _reasonController,
                label: "Reason",
                hintText: "Enter reason for leave",
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a reason";
                  }
                  if (value.length < 5) {
                    return "Reason must be at least 5 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 🔹 Submit Button
              UIHelper.customButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _submitLeaveRequest();
                  }
                },
                text: "Send Request",
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 