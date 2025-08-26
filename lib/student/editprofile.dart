import 'dart:io';

import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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
    if (user == null) return;

    final uid = user.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _regController.text = data['regno'] ?? '';
        _profilePicUrl = data['profileImage'];
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _loading = true);
    final user = _auth.currentUser;
    if (user == null) {
      UIHelper.customalertbox(context, "User not logged in");
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
        "profileImage": imageUrl ?? '',
      });

      UIHelper.customalertbox(context, "Profile Updated Successfully");
    } catch (e) {
      UIHelper.customalertbox(context, " Error updating profile: $e");
    }

    setState(() => _loading = false);
  }

  pickimage(ImageSource imagesource) async {
    try {
      final photo = await ImagePicker().pickImage(source: imagesource);
      if (photo == null) return;

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
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pick image from"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Center(
        child: Stack(
        alignment: Alignment.center,
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 80,
              backgroundImage: pickedimage != null
                  ? FileImage(pickedimage!)
                  : (_profilePicUrl != null && _profilePicUrl!.isNotEmpty)
                  ? NetworkImage(_profilePicUrl!)
                  : null,
              backgroundColor: (pickedimage == null &&
                  (_profilePicUrl == null || _profilePicUrl!.isEmpty))
                  ? Colors.blue
                  : Colors.indigo,
              child: (pickedimage == null &&
                  (_profilePicUrl == null || _profilePicUrl!.isEmpty))
                  ? Icon(CupertinoIcons.person, color: Colors.white, size: 60)
                  : null,
            ),

            // Camera icon overlay
            Positioned(
              bottom: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => showoptionbox(context),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
            SizedBox(height: 20),
            UIHelper.customTextField(
              controller: _nameController,
              label: "Name",
            ),

            UIHelper.customTextField(
              controller: _regController,
              label: "Registration Number",
            ),

            UIHelper.customButton(
              onPressed: _updateProfile,
              text: 'Update Profile',
              width: 280,
              isLoading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}
