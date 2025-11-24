import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream for auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException {
      // Re-throw the exception to be caught by the UI
      rethrow;
    }
  }

  // Register with email and password
  Future<User?> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Create a new document for the user with the uid
      // Also update the user's display name in Firebase Auth
      if (user != null) {
        await user.updateDisplayName('$firstName $lastName');
        // Reload the user to get the updated display name
        await user.reload();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'createdAt': Timestamp.now(),
        });
      }
      return result.user;
    } on FirebaseAuthException {
      // Re-throw the exception to be caught by the UI
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
