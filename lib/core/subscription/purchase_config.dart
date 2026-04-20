class PurchaseConfig {
  // Dart define or default product IDs:
  // --dart-define=PLUS_MONTHLY_PRODUCT_ID=com.company.app.plus.monthly
  // --dart-define=PLUS_YEARLY_PRODUCT_ID=com.company.app.plus.yearly
  static const String plusMonthlyProductId = String.fromEnvironment(
    'PLUS_MONTHLY_PRODUCT_ID',
    defaultValue: 'plus_monthly',
  );

  static const String plusYearlyProductId = String.fromEnvironment(
    'PLUS_YEARLY_PRODUCT_ID',
    defaultValue: 'plus_yearly',
  );

  static Set<String> get productIds => {
        plusMonthlyProductId,
        plusYearlyProductId,
      };
}
