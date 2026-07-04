import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    this.countryCode = '+91',
    this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final String countryCode;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      decoration: InputDecoration(
        labelText: 'Phone number',
        hintText: '9876543210',
        errorText: errorText,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                countryCode,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 24, color: AppColors.grey300),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(),
      ),
    );
  }
}
