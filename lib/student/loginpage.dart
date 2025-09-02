// lib/screens/login_screen.dart
import 'package:attendencesystem/Provider/authprovider.dart';
import 'package:attendencesystem/UIHelper/customwidgets.dart';
import 'package:attendencesystem/student/signupscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text:'anas@gmail.com'
  // 'awais@admin.com'
  );
  final _passwordController = TextEditingController(text: '123456');
  final formkey = GlobalKey<FormState>();
// void clearcontroller(){
//   _emailController.clear();
//   _passwordController.clear();
// }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Login',
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
                  'assets/login.json',
                  height: 200,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20,),
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
                      context.read<AuthProvider>().login(
                        context,
                        _emailController.text,
                        _passwordController.text,
                      );
                      // clearcontroller();
                    }
                  },
                  width: 280,
                  text: "Login",
                  icon: (Icons.login),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
