import '../models/purchase_receipt.dart';
import '../models/subscription_product.dart';
import 'purchase_gateway.dart';

class NoopPurchaseGateway implements PurchaseGateway {
  const NoopPurchaseGateway();

  @override
  Future<void> initialize() async {}

  @override
  Future<List<SubscriptionProduct>> listProducts() async {
    return const [
      SubscriptionProduct(
        id: 'plus_monthly',
        title: 'Plus Aylik',
        description: 'Cloud senkronizasyonu ve Plus ozellikler',
      ),
      SubscriptionProduct(
        id: 'plus_yearly',
        title: 'Plus Yillik',
        description: 'Cloud senkronizasyonu ve Plus ozellikler',
      ),
    ];
  }

  @override
  Future<PurchaseReceipt> purchase(String productId) async {
    throw UnsupportedError(
      'Gercek satin alma agidi henuz baglanmadi. In-App Purchase adapteri eklenmeli.',
    );
  }

  @override
  Future<List<PurchaseReceipt>> restorePurchases() async {
    return const [];
  }
}
