import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign-up method with username and role
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String username, String role) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        // Create user document in Firestore
        await _createUserDocument(user, username, role);
      }

      return user;
    } catch (e) {
      debugPrint("Error in SignUp: $e");
    }
    return null;
  }

  // Helper method to create user document in Firestore
  Future<void> _createUserDocument(
      User user, String role, String username) async {
    DocumentReference userDoc = _db.collection('users').doc(user.uid);

    await userDoc.set({
      'username': username,
      'email': user.email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
    }
    return null;
  }

  // Other methods (e.g., sign out, password reset) can be implemented as needed
}
