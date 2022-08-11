import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/message_dialog.dart';
import '../../helper/extension/validator.dart';
import '../blocs/auth/auth_bloc.dart';
import '../services/auth/auth_exception.dart';
import '../widgets/custom_form_text_field.dart';
import '../widgets/custom_material_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _mobile;
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _name = TextEditingController();
    _mobile = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await messageDialog(context, 'Please use a strong password!');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await messageDialog(
              context,
              'This email is already used by another account!',
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await messageDialog(context, 'Invalid email!');
          } else if (state.exception is GenericAuthException) {
            await messageDialog(context, 'Authentication Error!');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomTextFormField(
                  controller: _name,
                  hint: 'Toeato Toeato',
                  iconData: Icons.person,
                  validator: (val) => val?.isValidName(val),
                ),
                const SizedBox(height: 12),
                CustomTextFormField(
                  controller: _mobile,
                  hint: '98XXXXXXXX',
                  iconData: Icons.settings_cell_outlined,
                  validator: (val) => val?.isValidPhone(val),
                ),
                const SizedBox(height: 12),
                CustomTextFormField(
                  controller: _email,
                  hint: 'toeato@toeato.com',
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
                  title: 'Register',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final name = _name.text.trim();
                      final mobile = _mobile.text.trim();
                      final email = _email.text.trim();
                      final password = _password.text.trim();
                      context.read<AuthBloc>().add(AuthEventRegister(
                            name: name,
                            mobile: mobile,
                            email: email,
                            password: password,
                          ));
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Already have account? '),
                    GestureDetector(
                      onTap: () {
                        context.read<AuthBloc>().add(const AuthEventLogout());
                      },
                      child: const Text(
                        'Login',
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
