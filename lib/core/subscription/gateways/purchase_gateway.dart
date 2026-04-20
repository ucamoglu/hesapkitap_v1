import '../models/purchase_receipt.dart';
import '../models/subscription_product.dart';

abstract class PurchaseGateway {
  Future<void> initialize();
  Future<List<SubscriptionProduct>> listProducts();
  Future<PurchaseReceipt> purchase(String productId);
  Future<List<PurchaseReceipt>> restorePurchases();
}
