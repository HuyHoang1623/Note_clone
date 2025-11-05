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
