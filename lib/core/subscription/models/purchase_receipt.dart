class PurchaseReceipt {
  final String productId;
  final String transactionId;
  final String payload;
  final DateTime purchasedAt;

  const PurchaseReceipt({
    required this.productId,
    required this.transactionId,
    required this.payload,
    required this.purchasedAt,
  });
}
