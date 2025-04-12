import 'package:fyp_wyc/model/ingredient.dart';

class Recipe {
  String recipeID;
  String recipeName;
  String description;
  String imageUrl;
  List<Category> categories;
  List<Ingredient> ingredients;
  List<String> steps;
  String authorID;
  double time; // time to cook in minutes
  double difficulty;
  double rating;
  int viewCount;
  int savedCount;
  List<String> commentIDs;

  Recipe({
    required this.recipeID,
    required this.recipeName,
    this.description = '',
    this.imageUrl = '',
    this.categories = const [],
    this.ingredients = const [],
    this.steps = const [],
    required this.authorID,
    this.time = 0,
    this.difficulty = 0,
    this.rating = 0,
    this.viewCount = 0,
    this.savedCount = 0,
    this.commentIDs = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeID: json['recipeID'],
      recipeName: json['recipeName'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      categories: json['categories'].map((category) => Category.values[category]).toList(),
      ingredients: json['ingredients'].map((ingredient) => Ingredient.fromJson(ingredient)).toList(),
      steps: json['steps'],
      authorID: json['authorID'],
      time: json['time'],
      difficulty: json['difficulty'],
      rating: json['rating'],
      viewCount: json['viewCount'],
      savedCount: json['savedCount'],
      commentIDs: json['commentIDs'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'recipeID': recipeID,
      'recipeName': recipeName,
      'description': description,
      'imageUrl': imageUrl,
      'categories': categories.map((category) => category.name).toList(),
      'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
      'steps': steps,
      'authorID': authorID,
      'time': time,
      'difficulty': difficulty,
      'rating': rating,
      'viewCount': viewCount,
      'savedCount': savedCount,
      'commentIDs': commentIDs,
    };
  }
}

enum Category {
  chinese,
  western,
  japanese,
  korean,
  vietnamese,
  thai,
  indian,
  spicy,
  sweet,
  sour,
  bitter,
  salty,
  umami,
  healthy,
  dessert,
  snack,
  drink,
  soup,
  salad,
  pasta,
  rice,
  meat,
  fish,
  seafood,
  vegetable,
  fruit,
  dairy,
  bread,
  cake,
  pastry,
  iceCream,
  candy,
  chocolate,
  other,
}
