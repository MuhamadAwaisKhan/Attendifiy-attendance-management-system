// lib/screens/signup_screen.dart
import 'dart:math';

import 'package:attendencesystem/Provider/authprovider.dart';
import 'package:attendencesystem/faculty/loginpagefaculty.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../UIHelper/customwidgets.dart';

class SignupScreenfaculty extends StatefulWidget {
  const SignupScreenfaculty({super.key});

  @override
  State<SignupScreenfaculty> createState() => _SignupScreenfacultyState();
}

class _SignupScreenfacultyState extends State<SignupScreenfaculty> {
  final _emailController = TextEditingController();
  final _captchaController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _postionController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  late String _captchaCode;
  late Color _captchaColor;

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No 0/O or 1/I confusion
    final random = Random();
    setState(() {
      _captchaCode = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
      _captchaColor = Color.fromARGB(
        255,
        random.nextInt(200),
        random.nextInt(200),
        random.nextInt(200),
      ); // Random color for fun
    });
  }

  bool _verifyCaptcha() {
    if (_captchaController.text.toUpperCase() == _captchaCode) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Captcha Incorrect!")),
      );
      _generateCaptcha();
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formkey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    context.read<AuthProvider>().showoptionbox(context);
                  },
                  child: context.watch<AuthProvider>().pickedimage != null
                      ? CircleAvatar(
                    radius: 80,
                    backgroundImage: FileImage( context.watch<AuthProvider>().pickedimage!),
                  )
                      : Stack(
                      children:[ CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 80,
                        child: Icon(
                          color: Colors.white,
                          CupertinoIcons.person,
                          size: 60,
                        ),
                      ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () {
                              context.read<AuthProvider>().showoptionbox(context);                              },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.8),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ]),
                ),
                UIHelper.customTextField(
                  controller: _nameController,
                  label: "Full Name",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                UIHelper.customTextField(
                  controller: _postionController,
                  label: "Position",
                  hintText: 'e.g: lecture,Associate Professor, etc.',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your position status';
                    }
                    return null;
                  },
                ),
                UIHelper.customTextField(
                  controller: _emailController,
                  label: "Email",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                UIHelper.customTextField(
                  controller: _passwordController,
                  label: "Password",
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 4),
                      decoration: BoxDecoration(
                        color: _captchaColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _captchaColor, width: 2),
                      ),
                      child: Text(
                        _captchaCode,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _captchaColor,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      onPressed: _generateCaptcha,
                    ),
                  ],
                ),
                UIHelper.customTextField(controller: _captchaController, label: "Enter the code",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the code";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),
                UIHelper.customButton(
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      if (_verifyCaptcha()) {
                        context.read<AuthProvider>().signUpfaculty(
                          context,
                          _emailController.text,
                          _passwordController.text,
                          _nameController.text,
                          _postionController.text,
                        );
                      }
                    }
                  },
                  width: 280,

                  text: "Sign Up",
                  icon: (Icons.logout),
                ),
                 SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreenfaculty()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,

                    children: [
                      Text(
                        'Already have an account?',
                        style: GoogleFonts.poppins(
                          fontSize: 13,

                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
