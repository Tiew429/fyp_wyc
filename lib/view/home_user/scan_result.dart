import 'package:flutter/material.dart';
import 'package:fyp_wyc/event/recipe_event.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/utils/my_recipe_box.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:go_router/go_router.dart';

class ScanResultPage extends StatefulWidget {
  final User? user;
  final List<String> selectedIngredients;
  final List<Recipe> recipes;

  const ScanResultPage({
    super.key,
    required this.user,
    required this.selectedIngredients,
    required this.recipes,
  });

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  User? user;
  List<String> selectedIngredients = [];
  List<Recipe> recipes = [];
  List<Recipe> filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    user = widget.user;
    selectedIngredients = widget.selectedIngredients;
    recipes = widget.recipes;
    
    // Clear the filtered recipes list first
    filteredRecipes = [];
    
    // Create a Set to track which recipes we've already added
    Set<String> addedRecipeIds = {};
    
    for (var recipe in recipes) {
      bool hasMatch = false;
      
      // Check if this recipe has any of the selected ingredients
      for (var ingredient in recipe.ingredients) {
        for (var selectedIngredient in selectedIngredients) {
            print("${addedRecipeIds}2");
          if (ingredient.ingredientName.toLowerCase().trim() == selectedIngredient.toLowerCase().trim()) {
            print("111${addedRecipeIds}");
            hasMatch = true;
            break;
          }
        }
        if (hasMatch) break;
      }
      
      // If we found a match and haven't added this recipe yet, add it
      if (hasMatch && !addedRecipeIds.contains(recipe.recipeID)) {
        filteredRecipes.add(recipe);
        addedRecipeIds.add(recipe.recipeID);
      }
    }
    
    print("Found ${filteredRecipes.length} filtered recipes");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Suggestions'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIngredientsSection(),
          Expanded(
            child: _buildRecipeGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Ingredients:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 26, 218, 128),
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedIngredients.map((ingredient) {
              return Chip(
                label: Text(ingredient),
                backgroundColor: Color.fromARGB(255, 173, 216, 230),
                labelStyle: TextStyle(color: Colors.black87),
              );
            }).toList(),
          ),
          SizedBox(height: 4),
          Text(
            'Found ${filteredRecipes.length} matching recipes',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeGrid() {
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

    if (filteredRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_food,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No recipes found with these ingredients',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredRecipes.length,
      itemBuilder: (context, index) {
        return MyRecipeBox(
          imageUrl: filteredRecipes[index].imageUrl,
          title: filteredRecipes[index].recipeName,
          cookTime: filteredRecipes[index].timeToCookInMinute,
          showSaveButton: user != null,
          isSaved: user?.savedRecipes.contains(filteredRecipes[index].recipeID) ?? false,
          onSave: () async => await _onSaveTap(filteredRecipes[index].recipeID),
          onTap: () => _onRecipeTap(filteredRecipes[index]),
        );
      },
    );
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
}