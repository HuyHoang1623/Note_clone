import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note_clone/core/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      await user.updateDisplayName(name);

      final userModel = UserModel(
        uid: user.uid,
        email: user.email,
        name: name,
        photoUrl: user.photoURL,
        provider: 'email',
      );

      await _saveUserToFirestore(userModel);
    } catch (e) {
      throw Exception("Lỗi đăng ký: $e");
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      final user = _auth.currentUser!;
      final userModel = UserModel(
        uid: user.uid,
        email: user.email,
        name: user.displayName ?? '',
        photoUrl: user.photoURL,
        provider: 'email',
      );

      await _saveUserToFirestore(userModel);
    } catch (e) {
      throw Exception("Lỗi đăng nhập: $e");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final userModel = UserModel(
        uid: user.uid,
        email: user.email,
        name: user.displayName,
        photoUrl: user.photoURL,
        provider: 'google',
      );

      await _saveUserToFirestore(userModel);
    } catch (e) {
      throw Exception("Lỗi đăng nhập Google: $e");
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) return;

      final credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final userModel = UserModel(
        uid: user.uid,
        email: user.email,
        name: user.displayName,
        photoUrl: user.photoURL,
        provider: 'facebook',
      );

      await _saveUserToFirestore(userModel);
    } catch (e) {
      throw Exception("Lỗi đăng nhập Facebook: $e");
    }
  }

  Future<void> _saveUserToFirestore(UserModel user) async {
    final userDoc = _db.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set(user.toMap());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }
}
