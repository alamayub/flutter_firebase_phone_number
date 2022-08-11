import 'package:firebase_auth/firebase_auth.dart'
    show PhoneAuthCredential, User;

abstract class AuthProvider {
  Future<void> initialize();
  User? get currentUser;
  Future<User> login({
    required String email,
    required String password,
  });
  Future<User> createUser({
    required String name,
    required String mobile,
    required String email,
    required String password,
  });

  Future<void> requestOTP({
    required String mobile,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  });

  Future<PhoneAuthCredential> verifyOTP({
    required String verificationId,
    required String otp,
  });

  Future<User> loginWithMobileCred({
    required PhoneAuthCredential phoneAuthCredential,
  });

  Future<void> logout();
}
