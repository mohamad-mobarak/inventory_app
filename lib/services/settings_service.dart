import 'package:cloud_firestore/cloud_firestore.dart';

// Reads and writes the shop settings stored in Firestore.
class SettingsService {
  // Holds the Firestore instance used by this service.
  final _db = FirebaseFirestore.instance;

  // Reads the shop currency, or returns null when it is not set yet.
  Future<String?> getCurrency() async {
    final doc = await _db.collection('settings').doc('shop').get();
    if (!doc.exists) return null;
    final currency = doc.data()?['currency'] as String?;
    if (currency == null || currency.trim().isEmpty) return null;
    return currency;
  }

  // Saves the shop currency without touching other fields.
  Future<void> saveCurrency(String currency) async {
    await _db.collection('settings').doc('shop').set({
      'currency': currency.trim(),
    }, SetOptions(merge: true));
  }
}
