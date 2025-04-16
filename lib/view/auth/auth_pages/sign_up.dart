import 'package:flutter/material.dart';
import 'package:fyp_wyc/firebase/firebase_services.dart';
import 'package:fyp_wyc/utils/my_button.dart';
import 'package:fyp_wyc/functions/my_snackbar.dart';
import 'package:fyp_wyc/utils/my_text_field.dart';
import 'package:fyp_wyc/functions/textfield_validator.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback onLoginClicked;

  const SignUpPage({
    super.key,
    required this.onLoginClicked,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isPasswordVisible = false, isPasswordMoreThan6Characters = false,
   isPasswordContainsNumber = false, isPasswordContainsAlphabet = false, isSignUpLoading = false;
  final TextFieldValidator _textFieldValidator = TextFieldValidator();

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSignUpLoading = true;
    });

    // get email, phone and password from text fields
    // trim to remove any whitespace
    String email = _emailController.text.trim().toLowerCase();
    String phone = _phoneController.text.trim();
    String username = _usernameController.text;
    String password = _passwordController.text.trim();

    // sign up in firebase authentication and firestore
    FirebaseServices firebaseServices = FirebaseServices();
    Map<String, dynamic> response = await firebaseServices.signUpByEmail(email, phone, username, password);

    bool isSuccess = response['success'];
    String message = response['message'];

    setState(() {
      isSignUpLoading = false;
    });

    // show snackbar
    MySnackBar.showSnackBar(message);

    // if success, navigate to login page
    if (isSuccess) {
      widget.onLoginClicked();
    }
  }


  // validation for password
  void _checkPasswordRequirements(String value) {
    setState(() {
      isPasswordMoreThan6Characters = value.length >= 6;
      isPasswordContainsNumber = value.contains(RegExp(r'[0-9]'));
      isPasswordContainsAlphabet = value.contains(RegExp(r'[a-zA-Z]'));
    });
  }

  // toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // email, phone and password text fields
          _buildSignUpTextField(),
          SizedBox(height: 30),
          Row(
            children: [
              Text('Your Password must contain: '),
            ],
          ),
          SizedBox(height: 20),
          // password requirements
          _buildPasswordRequirements('At least 6 characters', isPasswordMoreThan6Characters),
          _buildPasswordRequirements('Contains a number', isPasswordContainsNumber),
          _buildPasswordRequirements('Contains an alphabet', isPasswordContainsAlphabet),
          // sign up button
          _buildSignUpButton(),
          // login text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account?'),
              TextButton(
                onPressed: isSignUpLoading ? null : widget.onLoginClicked,
                child: Text('Login',
                  style: TextStyle(
                    color: Color.fromARGB(255, 26, 218, 128),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // email, phone and password text fields
  Widget _buildSignUpTextField() {
    return Column(
      children: [
        // email text field
        MyTextField(
          controller: _emailController,
          icon: Icon(Icons.email),
          hintText: 'Email ex: example@gmail.com',
          validator: _textFieldValidator.emailValidator,
          isReadOnly: isSignUpLoading,
        ),
        SizedBox(height: 15),
        // phone text field
        MyTextField(
          controller: _phoneController,
          icon: Icon(Icons.phone),
          hintText: 'Phone number ex: (0167712349)',
          validator: _textFieldValidator.phoneValidator,
          isReadOnly: isSignUpLoading,
        ),
        SizedBox(height: 15),
        // username text field
        MyTextField(
          controller: _usernameController,
          icon: Icon(Icons.person),
          hintText: 'Username',
          validator: _textFieldValidator.usernameValidator,
          isReadOnly: isSignUpLoading,
        ),
        SizedBox(height: 15),
        // password text field
        MyTextField(
          controller: _passwordController,
          icon: Icon(Icons.lock),
          hintText: 'Password',
          isPassword: true,
          isVisible: isPasswordVisible,
          validator: _textFieldValidator.passwordValidator,
          onChanged: _checkPasswordRequirements,
          onSuffixIconTap: _togglePasswordVisibility,
          isReadOnly: isSignUpLoading,
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements(String text, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.check_circle_outline,
            color: isChecked ? Colors.green : Colors.grey,
          ),
          SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return MyButton(
      onPressed: _signUp, 
      text: 'Sign up',
      isLoading: isSignUpLoading,
      isEnabled: !isSignUpLoading,
    );
  }
}