import '../models/entitlement_state.dart';
import '../models/purchase_receipt.dart';

abstract class EntitlementApi {
  Future<EntitlementState> fetchCurrentEntitlement();
  Future<EntitlementState> verifyPurchase(PurchaseReceipt receipt);
  Future<EntitlementState> restorePurchases(List<PurchaseReceipt> receipts);
}
