import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';

class OtpInputField extends StatelessWidget {
  const OtpInputField({
    super.key,
    required this.controller,
    this.length = 6,
    this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ],
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 12,
      ),
      decoration: InputDecoration(
        labelText: 'Enter OTP',
        hintText: List.filled(length, '•').join(),
        errorText: errorText,
        counterText: '',
        filled: true,
        fillColor: AppColors.grey50,
      ),
    );
  }
}
