import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/recipe_event.dart';
import 'package:fyp_wyc/event/local_user_event.dart';
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
  late List<Recipe> recipeList, filteredRecipeList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    userAvatar = LocalUserStore.currentUserAvatar;
    recipeList = widget.recipeList ?? [];
    filteredRecipeList = recipeList;
  }

  void _onSearchChanged() {
    final String query = _searchController.text.trim().toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        filteredRecipeList = recipeList;
      });
      return;
    }

    final List<Recipe> results = recipeList.where((recipe) {
      // check recipe name
      if (recipe.recipeName.toLowerCase().contains(query)) {
        return true;
      }
      
      // check description
      if (recipe.description.toLowerCase().contains(query)) {
        return true;
      }
      
      // check time to cook with operators (>, <, =, >=, <=)
      if (_matchesCookingTime(recipe, query)) {
        return true;
      }
      
      // check ingredients
      for (var ingredient in recipe.ingredients) {
        if (ingredient.ingredientName.toLowerCase().contains(query)) {
          return true;
        }
      }
      
      // check tags
      for (var tag in recipe.tags) {
        if (tag.name.toLowerCase().contains(query)) {
          return true;
        }
      }
      
      return false;
    }).toList();
    
    setState(() {
      filteredRecipeList = results;
    });
  }
  
  bool _matchesCookingTime(Recipe recipe, String query) {
    // Check for time comparison queries
    final RegExp timeRegex = RegExp(r'^([<>=]{1,2})\s*(\d+)$');
    final match = timeRegex.firstMatch(query);
    
    if (match != null) {
      final String operator = match.group(1)!;
      final int value = int.parse(match.group(2)!);
      final int cookTime = recipe.timeToCookInMinute;
      
      switch (operator) {
        case '>':
          return cookTime > value;
        case '<':
          return cookTime < value;
        case '=':
          return cookTime == value;
        case '>=':
          return cookTime >= value;
        case '<=':
          return cookTime <= value;
        default:
          return false;
      }
    }
    
    // Check for direct cooking time mentions
    if (query.contains('min') || query.contains('minute')) {
      final RegExp minuteRegex = RegExp(r'(\d+)');
      final minuteMatch = minuteRegex.firstMatch(query);
      
      if (minuteMatch != null) {
        final int value = int.parse(minuteMatch.group(1)!);
        return recipe.timeToCookInMinute == value;
      }
    }
    
    return false;
  }

  Future<void> _refreshRecipeList() async {
    setState(() {
      isLoading = true;
    });
    await RecipeStore.getRecipeList();
    setState(() {
      recipeList = RecipeStore.recipeList;
      filteredRecipeList = recipeList;
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
                  _onSearchChanged();
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
        SizedBox(height: 150),
      ],
    );
  }

  Widget _buildRecipeGrid() {
    return Expanded(
      child: filteredRecipeList.isEmpty ? 
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
            itemCount: filteredRecipeList.length,
            itemBuilder: (context, index) {
              return MyRecipeBox(
                imageUrl: filteredRecipeList[index].imageUrl,
                title: filteredRecipeList[index].recipeName,
                cookTime: filteredRecipeList[index].timeToCookInMinute,
                isSaved: user?.savedRecipes.contains(filteredRecipeList[index].recipeID) ?? false,
                onSave: () async => await _onSaveTap(filteredRecipeList[index].recipeID),
                onTap: () => _onRecipeTap(filteredRecipeList[index]),
                showSaveButton: user != null,
              );
            },
          ),
        ),
    );
  }
}