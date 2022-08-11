import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:flutter_firebase_phone_number/services/user/user_exception.dart';

import '../auth/auth_exception.dart';
import 'user_provider.dart';

class FirestoreAuthProvider extends UserProvider {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  // register user
  @override
  Future<void> createUser({
    required String name,
    required String mobile,
    required String email,
  }) async {
    try {
      log('called 21');
      var user = FirebaseAuth.instance.currentUser!;
      await users.doc(user.uid).set({
        'name': name,
        'email': email,
        'mobile': mobile,
        'type': 'user',
        'points': 50,
        'createdAt': DateTime.now().microsecondsSinceEpoch,
      });
    } on FirebaseAuthException catch (e) {
      log('Line 32 user firestore ${e.toString()}');
      throw CouldNotCreateUserException();
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> updateUser({
    required String name,
    required String mobile,
    required String email,
    required String password,
  }) async {
    try {
      var user = FirebaseAuth.instance.currentUser!;
      await users.doc(user.uid).set({
        'name': name,
        'email': email,
        'mobile': mobile,
        'updatedAt': DateTime.now().microsecondsSinceEpoch,
      });
    } on FirebaseAuthException catch (e) {
      log('Line 56 user firestore ${e.toString()}');
      throw CouldNotCreateUserException();
    } catch (_) {
      throw GenericAuthException();
    }
  }
}
