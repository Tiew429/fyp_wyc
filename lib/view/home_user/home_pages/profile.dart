import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/user_event.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/utils/my_avatar.dart';
import 'package:fyp_wyc/functions/my_snackbar.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  final User? user;

  const ProfilePage({
    super.key, 
    this.user,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  Future<void> _logOut() async {
    try {
      // clear current user data in app event bus, firebase auth and shared preferences
      final response = await UserStore.logoutUser();
  
      // logout
      if (response['success']) {
        navigatorKey.currentContext!.go('/${ViewData.auth.path}');
      } else {
        MySnackBar.showSnackBar('Failed to logout: ${response['message']}');
      }
    } catch (e) {
      MySnackBar.showSnackBar('An error occurred during logout');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return user == null ? _buildNoLogInUserPage(screenSize) : _buildLoggedUserPage(screenSize);
  }

  // will display for guest user
  Widget _buildNoLogInUserPage(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Icon(
          Icons.account_circle,
          size: 100,
          color: Colors.grey,
        ),
        SizedBox(height: 20),
        Text(
          'You are not logged in',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Log in to access your profile and saved recipes',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            navigatorKey.currentContext!.push('/${ViewData.auth.path}');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 26, 218, 128),
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Login / Sign Up',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 50),
        // App info for guests
        _buildOptionList(screenSize, false),
        SizedBox(height: 20),
        Text('Version 1.0'),
      ],
    );
  }

  // will display if the user is logged in
  Widget _buildLoggedUserPage(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: screenSize.width * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // user name
                  Text(user!.username,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  // edit profile
                  GestureDetector(
                    onTap: () {},
                    child: Text('edit your profile',
                      style: TextStyle(
                        fontSize: 20,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // user avatar
            Container(
              width: screenSize.width * 0.3,
              alignment: Alignment.center,
              child: MyAvatar(
                radius: screenSize.width * 0.10,
              ),
            ),
          ],
        ),
        SizedBox(height: 50),
        // services and policy options
        _buildOptionList(screenSize, true),
        SizedBox(height: 50),
        // app version
        Text('Version 1.0'),
      ],
    );
  }

  Widget _buildOptionList(Size screenSize, bool isLoggedIn) {
    return Container(
      width: screenSize.width * 0.9,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 237, 248),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {},
              child: Text('Contact Us'),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {},
              child: Text('Terms of Service'),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {},
              child: Text('Privacy Policy'),
            ),
            SizedBox(height: 20),
            isLoggedIn ? GestureDetector(
              onTap: () async => await _logOut(),
              child: Text('Log Out'),
            ) : SizedBox(),
            SizedBox(height: 50), // just a dummy space
          ],
        ),
      ),
    );
  }
}
