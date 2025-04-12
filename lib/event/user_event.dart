import 'package:fyp_wyc/data/my_shared_preferences.dart';
import 'package:fyp_wyc/event/app_event_bus.dart';
import 'package:fyp_wyc/firebase/firebase_services.dart';
import 'package:fyp_wyc/model/user.dart';

class UserEvent {
  final User? user;

  UserEvent({this.user});
}

class UserStore {
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  // login or update
  static void setCurrentUser(User user) {
    _currentUser = user;

    // save user to shared preferences
    MySharedPreferences.saveUser(user);

    // fire event when user data is changed
    AppEventBus.instance.fire(UserEvent(user: user));
  }

  // logout
  static Future<Map<String, dynamic>> logoutUser() async {
    if (_currentUser != null) {
      clearCurrentUser();
    }

    return {
      'success': true,
      'message': 'Logged out successfully',
    };
  }

  static Future<Map<String, dynamic>> clearCurrentUser() async {
    _currentUser = null;

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
}
