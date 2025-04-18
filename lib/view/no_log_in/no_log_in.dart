import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/utils/my_avatar.dart';
import 'package:fyp_wyc/utils/my_button.dart';
import 'package:go_router/go_router.dart';

class NoLogInPage extends StatefulWidget {
  const NoLogInPage({super.key});

  @override
  State<NoLogInPage> createState() => _NoLogInPageState();
}

class _NoLogInPageState extends State<NoLogInPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyAvatar(
            radius: screenSize.width * 0.1,
          ),
          SizedBox(height: 24),
          Text('Please log in to continue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          MyButton(
            onPressed: () => navigatorKey.currentContext!.go('/${ViewData.auth.path}'), 
            text: 'Continue with Email',
            borderRadius: 12,
            width: screenSize.width * 0.58,
          ),
          SizedBox(height: 12),
          MyButton(
            onPressed: () {}, 
            text: 'Continue with Google',
            backgroundColor: Colors.red,
            borderRadius: 12,
            width: screenSize.width * 0.58,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(text: 'You need to agree to the '),
                    TextSpan(
                      text: 'Terms of Services',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                    TextSpan(text: ' and knowledge to our '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
