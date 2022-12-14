import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_phone_number/screens/home_screen.dart';

import '../blocs/auth/auth_bloc.dart';
import '../helper/loading/loading_screen.dart';
import 'login_screen.dart';
import '../widgets/loader.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const HomeScreen();
        } else if (state is AuthStateLoggedOut) {
          return const LoginScreen();
        } else {
          return const Scaffold(body: Loader());
        }
      },
    );
  }
}
