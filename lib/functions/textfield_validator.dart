class TextFieldValidator {
  String? phoneValidator(String? phone) {
    // example of correct phone number: 0167712349
    
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }

    // phone number does not have any character
    if (!phone.contains(RegExp(r'^\d+$'))) {
      return 'Phone number must be number only';
    }

    if (phone.length != 10 && phone.length != 11) {
      return 'Phone number must be 10 or 11 digits';
    }

    if (!phone.startsWith('01')) {
      return 'Phone number must start with 01';
    }

    if (phone.startsWith('+')) {
      return 'Phone number doesn\'t need to include country code';
    }

    return null;
  }

  String? emailValidator(String? email) {
    // example of correct email: example@gmail.com

    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    if (!email.contains('@')) {
      return 'Email must contain @';
    }

    // check if there's a dot after the @ symbol
    final atIndex = email.indexOf('@');
    if (atIndex == -1 || !email.substring(atIndex).contains('.')) {
      return 'Email must contain a dot after the @ symbol';
    }

    // email doesn't need to include space
    if (email.contains(' ')) {
      return 'Email doesn\'t need to include space';
    }

    return null;
  }

  String? usernameValidator(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }
    
    return null;
  }

  String? passwordValidator(String? password) {
    // example of correct password: Password123

    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (password.contains(' ')) {
      return 'Password doesn\'t need to include space';
    }

    if (!password.contains(RegExp(r'[A-Za-z]'))) {
      return 'Password must contain at least one alphabet';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }
}
