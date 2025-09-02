import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEditCourseScreen extends StatefulWidget {
  final String? courseId;
  final Map<String, dynamic>? courseData;

  const AddEditCourseScreen({Key? key, this.courseId, this.courseData})
      : super(key: key);

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.courseData != null) {
      nameController.text = widget.courseData!['name'];
      codeController.text = widget.courseData!['code'];
    }
  }

  Future<void> saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': nameController.text.trim(),
      'code': codeController.text.trim(),
      'createdAt': FieldValue.serverTimestamp()
    };

    if (widget.courseId == null) {
      // Add new course
      await FirebaseFirestore.instance.collection('courses').add(data);
      Fluttertoast.showToast(msg: "Course added successfully!");
    } else {
      // Update existing course
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .update(data);
      Fluttertoast.showToast(msg: "Course updated successfully!");
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseId == null ? "Add Course" : "Edit Course",
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Course Name"),
                validator: (value) =>
                value!.isEmpty ? "Enter course name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(labelText: "Course Code"),
                validator: (value) =>
                value!.isEmpty ? "Enter course code" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveCourse,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(widget.courseId == null ? "Add" : "Update",
                    style: GoogleFonts.poppins(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
