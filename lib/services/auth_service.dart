import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ WORKING constructor (google_sign_in 6.2.1)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  /// Auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Email & Password Login
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return result.user;
  }

  /// Register User
  Future<User?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = result.user;
    if (user != null) {
      await user.updateDisplayName('$firstName $lastName');

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return user;
  }

  /// ✅ Google Sign-In (STABLE & WORKING)
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final user = result.user;

      if (user != null) {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        if (!(await userRef.get()).exists) {
          final nameParts = user.displayName?.split(' ') ?? [];

          await userRef.set({
            'email': user.email,
            'firstName': nameParts.isNotEmpty ? nameParts.first : 'User',
            'lastName':
                nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
