import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double salePrice;
  final int quantity;
  final int lowStockThreshold;
  final String category;
  final bool isActive;
  final DateTime lastModifiedAt;
  final String lastModifiedBy;
  final DateTime? createdAt;
  Product({
    required this.id,
    required this.name,
    required this.salePrice,
    required this.quantity,
    required this.lowStockThreshold,
    required this.category,
    required this.isActive,
    required this.lastModifiedAt,
    required this.lastModifiedBy,
    this.createdAt,
  });
  // Builds a Product from a Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
        id: doc.id,
        name: data['name'],
        salePrice: (data['salePrice'] as num).toDouble(),
        quantity: data['quantity'],
        lowStockThreshold: data['lowStockThreshold'],
        category: data['category'],
        isActive: data['isActive'],
        lastModifiedAt: (data['lastModifiedAt'] as Timestamp).toDate(),
        lastModifiedBy: data['lastModifiedBy'],
        createdAt: data['createdAt'] == null
            ? null
            : (data['createdAt'] as Timestamp).toDate());
  }
  // Converts this Product into a Map to save in Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'salePrice': salePrice,
      'quantity': quantity,
      'lowStockThreshold': lowStockThreshold,
      'category': category,
      'isActive': isActive,
      'lastModifiedAt': Timestamp.fromDate(lastModifiedAt),
      'lastModifiedBy': lastModifiedBy,
      // Saves the creation time only when it exists
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}
