// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Drawers/progress_indicator.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/homepage_body.dart';
import 'package:hisab_kitab/pages/sign_up_page.dart';
import 'package:hisab_kitab/reuseable_widgets/buttons.dart';
import 'package:hisab_kitab/reuseable_widgets/textField.dart';
import 'package:hisab_kitab/reuseable_widgets/text_button.dart';
import 'package:hisab_kitab/services/User_authentication/firebase_authentication.dart';
import 'dart:math';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

Future<Map<String, dynamic>> getShopDetails() async {
  DocumentSnapshot adminDoc = await FirebaseFirestore.instance
      .collection('admin')
      .doc('09099090') // Replace with actual document ID if needed
      .get();
  return adminDoc.data() as Map<String, dynamic>;
}

String generateRandomPanNumber() {
  Random random = Random();
  String randomNumber = random.nextInt(1000000000).toString().padLeft(9, '0');
  return "PAN$randomNumber";
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Add this line to track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign-In"),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BanakoTextField(
                  hintText: "Enter Email",
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  controller: _emailController,
                ),
                const SizedBox(height: 16),
                BanakoTextField(
                  hintText: "Password",
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  controller: _passwordController,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BanakoButton(
                      textSize: 18,
                      backgroundColor: Colors.black,
                      height: 48,
                      text: "Log In",
                      textColor: Colors.white,
                      width: 116,
                      onPressed: _signIn,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 20),
                    ),
                    BanakoTextButton(
                      text: "Sign Up",
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return const SignUpPage();
                          },
                        ));
                      },
                      fontSize: 20,
                      textColor: Colors.deepPurpleAccent,
                    )
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            BanakoLoadingPage(), // Add this line to show loading indicator
        ],
      ),
    );
  }

  // Update the _signIn method
  _signIn() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;

          if (userData != null) {
            String role = userData['role'] ?? '';
            String userName = userData['username'] ?? '';
            String loginTime = DateTime.now().toString();

            String? panNumber = userData.containsKey('panNumber')
                ? userData['panNumber']
                : generateRandomPanNumber();

            if (role == 'staff' || role == 'admin') {
              if (panNumber != null && panNumber.isNotEmpty) {
                Map<String, dynamic> adminData = await getShopDetails();

                String shopName = adminData['shopName'] ?? '';
                String address = adminData['Address'] ?? '';

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({
                  'shopName': shopName,
                  'address': address,
                  'panNumber': panNumber,
                  'lastLogin': loginTime,
                });

                setState(() {
                  _isLoading = false; // Stop loading
                });

                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return HomePage(
                    userRole: role,
                    username: userName,
                  );
                }));
              } else {
                _showErrorAndResetLoading("PAN Number is missing");
              }
            } else {
              _showErrorAndResetLoading("Role not recognized");
            }
          } else {
            _showErrorAndResetLoading("User data not found");
          }
        } else {
          _showErrorAndResetLoading("User document not found");
        }
      } catch (e) {
        _showErrorAndResetLoading("Error fetching user data: $e");
      }
    } else {
      _showErrorAndResetLoading("Enter Valid Credentials");
      debugPrint("Error in login");
    }
  }

  void _showErrorAndResetLoading(String message) {
    setState(() {
      _isLoading = false; // Stop loading
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
