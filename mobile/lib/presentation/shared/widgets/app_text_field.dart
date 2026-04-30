import 'package:flutter/material.dart';
import '../constants.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.hintText,
    this.controller,
    this.prefixIcon,
    this.keyboardType,
    this.enabled = true,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: kSpacingUnit,
          vertical: kSpacingUnit,
        ),
      ),
    );
  }
}
