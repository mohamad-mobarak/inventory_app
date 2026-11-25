// Formats an amount with thousands separators and an optional currency.
String formatMoney(double amount, String currency) {
  // Checks if the amount has a fractional part (like 1500.5).
  final hasFraction = amount != amount.roundToDouble();

  // Converts the absolute value to text with 2 decimals or none.
  final fixed = amount.abs().toStringAsFixed(hasFraction ? 2 : 0);

  // Splits the text into the whole part and the decimal part.
  final parts = fixed.split('.');

  // Adds a comma between every three digits of the whole part.
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );

  // Puts the decimal part back when it exists.
  final number = parts.length > 1 ? '$whole.${parts[1]}' : whole;

  // Keeps the minus sign for negative amounts.
  final sign = amount < 0 ? '-' : '';

  // Adds the currency after the number only when it is not empty.
  return currency.isEmpty ? '$sign$number' : '$sign$number $currency';
}
