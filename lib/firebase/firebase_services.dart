import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fyp_wyc/event/local_user_event.dart';
import 'package:fyp_wyc/firebase/firebase_datacheck.dart';
import 'package:fyp_wyc/firebase/firebase_options.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/model/user.dart';

class FirebaseServices {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseDataCheck _firebaseDataCheck = FirebaseDataCheck();

  auth.UserCredential? userCredential;

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.appAttest,
    );
  }

  Future<bool> checkAdminLogin(String email, String password) async {
    try {
      final adminData = await _adminCollection.doc('admin').get();

      if (adminData['email'] != email) {
        return false;
      }

      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> adminSignOut() async {
    await _firebaseAuth.signOut();
  }

  Future<Map<String, dynamic>> signUpByEmail(String email, String phone, String username, String password) async {
    try {
      // check if email and phone exists in firestore
      bool emailExists = await _firebaseDataCheck.checkEmailExists(email);
      bool phoneExists = await _firebaseDataCheck.checkPhoneExists(phone);
      bool usernameExists = await _firebaseDataCheck.checkUsernameExists(username);

      if (emailExists) {
        return {
          'success': false,
          'message': 'The email address is already in use by another account',
        };
      }

      if (phoneExists) {
        return {
          'success': false,
          'message': 'The phone number is already in use by another account',
        };
      }

      if (usernameExists) {
        return {
          'success': false,
          'message': 'The username is already in use by another account',
        };
      }

      // user creation in firebase authentication (email and password)
      try {
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        return {
          'success': false,
          'message': 'Error occured when signing up: The email address is already in use by another account',
        };
      }

      // create user in firestore
      await createUser(email, username, phone);

      return {
        'success': true,
        'message': 'User created successfully. Please login to continue',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occured when signing up: $e',
      };
    }
  }

  Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    try {
      Map<String, dynamic> result = {};
      try {
        // check if email exists in firestore
        bool emailExists = await _firebaseDataCheck.checkEmailExists(email);

        if (!emailExists) {
          result = {
            'success': false,
            'message': 'The email address is not found',
            'firstTimeLogin': false,
          };
        }

        // sign in firebase authentication
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // get user data from firestore
        final userData = await _userCollection.doc(email).get();
        final User user = User.fromJson(userData.data()!);

        if (user.isBanned) {
          await _firebaseAuth.signOut();
          return {
            'success': false,
            'message': 'Your account has been banned',
          };
        }
        
        // set user to user provider
        await LocalUserStore.setCurrentUser(user);
        result = {
          'success': true,
          'message': 'Logged in successfully',
          'firstTimeLogin': user.firstTimeLogin,
        };
      } catch (e) {
        return {
          'success': false,
          'message': 'Error occured when signing in: $e',
          'firstTimeLogin': false,
        };
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occured when signing in: $e',
      };
    }
  }

  Future<Map<String, dynamic>> logOut() async {
    try {
      await _firebaseAuth.signOut();

      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occured when logging out: $e',
      };
    }
  }

  Future<Map<String, dynamic>> sendResetLink(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Reset link sent successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occured when sending reset link: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateUser(User user) async {
    try {
      await _userCollection.doc(user.email).update(user.toJson());
      return {
        'success': true,
        'message': 'User updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occured when updating user: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateDemographic(
    String ageRange,
    String gender,
    String occupation,
    String cookingFrequency,
    String usuallyPlanMeals,
    String comfortableUsingMobileOrWebApp,
    String helpfulOfAppSuggestRecipesBasedOnIngredients,
    String howOftenToStruggleToDecideWhatToCook,
    String haveYouThrownAwayFoodBeforeExpired,
    String howLikelyToUseAppToFindRecipes) async {
    try {
      await _userCollection.doc(auth.FirebaseAuth.instance.currentUser!.email).update({
        'ageRange': ageRange,
        'gender': gender,
        'occupation': occupation,
        'cookingFrequency': cookingFrequency,
        'usuallyPlanMeals': usuallyPlanMeals,
        'comfortableUsingMobileOrWebApp': comfortableUsingMobileOrWebApp,
        'helpfulOfAppSuggestRecipesBasedOnIngredients': helpfulOfAppSuggestRecipesBasedOnIngredients,
        'howOftenToStruggleToDecideWhatToCook': howOftenToStruggleToDecideWhatToCook,
        'haveYouThrownAwayFoodBeforeExpired': haveYouThrownAwayFoodBeforeExpired,
        'howLikelyToUseAppToFindRecipes': howLikelyToUseAppToFindRecipes,
      });

      return {
        'success': true,
        'message': 'Demographic updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occured when updating demographic: $e',
      };
    }
  }

  Future<Map<String, dynamic>> addRecipe(Recipe recipe) async {
    try {
      // check the number of recipe in firestore, then define the recipe id
      final recipeData = await _recipeCollection.get();
      int recipeCount = recipeData.size;

      recipe.recipeID = 'R-${recipeCount + 1}';

      // add recipe to recipe collection
      await _recipeCollection.doc(recipe.recipeID).set(recipe.toJson());

      // upload the image to firebase storage
      final imageUrl = await uploadRecipeImage(recipe.recipeID, recipe.imageUrl);

      // update the recipe with the image url
      await _recipeCollection.doc(recipe.recipeID).update({
        'imageUrl': imageUrl,
      });

      // then add recipe to users (author) collection also
      await _userCollection.doc(recipe.authorEmail).update({
        'addedRecipes': FieldValue.arrayUnion([recipe.recipeID]),
      });

      return {
        'success': true,
        'message': 'Recipe added successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occured when adding recipe: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getRecipeList() async {
    try {
      final recipeData = await _recipeCollection.get();
      
      if (recipeData.docs.isEmpty) {
        return {
          'success': true,
          'message': 'No recipes found',
          'recipeList': <Recipe>[],
        };
      }
      
      final List<Recipe> recipeList = [];
      
      for (var doc in recipeData.docs) {
        final data = doc.data();
        final recipe = Recipe.fromJson(data);
        recipeList.add(recipe);
      }
      
      return {
        'success': true,
        'message': 'Recipe list fetched successfully',
        'recipeList': recipeList,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occurred when fetching recipe list: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateRecipeViewCount(String recipeID) async {
    try {
      await _recipeCollection.doc(recipeID).update({
        'viewCount': FieldValue.increment(1),
      });

      return {
        'success': true,
        'message': 'Recipe view count updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occurred when updating recipe view count: $e',
      };
    }
  }

  Future<Map<String, dynamic>> saveRecipe(String recipeID) async {
    try {
      // get current user
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      // update user saved recipes
      await _userCollection.doc(currentUser.email).update({
        'savedRecipes': FieldValue.arrayUnion([recipeID]),
      });

      // update recipe saved count
      await _recipeCollection.doc(recipeID).update({
        'savedCount': FieldValue.increment(1),
      });

      return {
        'success': true,
        'message': 'Recipe saved successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occured when saving recipe: $e',
      };
    }
  }

  Future<Map<String, dynamic>> unsaveRecipe(String recipeID) async {
    try {
      // get current user
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      // update user saved recipes
      await _userCollection.doc(currentUser.email).update({
        'savedRecipes': FieldValue.arrayRemove([recipeID]),
      });

      // update recipe saved count
      await _recipeCollection.doc(recipeID).update({
        'savedCount': FieldValue.increment(-1),
      });

      return {
        'success': true,
        'message': 'Recipe unsaved successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occured when unsaving recipe: $e',
      };
    }
  }

  Future<Map<String, dynamic>> addRecipeToHistory(String recipeID) async {
    try {
      // get current user
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      // update user recipe history
      await _userCollection.doc(currentUser.email).update({
        'recipeHistory': {
          recipeID: DateTime.now().toIso8601String(),
        },
      });

      // update recipe view count
      await _recipeCollection.doc(recipeID).update({
        'viewCount': FieldValue.increment(1),
      });

      return {
        'success': true,
        'message': 'Recipe is added to your history.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to add recipe to your history.',
      };
    }
  }

  Future<Map<String, dynamic>> submitRecipeRating(String recipeID, double rating) async {
    try {
      // get current user
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      // update user rating
      await _userCollection.doc(currentUser.email).update({
        'recipeRating': {
          recipeID: rating,
        },
      });

      // update recipe rating
      await _recipeCollection.doc(recipeID).update({
        'rating': {
          currentUser.email: rating,
        },
      });

      return {
        'success': true,
        'message': 'User rating updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occured when updating user rating: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateRecipe(Recipe recipe, bool isImageChanged) async {
    try {
      // Handle image upload first if needed
      String updatedImageUrl = recipe.imageUrl;
      if (isImageChanged) {
        updatedImageUrl = await uploadRecipeImage(recipe.recipeID, recipe.imageUrl);
      }
      
      // Create a copy of the recipe with the updated image URL
      Recipe updatedRecipe = Recipe(
        recipeID: recipe.recipeID,
        recipeName: recipe.recipeName,
        description: recipe.description,
        imageUrl: updatedImageUrl,
        authorEmail: recipe.authorEmail,
        timeToCookInMinute: recipe.timeToCookInMinute,
        difficulty: recipe.difficulty,
        steps: recipe.steps,
        ingredients: recipe.ingredients,
        tags: recipe.tags,
        rating: recipe.rating,
        viewCount: recipe.viewCount,
        savedCount: recipe.savedCount,
      );
      
      // Update the recipe in Firestore using toJson() to properly convert enums
      await _recipeCollection.doc(recipe.recipeID).update(updatedRecipe.toJson());

      return {
        'success': true,
        'message': 'Recipe updated successfully.',
        'updatedRecipe': updatedRecipe,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update recipe: $e',
      };
    }
  }

  CollectionReference<Map<String, dynamic>> get _adminCollection => _firebaseFirestore.collection('admin');
  CollectionReference<Map<String, dynamic>> get _userCollection => _firebaseFirestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _recipeCollection => _firebaseFirestore.collection('recipes');

  Future<Map<String, dynamic>> createUser(String email, String? username, String? phone) async {
    // user creation in firebase firestore
    String uid = userCredential!.user!.uid;
    String createdAt = DateTime.now().toIso8601String();

    await _userCollection.doc(email).set({
      'email': email,
      'username': username ?? email,
      'uid': uid,
      'phone': phone ?? '',
      'createdAt': createdAt,
      'role': 'user',
      'aboutMe': '',
      'gender': 'Prefer not to say',
      'ageRange': '',
      'avatarUrl': '',
      'savedRecipes': [],
      'addedRecipes': [],
      'recipeRating': {},
      'recipeHistory': {},
      'firstTimeLogin': true,
      'occupation': '',
      'cookingFrequency': '',
      'usuallyPlanMeals': '',
      'comfortableUsingMobileOrWebApp': '',
      'helpfulOfAppSuggestRecipesBasedOnIngredients': '',
      'howOftenToStruggleToDecideWhatToCook': '',
      'haveYouThrownAwayFoodBeforeExpired': '',
      'howLikelyToUseAppToFindRecipes': '',
      'isBanned': false,
    });

    return {
      'success': true,
      'message': 'User created successfully',
    };
  }

  Future<String> uploadAvatar(String email, String imagePath) async {
    try {
      final imageUrl = await _firebaseStorage.ref().child('users/$email').putFile(File(imagePath));
      return await imageUrl.ref.getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  Future<String> uploadRecipeImage(String recipeID, String imagePath) async {
    try {
      final imageUrl = await _firebaseStorage.ref().child('recipes/$recipeID').putFile(File(imagePath));
      return await imageUrl.ref.getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  Future<bool> checkUserExistsByEmail(String email) async {
    try {
      final userData = await _userCollection.doc(email).get();
      return userData.exists;
    } catch (e) {
      return false;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final userData = await _userCollection.doc(email).get();
      return User.fromJson(userData.data()!);
    } catch (e) {
      return null;
    }
  }

  Future<List<User>?> getUserList() async {
    try {
      final userData = await _userCollection.get();
      return userData.docs.map((doc) => User.fromJson(doc.data())).toList();
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> deleteUser(String email) async {
    try {
      // First delete from Firestore
      await _userCollection.doc(email).delete();
      
      // Try to delete the user's avatar if it exists
      try {
        await _firebaseStorage.ref().child('users/$email').delete();
      } catch (e) {
        // Silently fail if avatar doesn't exist
      }
      
      // Note: For complete deletion, you would need admin privileges 
      // to delete the actual Firebase Auth account

      return {
        'success': true,
        'message': 'User deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occurred when deleting user: $e',
      };
    }
  }

  Future<Map<String, dynamic>> toggleUserBanStatus(String email, bool isBanned) async {
    try {
      // Update the user's isBanned status in Firestore
      await _userCollection.doc(email).update({
        'isBanned': isBanned
      });
      
      return {
        'success': true,
        'message': isBanned 
            ? 'User has been banned successfully' 
            : 'User has been unbanned successfully',
        'isBanned': isBanned
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occurred when ${isBanned ? "banning" : "unbanning"} user: $e',
        'isBanned': !isBanned // Return the original state since the operation failed
      };
    }
  }
}
