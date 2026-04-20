import 'package:flutter/foundation.dart';

import 'gateways/entitlement_api.dart';
import 'gateways/noop_entitlement_api.dart';
import 'gateways/noop_purchase_gateway.dart';
import 'gateways/purchase_gateway.dart';
import 'models/entitlement_state.dart';
import 'models/subscription_product.dart';

class SubscriptionController extends ChangeNotifier {
  final PurchaseGateway _purchaseGateway;
  final EntitlementApi _entitlementApi;

  EntitlementState _state = EntitlementState.freeLocalOnly();
  bool _initialized = false;
  bool _loading = false;
  String? _lastError;

  SubscriptionController({
    PurchaseGateway? purchaseGateway,
    EntitlementApi? entitlementApi,
  })  : _purchaseGateway = purchaseGateway ?? const NoopPurchaseGateway(),
        _entitlementApi = entitlementApi ?? const NoopEntitlementApi();

  EntitlementState get state => _state;
  bool get isInitialized => _initialized;
  bool get isLoading => _loading;
  String? get lastError => _lastError;

  Future<void> initialize() async {
    if (_initialized) return;
    _setLoading(true);
    _lastError = null;

    try {
      await _purchaseGateway.initialize();
      _state = await _entitlementApi.fetchCurrentEntitlement();
      _initialized = true;
    } catch (e) {
      _lastError = e.toString();
      _state = EntitlementState.freeLocalOnly();
      _initialized = true;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshEntitlement() async {
    _setLoading(true);
    _lastError = null;
    try {
      _state = await _entitlementApi.fetchCurrentEntitlement();
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<List<SubscriptionProduct>> listProducts() async {
    _lastError = null;
    try {
      return await _purchaseGateway.listProducts();
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      return const [];
    }
  }

  Future<bool> purchasePlus(String productId) async {
    _setLoading(true);
    _lastError = null;

    try {
      final receipt = await _purchaseGateway.purchase(productId);
      _state = await _entitlementApi.verifyPurchase(receipt);
      return _state.canUseCloud;
    } catch (e) {
      _lastError = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> restorePurchases() async {
    _setLoading(true);
    _lastError = null;

    try {
      final receipts = await _purchaseGateway.restorePurchases();
      _state = await _entitlementApi.restorePurchases(receipts);
      return _state.canUseCloud;
    } catch (e) {
      _lastError = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
