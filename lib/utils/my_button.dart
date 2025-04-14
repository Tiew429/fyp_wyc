import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Icon? icon;
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool? isLoading; // to show loading indicator
  final bool? isEnabled; // to disable button when loading, and avoid from all buttons display loading indicator

  const MyButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor = const Color.fromARGB(255, 26, 218, 128),
    this.icon,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return ElevatedButton(
      onPressed: isLoading ?? false ? () {} : isEnabled ?? true ? onPressed : () {},
      style: ElevatedButton.styleFrom(
        fixedSize: Size(width ?? screenSize.width, height ?? 50),
        backgroundColor: isEnabled ?? true ? backgroundColor : backgroundColor.withValues(alpha: 0.5),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon != null ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon!,
              SizedBox(width: 10),
            ],
          ) : SizedBox.shrink(),
          isLoading ?? false ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ) : Text(text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}