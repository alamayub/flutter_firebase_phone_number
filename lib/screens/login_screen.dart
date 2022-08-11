import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/message_dialog.dart';
import '../../helper/extension/validator.dart';
import '../blocs/auth/auth_bloc.dart';
import '../services/auth_exception.dart';
import '../widgets/custom_form_text_field.dart';
import '../widgets/custom_material_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await messageDialog(context, 'User not found!');
          } else if (state.exception is WrongPasswordAuthException) {
            await messageDialog(context, 'Wrong Password!');
          } else if (state.exception is GenericAuthException) {
            await messageDialog(context, 'Authentication Error!');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomTextFormField(
                  controller: _email,
                  hint: 'mynotes@mynotes.com',
                  iconData: Icons.email,
                  validator: (val) => val?.isValidEmail(val),
                ),
                const SizedBox(height: 12),
                CustomTextFormField(
                  controller: _password,
                  hint: '******',
                  iconData: Icons.lock,
                  validator: (val) => val?.isValidPassword(val),
                ),
                const SizedBox(height: 12),
                CustomMaterialButton(
                  title: 'Login',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final email = _email.text.trim();
                      final password = _password.text.trim();
                      context
                          .read<AuthBloc>()
                          .add(AuthEventLogin(email, password));
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Don\'t have account? '),
                    GestureDetector(
                      onTap: () {
                        context
                            .read<AuthBloc>()
                            .add(const AuthEventShouldRegister());
                      },
                      child: const Text(
                        'Create One',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
