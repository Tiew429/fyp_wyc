import 'package:flutter/material.dart';
import 'package:fyp_wyc/view/auth/auth.dart';
import 'package:fyp_wyc/view/auth/forgot.dart';
import 'package:fyp_wyc/view/home/dashboard.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

final router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthPage(),
      routes: <RouteBase>[
        GoRoute(
          path: 'forgot',
          builder: (context, state) => const ForgotPage(),
        ),
        GoRoute(
          path: 'dashboard',
          builder: (context, state) => const Dashboard(),
        ),
      ],
    ),
  ],
);
