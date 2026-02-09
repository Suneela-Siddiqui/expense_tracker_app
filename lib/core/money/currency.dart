enum AppCurrency {
  pkr('PKR', '₨'),
  usd('USD', r'$'),
  eur('EUR', '€'),
  gbp('GBP', '£'),
  aed('AED', 'د.إ'),
  sar('SAR', '﷼');

  final String code;
  final String symbol;
  const AppCurrency(this.code, this.symbol);

  static AppCurrency fromCode(String code) {
    return AppCurrency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => AppCurrency.pkr,
    );
  }
}
