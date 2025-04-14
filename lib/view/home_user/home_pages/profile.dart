import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/user_event.dart';
import 'package:fyp_wyc/functions/image_functions.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/utils/my_avatar.dart';
import 'package:fyp_wyc/functions/my_snackbar.dart';
import 'package:fyp_wyc/view/no_log_in/no_log_in.dart';
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
  late Image? userAvatar;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    
    if (user != null) {
      userAvatar = UserStore.currentUserAvatar;
      
      // if avatar is not in UserStore but URL exists, load it from network
      if (userAvatar == null && user!.avatarUrl.isNotEmpty) {
        userAvatar = ImageFunctions.getAvatarInFuture(user!.avatarUrl);
        UserStore.setCurrentUserAvatar(userAvatar!);
      }
    }
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

    return user == null ? NoLogInPage() : _buildLoggedUserPage(screenSize);
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
                    onTap: () => navigatorKey.currentContext!.push('/${ViewData.profileEdit.path}'),
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
                image: userAvatar,
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
