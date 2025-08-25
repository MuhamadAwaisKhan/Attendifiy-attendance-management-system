import 'package:attendencesystem/admin/fullrecord.dart';
import 'package:attendencesystem/admin/viewonestfattendence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class viewrecord extends StatefulWidget {
  const viewrecord({super.key});

  @override
  State<viewrecord> createState() => _viewrecordState();
}

class _viewrecordState extends State<viewrecord> {
  Stream<QuerySnapshot> getUsersStream() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          " Record",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  highlightColor: Colors.grey.shade100,
                  baseColor: Colors.grey.shade300,
                  child: ListTile(
                    leading: Container(
                      height: 50,
                      width: 50,
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
            return const Center(child: Text("No attendance records found"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    backgroundImage: NetworkImage(user['profileImage']),
                  ),
                  title: Text("Name: ${user['name']}"),
                  subtitle: Text('Reg No: ${user['regno']}'),
                  trailing: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Text(
                      "${index + 1}", style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    alignment: Alignment.center,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>FullRecord(name: user['name'], regno: user['regno'], email: user['email'], profileImage: user['profileImage'],id:user.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
