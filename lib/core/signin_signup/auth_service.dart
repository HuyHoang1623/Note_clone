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
