import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Class that handles all login-related work
class AuthService {
  // Private Firebase Auth object to talk to Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    // Send email and password to Firebase and wait for the result
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserDoc({
    required String uid,
    required String name,
    required String email,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'name': name, 'email': email, 'role': 'admin', 'isActive': true});
  }

  // Save the shop's name in settings/shop (admin only, per the security rules)
  // نحفظ اسم المحل بوثيقة settings/shop (للمدير فقط حسب قواعد الأمان)
  Future<void> createShopDoc({required String shopName}) async {
    await _db.collection('settings').doc('shop').set({'name': shopName});
  }

  Future<void> createSetupDoc({required String adminUid}) async {
    await _db.collection('settings').doc('setup').set({'adminUid': adminUid});
  }

  // Creat a new Firebase Auth account with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<String?> getUserRole(String uid) async {
    // Fetch the user's document from the users
    final doc = await _db.collection('users').doc(uid).get();
    // If no document exists, return null
    if (!doc.exists) {
      return null;
    }
    return doc.data()?['role'] as String?;
  }

  // Returns the user's name from the users collection, or null if not found
  Future<String?> getUserName(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) {
      return null;
    }
    return doc.data()?['name'] as String?;
  }

  // Check if the user account is active
  Future<bool> isUserActive(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    // If no document exists, treat the user as not active
    if (!doc.exists) {
      return false;
    }
    // Return isActive, or false if the field is missing
    return doc.data()?['isActive'] as bool? ?? false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if sign up is still open
  Future<bool> isSignUpOpen() async {
    final doc = await _db.collection('settings').doc('setup').get();
    return !doc.exists;
  }
}
