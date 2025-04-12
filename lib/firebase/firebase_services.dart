import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_wyc/event/user_event.dart';
import 'package:fyp_wyc/firebase/firebase_datacheck.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseServices {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseDataCheck _firebaseDataCheck = FirebaseDataCheck();

  auth.UserCredential? userCredential;

  Future<Map<String, dynamic>> signUp(String email, String phone, String username, String password) async {
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

      // user creation in firebase firestore
      String uid = userCredential!.user!.uid;
      String createdAt = DateTime.now().toIso8601String();

      await _userCollection.doc(email).set({
        'email': email,
        'username': username,
        'uid': uid,
        'phone': phone,
        'createdAt': createdAt,
        'role': 'user',
        'aboutMe': '',
        'gender': '',
        'ageRange': '',
        'avatarUrl': '',
        'savedRecipes': [],
        'addedRecipes': [],
        'searchHistory': [],
        'recipeHistory': [],
        'commentIDs': [],
      });

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
      try {
        // check if email exists in firestore
        bool emailExists = await _firebaseDataCheck.checkEmailExists(email);

        if (!emailExists) {
          return {
            'success': false,
            'message': 'The email address is not found',
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

        // set user to user provider
        await UserStore.setCurrentUser(user);
      } catch (e) {
        return {
          'success': false,
          'message': 'Error occured when signing in: $e',
        };
      }

      return {
        'success': true,
        'message': 'Logged in successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occured when signing in: $e',
      };
    }
  }

  // Future<Map<String, dynamic>> signInWithPhone(String phone, String password) async {}

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

  Future<Map<String, dynamic>> updateUser(String email, XFile? imageFile, String newName, String newAboutMe, String newGender) async {
    try {
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

  CollectionReference<Map<String, dynamic>> get _userCollection => _firebaseFirestore.collection('users');
}
