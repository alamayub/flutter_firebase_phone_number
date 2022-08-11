import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final IconData iconData;
  final String hint;

  final String? Function(String?)? validator;

  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.iconData,
    required this.hint,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        counterText: '',
        prefixIcon: Icon(
          iconData,
          size: 20,
        ),
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        border: outlineInputBorder(
          Theme.of(context).colorScheme.background,
        ),
        enabledBorder: outlineInputBorder(Colors.grey.withOpacity(.05)),
        focusedBorder:
            outlineInputBorder(Theme.of(context).colorScheme.primary),
        focusedErrorBorder: outlineInputBorder(Colors.red),
        disabledBorder: outlineInputBorder(Colors.grey),
        errorBorder: outlineInputBorder(Colors.red.shade500),
      ),
    );
  }
}

outlineInputBorder(Color color) {
  return OutlineInputBorder(
    borderSide: BorderSide(color: color.withOpacity(.5), width: 1),
    borderRadius: const BorderRadius.all(Radius.circular(6)),
  );
}
