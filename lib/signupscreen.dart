// lib/screens/signup_screen.dart
import 'package:attendencesystem/Provider/authprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'UIHelper/customwidgets.dart';
import 'loginpage.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _regnoController = TextEditingController();
  final formkey = GlobalKey<FormState>();

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
                  controller: _regnoController,
                  label: "Registration Number",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your registration number';
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

                UIHelper.customButton(
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      context.read<AuthProvider>().signUp(
                        context,
                        _emailController.text,
                        _passwordController.text,
                        _nameController.text,
                        _regnoController.text,
                      );
                    }
                  },
                  width: 280,

                  text: "Sign Up",
                  icon: (Icons.logout),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
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
