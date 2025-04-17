import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/local_user_event.dart';
import 'package:fyp_wyc/event/recipe_event.dart';
import 'package:fyp_wyc/functions/image_functions.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/utils/my_avatar.dart';
import 'package:fyp_wyc/utils/my_recipe_box.dart';
import 'package:fyp_wyc/view/no_log_in/no_log_in.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  final User? user;
  final List<Recipe>? recipes;

  const ProfilePage({
    super.key, 
    this.user,
    this.recipes,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  late Image? userAvatar;
  List<Recipe>? recipes;
  List<Recipe>? userAddedRecipes;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    recipes = widget.recipes;
    userAddedRecipes = user?.addedRecipes
        .map((e) => recipes?.firstWhere((recipe) => recipe.recipeID == e))
        .whereType<Recipe>()
        .toList();

    if (user != null) {
      userAvatar = LocalUserStore.currentUserAvatar;
      
      // if avatar is not in UserStore but URL exists, load it from network
      if (userAvatar == null && user!.avatarUrl.isNotEmpty) {
        userAvatar = ImageFunctions.getAvatarInFuture(user!.avatarUrl);
        LocalUserStore.setCurrentUserAvatar(userAvatar!);
      }
    }
  }

  Future<void> _refreshRecipeIdeas() async {
    setState(() {
      isRefreshing = true;
    });
    await RecipeStore.getRecipeList();
    setState(() {
      recipes = RecipeStore.recipeList;
      userAddedRecipes = user?.addedRecipes
        .map((e) => recipes?.firstWhere((recipe) => recipe.recipeID == e))
        .whereType<Recipe>()
        .toList();
      isRefreshing = false;
    });
  }

  Future<void> _onRecipeTap(Recipe recipe) async {
    // select recipe
    RecipeStore.setRecipe(recipe);

    // add to recipe history
    await RecipeStore.addRecipeToHistory(recipe.recipeID);

    // navigate to recipe details page
    navigatorKey.currentContext!.push(
      '/${ViewData.recipeDetails.path}',
      extra: {
        'recipe': recipe,
        'user': user,
        'isAdmin': false,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return user == null ? NoLogInPage() : _buildLoggedUserPage(screenSize);
  }

  // will display if the user is logged in
  Widget _buildLoggedUserPage(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppBar(
          actions: [
            IconButton(
              onPressed: () => navigatorKey.currentContext!.push('/${ViewData.aboutActivity.path}', extra: user),
              icon: const Icon(Icons.menu),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: screenSize.width * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // user name
                  Text(user!.username,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  // edit profile
                  GestureDetector(
                    onTap: () => navigatorKey.currentContext!.push('/${ViewData.profileEdit.path}', extra: user),
                    child: Text('edit your profile',
                      style: TextStyle(
                        fontSize: 20,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // user avatar
            Container(
              width: screenSize.width * 0.3,
              alignment: Alignment.center,
              child: MyAvatar(
                radius: screenSize.width * 0.10,
                image: userAvatar,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(),
        ),
        _buildRecipeIdeas(),
        SizedBox(height: 50),
      ],
    );
  }

  Widget _buildRecipeIdeas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recipe Ideas',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 123, 167),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.0),
        _buildRecipeIdeasGrid(),
      ],
    );
  }

  Widget _buildRecipeIdeasGrid() {
    if (userAddedRecipes == null || userAddedRecipes!.isEmpty) {
      return Center(
        child: Text('No recipe ideas yet'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async => await _refreshRecipeIdeas(),
      color: Color(0xFF00BFA6),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 300,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: GridView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: userAddedRecipes!.length,
          itemBuilder: (context, index) {
            return MyRecipeBox(
              imageUrl: userAddedRecipes![index].imageUrl,
              title: userAddedRecipes![index].recipeName,
              cookTime: userAddedRecipes![index].timeToCookInMinute,
              isSaved: false,
              showSaveButton: false,
              onTap: () async => await _onRecipeTap(userAddedRecipes![index]),
            );
          },
        ),
      ),
    );
  }
}
