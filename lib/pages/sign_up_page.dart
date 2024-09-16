import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/reuseable_widgets/textField.dart';
import 'package:hisab_kitab/reuseable_widgets/text_button.dart';
import 'package:hisab_kitab/services/User_authentication/firebase_authentication.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController =
      TextEditingController(); // Added phone number controller

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose(); // Dispose of phone controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Staff Sign-Up"),
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
                  labelText: "Username",
                  controller: _usernameController,
                ),
                const SizedBox(height: 16),
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
                BanakoTextField(
                  labelText: "Phone Number", // Added phone number field
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BanakoTextButton(
                      text: "Sign Up",
                      onPressed: () => _signUp(role: "staff"),
                      fontSize: 20,
                      textColor: const Color.fromARGB(255, 144, 113, 229),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _signUp({required String role}) async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String phoneNumber = _phoneController.text; // Get phone number

    User? user = await _auth.signUpWithEmailAndPassword(
      email,
      password,
      role,
      username,
      phoneNumber, // Pass phone number to the sign-up method
    );

    if (user != null) {
      debugPrint("User created successfully");

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('User Created Successfully'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.pop(context); // Navigate back to the sign-in page
                },
              ),
            ],
          );
        },
      );
    } else {
      debugPrint("User creation error");
    }
  }
}
