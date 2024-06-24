import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/User_authentication/firebase_implementation.dart';
import 'package:hisab_kitab/reuseable_widgets/textField.dart';
import 'package:hisab_kitab/reuseable_widgets/text_button.dart';
import 'package:hisab_kitab/utils/gradiants.dart';

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

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          const MeroGradiant(),
          // Centered content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Center the column itself
              children: [
                BanakoTextField(
                  // hintText: "Username",
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BanakoTextButton(
                      text: "Master Sign-up",
                      onPressed: () {},
                      fontSize: 20,
                      textColor: Colors.deepPurpleAccent,
                    ),
                    BanakoTextButton(
                      text: "Sign Up",
                      onPressed: _signUp,
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

  void _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      print("User created successfully");

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('User Created Successfully'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
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
      print("User creation error");
    }
  }
}
