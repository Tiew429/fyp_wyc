import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fyp_wyc/event/user_event.dart';
import 'package:fyp_wyc/firebase/firebase_services.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/utils/my_button.dart';
import 'package:fyp_wyc/functions/my_snackbar.dart';
import 'package:fyp_wyc/utils/my_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:fyp_wyc/data/viewdata.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSignUpClicked;

  const LoginPage({
    super.key, 
    required this.onSignUpClicked,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isPasswordVisible = false, isLoginLoading = false,
    isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    // for testing purpose, remove after complete
    _emailOrPhoneController.text = 'tiewjiajun0429@gmail.com';
    _passwordController.text = '111111a';
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loginWithEmailOrPhone() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoginLoading = true;
    });

    Map<String, dynamic> response = {
      'success': false,
      'message': '',
    };
    String emailOrPhone = _emailOrPhoneController.text.toLowerCase();
    String password = _passwordController.text;

    // check is email or phone number
    if (emailOrPhone.contains('@')) {
      // email
      FirebaseServices firebaseServices = FirebaseServices();
      response = await firebaseServices.signInWithEmail(emailOrPhone, password);
    } else {
      // phone number
      // still thinking
    }

    setState(() {
      isLoginLoading = false;
    });

    bool isSuccess = response['success'];
    String message = response['message'];

    // show snackbar
    MySnackBar.showSnackBar(message);

    if (isSuccess) {
      navigatorKey.currentContext!.go('/${ViewData.dashboard.path}');
    }
  }

  Future<void> loginWithGoogle() async {}

  Future<void> loginAsGuest() async {
    // ensure there has no user data in app event bus, firebase auth and shared preferences
    final response = await UserStore.clearCurrentUser();

    if (response['success']) {
      MySnackBar.showSnackBar('Continue as guest');
      // navigate to dashboard
      navigatorKey.currentContext!.go('/${ViewData.dashboard.path}');
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  bool _isLoading() {
    return isLoginLoading || isGoogleLoading;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // login form (email or phone number and password)
        _buildLoginForm(),
        SizedBox(height: 20),
        // forgot password
        Row(
          children: [
            Spacer(),
            GestureDetector(
              onTap: () {
                navigatorKey.currentContext!.push('/${ViewData.forgot.path}');
              },
              child: Text('Forgot password?',
                style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 16,
                ),
              ),
            ),
          ]
        ),
        SizedBox(height: 40),
        // login button
        _buildLoginButton(),
        SizedBox(height: 30),
        Text('Or continue with',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 30),
        // google and guest buttons
        _buildExtraButtons(),
        // sign up text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Don\'t have any account?'),
            TextButton(
              onPressed: widget.onSignUpClicked,
              child: Text('Sign up',
                style: TextStyle(
                  color: Color.fromARGB(255, 26, 218, 128),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // email or phone number and password text fields
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // email or phone number text field
          MyTextField(
            controller: _emailOrPhoneController,
            icon: Icon(Icons.email),
            hintText: 'Email or phone number',
          ),
          SizedBox(height: 15),
          // password text field
          MyTextField(
            controller: _passwordController,
            icon: Icon(Icons.lock),
            hintText: 'Password',
            isPassword: true,
            isVisible: isPasswordVisible,
            onSuffixIconTap: _togglePasswordVisibility,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return MyButton(
      onPressed: () async {
        await loginWithEmailOrPhone();
      },
      text: 'Login',
      backgroundColor: const Color.fromARGB(255, 26, 218, 128),
      isLoading: isLoginLoading,
      isEnabled: !_isLoading(),
    );
  }

  Widget _buildExtraButtons() {
    return Column(
      children: [
        // google button
        MyButton(
          onPressed: loginWithGoogle,
          text: 'Google',
          backgroundColor: const Color.fromARGB(255, 244, 81, 63),
          icon: Icon(FontAwesomeIcons.google,
            color: Colors.white,
          ),
          isLoading: isGoogleLoading,
          isEnabled: !_isLoading(),
        ),
        SizedBox(height: 15),
        // continue as guest
        MyButton(
          onPressed: loginAsGuest,
          text: 'Continue as guest',
          backgroundColor: Colors.grey,
          isEnabled: !_isLoading(),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}