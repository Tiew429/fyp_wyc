import 'package:fyp_wyc/functions/data_type_converter.dart';

class User {
  String email;
  String phone;
  String username;
  String createdAt; // store datetime as iso8601 string
  String role; // user or admin
  String aboutMe;
  String gender;
  String ageRange;
  String avatarUrl; // path to avatar image in firebase storage
  List<String> savedRecipes; // list of saved recipe ids
  List<String> addedRecipes; // list of added recipe ids
  Map<String, dynamic> recipeRating; // map of recipe id to rating (recipeID -> rating(int))
  Map<String, dynamic> recipeHistory; // map of recipe id to datetime (recipeID -> datetime(iso8601 string))
  bool firstTimeLogin;

  User({
    required this.email,
    required this.phone,
    required this.username,
    required this.createdAt,
    this.role = 'user',
    this.aboutMe = '',
    this.gender = 'Not to say',
    this.ageRange = '',
    this.avatarUrl = '',
    this.savedRecipes = const [],
    this.addedRecipes = const [],
    this.recipeRating = const {},
    this.recipeHistory = const {},
    this.firstTimeLogin = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'], 
      phone: json['phone'],
      username: json['username'],
      createdAt: json['createdAt'],
      role: json['role'],
      aboutMe: json['aboutMe'],
      gender: json['gender'],
      ageRange: json['ageRange'],
      avatarUrl: json['avatarUrl'],
      savedRecipes: DataTypeConverter.convertToStringList(json['savedRecipes']),
      addedRecipes: DataTypeConverter.convertToStringList(json['addedRecipes']),
      recipeRating: json['recipeRating'],
      recipeHistory: json['recipeHistory'],
      firstTimeLogin: json['firstTimeLogin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'username': username,
      'role': role,
      'aboutMe': aboutMe,
      'gender': gender,
      'ageRange': ageRange,
      'createdAt': createdAt,
      'avatarUrl': avatarUrl,
      'savedRecipes': savedRecipes,
      'addedRecipes': addedRecipes,
      'recipeRating': recipeRating,
      'recipeHistory': recipeHistory,
      'firstTimeLogin': firstTimeLogin,
    };
  }

  User copyWith({
    String? email,
    String? phone,
    String? username,
    String? createdAt,
    String? role,
    String? aboutMe,
    String? gender,
    String? ageRange,
    String? avatarUrl,
    List<String>? savedRecipes,
    List<String>? addedRecipes,
    Map<String, dynamic>? recipeRating,
    List<String>? searchHistory,
    Map<String, dynamic>? recipeHistory,
    bool? firstTimeLogin,
  }) {
    return User(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      aboutMe: aboutMe ?? this.aboutMe,
      gender: gender ?? this.gender,
      ageRange: ageRange ?? this.ageRange,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      savedRecipes: savedRecipes ?? this.savedRecipes,
      addedRecipes: addedRecipes ?? this.addedRecipes,
      recipeRating: recipeRating ?? this.recipeRating,
      recipeHistory: recipeHistory ?? this.recipeHistory,
      firstTimeLogin: firstTimeLogin ?? this.firstTimeLogin,
    );
  }
}
