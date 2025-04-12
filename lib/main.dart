import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/my_shared_preferences.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/view/auth/auth.dart';
import 'package:fyp_wyc/view/auth/forgot.dart';
import 'package:fyp_wyc/view/home_user/dashboard.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: GoRouter(
        routes: routes(user),
        navigatorKey: navigatorKey,
        initialLocation: initialLocation,
      ),
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}

List<RouteBase> routes(User? user) {
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
      path: '/${ViewData.dashboard.path}',
      builder: (context, state) => user != null ? Dashboard(user: user) : const Dashboard(),
    ),
  ];
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
