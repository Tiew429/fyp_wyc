import 'package:fyp_wyc/event/app_event_bus.dart';
import 'package:fyp_wyc/event/user_event.dart';
import 'package:fyp_wyc/firebase/firebase_services.dart';
import 'package:fyp_wyc/model/recipe.dart';

class RecipeEvent {
  final Recipe? recipe;
  final List<Recipe>? recipeList;

  RecipeEvent({
    this.recipe,
    this.recipeList,
  });
}

class RecipeStore {
  static Recipe? _recipe;
  static List<Recipe> _recipeList = [];

  static Recipe? get recipe => _recipe;
  static List<Recipe> get recipeList => _recipeList;

  static void setRecipe(Recipe recipe) {
    _recipe = recipe;

    // fire event when recipe data is changed
    AppEventBus.instance.fire(RecipeEvent(recipe: _recipe));
  }

  static void clearRecipe() {
    _recipe = null;

    // fire event when recipe data is changed
    AppEventBus.instance.fire(RecipeEvent(recipe: _recipe));
  }

  static void setRecipeList(List<Recipe> recipeList) {
    _recipeList = recipeList;

    // fire event when recipe data is changed
    AppEventBus.instance.fire(RecipeEvent(recipeList: _recipeList));
  }

  static void clearRecipeList() {
    _recipeList = [];

    // fire event when recipe data is changed
    AppEventBus.instance.fire(RecipeEvent(recipeList: _recipeList));
  }

  static Future<Map<String, dynamic>> addRecipe(Recipe recipe) async {
    try {
      FirebaseServices firebaseServices = FirebaseServices();
      await firebaseServices.addRecipe(recipe);

      // update local recipe list
      _recipeList.add(recipe);

      // fire event when recipe data is changed
      AppEventBus.instance.fire(RecipeEvent(recipeList: _recipeList));

      return {
        'success': true,
        'message': 'Recipe added successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to add recipe',
      };
    }
  }

  static Future<Map<String, dynamic>> getRecipeList() async {
    try {
      FirebaseServices firebaseServices = FirebaseServices();
      final response = await firebaseServices.getRecipeList();
      if (response['success']) {
        setRecipeList(response['recipeList']);
      }
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch recipe list',
      };
    }
  }

  static Future<Map<String, dynamic>> saveRecipe(String recipeID) async {
    try {
      FirebaseServices firebaseServices = FirebaseServices();
      await firebaseServices.saveRecipe(recipeID);

      // update local user saved recipes
      UserStore.currentUser?.savedRecipes.add(recipeID);

      // fire event when recipe data is changed
      AppEventBus.instance.fire(RecipeEvent(recipeList: _recipeList));

      return {
        'success': true,
        'message': 'Recipe saved successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to save recipe',
      };
    }
  }

  static Future<Map<String, dynamic>> unsaveRecipe(String recipeID) async {
    try {
      FirebaseServices firebaseServices = FirebaseServices();
      await firebaseServices.unsaveRecipe(recipeID);

      // update local user saved recipes
      UserStore.currentUser?.savedRecipes.remove(recipeID);

      // fire event when recipe data is changed
      AppEventBus.instance.fire(RecipeEvent(recipeList: _recipeList));

      return {
        'success': true,
        'message': 'Recipe unsaved successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to unsave recipe',
      };
    }
  }
}
