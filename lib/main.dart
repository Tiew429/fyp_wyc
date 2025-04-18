import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/my_shared_preferences.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/online_user_event.dart';
import 'package:fyp_wyc/event/recipe_event.dart';
import 'package:fyp_wyc/event/local_user_event.dart';
import 'package:fyp_wyc/firebase/firebase_services.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/view/auth/auth.dart';
import 'package:fyp_wyc/view/auth/forgot.dart';
import 'package:fyp_wyc/view/home_admin/admin.dart';
import 'package:fyp_wyc/view/home_user/about_activity.dart';
import 'package:fyp_wyc/view/home_user/about_us.dart';
import 'package:fyp_wyc/view/home_user/author_page.dart';
import 'package:fyp_wyc/view/home_user/dashboard.dart';
import 'package:fyp_wyc/view/home_user/demographic.dart';
import 'package:fyp_wyc/view/home_user/history.dart';
import 'package:fyp_wyc/view/home_user/privacy_policy.dart';
import 'package:fyp_wyc/view/home_user/profile_edit.dart';
import 'package:fyp_wyc/view/home_user/recipe_details.dart';
import 'package:fyp_wyc/view/home_user/recipe_edit.dart';
import 'package:fyp_wyc/view/home_user/scan_result.dart';
import 'package:fyp_wyc/view/home_user/scanning.dart';
import 'package:fyp_wyc/view/home_user/terms_services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseServices.initializeFirebase();

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
          LocalUserStore.setCurrentUser(userSharedPreferences);
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
      builder: (context, state) {
        final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
        final String? email = extras['email'] as String?;
        return ForgotPage(email: email);
      },
    ),
    GoRoute(
      path: '/${ViewData.demographic.path}',
      builder: (context, state) {
        final User? user = LocalUserStore.currentUser;
        return DemographicPage(user: user!);
      },
    ),
    GoRoute(
      path: '/${ViewData.profileEdit.path}',
      builder: (context, state) {
        final dynamic extras = state.extra;
        User? currentUser;
        
        if (extras is Map<String, dynamic>) {
          currentUser = extras['user'] as User?;
        } else if (extras is User) {
          currentUser = extras;
        }
        return ProfileEditPage(user: currentUser!);
      },
    ),
    GoRoute(
      path: '/${ViewData.dashboard.path}',
      builder: (context, state) {
        // get current user at the time of navigation
        User? currentUser = LocalUserStore.currentUser;

        // if not available in UserStore, try to get from SharedPreferences
        if (currentUser == null) {
          // handle the synchronously for the router
          final userFromPrefs = MySharedPreferences.getUser().then((user) {
            if (user != null) {
              // update the UserStore with the user from SharedPreferences
              LocalUserStore.setCurrentUser(user);
            }
            return user;
          });

          // need to load recipes before showing the Dashboard  
          return FutureBuilder<User?>(
            future: userFromPrefs,
            builder: (context, userSnapshot) {
              // first load user data
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen();
              }
              
              // then load recipe data
              return FutureBuilder<Map<String, dynamic>>(
                future: RecipeStore.getRecipeList(),
                builder: (context, recipeSnapshot) {
                  if (recipeSnapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingScreen();
                  }
                  
                  // both user and recipes are now loaded
                  List<Recipe> recipeList = [];
                  if (recipeSnapshot.hasData && recipeSnapshot.data!['success']) {
                    recipeList = RecipeStore.recipeList;
                  }
                  
                  return Dashboard(user: userSnapshot.data, recipeList: recipeList);
                },
              );
            },
          );
        }
        
        // if we already have a user, but still need to load recipes first
        return FutureBuilder<Map<String, dynamic>>(
          future: RecipeStore.getRecipeList(),
          builder: (context, recipeSnapshot) {
            if (recipeSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen();
            }
            
            List<Recipe> recipeList = [];
            if (recipeSnapshot.hasData && recipeSnapshot.data!['success']) {
              recipeList = RecipeStore.recipeList;
            }
            
            return Dashboard(user: currentUser, recipeList: recipeList);
          },
        );
      },
    ),
    GoRoute(
      path: '/${ViewData.recipeDetails.path}', 
      builder: (context, state) {
        final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
        final Recipe recipe = extras['recipe'] as Recipe;
        final User? user = extras['user'] as User?;
        final bool? isAdmin = extras['isAdmin'] as bool?;
        return RecipeDetailsPage(recipe: recipe, user: user, isAdmin: isAdmin);
      },
    ),
    GoRoute(
      path: '/${ViewData.recipeEdit.path}',
      builder: (context, state) {
        final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
        final Recipe recipe = extras['recipe'] as Recipe;
        return RecipeEditPage(recipe: recipe);
      },
    ),
    GoRoute(
      path: '/${ViewData.recipeEdit.path}',
      builder: (context, state) {
        final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
        final Recipe recipe = extras['recipe'] as Recipe;
        return RecipeEditPage(recipe: recipe);
      },
    ),
    GoRoute(
      path: '/${ViewData.scanning.path}',
      builder: (context, state) {
        final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
        final XFile image = extras['image'] as XFile;
        return ScanningPage(image: image);
      },
    ),
    GoRoute(
      path: '/${ViewData.scanResult.path}',
      builder: (context, state) {
        final List<String> selectedIngredients = state.extra as List<String>;
        return ScanResultPage(
          user: LocalUserStore.currentUser,
          selectedIngredients: selectedIngredients,
          recipes: RecipeStore.recipeList,
        );
      },
    ),
    GoRoute(
      path: '/${ViewData.aboutActivity.path}',
      builder: (context, state) {
        final User user = state.extra as User;
        return AboutActivityPage(user: user);
      },
    ),
    GoRoute(
      path: '/${ViewData.aboutUs.path}',
      builder: (context, state) {
        return const AboutUsPage();
      }
    ),
    GoRoute(
      path: '/${ViewData.privacyPolicy.path}',
      builder: (context, state) {
        return const PrivacyPolicyPage();
      }
    ),
    GoRoute(
      path: '/${ViewData.termsOfService.path}',
      builder: (context, state) {
        return const TermsServicesPage();
      }
    ),
    GoRoute(
      path: '/${ViewData.history.path}',
      builder: (context, state) {
        final List<Recipe> recipeList = RecipeStore.recipeList;
        final User user = LocalUserStore.currentUser!;
        return HistoryPage(recipeList: recipeList, user: user);
      },
    ),
    GoRoute(
      path: '/${ViewData.author.path}',
      builder: (context, state) {
        final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
        final User user = LocalUserStore.currentUser!;
        final User author = extras['author'] as User;
        final List<Recipe> recipeList = RecipeStore.recipeList;
        return AuthorPage(author: author, recipeList: recipeList, user: user);
      },
    ),
    GoRoute(
      path: '/${ViewData.admin.path}',
      builder: (context, state) {
        return FutureBuilder(
          future: Future.wait([
            OnlineUserStore.getUserList(),
            RecipeStore.getRecipeList(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }
            
            if (!snapshot.hasData || snapshot.data == null) {
              return const Scaffold(
                body: Center(
                  child: Text('No data available'),
                ),
              );
            }

            final userList = OnlineUserStore.userList;
            final recipeList = RecipeStore.recipeList;
            
            return AdminPage(userList: userList, recipeList: recipeList);
          },
        );
      },
    ),
  ];
}

// helper widget for loading screen
Widget _buildLoadingScreen() {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF00BFA6),
          ),
          SizedBox(height: 16),
          Text(
            "Loading...",
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
