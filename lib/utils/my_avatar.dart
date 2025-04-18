import 'package:flutter/material.dart';

class MyAvatar extends StatelessWidget {
  final double? radius;
  final Image? image;
  final Icon? icon;
  final VoidCallback? onTap;

  const MyAvatar({
    super.key,
    this.radius,
    this.image,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius ?? screenSize.width * 0.07,
        backgroundColor: const Color.fromARGB(255, 236, 237, 248),
        child: image != null 
            ? ClipOval(
                child: SizedBox(
                  width: radius != null ? radius! * 2 : screenSize.width * 0.14,
                  height: radius != null ? radius! * 2 : screenSize.width * 0.14,
                  child: image,
                ),
              )
            : (icon ?? Icon(Icons.person, color: Colors.grey[800])),
      ),
    );
  }
}
