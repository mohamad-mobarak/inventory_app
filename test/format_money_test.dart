import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/utils/format_money.dart';

void main() {
  group('formatMoney', () {
    // Checks that a large whole number gets thousands separators.
    test('adds separators to a large whole number', () {
      expect(formatMoney(1500000, 'ل.س'), '1,500,000 ل.س');
    });

    // Checks that a fractional amount shows two decimals.
    test('shows two decimals when there is a fraction', () {
      expect(formatMoney(1500.5, 'ل.س'), '1,500.50 ل.س');
    });

    // Checks that a small number gets no separator.
    test('adds no separator below 1000', () {
      expect(formatMoney(750, 'ل.س'), '750 ل.س');
    });

    // Checks that an empty currency leaves no trailing space.
    test('leaves no trailing space when currency is empty', () {
      expect(formatMoney(1500, ''), '1,500');
    });

    // Checks that zero is formatted as a plain 0.
    test('formats zero', () {
      expect(formatMoney(0, 'ل.س'), '0 ل.س');
    });

    // Checks that the minus sign stays before a negative amount.
    test('keeps the minus sign for negatives', () {
      expect(formatMoney(-1500, 'ل.س'), '-1,500 ل.س');
    });
  });
}
