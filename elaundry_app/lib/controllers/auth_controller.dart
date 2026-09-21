import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../models/auth_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current logged in Firebase User
  User? get currentFirebaseUser => _auth.currentUser;

  /// Helper to convert Firebase User & Token into your custom AuthModel
  Future<AuthModel> _createAuthModel(
    User user, {
    String? fullNameFallback,
  }) async {
    final IdTokenResult idTokenResult = await user.getIdTokenResult(true);
    final String token = idTokenResult.token ?? '';
    final DateTime? expiration = idTokenResult.expirationTime;

    final docSnapshot =
        await _firestore.collection('users').doc(user.uid).get();

    UserModel userModel;
    if (docSnapshot.exists && docSnapshot.data() != null) {
      userModel = UserModel.fromMap(docSnapshot.data()!, user.uid);
    } else {
      userModel = UserModel(
        id: user.uid,
        fullName: user.displayName ?? fullNameFallback ?? '',
        email: user.email ?? '',
        phone: user.phoneNumber,
        profileImage: user.photoURL,
        createdAt: DateTime.now(),
      );
    }

    return AuthModel(
      accessToken: token,
      expiresAt: expiration,
      tokenType: 'Bearer',
      user: userModel,
    );
  }

  /// Register user with Email, Password, and Full Name
  Future<AuthModel> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final User? user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'USER_NULL',
          message: 'An error occurred while creating the account.',
        );
      }

      await user.updateDisplayName(fullName);

      final newUser = UserModel(
        id: user.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone,
        profileImage: null,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

      return await _createAuthModel(user, fullNameFallback: fullName);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Sign In with Email and Password
  Future<AuthModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'USER_NULL',
          message: 'Failed to sign in.',
        );
      }

      return await _createAuthModel(user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Sign In or Register using Google (v7 API)
  Future<AuthModel> signInWithGoogle() async {
    try {
      // 1. Trigger the Google Account selection prompt
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Sign in cancelled');
      }

      // 2. Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in with Google');
      }

      // 5. Ensure profile exists in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        final newUser = UserModel(
          id: user.uid,
          fullName: user.displayName ?? 'eLaundry User',
          email: user.email ?? '',
          phone: user.phoneNumber,
          profileImage: user.photoURL,
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }

      return await _createAuthModel(user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'An unexpected authentication error occurred.';
    }
  }
}
