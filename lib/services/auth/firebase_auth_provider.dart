import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import 'auth_exception.dart';
import 'auth_provider.dart';

class FirebaseAuthProvider implements AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // register user
  @override
  Future<User> createUser({
    required String name,
    required String mobile,
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        return user;
      } else {
        throw UserNotFoundAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  // get current user
  @override
  User? get currentUser {
    final user = _auth.currentUser;
    if (user != null) {
      return user;
    } else {
      return null;
    }
  }

  // login user
  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotFoundAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  // logout
  @override
  Future<void> logout() async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  // initialize firebase app
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // request OTP for user creation
  @override
  Future<String?> requestOTP({
    required String mobile,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(PhoneAuthCredential phoneAuthCredential)
        verificationCompleted,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    try {
      String? id;
      await _auth.verifyPhoneNumber(
        phoneNumber: '+977$mobile',
        codeSent: codeSent,
        verificationCompleted: verificationCompleted,
        verificationFailed: (FirebaseAuthException e) {
          throw GenericAuthException();
        },
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
      return id;
    } on FirebaseAuthException catch (_) {
      throw GenericAuthException();
    } catch (_) {
      throw GenericAuthException();
    }
  }

  // verify phone OTP sent to mobile number
  @override
  Future<PhoneAuthCredential> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      return PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
    } on FirebaseAuthException catch (_) {
      throw GenericAuthException();
    } catch (_) {
      throw GenericAuthException();
    }
  }

  // login with mobile number credential
  @override
  Future<User> loginWithMobileCred({
    required PhoneAuthCredential phoneAuthCredential,
  }) async {
    try {
      await _auth.signInWithCredential(phoneAuthCredential);
      var user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotFoundAuthException();
      }
    } on FirebaseAuthException catch (_) {
      throw GenericAuthException();
    } catch (_) {
      throw GenericAuthException();
    }
  }
}
