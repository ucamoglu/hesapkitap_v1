import '../models/entitlement_state.dart';
import '../models/purchase_receipt.dart';
import 'entitlement_api.dart';

class NoopEntitlementApi implements EntitlementApi {
  const NoopEntitlementApi();

  @override
  Future<EntitlementState> fetchCurrentEntitlement() async {
    return EntitlementState.freeLocalOnly();
  }

  @override
  Future<EntitlementState> restorePurchases(List<PurchaseReceipt> receipts) async {
    return EntitlementState.freeLocalOnly();
  }

  @override
  Future<EntitlementState> verifyPurchase(PurchaseReceipt receipt) async {
    return EntitlementState.freeLocalOnly();
  }
}
