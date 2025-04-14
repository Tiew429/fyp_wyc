import 'package:flutter/material.dart';
import 'package:fyp_wyc/utils/my_button.dart';

class MyEmptyWidgets extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool? isLoading;

  const MyEmptyWidgets({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text),
          SizedBox(height: 30),
          MyButton(
            onPressed: onPressed ?? () {},
            text: 'Try refresh it',
            isLoading: isLoading ?? false,
            width: screenSize.width * 0.5,
          ),
        ],
      ),
    );
  }
}