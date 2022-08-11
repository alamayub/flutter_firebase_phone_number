import 'package:firebase_auth/firebase_auth.dart' show User;

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

  Future<void> logout();
}
