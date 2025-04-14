import 'package:flutter/material.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/model/user.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Recipe recipe;
  final User? user;

  const RecipeDetailsPage({
    super.key,
    required this.recipe,
    this.user,
  });

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  late Recipe recipe;
  User? user;

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}