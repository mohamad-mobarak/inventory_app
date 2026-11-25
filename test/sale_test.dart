import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/models/sale.dart';

void main() {
  // Groups all tests that check the SaleItem class.
  group('SaleItem', () {
    // Checks that the line total is the unit price times the quantity.
    test('lineTotal multiplies the unit price by the quantity', () {
      const item = SaleItem(
        productId: 'p1',
        productName: 'Pen',
        quantity: 4,
        unitPrice: 2.5,
      );

      expect(item.lineTotal, 10.0);
    });

    // Checks that a quantity of zero gives a line total of zero.
    test('lineTotal is zero when the quantity is zero', () {
      const item = SaleItem(
        productId: 'p1',
        productName: 'Pen',
        quantity: 0,
        unitPrice: 2.5,
      );

      expect(item.lineTotal, 0.0);
    });
  });

  // Groups all tests that check the Sale class.
  group('Sale', () {
    // Checks that itemCount adds up the quantities of all items.
    test('itemCount adds the quantities of all items', () {
      final sale = Sale(
        id: 's1',
        items: const [
          SaleItem(
            productId: 'p1',
            productName: 'Pen',
            quantity: 2,
            unitPrice: 2.5,
          ),
          SaleItem(
            productId: 'p2',
            productName: 'Notebook',
            quantity: 3,
            unitPrice: 10,
          ),
        ],
        total: 35,
        sellerId: 'u1',
        sellerName: 'Test',
        createdAt: DateTime(2026, 11, 6, 5, 10),
        status: 'completed',
      );

      expect(sale.itemCount, 5);
    });

    // Checks that a cancelled sale is reported as cancelled.
    test('isCancelled is true when the status is cancelled', () {
      final sale = Sale(
        id: 's1',
        items: const [],
        total: 0,
        sellerId: 'u1',
        sellerName: 'Test',
        createdAt: DateTime(2026, 11, 6, 5, 10),
        status: 'cancelled',
      );

      expect(sale.isCancelled, true);
    });

    // Checks that a completed sale is not reported as cancelled.
    test('isCancelled is false when the status is completed', () {
      final sale = Sale(
        id: 's1',
        items: const [],
        total: 0,
        sellerId: 'u1',
        sellerName: 'Test',
        createdAt: DateTime(2026, 11, 6, 5, 10),
        status: 'completed',
      );

      expect(sale.isCancelled, false);
    });
  });
}
