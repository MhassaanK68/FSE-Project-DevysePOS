class CurrencyFormatter {
  static String format(double amount, {int decimalPlaces = 2}) {
    return 'PKR ${amount.toStringAsFixed(decimalPlaces)}';
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return 'PKR ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'PKR ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}
