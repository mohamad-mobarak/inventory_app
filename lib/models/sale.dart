import 'package:cloud_firestore/cloud_firestore.dart';

// One product line inside a sale.
class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  // Total price of this line.
  double get lineTotal => unitPrice * quantity;

  // Builds an item from a map stored inside the sale document.
  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unitPrice'] as num).toDouble(),
    );
  }

  // Converts the item to a map for saving.
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}

// A single sale record (one or more products per sale).
class Sale {
  final String id;
  final List<SaleItem> items;
  final double total;
  final String sellerId;
  final String sellerName;
  final DateTime createdAt;
  final String status;
  final String? cancelledBy;
  final String? cancelledByName;
  final DateTime? cancelledAt;

  // Creates a sale; the cancel fields are optional.
  const Sale({
    required this.id,
    required this.items,
    required this.total,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
    required this.status,
    this.cancelledBy,
    this.cancelledByName,
    this.cancelledAt,
  });

  // Builds a Sale from a Firestore document.
  factory Sale.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Sale(
      id: doc.id,
      items: (data['items'] as List)
          .map((e) => SaleItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      total: (data['total'] as num).toDouble(),
      sellerId: data['sellerId'] as String,
      sellerName: data['sellerName'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] as String,
      cancelledBy: data['cancelledBy'] as String?,
      cancelledByName: data['cancelledByName'] as String?,
      cancelledAt: data['cancelledAt'] == null
          ? null
          : (data['cancelledAt'] as Timestamp).toDate(),
    );
  }

  // Converts the sale to a map for saving (without id).
  Map<String, dynamic> toMap() {
    return {
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'cancelledBy': cancelledBy,
      'cancelledByName': cancelledByName,
      'cancelledAt':
          cancelledAt == null ? null : Timestamp.fromDate(cancelledAt!),
    };
  }

  // True when this sale was cancelled.
  bool get isCancelled => status == 'cancelled';

  // Total number of pieces in this sale.
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
}
