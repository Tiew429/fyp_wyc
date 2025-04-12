import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataCheck {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // check if email exists in firestore
  Future<bool> checkEmailExists(String email) async {
    try {
      final emailExist = await _firebaseFirestore.collection('users').where('email', isEqualTo: email).get();
      return emailExist.docs.isNotEmpty;
    } catch (e) {
      return false;
    } 
  }

  // check if phone exists in firestore
  Future<bool> checkPhoneExists(String phone) async {
    try {
      final phoneExist = await _firebaseFirestore.collection('users').where('phone', isEqualTo: phone).get();
      return phoneExist.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // check if username exists in firestore
  Future<bool> checkUsernameExists(String username) async {
    try {
      final usernameExist = await _firebaseFirestore.collection('users').where('username', isEqualTo: username).get();
      return usernameExist.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}