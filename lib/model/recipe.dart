import 'package:fyp_wyc/functions/data_type_converter.dart';
import 'package:fyp_wyc/model/ingredient.dart';

class Recipe {
  String recipeID;
  String recipeName;
  String description;
  String imageUrl;
  List<Tag> tags;
  List<Ingredient> ingredients;
  List<String> steps;
  String authorEmail;
  int timeToCookInMinute; // time to cook in minutes
  double difficulty;
  Map<String, double> rating; // store user email and rating
  int viewCount;
  int savedCount;

  Recipe({
    required this.recipeID,
    required this.recipeName,
    this.description = '',
    this.imageUrl = '',
    this.tags = const [],
    this.ingredients = const [],
    this.steps = const [],
    required this.authorEmail,
    this.timeToCookInMinute = 0,
    this.difficulty = 0,
    this.rating = const {},
    this.viewCount = 0,
    this.savedCount = 0,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    try {
      List<Tag> parsedTags = [];
      if (json['tags'] != null) {
        if (json['tags'] is List) {
          for (var tag in json['tags']) {
            if (tag is String) {
              try {
                final matchingTag = Tag.values.firstWhere(
                  (t) => t.name.toLowerCase() == tag.toLowerCase(),
                  orElse: () => Tag.other,
                );
                parsedTags.add(matchingTag);
              } catch (_) {
                parsedTags.add(Tag.other);
              }
            } else if (tag is int) {
              if (tag >= 0 && tag < Tag.values.length) {
                parsedTags.add(Tag.values[tag]);
              }
            }
          }
        }
      }
      List<Ingredient> parsedIngredients = [];
      if (json['ingredients'] != null) {
        if (json['ingredients'] is List) {
          for (var ingredient in json['ingredients']) {
            if (ingredient is Map<String, dynamic>) {
                parsedIngredients.add(Ingredient.fromJson(ingredient));
            }
          }
        }
      }
      List<String> parsedSteps = [];
      if (json['steps'] != null) {
        if (json['steps'] is List) {
          for (var step in json['steps']) {
            if (step is String) {
              parsedSteps.add(step);
            }
          }
        }
      }
      List<String> parsedCommentIDs = [];
      if (json['commentIDs'] != null) {
        if (json['commentIDs'] is List) {
          for (var commentID in json['commentIDs']) {
            if (commentID is String) {
              parsedCommentIDs.add(commentID);
            }
          }
        }
      }
      
      return Recipe(
        recipeID: json['recipeID'] ?? '',
        recipeName: json['recipeName'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        tags: parsedTags,
        ingredients: parsedIngredients,
        steps: parsedSteps,
        authorEmail: json['authorID'] ?? '',
        timeToCookInMinute: json['timeToCookInMinute'] is int ? json['timeToCookInMinute'] : 0,
        difficulty: json['difficulty'] is double ? json['difficulty'] : json['difficulty'] is int ? json['difficulty'].toDouble() : 0.0,
        rating: DataTypeConverter.parseRatingMap(json['rating']),
        viewCount: json['viewCount'] is int ? json['viewCount'] : 0,
        savedCount: json['savedCount'] is int ? json['savedCount'] : 0,
      );
    } catch (e) {
      return Recipe(
        recipeID: json['recipeID'] ?? '',
        recipeName: json['recipeName'] ?? '',
        description: '',
        authorEmail: json['authorID'] ?? '',
      );
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'recipeID': recipeID,
      'recipeName': recipeName,
      'description': description,
      'imageUrl': imageUrl,
      'tags': tags.map((tag) => tag.name).toList(),
      'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
      'steps': steps,
      'authorID': authorEmail,
      'timeToCookInMinute': timeToCookInMinute,
      'difficulty': difficulty,
      'rating': rating,
      'viewCount': viewCount,
      'savedCount': savedCount,
    };
  }
}

enum Tag {
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
