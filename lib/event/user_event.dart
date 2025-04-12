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
  static Future<void> setCurrentUser(User user) async {
    _currentUser = user;

    // save user to shared preferences
    await MySharedPreferences.saveUser(user);

    // fire event when user data is changed
    AppEventBus.instance.fire(UserEvent(user: user));
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
