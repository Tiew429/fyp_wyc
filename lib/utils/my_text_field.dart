import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final Icon? icon;
  final String hintText;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onSuffixIconTap;
  final Color? backgroundColor;
  final bool borderDisplay;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool isReadOnly;
  final int maxLines;
  final TextInputType keyboardType;

  const MyTextField({
    super.key,
    required this.controller,
    this.icon,
    required this.hintText,
    this.isPassword = false,
    this.isVisible = true,
    this.onSuffixIconTap,
    this.backgroundColor,
    this.borderDisplay = true,
    this.validator,
    this.onChanged,
    this.isReadOnly = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      readOnly: isReadOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: icon,
        suffixIcon: isPassword ? IconButton(
          onPressed: onSuffixIconTap,
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
        ) : null,
        hintText: hintText,
        filled: backgroundColor != null,
        fillColor: backgroundColor,
        border: borderDisplay ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey),
        ) : InputBorder.none,
        enabledBorder: !borderDisplay ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ) : null,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: borderDisplay 
              ? BorderSide(color: const Color.fromARGB(255, 26, 218, 128)) 
              : BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey[400]),
        labelStyle: TextStyle(color: Colors.grey[800]),
      ),
      obscureText: !isVisible,
      style: TextStyle(color: Colors.grey[800]),
    );
  }
}
