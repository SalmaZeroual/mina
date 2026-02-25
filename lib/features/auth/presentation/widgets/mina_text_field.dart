import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MinaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const MinaTextField({
    super.key, required this.controller, required this.label,
    this.obscure = false, this.keyboardType, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(labelText: label),
    );
  }
}
