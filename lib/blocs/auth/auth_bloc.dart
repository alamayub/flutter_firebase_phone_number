import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_phone_number/services/user/user_provider.dart';
import '../../services/auth/auth_provider.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthProvider provider,
    required UserProvider userProvider,
  }) : super(const AuthInitial(isLoading: true)) {
    String? verificationId;
    // initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    // login with mobile
    on<AuthEventLogin>((event, emit) async {
      try {
        emit(const AuthStateLoggedOut(exception: null, isLoading: true));
        await provider.requestOTP(
          mobile: event.mobile,
          codeSent: (String verificationId, int? resendToken) {
            verificationId = verificationId;
          },
          verificationCompleted: (PhoneAuthCredential phoneAuthCred) async {
            provider.loginWithMobileCred(phoneAuthCredential: phoneAuthCred);
            final user = provider.currentUser;
            if (user != null) {
              emit(AuthStateLoggedIn(user: user, isLoading: false));
            } else {
              emit(const AuthStateLoggedOut(exception: null, isLoading: false));
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            verificationId = verificationId;
          },
        );
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    // request OTP
    on<AuthEventVerifyOtp>((event, emit) async {
      try {
        emit(const AuthStateLoggedOut(exception: null, isLoading: true));
        PhoneAuthCredential phoneAuthCredential = await provider.verifyOTP(
          verificationId: verificationId!,
          otp: event.otp,
        );
        await provider.loginWithMobileCred(
          phoneAuthCredential: phoneAuthCredential,
        );
        final user = provider.currentUser;
        if (user != null) {
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        } else {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    // log out
    on<AuthEventLogout>((event, emit) async {
      try {
        emit(const AuthStateLoggedOut(exception: null, isLoading: true));
        await provider.logout();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }
}
