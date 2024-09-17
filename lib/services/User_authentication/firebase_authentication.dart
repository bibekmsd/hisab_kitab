import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign-up method with username, role, and phone number
  Future<User?> signUpWithEmailAndPassword(String email, String password,
      String username, String role, String phoneNumber) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        // Create user document in Firestore
        await _createUserDocument(user, username, role, phoneNumber);
        debugPrint("User document created successfully");
      }

      return user;
    } catch (e) {
      debugPrint("Error in SignUp: $e");
      return null;
    }
  }

  // Helper method to create user document in Firestore
  Future<void> _createUserDocument(
      User user, String username, String role, String phoneNumber) async {
    DocumentReference userDoc = _db.collection('users').doc(user.uid);

    try {
      await userDoc.set({
        'username': role, // Correct the role and username values here
        'email': user.email,
        'role': username, // Swap these values if needed
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint("User document successfully created in Firestore");
    } catch (e) {
      debugPrint("Error creating user document in Firestore: $e");
      rethrow; // Rethrow if you want to handle the error elsewhere
    }
  }

  // Sign-in method
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential.user;
    } catch (e) {
      debugPrint("Error in SignIn: $e");
      return null;
    }
  }

  // Other methods (e.g., sign out, password reset) can be implemented as needed
}
