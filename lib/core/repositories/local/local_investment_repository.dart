import '../../../models/investment_transaction.dart';
import '../../../services/investment_transaction_service.dart';
import '../contracts/investment_repository.dart';

class LocalInvestmentRepository implements InvestmentRepository {
  const LocalInvestmentRepository();

  @override
  Future<int> addAndGetId({
    required int investmentAccountId,
    required int cashAccountId,
    required String symbol,
    required String type,
    required double quantity,
    required double unitPrice,
    required double total,
    required DateTime date,
  }) {
    return InvestmentTransactionService.addAndGetId(
      investmentAccountId: investmentAccountId,
      cashAccountId: cashAccountId,
      symbol: symbol,
      type: type,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
      date: date,
    );
  }

  @override
  Future<void> deleteAndReturn(int transactionId) {
    return InvestmentTransactionService.deleteAndReturn(transactionId);
  }

  @override
  Future<List<InvestmentTransaction>> getAll() {
    return InvestmentTransactionService.getAll();
  }

  @override
  Future<FifoSellPreview> previewSell({
    required int investmentAccountId,
    required String symbol,
    required double sellQuantity,
    required double sellUnitPrice,
  }) {
    return InvestmentTransactionService.previewSell(
      investmentAccountId: investmentAccountId,
      symbol: symbol,
      sellQuantity: sellQuantity,
      sellUnitPrice: sellUnitPrice,
    );
  }

  @override
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
  }) {
    return InvestmentTransactionService.updateTransaction(
      transactionId: transactionId,
      investmentAccountId: investmentAccountId,
      cashAccountId: cashAccountId,
      symbol: symbol,
      type: type,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
      date: date,
    );
  }
}
