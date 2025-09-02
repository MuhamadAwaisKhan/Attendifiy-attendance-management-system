// lib/providers/auth_provider.dart
import 'dart:io';

import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:attendencesystem/admin/admindashboard.dart';
import 'package:attendencesystem/faculty/facultydashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../faculty/emailverification.dart';
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
      await uploaddatastudent(uid);

      // Clear controllers

      UIHelper.customalertbox(context, "Registration successful");
    }
    on FirebaseAuthException catch (e) {
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
  Future<void> signUpfaculty(
      BuildContext context,
      String email,
      String password,
      String name,
      String position,
      ) async {
    // Show loading dialog
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
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Get user from userCredential
      User? user = userCredential.user;
      if (user == null) throw Exception("User creation failed");

      // Save user info in Firestore
      await firestore.collection('faculty').doc(user.uid).set({
        "uid": user.uid,
        "position": position,
        "name": name,
        "email": email,
        "role": "faculty",
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Upload additional faculty data if needed
      await uploaddatafaculty(user.uid);

      // Send email verification
      await user.sendEmailVerification();

      // Close the loading dialog safely
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      Fluttertoast.showToast(
        msg: 'Verification email sent. Please verify your email.',
      );

      // Navigate to Email Verification Screen safely
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(),
          ),
        );
      });
    } on FirebaseAuthException catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
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
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      UIHelper.customalertbox(context, "An unexpected error occurred: $e");
    }
  }

  Future<void> uploaddatastudent(String uid) async {
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
  Future<void> uploaddatafaculty(String uid) async {
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
      await FirebaseFirestore.instance.collection("faculty").doc(uid).update({
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
    // Show loading dialog
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

      // Fetch user document
      DocumentSnapshot doc = await firestore
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      // Close loading dialog safely
      if (Navigator.canPop(context)) Navigator.pop(context);

      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        String role = data['role'] ?? 'student';

        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("role", role);

        UIHelper.customalertbox(context, "Login successful");

        if (role == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => StudentDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminDashboard()),
          );
        }
      } else if (isManualAdminAccount(email)) {
        // Manual Admin account creation
        await firestore.collection('admin').doc(cred.user!.uid).set({
          'email': email,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'isManualAdmin': true,
        });

        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("role", 'admin');

        UIHelper.customalertbox(context, "Welcome Admin");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard()),
        );
      } else {
        await _auth.signOut();
        UIHelper.customalertbox(
          context,
          "Account not properly set up. Contact admin.",
        );
      }
    } on FirebaseAuthException catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found with this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email format.";
          break;
        case 'user-disabled':
          errorMessage = "Account disabled.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many attempts. Try later.";
          break;
        default:
          errorMessage = e.message ?? "Login failed";
      }
      UIHelper.customalertbox(context, errorMessage);
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      UIHelper.customalertbox(context, "Unexpected error: $e");
    }
  }
Future<void> loginfaculty(
    BuildContext context,
    String email,
    String password,
  ) async {
    // Show loading dialog
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
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = cred.user; // ✅ store user here safely

      if (user == null) {
        UIHelper.customalertbox(context, "Login failed. Please try again.");
        return;
      }

// Fetch user document
      DocumentSnapshot doc = await firestore
          .collection('faculty')
          .doc(user.uid)
          .get();

// Close loading dialog safely
      if (Navigator.canPop(context)) Navigator.pop(context);

      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        String role = data['role'] ?? 'faculty';

        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("role", role);

        UIHelper.customalertbox(context, "Login successful");

        // ✅ Safe null check before using emailVerified
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          Fluttertoast.showToast(
              msg: "Your email is not verified. Please verify your email.");

          // Navigate to EmailVerificationScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => EmailVerificationScreen(),
            ),
          );
        } else {
          // Email already verified → Go to dashboard directly
          if (role == 'faculty') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => facultydashboard()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminDashboard()),
            );
          }
        }
      } else if (isManualAdminAccount(email)) {
        await firestore.collection('admin').doc(user.uid).set({
          'email': email,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'isManualAdmin': true,
        });

        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("role", 'admin');

        UIHelper.customalertbox(context, "Welcome Admin");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard()),
        );
      } else {
        await _auth.signOut();
        UIHelper.customalertbox(
          context,
          "Account not properly set up. Contact admin.",
        );
      }

    } on FirebaseAuthException catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found with this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email format.";
          break;
        case 'user-disabled':
          errorMessage = "Account disabled.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many attempts. Try later.";
          break;
        default:
          errorMessage = e.message ?? "Login failed";
      }
      UIHelper.customalertbox(context, errorMessage);
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      UIHelper.customalertbox(context, "Unexpected error: $e");
    }
  }

  bool isManualAdminAccount(String email) {
    List<String> manualAdminEmails = ['awais@admin.com', 'admin2@example.com'];
    return manualAdminEmails.contains(email);
  }
  //   Future<void> logout(BuildContext context) async {
  //     try {
  //       await _auth.signOut();
  //
  //       // Clear all stored preferences
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.remove("isLoggedIn");
  //       await prefs.clear();
  // notifyListeners();
  //
  //       Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (context) => LoginScreen()),
  //             (Route<dynamic> route) => false,
  //       );
  //     } catch (e) {
  //       print('Logout error: $e');
  //       // Even if there's an error, navigate to login screen
  //       // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
  //
  //       Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (context) => LoginScreen()),
  //             (Route<dynamic> route) => false,
  //       );
  //     }
  //   }
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);
    await prefs.remove("isLoggedIn");
    await prefs.clear();
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    notifyListeners();
  }
  // Future<void> logoutforadmin(BuildContext context) async {
  //   await _auth.signOut();
  //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  //    notifyListeners();
  // }
}
