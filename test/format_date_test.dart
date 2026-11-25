import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/utils/format_date.dart';

void main() {
  // Groups all tests that check the formatDate function.
  group('formatDate', () {
    // Checks that a morning time shows the AM label.
    test('shows a morning time with the AM label', () {
      final date = DateTime(2026, 11, 6, 5, 10);

      expect(formatDate(date, 'AM', 'PM'), '2026-11-06 - 5:10 AM');
    });

    // Checks that an afternoon time is converted to 12-hour format with PM.
    test('shows an afternoon time with the PM label', () {
      final date = DateTime(2026, 11, 6, 17, 10);

      expect(formatDate(date, 'AM', 'PM'), '2026-11-06 - 5:10 PM');
    });

    // Checks that midnight is shown as 12 AM and not 0 AM.
    test('shows midnight as 12 AM', () {
      final date = DateTime(2026, 11, 6, 0, 0);

      expect(formatDate(date, 'AM', 'PM'), '2026-11-06 - 12:00 AM');
    });

    // Checks that noon is shown as 12 PM and not 0 PM.
    test('shows noon as 12 PM', () {
      final date = DateTime(2026, 11, 6, 12, 0);

      expect(formatDate(date, 'AM', 'PM'), '2026-11-06 - 12:00 PM');
    });

    // Checks that single-digit month, day and minute get a leading zero.
    test('adds a leading zero to month, day and minute', () {
      final date = DateTime(2026, 1, 5, 9, 3);

      expect(formatDate(date, 'AM', 'PM'), '2026-01-05 - 9:03 AM');
    });

    // Checks that the Arabic labels are used when they are passed in.
    test('uses the labels that are passed in', () {
      final date = DateTime(2026, 11, 6, 17, 10);

      expect(formatDate(date, 'ص', 'م'), '2026-11-06 - 5:10 م');
    });
  });
}
