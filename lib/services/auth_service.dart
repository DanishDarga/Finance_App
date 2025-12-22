import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for handling authentication operations
class AuthService {
  AuthService._();

  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream for auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  /// 
  /// Throws [FirebaseAuthException] if authentication fails
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Register a new user with email and password
  /// 
  /// Throws [FirebaseAuthException] if registration fails
  Future<User?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = result.user;

      if (user != null) {
        // Update display name in Firebase Auth
        await user.updateDisplayName('$firstName $lastName');
        await user.reload();

        // Create user document in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email.trim(),
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return result.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

