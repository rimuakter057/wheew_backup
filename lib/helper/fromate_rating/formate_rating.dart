String formatRating(double? rating) {
  if (rating == null) return '0';
  return rating % 1 == 0
      ? rating.toInt().toString()  // 0.0 → "0", 5.0 → "5"
      : rating.toString();         // 4.5 → "4.5"
}