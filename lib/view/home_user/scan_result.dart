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
  List<String> allDetectedIngredients = []; // Store all detected ingredients
  List<Recipe> recipes = [];
  List<Recipe> filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    user = widget.user;
    // Save all detected ingredients from the scan
    allDetectedIngredients = List.from(widget.selectedIngredients);
    // Initially all ingredients are selected
    selectedIngredients = List.from(widget.selectedIngredients);
    recipes = widget.recipes;
    
    _filterRecipes();
  }
  
  // Method to filter recipes based on selected ingredients
  void _filterRecipes() {
    // Clear the filtered recipes list first
    filteredRecipes = [];
    
    // If no ingredients are selected, no recipes to show
    if (selectedIngredients.isEmpty) {
      return;
    }
    
    // Create a Set to track which recipes we've already added
    Set<String> addedRecipeIds = {};
    
    for (var recipe in recipes) {
      // For each recipe, check if it contains ALL of the selected ingredients
      bool containsAllIngredients = true;
      
      // Check each selected ingredient
      for (var selectedIngredient in selectedIngredients) {
        bool foundIngredient = false;
        
        // Look for this ingredient in the recipe
        for (var recipeIngredient in recipe.ingredients) {
          if (recipeIngredient.ingredientName.toLowerCase().trim() == selectedIngredient.toLowerCase().trim()) {
            foundIngredient = true;
            break;
          }
        }
        
        // If any selected ingredient is not found in the recipe, recipe doesn't match
        if (!foundIngredient) {
          containsAllIngredients = false;
          break;
        }
      }
      
      // If recipe contains all selected ingredients and hasn't been added yet, add it
      if (containsAllIngredients && !addedRecipeIds.contains(recipe.recipeID)) {
        filteredRecipes.add(recipe);
        addedRecipeIds.add(recipe.recipeID);
      }
    }
  }

  // Toggle ingredient selection
  void _toggleIngredient(String ingredient) {
    setState(() {
      if (selectedIngredients.contains(ingredient)) {
        selectedIngredients.remove(ingredient);
      } else {
        selectedIngredients.add(ingredient);
      }
      _filterRecipes();
    });
  }
  
  // Select all ingredients
  void _selectAllIngredients() {
    setState(() {
      selectedIngredients = List.from(allDetectedIngredients);
      _filterRecipes();
    });
  }
  
  // Clear all ingredient selections
  void _clearAllIngredients() {
    setState(() {
      selectedIngredients.clear();
      _filterRecipes();
    });
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
            'Detected Ingredients:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 26, 218, 128),
            ),
          ),
          Text(
            'Tap to select/unselect ingredients. Recipes must contain ALL selected ingredients.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allDetectedIngredients.map((ingredient) {
              final isSelected = selectedIngredients.contains(ingredient);
              return GestureDetector(
                onTap: () => _toggleIngredient(ingredient),
                child: Chip(
                  label: Text(ingredient),
                  backgroundColor: isSelected 
                    ? Color.fromARGB(255, 173, 216, 230) 
                    : Colors.grey[300],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black87 : Colors.black54,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  avatar: isSelected 
                    ? Icon(Icons.check_circle, size: 18, color: Colors.green) 
                    : null,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Found ${filteredRecipes.length} recipes with ALL selected ingredients',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              if (allDetectedIngredients.length > 1) // Only show if there are multiple ingredients
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _selectAllIngredients,
                      icon: Icon(Icons.select_all, size: 18),
                      label: Text('Select All'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        minimumSize: Size(0, 0),
                      ),
                    ),
                    SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _clearAllIngredients,
                      icon: Icon(Icons.clear_all, size: 18),
                      label: Text('Clear All'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        minimumSize: Size(0, 0),
                      ),
                    ),
                  ],
                ),
            ],
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