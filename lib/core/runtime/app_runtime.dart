import 'package:flutter/foundation.dart';

import '../repositories/data_layer.dart';
import '../subscription/gateways/in_app_purchase_gateway.dart';
import '../subscription/gateways/noop_purchase_gateway.dart';
import '../subscription/gateways/purchase_gateway.dart';
import '../subscription/subscription_controller.dart';

class AppRuntime {
  static final SubscriptionController subscriptions = SubscriptionController(
    purchaseGateway: _buildPurchaseGateway(),
  );
  static final DataLayer dataLayer = DataLayer.localOnly();

  static Future<void> initialize() async {
    await subscriptions.initialize();
  }

  static PurchaseGateway _buildPurchaseGateway() {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android)) {
      return InAppPurchaseGateway();
    }
    return const NoopPurchaseGateway();
  }
}
