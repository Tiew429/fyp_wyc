import 'package:flutter/widgets.dart';
import 'package:fyp_wyc/model/recipe.dart';

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

  @override
  void initState() {
    super.initState();
    recipeList = widget.recipeList;
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
