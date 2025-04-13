import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/my_shared_preferences.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/user_event.dart';
import 'package:fyp_wyc/firebase/firebase_services.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/view/auth/auth.dart';
import 'package:fyp_wyc/view/auth/forgot.dart';
import 'package:fyp_wyc/view/home_user/dashboard.dart';
import 'package:fyp_wyc/view/home_user/profile_edit.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseServices().initializeFirebase();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String initialLocation = '/${ViewData.auth.path}';
  User? user;

  @override
  void initState() {
    super.initState();
    MySharedPreferences.getUser().then((userSharedPreferences) {
      if (userSharedPreferences != null) {
        setState(() {
          user = userSharedPreferences;
          initialLocation = '/${ViewData.dashboard.path}';
          UserStore.setCurrentUser(userSharedPreferences);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: GoRouter(
        routes: routes(),
        navigatorKey: navigatorKey,
        initialLocation: initialLocation,
      ),
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}

List<RouteBase> routes() {
  return [
    GoRoute(
      path: '/${ViewData.auth.path}',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: '/${ViewData.forgot.path}',
      builder: (context, state) => const ForgotPage(),
    ),
    GoRoute(
      path: '/${ViewData.profileEdit.path}',
      builder: (context, state) {
        User? currentUser = UserStore.currentUser;
        // there is no way to navigate to this page if there is no user, so use ! to bypass the null check
        return ProfileEditPage(user: currentUser!);
      },
    ),
    GoRoute(
      path: '/${ViewData.dashboard.path}',
      builder: (context, state) {
        // get current user at the time of navigation
        User? currentUser = UserStore.currentUser;
        
        // if not available in UserStore, try to get from SharedPreferences
        if (currentUser == null) {
          // handle the synchronously for the router
          final userFromPrefs = MySharedPreferences.getUser().then((user) {
            if (user != null) {
              // update the UserStore with the user from SharedPreferences
              UserStore.setCurrentUser(user);
            }
            return user;
          });
          
          // return the Dashboard with or without user
          return FutureBuilder<User?>(
            future: userFromPrefs,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Dashboard(user: snapshot.data);
              } else {
                return const Dashboard();
              }
            },
          );
        }
        
        // if already have the user, return Dashboard with user
        return Dashboard(user: currentUser);
      },
    ),
  ];
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
