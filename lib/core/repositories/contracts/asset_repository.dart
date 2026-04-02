import '../../../models/asset_record.dart';

abstract class AssetRepository {
  Future<List<AssetRecord>> getAll();
  Future<List<AssetRecord>> getActive();
  Future<AssetRecord?> getById(int id);
  Future<int> addPurchase({
    required String assetType,
    required String name,
    String? areaSquareMeters,
    String? address,
    String? brand,
    String? model,
    String? description,
    String? currentValueInput,
    required double acquisitionValue,
    required DateTime acquisitionDate,
    required int expenseAccountId,
    required int expenseCategoryId,
    String paymentMethod,
    double? primaryPaymentAmount,
    int? secondaryExpenseAccountId,
    double? secondaryPaymentAmount,
    int? installmentCount,
    double? latitude,
    double? longitude,
  });
  Future<void> sell({
    required int assetId,
    required int incomeAccountId,
    required int incomeCategoryId,
    required double saleValue,
    required DateTime saleDate,
    String? description,
    double? latitude,
    double? longitude,
  });
  Future<void> updateDefinition({
    required int assetId,
    required String assetType,
    required String name,
    String? areaSquareMeters,
    String? address,
    String? brand,
    String? model,
    String? description,
    String? currentValueInput,
    required bool isActive,
  });
  Future<void> setActive(int assetId, bool value);
}
