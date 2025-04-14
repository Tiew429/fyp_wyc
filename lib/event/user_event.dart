import 'package:flutter/widgets.dart';
import 'package:fyp_wyc/data/my_shared_preferences.dart';
import 'package:fyp_wyc/event/app_event_bus.dart';
import 'package:fyp_wyc/firebase/firebase_services.dart';
import 'package:fyp_wyc/functions/image_functions.dart';
import 'package:fyp_wyc/model/user.dart';

class UserEvent {
  final User? user;
  final Image? avatar;

  UserEvent({this.user, this.avatar});
}

class UserStore {
  static User? _currentUser;
  static Image? _currentUserAvatar;

  static User? get currentUser => _currentUser;
  static Image? get currentUserAvatar => _currentUserAvatar;

  // login or update
  static Future<void> setCurrentUser(User user) async {
    _currentUser = user;
    if (user.avatarUrl != '') {
      _currentUserAvatar = ImageFunctions.getAvatarInFuture(user.avatarUrl);
    }

    // save user to shared preferences
    await MySharedPreferences.saveUser(user);

    // fire event when user data is changed
    AppEventBus.instance.fire(UserEvent(user: user));
  }

  static Future<void> setCurrentUserAvatar(Image avatar) async {
    _currentUserAvatar = avatar;

    // fire event when user data is changed
    AppEventBus.instance.fire(UserEvent(user: _currentUser!, avatar: avatar));
  }

  // logout
  static Future<Map<String, dynamic>> logoutUser() async {
    try {
      if (_currentUser != null) {
        return await clearCurrentUser();
      }
      
      return {
        'success': true,
        'message': '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Logout failed: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> clearCurrentUser() async {
    _currentUser = null;
    _currentUserAvatar = null;

    // clear user from shared preferences
    await MySharedPreferences.clearUser();

    // clear firebase auth
    FirebaseServices firebaseServices = FirebaseServices();
    await firebaseServices.logOut();

    // fire event when user data is changed
    AppEventBus.instance.fire(UserEvent());

    return {
      'success': true,
      'message': '',
    };
  }

  // update user
  static Future<Map<String, dynamic>> updateUser(
    String email,
    String? imagePath,
    String newName,
    String newAboutMe,
    String newGender,
  ) async {
    try {
      FirebaseServices firebaseServices = FirebaseServices();
      // check is user exist in firebase
      final isUserExist = await firebaseServices.checkUserExistsByEmail(email);
      if (!isUserExist) {
        return {
          'success': false,
          'message': 'User not found',
        };
      }

      // if image file is not null, upload image to firebase storage
      String imageUrl = '';
      if (imagePath != null) {
        imageUrl = await firebaseServices.uploadAvatar(email, imagePath);
      }

      // update user
      final updatedUser = _currentUser?.copyWith(
        username: newName,
        aboutMe: newAboutMe,
        gender: newGender,
        avatarUrl: imageUrl != '' ? imageUrl : _currentUser?.avatarUrl,
      );

      // update current user avatar
      if (imageUrl != '') {
        _currentUserAvatar = Image.network(imageUrl);
      }

      // update user in firebase
      final response = await firebaseServices.updateUser(updatedUser!);

      if (response['success']) {
        // update current user
        _currentUser = updatedUser;

        // update user in shared preferences
        await MySharedPreferences.saveUser(updatedUser);

        // fire event when user data is changed
        AppEventBus.instance.fire(UserEvent(user: updatedUser));
      }
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occured when updating user: $e',
      };
    }
  }
}
