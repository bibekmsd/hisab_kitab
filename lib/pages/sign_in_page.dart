import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/homepage_body.dart';
import 'package:hisab_kitab/pages/sign_up_page.dart';
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
      .doc('09099090')
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
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade300, Colors.purple.shade300],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Sign in to continue",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: "Email",
                                prefixIcon: const HeroIcon(HeroIcons.envelope),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                hintText: "Password",
                                prefixIcon:
                                    const HeroIcon(HeroIcons.lockClosed),
                                suffixIcon: IconButton(
                                  icon: HeroIcon(
                                    _obscureText
                                        ? HeroIcons.eyeSlash
                                        : HeroIcons.eye,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      "Sign In",
                                      style: TextStyle(fontSize: 18),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ));
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _signIn() async {
    setState(() {
      _isLoading = true;
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
                  _isLoading = false;
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
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
