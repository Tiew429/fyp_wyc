import 'package:flutter/material.dart';
import 'package:fyp_wyc/event/local_user_event.dart';
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
    _emailOrPhoneController.text = 'wongyc-wp21@student.tarc.edu.my';
    _passwordController.text = 'admin1111';
    // _emailOrPhoneController.text = 'tiewjiajun0429@gmail.com';
    // _passwordController.text = 'aaaaaa1';
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

    // check is admin login
    FirebaseServices firebaseServices = FirebaseServices();
    bool isAdmin = await firebaseServices.checkAdminLogin(_emailOrPhoneController.text, _passwordController.text);
    if (isAdmin) {
      navigatorKey.currentContext!.go('/${ViewData.admin.path}');
      return;
    }

    Map<String, dynamic> response = {
      'success': false,
      'message': '',
      'firstTimeLogin': false,
    };
    String emailOrPhone = _emailOrPhoneController.text.toLowerCase();
    String password = _passwordController.text;

    // check is email or phone number
    if (emailOrPhone.contains('@')) {
      // email
      response = await firebaseServices.signInWithEmail(emailOrPhone, password);
    } else {
      MySnackBar.showSnackBar('Please enter email only');
    }

    setState(() {
      isLoginLoading = false;
    });

    bool isSuccess = response['success'];
    String message = response['message'];

    // show snackbar
    MySnackBar.showSnackBar(message);

    if (isSuccess) {
      // check is first time login
      bool firstTimeLogin = response['firstTimeLogin'];
      if (firstTimeLogin) {
        navigatorKey.currentContext!.go('/${ViewData.demographic.path}');
      } else {
        navigatorKey.currentContext!.go('/${ViewData.dashboard.path}');
      }
    }
  }

  Future<void> loginAsGuest() async {
    // ensure there has no user data in app event bus, firebase auth and shared preferences
    final response = await LocalUserStore.clearCurrentUser();

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
                navigatorKey.currentContext!.push('/${ViewData.forgot.path}', extra: {'email': _emailOrPhoneController.text});
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
      onPressed: () async => await loginWithEmailOrPhone(),
      text: 'Login',
      backgroundColor: const Color.fromARGB(255, 26, 218, 128),
      isLoading: isLoginLoading,
      isEnabled: !_isLoading(),
    );
  }

  Widget _buildExtraButtons() {
    return Column(
      children: [
        // continue as guest
        MyButton(
          onPressed: () async => await loginAsGuest(),
          text: 'Continue as guest',
          backgroundColor: Colors.grey,
          isEnabled: !_isLoading(),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}