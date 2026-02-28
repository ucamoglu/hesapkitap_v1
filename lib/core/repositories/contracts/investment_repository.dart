import '../../../models/investment_transaction.dart';
import '../../../services/investment_transaction_service.dart';

abstract class InvestmentRepository {
  // Tum yatirim hareketlerini getirir.
  Future<List<InvestmentTransaction>> getAll();
  // Alis/satis hareketi ekler.
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
  // Yatirim hareketini gunceller.
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
  // Yatirim hareketini geri sararak siler.
  Future<void> deleteAndReturn(int transactionId);
  // Satis oncesi FIFO maliyet onizlemesi uretir.
  Future<FifoSellPreview> previewSell({
    required int investmentAccountId,
    required String symbol,
    required double sellQuantity,
    required double sellUnitPrice,
  });
}
