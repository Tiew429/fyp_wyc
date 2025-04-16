import 'package:flutter/material.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/view/home_user/home_pages/add_recipe.dart';
import 'package:fyp_wyc/view/home_user/home_pages/home.dart';
import 'package:fyp_wyc/view/home_user/home_pages/saved.dart';
import 'package:fyp_wyc/view/home_user/home_pages/scan.dart';
import 'package:fyp_wyc/view/home_user/home_pages/profile.dart';


class Dashboard extends StatefulWidget {
  final User? user;
  final List<Recipe>? recipeList;
  
  const Dashboard({
    super.key, 
    this.user,
    this.recipeList,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late int _selectedIndex;
  User? user;
  List<Recipe>? recipeList = [];

  // declare pages list but don't initialize it yet
  List<Widget> _pages = [
    HomePage(onAvatarTap: () {}, user: null),
    SavedPage(user: null, recipeLists: null),
    ScanPage(),
    AddRecipePage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    user = widget.user;
    recipeList = widget.recipeList;

    // update pages
    // if user is logged in, update display profile view page for logged user
    // also the saved page and add recipe page too
    if (user != null) {
      _pages = [
        HomePage(onAvatarTap: () {
          setState(() {
            _selectedIndex = 4;
          });
        }, user: user, recipeList: recipeList),
        SavedPage(user: user, recipeLists: recipeList),
        ScanPage(),
        AddRecipePage(user: user),
        ProfilePage(user: user, recipes: recipeList),
      ];
    } else {
      _pages = [
        HomePage(onAvatarTap: () {
          setState(() {
            _selectedIndex = 4;
          });
        }, user: user, recipeList: recipeList),
        SavedPage(
          user: user, 
          recipeLists: recipeList, 
          onEmptyButtonClick: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
        ),
        ScanPage(),
        AddRecipePage(),
        ProfilePage(recipes: recipeList),
      ];
    }
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    final screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: screenSize.width * 0.05, right: screenSize.width * 0.05, top: 16.0),
        child: _pages[_selectedIndex],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return SizedBox(
      width: 50,
      height: 50,
      child: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Color(0xFF00BFA6),
        elevation: 2,
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 22,
        ),
        onPressed: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      height: 75,
      notchMargin: 6.0,
      shape: CircularNotchedRectangle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildAnimatedNavItem(Icons.home, 'Home', 0),
            _buildAnimatedNavItem(Icons.bookmark_outline, 'Saved', 1),
            _buildAnimatedNavItem(null, 'Scan', 2),
            _buildAnimatedNavItem(Icons.add_circle_outline, 'Add', 3),
            _buildAnimatedNavItem(Icons.person, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedNavItem(IconData? icon, String label, int index) {
    return Expanded(
      child: index != 2 ? InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _selectedIndex == index ? Color(0xFF00BFA6).withOpacity(0.1) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: _selectedIndex == index ? Color(0xFF00BFA6) : Colors.grey,
                  size: 20,
                ),
              ),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: _selectedIndex == index ? Color(0xFF00BFA6) : Colors.grey,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ) : Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 35),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Color(0xFF00BFA6) : Colors.grey,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
