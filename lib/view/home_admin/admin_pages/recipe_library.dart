import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/recipe_event.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/utils/my_empty_widgets.dart';
import 'package:fyp_wyc/utils/my_recipe_box.dart';
import 'package:go_router/go_router.dart';

class RecipeLibraryPage extends StatefulWidget {
  final List<Recipe>? recipeList;

  const RecipeLibraryPage({
    super.key,
    this.recipeList,
  });

  @override
  State<RecipeLibraryPage> createState() => _RecipeLibraryPageState();
}

class _RecipeLibraryPageState extends State<RecipeLibraryPage> {
  List<Recipe>? recipeList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    recipeList = widget.recipeList;
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

  Future<void> _onRecipeTap(Recipe recipe) async {
    // select recipe
    RecipeStore.setRecipe(recipe);

    // navigate to recipe details page
    navigatorKey.currentContext!.push(
      '/${ViewData.recipeDetails.path}',
      extra: {
        'recipe': recipe,
        'isAdmin': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRecipeGrid(),
      ],
    );
  }

  Widget _buildRecipeGrid() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: recipeList!.isEmpty ? 
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
              itemCount: recipeList!.length,
              itemBuilder: (context, index) {
                return MyRecipeBox(
                  imageUrl: recipeList![index].imageUrl,
                  title: recipeList![index].recipeName,
                  cookTime: recipeList![index].timeToCookInMinute,
                  onTap: () => _onRecipeTap(recipeList![index]),
                  showSaveButton: false,
                );
              },
            ),
          ),
      ),
    );
  }
}
