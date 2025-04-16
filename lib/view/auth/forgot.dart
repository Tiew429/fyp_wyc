import 'package:flutter/material.dart';
import 'package:fyp_wyc/firebase/firebase_services.dart';
import 'package:fyp_wyc/functions/my_snackbar.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/utils/my_button.dart';
import 'package:fyp_wyc/utils/my_text_field.dart';
import 'package:go_router/go_router.dart';

class ForgotPage extends StatefulWidget {
  final String? email;

  const ForgotPage({
    super.key,
    this.email,
  });

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final _emailController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email ?? '';
  }

  Future<void> _onSendResetLinkPressed() async {
    Map<String, dynamic> result = {};

    try {
      setState(() {
        isLoading = true;
      });

      FirebaseServices firebaseServices = FirebaseServices();
      result = await firebaseServices.sendResetLink(_emailController.text);
      if (result['success']) {
        MySnackBar.showSnackBar(result['message']);
        navigatorKey.currentContext!.pop();
      }
    } catch (e) {
      MySnackBar.showSnackBar(result['message']);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Column(
        children: [
          MyTextField(
            controller: _emailController,
            hintText: 'Email',
            icon: Icon(Icons.email),
          ),
          MyButton(
            text: 'Send Reset Link',
            onPressed: () async => await _onSendResetLinkPressed(),
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
