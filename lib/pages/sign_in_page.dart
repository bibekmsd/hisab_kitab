import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/HomePages/homepage.dart';
// import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/homepage_body.dart';
import 'package:hisab_kitab/pages/sign_up_page.dart';
import 'package:hisab_kitab/reuseable_widgets/buttons.dart';
import 'package:hisab_kitab/reuseable_widgets/textField.dart';
import 'package:hisab_kitab/services/User_authentication/firebase_authentication.dart';
import 'package:hisab_kitab/utils/constants/app_text_styles.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final logInKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: logInKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  const Text('Welcome Back', style: AppTextStyle.header),
                  const Text('Sign in to continue',
                      style: AppTextStyle.subHeader),
                  const SizedBox(height: 50),
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
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(
                          0xEAF4FE), // Equivalent to rgba(234, 244, 254, 1)
                      borderRadius: BorderRadius.circular(
                          8), // Optional: adds rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal:
                            12), // Optional: adds padding inside the dropdown
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border:
                            InputBorder.none, // Remove the default underline
                      ),
                      hint: const Text("Select Role"),
                      value: _selectedRole,
                      items: ['Admin', 'Staff'].map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedRole = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a role';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // In Button
                  AppButton(
                    onTap: _isLoading ? () {} : () => _signIn(),
                    label: _isLoading ? 'Signing In...' : 'Sign In',
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading) const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text("Don't have an account?",
                      style: AppTextStyle.body),
                  const SizedBox(height: 20),
                  AppButton(
                    labelColor: const Color.fromARGB(255, 17, 24, 39),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ));
                    },
                    label: 'Sign Up',
                    isNegativeButton: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Fetch user details based on role (Admin or Staff) and UID
  Future<Map<String, dynamic>> getDetailsByRole(String role, String uid) async {
    // Choose the Firestore collection based on the role
    String collection = role == 'Admin' ? 'admin' : 'users';

    // Fetch the document from the selected collection
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection(collection).doc(uid).get();

    // Check if the document exists and return its data
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    } else {
      throw Exception('No data found for the provided role and UID.');
    }
  }

  Future<void> _signIn() async {
    if (!logInKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      // Firebase authentication to sign in with email and password
      User? user = await _auth.signInWithEmailAndPassword(email, password);

      if (user != null) {
        // Convert role to lowercase to ensure it's saved correctly
        String roleCollection =
            _selectedRole!.toLowerCase() == 'admin' ? 'admin' : 'users';

        // Search Firestore for the user with the provided email in the specific collection
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection(roleCollection)
            .where('email', isEqualTo: email)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          // Get the user data from Firestore
          DocumentSnapshot userDoc = userSnapshot.docs.first;
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          String role = userData['role'] ?? '';
          String email = userData['email'] ?? '';
          String panNo = userData['panNo'] ?? '';

          String userName = userData['username'] ?? '';

          // Ensure the selected role matches the Firestore role (both lowercased)
          if (_selectedRole!.toLowerCase() == role.toLowerCase()) {
            // Update the user's last login time in Firestore as a Timestamp
            await FirebaseFirestore.instance
                .collection(roleCollection)
                .doc(userDoc.id) // Use the document ID to update the record
                .update({
              'lastLogin': Timestamp.now(), // Save as Firestore Timestamp
            });

            setState(() {
              _isLoading = false;
            });

            // Navigate to the home page
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomePage(
                  email: email,
                  panNo: panNo,
                  userRole: role,
                  username: userName,
                ),
              ),
              (Route<dynamic> route) => false,
            );
          } else {
            _showErrorAndResetLoading("Invalid role for this email.");
          }
        } else {
          _showErrorAndResetLoading("No user found for the selected role.");
        }
      } else {
        _showErrorAndResetLoading("Invalid credentials.");
      }
    } catch (e) {
      _showErrorAndResetLoading("Error during sign in: $e");
    }
  }

  /// Helper function to show error messages and reset loading state
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
