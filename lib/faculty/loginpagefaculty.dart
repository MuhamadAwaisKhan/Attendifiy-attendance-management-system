import 'dart:math';
import 'package:attendencesystem/Provider/authprovider.dart';
import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:attendencesystem/faculty/signupfaculty.dart';
import 'package:attendencesystem/student/signupscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginScreenfaculty extends StatefulWidget {
  const LoginScreenfaculty({super.key});

  @override
  State<LoginScreenfaculty> createState() => _LoginScreenfacultyState();
}

class _LoginScreenfacultyState extends State<LoginScreenfaculty> {
  final _captchaController = TextEditingController();
  final _emailController = TextEditingController(text: 'awais@admin.com');
  final _passwordController = TextEditingController(text: '123456');
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
          'Faculty Login',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formkey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/admin.json',
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
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
                        context.read<AuthProvider>().loginfaculty(
                          context,
                          _emailController.text,
                          _passwordController.text,
                        );
                        // _generateCaptcha();

                      }
                    }
                  },
                  width: 280,
                  text: "Login",
                  icon: (Icons.login),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) =>  SignupScreenfaculty()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Sign up',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
