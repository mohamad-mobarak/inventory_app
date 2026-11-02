import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;
  // Streams all products, updating live when Firestore changes
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Adds a product and its purchase price together in one batch
  Future<void> addProduct(Product product, double purchasePrice) async {
    final batch = _db.batch();
    final productRef = _db.collection('products').doc();
    batch.set(productRef, product.toMap());
    batch.set(_db.collection('productCosts').doc(productRef.id),
        {'purchasePrice': purchasePrice});
    await batch.commit();
  }

  // Updates a product and its purchase price together in one batch
  Future<void> updateProduct(Product product, double purchasePrice) async {
    final batch = _db.batch();
    batch.update(_db.collection('products').doc(product.id), product.toMap());
    batch.update(_db.collection('productCosts').doc(product.id),
        {'purchasePrice': purchasePrice});
    await batch.commit();
  }

  // Checks if a product with this name already exists.
  Future<bool> productNameExists(String name, {String? excludeId}) async {
    final result =
        await _db.collection('products').where('name', isEqualTo: name).get();
    return result.docs.any((doc) => doc.id != excludeId);
  }

  // Returns the distinct categories used by existing products.
  Future<List<String>> getCategories() async {
    // Gets all products
    final result = await _db.collection('products').get();
    // Unique category names
    return result.docs.map((doc) => doc['category'] as String).toSet().toList();
  }

  // Returns the purchase price of a product from productCosts,
  //  or null if no cost document exists.
  Future<double?> getPurchasePrice(String productId) async {
    final doc = await _db.collection('productCosts').doc(productId).get();
    if (!doc.exists) return null;
    return (doc.data()?['purchasePrice'] as num?)?.toDouble();
  }

  // Shows or hides a product by changing its isActive field
  Future<void> setProductActive(
      String productId, bool isActive, String uid) async {
    await _db.collection('products').doc(productId).update({
      'isActive': isActive,
      'lastModifiedAt': Timestamp.now(),
      'lastModifiedBy': uid,
    });
  }
}
