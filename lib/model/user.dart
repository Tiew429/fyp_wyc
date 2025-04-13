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
  List<String> searchHistory;
  List<String> recipeHistory; // list of recipe ids that viewed
  List<String> commentIDs;

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
    this.searchHistory = const [],
    this.recipeHistory = const [],
    this.commentIDs = const [],
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
      searchHistory: DataTypeConverter.convertToStringList(json['searchHistory']),
      recipeHistory: DataTypeConverter.convertToStringList(json['recipeHistory']),
      commentIDs: DataTypeConverter.convertToStringList(json['commentIDs']),
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
      'searchHistory': searchHistory,
      'recipeHistory': recipeHistory,
      'commentIDs': commentIDs,
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
    List<String>? searchHistory,
    List<String>? recipeHistory,
    List<String>? commentIDs,
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
      searchHistory: searchHistory ?? this.searchHistory,
      recipeHistory: recipeHistory ?? this.recipeHistory,
      commentIDs: commentIDs ?? this.commentIDs,
    );
  }
}
