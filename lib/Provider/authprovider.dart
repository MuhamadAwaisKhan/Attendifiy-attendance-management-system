// lib/providers/auth_provider.dart
import 'dart:io';

import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:attendencesystem/admin/admindashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../loginpage.dart';
import '../student/stdhomescreen.dart';

class AuthProvider with ChangeNotifier {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  User? _user;
  bool _loading = false;
  File? pickedimage;

  User? get user => _user;

  bool get loading => _loading;

  loadingfunction(bool value) {
    _loading = value;
    notifyListeners();
  }

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUp(
      BuildContext context,
      String email,
      String password,
      String name,
      String regno,
      ) async {
    if (pickedimage == null) {
      UIHelper.customalertbox(
        context,
        "Please select a profile image by clicking on it",
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.blue,
            ),
          ),
        );
      },
    );

    try {
      // Create user in Firebase Auth
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String uid = _auth.currentUser!.uid;

      // Save basic user info first
      await firestore.collection('users').doc(uid).set({
        "uid": uid,
        "regno": regno,
        "name": name,
        "email": email,
        "role": "student",
        "createdAt": FieldValue.serverTimestamp(),

      });

      // Upload image and update Firestore
      await uploaddata(uid);

      // Clear controllers


      UIHelper.customalertbox(context, "Registration successful");
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed";
      if (e.code == 'weak-password') {
        errorMessage = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "The account already exists for that email.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is badly formatted.";
      } else {
        errorMessage = e.message ?? errorMessage;
      }
      UIHelper.customalertbox(context, errorMessage);
    }
  }

  Future<void> uploaddata(String uid) async {
    try {
      // Upload image to Firebase Storage
      UploadTask uploadTask = FirebaseStorage.instance
          .ref("profile_images")
          .child(uid) // use uid instead of email
          .putFile(pickedimage!);

      TaskSnapshot taskSnapshot = await uploadTask;

      // Get download URL
      String url = await taskSnapshot.ref.getDownloadURL();

      // Update Firestore user document with image URL
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "profileImage": url,
      });
    } catch (e) {
      debugPrint("Error uploading image: $e");
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


  pickimage(ImageSource imagesource) async {
    try {
      final photo = await ImagePicker().pickImage(source: imagesource);
      if (photo == null) {
        return null;
      }
      final tempimage = File(photo.path);

        pickedimage = tempimage;
        notifyListeners();

    } catch (e) {
      print(e.toString());
    }
  }
  Future<void> login(
      BuildContext context,
      String email,
      String password,
      ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.blue,
            ),
          ),
        );
      },
    );


    try {
      // Sign in with Firebase Auth
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Get user document
      DocumentSnapshot doc =
      await firestore.collection('users').doc(cred.user!.uid).get();

      // Close loading indicator
      Navigator.pop(context);

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;

        // If role exists and is student → StudentDashboard
        if (data.containsKey('role') && data['role'] == 'student') {
          UIHelper.customalertbox(context, "Login successful");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StudentDashboard()),
          );
        } else {
          // No role → Assume Admin
          UIHelper.customalertbox(context, "Welcome Admin");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        }
      } else {
        // No document → Admin
        UIHelper.customalertbox(context, "Welcome Admin");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading on error

      String errorMessage = "Login failed";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password. Please try again.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is badly formatted.";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This account has been disabled by an administrator.";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Too many attempts. Try again later.";
      } else {
        errorMessage = e.message ?? errorMessage;
      }

      UIHelper.customalertbox(context, errorMessage);
    } catch (e) {
      Navigator.pop(context); // Close loading on unexpected error
      UIHelper.customalertbox(
        context,
        "An unexpected error occurred. Please try again.",
      );
    }
  }


  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
     notifyListeners();
  }
  Future<void> logoutforadmin(BuildContext context) async {
    await _auth.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
     notifyListeners();
  }
}
