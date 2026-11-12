// Adds a leading zero to one digit numbers.
String two(int n) {
  return n.toString().padLeft(2, '0');
}

// Formats a date as 12-hour time, like 2026-11-06 - 5:10 PM.
String formatDate(DateTime date, String amLabel, String pmLabel) {
  final d = date.toLocal();
  final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  // Picks the AM or PM label from the hour.
  final period = d.hour < 12 ? amLabel : pmLabel;
  // Builds the final text from the date parts and the AM or PM label.
  return '${d.year}-${two(d.month)}-${two(d.day)} - $hour12:${two(d.minute)} $period';
}
