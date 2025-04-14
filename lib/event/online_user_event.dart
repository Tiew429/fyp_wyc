import 'package:flutter/widgets.dart';
import 'package:fyp_wyc/event/app_event_bus.dart';
import 'package:fyp_wyc/firebase/firebase_services.dart';
import 'package:fyp_wyc/functions/image_functions.dart';
import 'package:fyp_wyc/model/user.dart';

class OnlineUserEvent {
  final User? user;
  final Image? avatar;

  OnlineUserEvent({this.user, this.avatar});
}

class OnlineUserStore {
  static User? _currentUser;
  static Image? _currentUserAvatar;

  static User? get currentUser => _currentUser;
  static Image? get currentUserAvatar => _currentUserAvatar;

  static void setCurrentUser(User user) {
    _currentUser = user;

    // fire event when user data is changed
    AppEventBus.instance.fire(OnlineUserEvent(user: user));
  }

  static void setCurrentUserAvatar(Image avatar) {
    _currentUserAvatar = avatar;

    // fire event when user data is changed
    AppEventBus.instance.fire(OnlineUserEvent(user: _currentUser!, avatar: avatar));
  }

  static void clearCurrentUser() {
    _currentUser = null;

    // fire event when user data is changed
    AppEventBus.instance.fire(OnlineUserEvent());
  }

  // in recipe details page, get the user who created the recipe
  static Future<User?> getOnlineUser(String email) async {
    try {
      // get user from firebase
      FirebaseServices firebaseServices = FirebaseServices();
      final user = await firebaseServices.getUserByEmail(email);

      // set the user to the store
      setCurrentUser(user!);

      // get the avatar from the user
      final avatar = ImageFunctions.getAvatarInFuture(user.avatarUrl);

      // set the avatar to the store
      setCurrentUserAvatar(avatar);

      // fire event when user data is changed
      AppEventBus.instance.fire(OnlineUserEvent(user: user, avatar: avatar));

      return user;
    } catch (e) {
      return null;
    }
  }
}

