import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign-up method with username, role, and phone number
  Future<User?> signUpWithEmailAndPassword(String email, String password,
      String role, String username, String phoneNumber) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;
      if (user != null) {
        // Create user document in Firestore based on the role
        await _createUserDocument(user, role, username, phoneNumber);
        debugPrint("User document created successfully");
      }
      return user;
    } catch (e) {
      debugPrint("Error in SignUp: $e");
      return null;
    }
  }

  // Helper method to create user document in Firestore based on the role
  Future<void> _createUserDocument(
      User user, String role, String username, String phoneNumber) async {
    String collection = role.toLowerCase() == 'admin' ? 'admin' : 'users';
    DocumentReference userDoc = _db.collection(collection).doc(user.uid);

    try {
      await userDoc.set({
        'username': username, // Ensure correct username is used
        'email': user.email,
        'role': role, // Store the role correctly
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint(
          "User document successfully created in $collection collection");
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
