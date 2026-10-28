import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerService {
  // Our connection to the Firestore database
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<List<AppUser>> getSellers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'seller')
        .snapshots()
        // Convert each updata into a list of AppUser objects
        .map((snapshot) => snapshot.docs
            .map((doc) => AppUser.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Creates a seller account and saves his user doccument
  Future<void> addSeller({
    required String name,
    required String email,
    required String password,
  }) async {
    // Open a second, separate connection to our Firebase project
    final secondaryApp = await Firebase.initializeApp(
      // A different name keeps it apart from the admin's connection
      name: 'secondary',
      // Copy the project settings from the main connection
      options: Firebase.app().options,
    );
    try {
      // Use the auth of the second connection, so the admin stays signed in
      final credential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(email: email, password: password);
      // Save the seller's document using the admin's main connection
      await _db.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'role': 'seller',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } finally {
      await secondaryApp.delete();
    }
  }

  Future<void> updateSellerName(String uid, String name) async {
    await _db.collection('users').doc(uid).update({'name': name});
  }

  Future<void> updateSellerActive(String uid, bool isActive) async {
    await _db.collection('users').doc(uid).update({'isActive': isActive});
  }
}
