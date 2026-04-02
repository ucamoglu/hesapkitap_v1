import '../../../models/asset_record.dart';
import '../../../services/asset_record_service.dart';
import '../../sync/sync_change_tracker.dart';
import '../contracts/asset_repository.dart';

class LocalAssetRepository implements AssetRepository {
  LocalAssetRepository({
    SyncChangeTracker? changeTracker,
  }) : _changeTracker = changeTracker ?? SyncChangeTracker();

  final SyncChangeTracker _changeTracker;

  @override
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
    String paymentMethod = 'single',
    double? primaryPaymentAmount,
    int? secondaryExpenseAccountId,
    double? secondaryPaymentAmount,
    int? installmentCount,
    double? latitude,
    double? longitude,
  }) async {
    final id = await AssetRecordService.addPurchase(
      assetType: assetType,
      name: name,
      areaSquareMeters: areaSquareMeters,
      address: address,
      brand: brand,
      model: model,
      description: description,
      currentValueInput: currentValueInput,
      acquisitionValue: acquisitionValue,
      acquisitionDate: acquisitionDate,
      expenseAccountId: expenseAccountId,
      expenseCategoryId: expenseCategoryId,
      paymentMethod: paymentMethod,
      primaryPaymentAmount: primaryPaymentAmount,
      secondaryExpenseAccountId: secondaryExpenseAccountId,
      secondaryPaymentAmount: secondaryPaymentAmount,
      installmentCount: installmentCount,
      latitude: latitude,
      longitude: longitude,
    );
    await _changeTracker.markUpsert(entityType: 'asset_record', localId: id);
    return id;
  }

  @override
  Future<List<AssetRecord>> getActive() {
    return AssetRecordService.getActive();
  }

  @override
  Future<List<AssetRecord>> getAll() {
    return AssetRecordService.getAll();
  }

  @override
  Future<AssetRecord?> getById(int id) {
    return AssetRecordService.getById(id);
  }

  @override
  Future<void> sell({
    required int assetId,
    required int incomeAccountId,
    required int incomeCategoryId,
    required double saleValue,
    required DateTime saleDate,
    String? description,
    double? latitude,
    double? longitude,
  }) async {
    await AssetRecordService.sell(
      assetId: assetId,
      incomeAccountId: incomeAccountId,
      incomeCategoryId: incomeCategoryId,
      saleValue: saleValue,
      saleDate: saleDate,
      description: description,
      latitude: latitude,
      longitude: longitude,
    );
    await _changeTracker.markUpsert(entityType: 'asset_record', localId: assetId);
  }

  @override
  Future<void> setActive(int assetId, bool value) async {
    await AssetRecordService.setActive(assetId, value);
    await _changeTracker.markUpsert(entityType: 'asset_record', localId: assetId);
  }

  @override
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
  }) async {
    await AssetRecordService.updateDefinition(
      assetId: assetId,
      assetType: assetType,
      name: name,
      areaSquareMeters: areaSquareMeters,
      address: address,
      brand: brand,
      model: model,
      description: description,
      currentValueInput: currentValueInput,
      isActive: isActive,
    );
    await _changeTracker.markUpsert(entityType: 'asset_record', localId: assetId);
  }
}
