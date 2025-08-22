import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _regController = TextEditingController();
  String? _profilePicUrl;
  File? pickedimage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return; // ✅ Check if user is logged in

    final uid = user.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _regController.text = data['regno'] ?? '';
        _profilePicUrl = data['profileImage'] ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _loading = true);
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
      setState(() => _loading = false);
      return;
    }

    final uid = user.uid;
    String? imageUrl = _profilePicUrl; // keep old URL if no new image

    try {
      // Upload only if new image selected
      if (pickedimage != null) {
        final ref = FirebaseStorage.instance.ref("profile_images/$uid.jpg");
        await ref.putFile(pickedimage!);
        imageUrl = await ref.getDownloadURL();
      }

      await _firestore.collection("users").doc(uid).update({
        "name": _nameController.text.trim(),
        "regno": _regController.text.trim(),
        "profileImage": imageUrl ?? '', // ✅ Safe update
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }

    setState(() => _loading = false);
  }

  pickimage(ImageSource imagesource) async {
    try {
      final photo = await ImagePicker().pickImage(source: imagesource);
      if (photo == null) {
        return null;
      }
      final tempimage = File(photo.path);

    setState(() {
      pickedimage = tempimage;

    });
    } catch (e) {
      print(e.toString());
    }
  }
  showoptionbox(BuildContext context) {
    showDialog(
      context: context, // ✅ you must provide context here
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pick image from"),
          content: Column(
            mainAxisSize: MainAxisSize.min, // 👈 shrink to fit
            children: [
              ListTile(
                leading: const Icon(CupertinoIcons.camera),
                title: const Text("Camera"),
                onTap: () {
                  pickimage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  pickimage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile",
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                showoptionbox(context);
              },
              child: NetworkImage(_profilePicUrl!) != null
                  ? CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(_profilePicUrl!),
              )
                  : CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 80,
                child: Icon(
                  color: Colors.white,
                  CupertinoIcons.person,
                  size: 60,
                ),
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),
           TextField(
              controller: _regController,
              decoration: InputDecoration(labelText: 'Registration Number'),
            ),
            SizedBox(height: 20),
            _loading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
