import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CoursesScreen extends StatefulWidget {
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  // Time utility functions
  String _timeOfDayToString(TimeOfDay time) => "${time.hour}:${time.minute}";
  TimeOfDay _stringToTimeOfDay(String time) {
    final parts = time.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Check for time conflicts
  Future<bool> _checkTimeConflict(String day, TimeOfDay start, TimeOfDay end, {String? courseId}) async {
    final snapshot = await FirebaseFirestore.instance.collection('courses').get();

    for (var doc in snapshot.docs) {
      if (courseId != null && doc.id == courseId) continue;

      final timeSlots = doc['timeSlots'] as List<dynamic>;
      for (var slot in timeSlots) {
        if (slot['day'] == day) {
          final existingStart = _stringToTimeOfDay(slot['start']);
          final existingEnd = _stringToTimeOfDay(slot['end']);

          if (start.hour * 60 + start.minute < existingEnd.hour * 60 + existingEnd.minute &&
              end.hour * 60 + end.minute > existingStart.hour * 60 + existingStart.minute) {
            return true; // conflict found
          }
        }
      }
    }
    return false; // no conflict
  }

  // Add/Edit Course Dialog
  void _showCourseDialog({String? courseId, Map<String, dynamic>? existingData}) {
    final nameController = TextEditingController(text: existingData?['name'] ?? "");
    final codeController = TextEditingController(text: existingData?['code'] ?? "");

    String? day1 = existingData != null ? existingData['timeSlots'][0]['day'] : null;
    String? day2 = existingData != null ? existingData['timeSlots'][1]['day'] : null;

    TimeOfDay? slot1Start = existingData != null ? _stringToTimeOfDay(existingData['timeSlots'][0]['start']) : null;
    TimeOfDay? slot1End = existingData != null ? _stringToTimeOfDay(existingData['timeSlots'][0]['end']) : null;
    TimeOfDay? slot2Start = existingData != null ? _stringToTimeOfDay(existingData['timeSlots'][1]['start']) : null;
    TimeOfDay? slot2End = existingData != null ? _stringToTimeOfDay(existingData['timeSlots'][1]['end']) : null;

    Future<void> pickTime(BuildContext context, bool isStart, bool isFirstSlot) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        setState(() {
          if (isFirstSlot) {
            if (isStart) slot1Start = picked; else slot1End = picked;
          } else {
            if (isStart) slot2Start = picked; else slot2End = picked;
          }
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(courseId == null ? "Add Course" : "Edit Course"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Course Name")),
              TextField(controller: codeController, decoration: InputDecoration(labelText: "Course Code")),
              const SizedBox(height: 10),

              DropdownButton<String>(
                hint: Text("Select Day 1"),
                value: day1,
                isExpanded: true,
                items: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => day1 = value),
              ),
              Row(
                children: [
                  TextButton(onPressed: () => pickTime(context, true, true), child: Text("Start Time")),
                  TextButton(onPressed: () => pickTime(context, false, true), child: Text("End Time")),
                ],
              ),

              DropdownButton<String>(
                hint: Text("Select Day 2"),
                value: day2,
                isExpanded: true,
                items: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => day2 = value),
              ),
              Row(
                children: [
                  TextButton(onPressed: () => pickTime(context, true, false), child: Text("Start Time")),
                  TextButton(onPressed: () => pickTime(context, false, false), child: Text("End Time")),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || codeController.text.isEmpty || day1 == null || day2 == null) {
                Fluttertoast.showToast(msg: "Please fill all fields");
                return;
              }

              if (slot1Start == null || slot1End == null || slot2Start == null || slot2End == null) {
                Fluttertoast.showToast(msg: "Please select all time slots");
                return;
              }

              bool conflict1 = await _checkTimeConflict(day1!, slot1Start!, slot1End!, courseId: courseId);
              bool conflict2 = await _checkTimeConflict(day2!, slot2Start!, slot2End!, courseId: courseId);

              if (conflict1 || conflict2) {
                Fluttertoast.showToast(msg: "Time slot conflict! Choose different timings.");
                return;
              }

              final data = {
                'name': nameController.text.trim(),
                'code': codeController.text.trim(),
                'timeSlots': [
                  {'day': day1, 'start': _timeOfDayToString(slot1Start!), 'end': _timeOfDayToString(slot1End!)},
                  {'day': day2, 'start': _timeOfDayToString(slot2Start!), 'end': _timeOfDayToString(slot2End!)}
                ],
                'createdAt': FieldValue.serverTimestamp()
              };

              if (courseId == null) {
                await FirebaseFirestore.instance.collection('courses').add(data);
                Fluttertoast.showToast(msg: "Course added");
              } else {
                await FirebaseFirestore.instance.collection('courses').doc(courseId).update(data);
                Fluttertoast.showToast(msg: "Course updated");
              }

              Navigator.pop(context);
            },
            child: Text(courseId == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  // Delete Course
  void _deleteCourse(String id) async {
    await FirebaseFirestore.instance.collection('courses').doc(id).delete();
    Fluttertoast.showToast(msg: "Course deleted");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Courses"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final query = await showSearch(
                context: context,
                delegate: CourseSearchDelegate(),
              );
              if (query != null) setState(() => searchQuery = query);
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final courses = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['name'].toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          if (courses.isEmpty) return Center(child: Text("No Courses Found"));

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final doc = courses[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 4,
                child: ListTile(
                  title: Text(data['name']),
                  subtitle: Text("Code: ${data['code']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showCourseDialog(courseId: doc.id, existingData: data),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCourse(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCourseDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class CourseSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, ""));

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text("Search Courses by Name"),
    );
  }
}
