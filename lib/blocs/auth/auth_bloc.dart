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
    String? name, mobile, email, password;
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

    // for registering user screen
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    });

    // regsiter user with mobile number & email along with create both signin credential
    on<AuthEventRegister>((event, emit) async {
      emit(const AuthStateRegistering(exception: null, isLoading: true));
      name = event.name;
      mobile = event.mobile;
      email = event.email;
      password = event.password;
      try {
        await provider.requestOTP(
          mobile: mobile!,
          verificationCompleted: (
            PhoneAuthCredential phoneAuthCredential,
          ) async {
            await provider.createUser(
              name: name!,
              mobile: mobile!,
              email: email!,
              password: password!,
            );
            await userProvider.createUser(
              name: name!,
              mobile: mobile!,
              email: email!,
            );
            await provider.loginWithMobileCred(
              phoneAuthCredential: phoneAuthCredential,
            );
            var user = provider.currentUser;
            emit(AuthStateLoggedIn(user: user!, isLoading: false));
          },
          codeSent: (verificationId, forceResendingToken) {
            verificationId = verificationId;
          },
          codeAutoRetrievalTimeout: (verificationId) {
            verificationId = verificationId;
            emit(AuthStateVerifyOTP(
              verificationId: verificationId,
              exception: null,
              isLoading: false,
            ));
          },
        );
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });

    // verify otp
    on<AuthEventVerifyOTP>((event, emit) async {
      emit(AuthStateVerifyOTP(
        exception: null,
        isLoading: true,
        verificationId: verificationId!,
      ));
      try {
        PhoneAuthCredential phoneAuthCredential = await provider.verifyOTP(
          verificationId: verificationId,
          otp: event.otp,
        );
        await provider.createUser(
          name: name!,
          mobile: mobile!,
          email: email!,
          password: password!,
        );
        await userProvider.createUser(
          name: name!,
          mobile: mobile!,
          email: email!,
        );
        await provider.loginWithMobileCred(
          phoneAuthCredential: phoneAuthCredential,
        );
        var user = provider.currentUser;
        emit(AuthStateLoggedIn(user: user!, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateVerifyOTP(
          exception: e,
          isLoading: false,
          verificationId: verificationId,
        ));
      }
    });

    // login with email & password
    on<AuthEventLogin>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while I log you in',
        ),
      );
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.login(email: email, password: password);
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    // for request OTP from mobile screen
    on<AuthEventShouldRequestOTP>((event, emit) {
      emit(const AuthStateRequestOTP(exception: null, isLoading: false));
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


/*on<AuthEventRegister>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while I create your account',
        ),
      );
      final name = event.name;
      final mobile = event.mobile;
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(
          name: name,
          mobile: mobile,
          email: email,
          password: password,
        );
        final user = provider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } else {
          await userProvider.createUser(
            email: email,
            name: name,
            mobile: mobile,
          );
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });*/