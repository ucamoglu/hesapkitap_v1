import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/purchase_receipt.dart';
import '../models/subscription_product.dart';
import '../purchase_config.dart';
import 'purchase_gateway.dart';

class InAppPurchaseGateway implements PurchaseGateway {
  final InAppPurchase _inAppPurchase;

  bool _initialized = false;
  bool _available = false;
  Completer<PurchaseReceipt>? _purchaseCompleter;
  String? _pendingProductId;

  Completer<List<PurchaseReceipt>>? _restoreCompleter;
  final List<PurchaseReceipt> _restoredReceipts = <PurchaseReceipt>[];
  Timer? _restoreDebounceTimer;

  InAppPurchaseGateway({InAppPurchase? inAppPurchase})
      : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    _available = await _inAppPurchase.isAvailable();
    _inAppPurchase.purchaseStream.listen(_handlePurchaseUpdates);

    _initialized = true;
  }

  @override
  Future<List<SubscriptionProduct>> listProducts() async {
    _ensureInitialized();
    if (!_available) return const <SubscriptionProduct>[];

    final response = await _inAppPurchase.queryProductDetails(
      PurchaseConfig.productIds,
    );

    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    return response.productDetails
        .map(
          (p) => SubscriptionProduct(
            id: p.id,
            title: p.title,
            description: p.description,
          ),
        )
        .toList();
  }

  @override
  Future<PurchaseReceipt> purchase(String productId) async {
    _ensureInitialized();
    if (!_available) {
      throw Exception('Magaza baglantisi su an kullanilamiyor.');
    }

    final response = await _inAppPurchase.queryProductDetails({productId});
    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    if (response.productDetails.isEmpty) {
      throw Exception('Urun bulunamadi: $productId');
    }

    _purchaseCompleter = Completer<PurchaseReceipt>();
    _pendingProductId = productId;

    final purchaseParam = PurchaseParam(
      productDetails: response.productDetails.first,
    );

    final started =
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    if (!started) {
      _clearPendingPurchase();
      throw Exception('Satin alma baslatilamadi.');
    }

    return _purchaseCompleter!.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        _clearPendingPurchase();
        throw TimeoutException('Satin alma onayi zaman asimina ugradi.');
      },
    );
  }

  @override
  Future<List<PurchaseReceipt>> restorePurchases() async {
    _ensureInitialized();
    if (!_available) return const <PurchaseReceipt>[];

    _restoredReceipts.clear();
    _restoreCompleter = Completer<List<PurchaseReceipt>>();

    _restartRestoreDebounce();
    await _inAppPurchase.restorePurchases();

    return _restoreCompleter!.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _finishRestore();
        return List<PurchaseReceipt>.unmodifiable(_restoredReceipts);
      },
    );
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> updates) {
    if (updates.isEmpty) {
      _restartRestoreDebounce();
      return;
    }

    for (final purchase in updates) {
      if (purchase.pendingCompletePurchase) {
        unawaited(_inAppPurchase.completePurchase(purchase));
      }

      if (purchase.status == PurchaseStatus.error) {
        _completePurchaseWithError(purchase.error?.message ?? 'Satin alma hatasi.');
        continue;
      }

      if (purchase.status == PurchaseStatus.canceled) {
        _completePurchaseWithError('Satin alma iptal edildi.');
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final receipt = _toReceipt(purchase);

        if (_purchaseCompleter != null &&
            !_purchaseCompleter!.isCompleted &&
            purchase.productID == _pendingProductId) {
          _purchaseCompleter!.complete(receipt);
          _clearPendingPurchase();
        }

        if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
          final alreadyAdded = _restoredReceipts.any(
            (r) => r.transactionId == receipt.transactionId,
          );
          if (!alreadyAdded) {
            _restoredReceipts.add(receipt);
          }
          _restartRestoreDebounce();
        }
      }
    }
  }

  PurchaseReceipt _toReceipt(PurchaseDetails p) {
    final txId = p.purchaseID ??
        '${p.productID}_${p.transactionDate ?? DateTime.now().millisecondsSinceEpoch}';

    final millis = int.tryParse(p.transactionDate ?? '') ??
        DateTime.now().millisecondsSinceEpoch;

    return PurchaseReceipt(
      productId: p.productID,
      transactionId: txId,
      payload: p.verificationData.serverVerificationData,
      purchasedAt: DateTime.fromMillisecondsSinceEpoch(millis),
    );
  }

  void _completePurchaseWithError(String message) {
    if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
      _purchaseCompleter!.completeError(Exception(message));
      _clearPendingPurchase();
    }
  }

  void _restartRestoreDebounce() {
    if (_restoreCompleter == null || _restoreCompleter!.isCompleted) return;

    _restoreDebounceTimer?.cancel();
    _restoreDebounceTimer = Timer(const Duration(seconds: 2), _finishRestore);
  }

  void _finishRestore() {
    _restoreDebounceTimer?.cancel();
    if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
      _restoreCompleter!.complete(
        List<PurchaseReceipt>.unmodifiable(_restoredReceipts),
      );
    }
  }

  void _clearPendingPurchase() {
    _pendingProductId = null;
    _purchaseCompleter = null;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('InAppPurchaseGateway.initialize() once before use.');
    }
  }
}
