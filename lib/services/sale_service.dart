import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sale.dart';

// Handles saving and reading sales in Firestore.
class SaleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Saves a sale with several products and reduces the stock in one transaction.
  // quantities maps each productId to the quantity being sold.
  Future<void> createSale({
    required Map<String, int> quantities,
    required String sellerId,
    required String sellerName,
  }) async {
    if (quantities.isEmpty) {
      throw Exception('invalid-quantity');
    }

    for (final quantity in quantities.values) {
      if (quantity <= 0) {
        throw Exception('invalid-quantity');
      }
    }

    final saleRef = _db.collection('sales').doc();

    await _db.runTransaction((transaction) async {
      final items = <SaleItem>[];
      final newQuantities = <DocumentReference, int>{};

      // Read and check every product first (all reads before any write).
      for (final entry in quantities.entries) {
        final productRef = _db.collection('products').doc(entry.key);
        final productDoc = await transaction.get(productRef);

        if (!productDoc.exists) {
          throw Exception('product-not-found');
        }

        final data = productDoc.data() as Map<String, dynamic>;

        if (data['isActive'] != true) {
          throw Exception('product-inactive');
        }

        final currentQuantity = data['quantity'] as int;

        if (entry.value > currentQuantity) {
          throw Exception('not-enough-stock');
        }

        items.add(
          SaleItem(
            productId: entry.key,
            productName: data['name'] as String,
            quantity: entry.value,
            unitPrice: (data['salePrice'] as num).toDouble(),
          ),
        );

        newQuantities[productRef] = currentQuantity - entry.value;
      }

      // Reduce the stock of every product.
      for (final entry in newQuantities.entries) {
        transaction.update(entry.key, {'quantity': entry.value});
      }

      // Save the sale with its items and total.
      final sale = Sale(
        id: saleRef.id,
        items: items,
        total: items.fold<double>(0, (sum, item) => sum + item.lineTotal),
        sellerId: sellerId,
        sellerName: sellerName,
        createdAt: DateTime.now(),
        status: 'completed',
      );

      transaction.set(saleRef, sale.toMap());
    });
  }

  // Cancels a sale and returns all its quantities to the stock in one transaction.
  Future<void> cancelSale({
    required String saleId,
    required String cancelledBy,
    required String cancelledByName,
  }) async {
    final saleRef = _db.collection('sales').doc(saleId);

    await _db.runTransaction((transaction) async {
      final saleDoc = await transaction.get(saleRef);

      if (!saleDoc.exists) {
        throw Exception('sale-not-found');
      }

      final sale = Sale.fromFirestore(saleDoc);

      if (sale.isCancelled) {
        throw Exception('already-cancelled');
      }

      final newQuantities = <DocumentReference, int>{};

      // Read every product first (all reads before any write).
      for (final item in sale.items) {
        final productRef = _db.collection('products').doc(item.productId);
        final productDoc = await transaction.get(productRef);

        if (productDoc.exists) {
          final data = productDoc.data() as Map<String, dynamic>;
          final currentQuantity = data['quantity'] as int;
          newQuantities[productRef] = currentQuantity + item.quantity;
        }
      }

      // Return the quantity of every product.
      for (final entry in newQuantities.entries) {
        transaction.update(entry.key, {'quantity': entry.value});
      }

      // Mark the sale as cancelled.
      transaction.update(saleRef, {
        'status': 'cancelled',
        'cancelledBy': cancelledBy,
        'cancelledByName': cancelledByName,
        'cancelledAt': Timestamp.now(),
      });
    });
  }

  // Streams the sales of one seller, newest first.
  Stream<List<Sale>> getSellerSales(String sellerId) {
    return _db
        .collection('sales')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      final sales =
          snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList();
      sales.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sales;
    });
  }

  // Streams all sales (for the admin), newest first.
  Stream<List<Sale>> getAllSales() {
    return _db
        .collection('sales')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList());
  }

  // Streams all sales created since a given date (for the dashboard), newest first.
  Stream<List<Sale>> getSalesSince(DateTime since) {
    return _db
        .collection('sales')
        .where('createdAt', isGreaterThanOrEqualTo: since)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList());
  }
}
