import '../../../models/investment_transaction.dart';
import '../../../services/investment_transaction_service.dart';

abstract class InvestmentRepository {
  Future<List<InvestmentTransaction>> getAll();
  Future<int> addAndGetId({
    required int investmentAccountId,
    required int cashAccountId,
    required String symbol,
    required String type,
    required double quantity,
    required double unitPrice,
    required double total,
    required DateTime date,
  });
  Future<void> updateTransaction({
    required int transactionId,
    required int investmentAccountId,
    required int cashAccountId,
    required String symbol,
    required String type,
    required double quantity,
    required double unitPrice,
    required double total,
    required DateTime date,
  });
  Future<void> deleteAndReturn(int transactionId);
  Future<FifoSellPreview> previewSell({
    required int investmentAccountId,
    required String symbol,
    required double sellQuantity,
    required double sellUnitPrice,
  });
}
