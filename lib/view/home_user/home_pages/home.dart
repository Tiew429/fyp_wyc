import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/recipe_event.dart';
import 'package:fyp_wyc/event/user_event.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/utils/my_avatar.dart';
import 'package:fyp_wyc/utils/my_empty_widgets.dart';
import 'package:fyp_wyc/utils/my_recipe_box.dart';
import 'package:fyp_wyc/utils/my_search_bar.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  final User? user;
  final VoidCallback onAvatarTap;
  final List<Recipe>? recipeList;

  const HomePage({
    super.key,
    required this.user,
    required this.onAvatarTap,
    this.recipeList = const [],
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  late Image? userAvatar;
  final TextEditingController _searchController = TextEditingController();
  late List<Recipe> recipeList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    userAvatar = UserStore.currentUserAvatar;
    recipeList = widget.recipeList ?? [];
  }

  Future<void> _refreshRecipeList() async {
    setState(() {
      isLoading = true;
    });
    await RecipeStore.getRecipeList();
    setState(() {
      recipeList = RecipeStore.recipeList;
      isLoading = false;
    });
  }

  Future<void> _onSaveTap(String recipeID) async {
    // check the saved status
    final isSaved = user?.savedRecipes.contains(recipeID) ?? false;

    // save or unsave recipe
    if (isSaved) {
      await RecipeStore.unsaveRecipe(recipeID);
    } else {
      await RecipeStore.saveRecipe(recipeID);
    }

    // refresh the page to update the saved status
    setState(() {});
  }

  void _onRecipeTap(Recipe recipe) {
    // select recipe
    RecipeStore.setRecipe(recipe);

    // navigate to recipe details page
    navigatorKey.currentContext!.push(
      '/${ViewData.recipeDetails.path}',
      extra: {
        'recipe': recipe,
        'user': user,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        // top appbar widgets
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // top-left user avatar
            MyAvatar(
              onTap: widget.onAvatarTap,
              image: userAvatar,
            ),
            SizedBox(width: screenSize.width * 0.05),
            // top search bar
            SizedBox(
              width: screenSize.width * 0.7,
              child: MySearchBar(
                controller: _searchController,
                hintText: 'Search...',
                onChanged: (value) {
                  setState(() {});
                },
                isClearable: _searchController.text.isNotEmpty,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        // body widgets - Recipe Grid
        _buildRecipeGrid(),
      ],
    );
  }

  Widget _buildRecipeGrid() {
    return Expanded(
      child: recipeList.isEmpty ? 
        MyEmptyWidgets(
          text: 'No recipes found',
          onPressed: () async => await _refreshRecipeList(),
          isLoading: isLoading,
        ) :
        RefreshIndicator(
          onRefresh: () async => await _refreshRecipeList(),
          color: Color(0xFF00BFA6),
          child: GridView.builder(
            padding: EdgeInsets.only(top: 16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: recipeList.length,
            itemBuilder: (context, index) {
              return MyRecipeBox(
                imageUrl: recipeList[index].imageUrl,
                title: recipeList[index].recipeName,
                cookTime: recipeList[index].timeToCookInMinute,
                isSaved: user?.savedRecipes.contains(recipeList[index].recipeID) ?? false,
                onSave: () async => await _onSaveTap(recipeList[index].recipeID),
                onTap: () => _onRecipeTap(recipeList[index]),
                showSaveButton: user != null,
              );
            },
          ),
        ),
    );
  }
}