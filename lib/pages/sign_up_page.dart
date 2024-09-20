import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/pages/sign_in_page.dart';
import 'package:hisab_kitab/reuseable_widgets/buttons.dart';
import 'package:hisab_kitab/reuseable_widgets/loading_incidator.dart';
import 'package:hisab_kitab/reuseable_widgets/radio_text_widget.dart';
import 'package:hisab_kitab/reuseable_widgets/textField.dart';
import 'package:hisab_kitab/services/User_authentication/firebase_authentication.dart';
import 'package:hisab_kitab/utils/constants/app_text_styles.dart';

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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final signUpKey = GlobalKey<FormState>();
  String? _selectedRole;
  bool _isLoading = false; // Loading state

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _panController.dispose();
    _shopNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: signUpKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                const Text('Create Account', style: AppTextStyle.header),
                const Text(
                  'Please fill in the details to sign up',
                  style: AppTextStyle.subHeader,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                AppInputField(
                  controller: _usernameController,
                  hint: 'Username',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 10),
                AppInputField(
                  controller: _emailController,
                  hint: 'Email',
                  prefixIcon: const Icon(Icons.mail),
                ),
                const SizedBox(height: 10),
                AppInputField(
                  controller: _passwordController,
                  hint: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  isPassword: true,
                ),
                const SizedBox(height: 10),
                AppInputField(
                  controller: _phoneController,
                  hint: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: 10),
                AppInputField(
                  controller: _panController,
                  hint: 'PAN Number',
                  prefixIcon: const Icon(Icons.credit_card_outlined),
                ),
                const SizedBox(height: 10),
                AppInputField(
                  controller: _shopNameController,
                  hint: 'Shop Name',
                  prefixIcon: const Icon(Icons.store_outlined),
                ),
                const SizedBox(height: 10),
                AppInputField(
                  controller: _addressController,
                  hint: 'Address',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                const SizedBox(height: 20),
                const Text('Select Role', style: AppTextStyle.body),
                const SizedBox(height: 10),
                RadioTextWidget(
                  text: 'Admin',
                  isSelected: _selectedRole == 'Admin',
                  onChanged: (value) {
                    setState(() {
                      _selectedRole =
                          value == true ? 'admin' : null; // Store as lowercase
                    });
                  },
                ),
                RadioTextWidget(
                  text: 'Staff',
                  isSelected: _selectedRole == 'Staff',
                  onChanged: (value) {
                    setState(() {
                      _selectedRole =
                          value == true ? 'staff' : null; // Store as lowercase
                    });
                  },
                ),
                const SizedBox(height: 20),
                AppButton(
                  onTap: () {
                    if (signUpKey.currentState!.validate() &&
                        _selectedRole != null) {
                      _signUp(role: _selectedRole!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please fill all fields and select a role')),
                      );
                    }
                  },
                  label: 'Sign Up',
                ),
                const SizedBox(height: 10),
                if (_isLoading)
                  const LoadingIndicator(
                    size: 30,
                  ),
                const SizedBox(height: 20),
                const Text(
                  "Already have an account?",
                  style: AppTextStyle.body,
                ),
                const SizedBox(height: 20),
                AppButton(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInPage(),
                        ));
                  },
                  label: 'Log In',
                  isNegativeButton: true,
                ),
                const SizedBox(height: 20),
                // Show loading animation if the signup process is in progress
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signUp({required String role}) async {
    setState(() {
      _isLoading = true; // Start loading when sign-up begins
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String phoneNumber = _phoneController.text;
    String panNumber = _panController.text;
    String shopName = _shopNameController.text;
    String address = _addressController.text;

    User? user = await _auth.signUpWithEmailAndPassword(
      email,
      password,
      role,
      username,
      phoneNumber,
    );

    if (user != null) {
      try {
        // Convert role to lowercase for case-insensitive comparison
        String normalizedRole = role.toLowerCase();

        // Determine the collection based on the normalized role
        String collection;
        if (normalizedRole == 'admin') {
          collection = 'admin'; // Store Admin in "admin" collection
        } else if (normalizedRole == 'users' || normalizedRole == 'staff') {
          collection = 'users'; // Store Staff in "users" collection
        } else {
          collection = 'users'; // Default to 'users' for unknown roles
        }

        // Use user.uid as documentId for consistency
        String documentId = user.uid;

        await FirebaseFirestore.instance
            .collection(collection)
            .doc(documentId)
            .set({
          'username': username,
          'email': email,
          'phoneNo': phoneNumber,
          'role': role,
          'panNo': panNumber,
          'shopName': shopName,
          'Address': address,
          'createdAt': FieldValue.serverTimestamp(), // Creation time
          'lastLogin':
              FieldValue.serverTimestamp(), // Store lastLogin as Timestamp
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User created successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        print("Error adding user data to Firestore: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error creating user. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error creating user. Please try again.')),
      );
    }

    setState(() {
      _isLoading = false; // Stop loading once sign-up completes
    });
  }
}
