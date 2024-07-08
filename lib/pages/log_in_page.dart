import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/admin/admin_page.dart';
import 'package:hisab_kitab/pages/home_page.dart';
import 'package:hisab_kitab/pages/sign_up_page.dart';
import 'package:hisab_kitab/reuseable_widgets/buttons.dart';
import 'package:hisab_kitab/reuseable_widgets/textField.dart';
import 'package:hisab_kitab/reuseable_widgets/text_button.dart';
import 'package:hisab_kitab/services/User_authentication/firebase_authentication.dart';
import 'package:hisab_kitab/user/staff_user_page.dart';
import 'package:hisab_kitab/utils/gradiants.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign-In"),
        leading: const BackButton(),
      ),
      body: Stack(
        children: [
          // Gradient background
          // const MeroGradiant(),
          // Centered content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Center the column itself
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
                  // ignore: sort_child_properties_last
                  children: [
                    BanakoButton(
                      textSize: 18,
                      backgroundColor: Colors.black,
                      height: 48,
                      text: "Log In",
                      textColor: Colors.black,
                      width: 116,
                      onPressed: _signIn,
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
        ],
      ),
    );
  }

  _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if (user != null) {
      // Retrieve user role from Firestore
      String role = await _getUserRole(user.uid);

      // Navigate based on role
      if (role == 'admin') {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return const AdminUserScreen();
        }));
      } else if (role == 'staff') {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return const StaffUserScreen();
        }));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter Valid Credentials")));
      debugPrint("Error in login");
    }
  }

  Future<String> _getUserRole(String uid) async {
    String role = 'user'; // Default role

    try {
      DocumentSnapshot docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        role = docSnapshot.get('role');
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
    }

    return role;
  }
}
