import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/recipe_event.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/utils/my_empty_widgets.dart';
import 'package:fyp_wyc/utils/my_recipe_box.dart';
import 'package:fyp_wyc/view/no_log_in/no_log_in.dart';
import 'package:go_router/go_router.dart';

class SavedPage extends StatefulWidget {
  final User? user;
  final List<Recipe>? recipeLists;
  final VoidCallback? onEmptyButtonClick;

  const SavedPage({
    super.key,
    required this.user,
    this.recipeLists,
    this.onEmptyButtonClick,
  });

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> with SingleTickerProviderStateMixin {
  User? user;
  List<Recipe> savedRecipes = [];
  List<Recipe> addedRecipes = [];
  bool isSavedTab = true;
  bool isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    
    if (widget.recipeLists != null && user != null) {
      savedRecipes = widget.recipeLists!.where((recipe) => user!.savedRecipes.contains(recipe.recipeID)).toList();
      addedRecipes = widget.recipeLists!.where((recipe) => user!.addedRecipes.contains(recipe.recipeID)).toList();
    }

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _switchTab(bool toSaved) {
    if (isSavedTab != toSaved) {
      setState(() {
        isSavedTab = toSaved;
        if (toSaved) {
          _animationController.reverse();
        } else {
          _animationController.forward();
        }
      });
    }
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
    return user == null ? NoLogInPage() : Column(
      children: [
        // title selection
        _buildTitleSelection(),
        // recipes grid with fade transition
        _buildRecipesGrid(),
      ],
    );
  }

  Widget _buildTitleSelection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _switchTab(true),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSavedTab ? Theme.of(context).primaryColor : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: isSavedTab ? FontWeight.bold : FontWeight.normal,
                  color: isSavedTab ? Theme.of(context).primaryColor : Colors.grey,
                ),
                child: Text('Saved'),
              ),
            ),
          ),
          SizedBox(width: 32),
          GestureDetector(
            onTap: () => _switchTab(false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: !isSavedTab ? Theme.of(context).primaryColor : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: !isSavedTab ? FontWeight.bold : FontWeight.normal,
                  color: !isSavedTab ? Theme.of(context).primaryColor : Colors.grey,
                ),
                child: Text('Added'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesGrid() {
    return Expanded(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: (isSavedTab ? savedRecipes : addedRecipes).isNotEmpty ? 
          GridView.builder(
            key: ValueKey<bool>(isSavedTab),
            padding: EdgeInsets.only(top: 16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: (isSavedTab ? savedRecipes : addedRecipes).length,
            itemBuilder: (context, index) {
              final recipe = (isSavedTab ? savedRecipes : addedRecipes)[index];
              return MyRecipeBox(
                imageUrl: recipe.imageUrl,
                title: recipe.recipeName,
                cookTime: recipe.timeToCookInMinute,
                isSaved: user?.savedRecipes.contains(recipe.recipeID) ?? false,
                onSave: () async => _onSaveTap(recipe.recipeID),
                onTap: () => _onRecipeTap(recipe),
              );
            },
          ) :
          MyEmptyWidgets(
            key: ValueKey<bool>(isSavedTab),
            text: isSavedTab ? 'No saved recipes' : 'No added recipes',
            onPressed: widget.onEmptyButtonClick,
            isLoading: false,
          ),
      ),
    );
  }
}