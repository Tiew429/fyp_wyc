import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/firebase/firebase_services.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/view/home_admin/admin_pages/recipe_library.dart';
import 'package:fyp_wyc/view/home_admin/admin_pages/report.dart';
import 'package:fyp_wyc/view/home_admin/admin_pages/user_list.dart';
import 'package:go_router/go_router.dart';

class AdminPage extends StatefulWidget {
  final List<Recipe>? recipeList;
  final List<User>? userList;

  const AdminPage({
    super.key,
    this.recipeList,
    this.userList,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late int _selectedIndex;
  late List<String> _appBarTitles;
  late List<Widget> _pages;
  List<Recipe>? recipeList = [];
  List<User>? userList = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = 2;
    recipeList = widget.recipeList;
    userList = widget.userList;

    _pages = [
      RecipeLibraryPage(recipeList: recipeList),
      UserListPage(userList: userList),
      ReportPage(userList: userList),
    ];

    _appBarTitles = [
      'Recipe Library',
      'User List',
      'Report',
    ];
  }

  @override
  void dispose() {
    super.dispose();
    userList = null;
    recipeList = null;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(_appBarTitles[_selectedIndex]),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            _buildListTile('Recipe Library', () {
              setState(() {
                _selectedIndex = 0;
              });
            }),
            _buildListTile('User List', () {
              setState(() {
                _selectedIndex = 1;
              });
            }),
            _buildListTile('Report', () {
              setState(() {
                _selectedIndex = 2;
              });
            }),
            SizedBox(height: screenSize.height * 0.7),
            _buildListTile('Logout', () {
              FirebaseServices firebaseServices = FirebaseServices();
              firebaseServices.adminSignOut();
              navigatorKey.currentContext!.go('/${ViewData.auth.path}');
            }),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  Widget _buildListTile(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AdminPage(),
  ));
}
