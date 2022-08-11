import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/message_dialog.dart';
import '../../helper/extension/validator.dart';
import '../blocs/auth/auth_bloc.dart';
import '../services/auth/auth_exception.dart';
import '../widgets/custom_form_text_field.dart';
import '../widgets/custom_material_button.dart';

class VerifyOTPScreen extends StatefulWidget {
  const VerifyOTPScreen({Key? key}) : super(key: key);

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _otp;

  @override
  void initState() {
    _otp = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _otp.dispose();
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
          title: const Text('Verify OTP'),
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
                  controller: _otp,
                  hint: 'XXXXXX',
                  iconData: Icons.mobile_friendly,
                  validator: (val) => val?.isValidPhone(val),
                ),
                const SizedBox(height: 12),
                CustomMaterialButton(
                  title: 'Login',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final otp = _otp.text.trim();
                      context
                          .read<AuthBloc>()
                          .add(AuthEventVerifyOTP(otp: otp));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
