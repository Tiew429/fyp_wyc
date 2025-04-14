import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final bool isClearable;

  const MySearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.isClearable = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        suffixIcon: isClearable ? IconButton(
          onPressed: () {
            controller.clear();
          }, 
          icon: Icon(Icons.cancel),
        ) : SizedBox.shrink(),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 236, 237, 248),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      style: TextStyle(color: Colors.grey[800]),
    );
  }
}