import 'package:flutter/material.dart';
import 'dart:developer' as console show log;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_phone_number/screens/wrapper.dart';

import 'blocs/auth/auth_bloc.dart';
import 'config/theme.dart';
import 'services/firebase_auth_provider.dart';

void main() {
  console.log('app started successfully!');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FirebaseAuthProvider()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Firebase Phone Number',
        debugShowCheckedModeBanner: false,
        theme: theme(),
        home: const Wrapper(),
      ),
    );
  }
}
