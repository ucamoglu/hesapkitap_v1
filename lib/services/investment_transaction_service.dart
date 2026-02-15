import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/finance_transaction.dart';
import '../models/investment_transaction.dart';
import 'investment_outcome_category_service.dart';

class FifoSellPreview {
  final double costBasisTotal;
  final double proceedsTotal;
  final double realizedPnl;

  const FifoSellPreview({
    required this.costBasisTotal,
    required this.proceedsTotal,
    required this.realizedPnl,
  });
}

class InvestmentTransactionService {
  static Future<List<InvestmentTransaction>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.investmentTransactions.where().anyId().findAll();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  static Future<int> addAndGetId({
    required int investmentAccountId,
    required int cashAccountId,
    required String symbol,
    required String type,
    required double quantity,
    required double unitPrice,
    required double total,
    required DateTime date,
  }) async {
    if (investmentAccountId == cashAccountId) {
      throw Exception('Yatırım hesabı ve kaynak/hedef hesap aynı olamaz.');
    }
    if (type != 'buy' && type != 'sell') {
      throw Exception('Geçersiz işlem türü.');
    }
    if (quantity <= 0 || unitPrice <= 0 || total <= 0) {
      throw Exception('Miktar, fiyat ve tutar sıfırdan büyük olmalıdır.');
    }

    final isar = IsarService.isar;
    late int createdId;

    await isar.writeTxn(() async {
      final investmentAccount = await isar.accounts.get(investmentAccountId);
      final cashAccount = await isar.accounts.get(cashAccountId);

      if (investmentAccount == null || cashAccount == null) {
        throw Exception('Hesap bulunamadı.');
      }
      if (investmentAccount.type != 'investment') {
        throw Exception('Seçilen yatırım hesabı geçersiz.');
      }
      if (cashAccount.type == 'investment') {
        throw Exception('Kaynak/Hedef hesap yatırım türünde olamaz.');
      }
      if (!investmentAccount.isActive || !cashAccount.isActive) {
        throw Exception('Pasif hesapta işlem yapılamaz.');
      }

      if (type == 'buy' && cashAccount.balance < total) {
        throw Exception('Kaynak hesap bakiyesi yetersiz.');
      }
      if (type == 'sell' && investmentAccount.balance < quantity) {
        throw Exception('Satış miktarı yatırım bakiyesinden büyük olamaz.');
      }

      FifoSellPreview? sellPreview;
      if (type == 'sell') {
        sellPreview = await _calculateFifoSellPreview(
          isar: isar,
          investmentAccountId: investmentAccountId,
          symbol: symbol,
          sellQuantity: quantity,
          sellUnitPrice: unitPrice,
        );
      }

      final tx = InvestmentTransaction()
        ..investmentAccountId = investmentAccountId
        ..cashAccountId = cashAccountId
        ..symbol = symbol
        ..type = type
        ..quantity = quantity
        ..unitPrice = unitPrice
        ..total = total
        ..costBasisTotal = sellPreview?.costBasisTotal ?? 0
        ..realizedPnl = sellPreview?.realizedPnl ?? 0
        ..date = date
        ..createdAt = DateTime.now();

      if (type == 'buy') {
        cashAccount.balance -= total;
        investmentAccount.balance += quantity;
      } else {
        investmentAccount.balance -= quantity;
        cashAccount.balance += total;

        final pnl = sellPreview?.realizedPnl ?? 0;
        if (pnl.abs() > 1e-9) {
          final pair = await InvestmentOutcomeCategoryService.ensurePairForSymbol(
            isar: isar,
            symbol: symbol,
          );
          final financeTx = FinanceTransaction()
            ..accountId = cashAccountId
            ..categoryId = pnl >= 0 ? pair.income.id : pair.expense.id
            ..type = pnl >= 0 ? 'income' : 'expense'
            ..amount = pnl.abs()
            ..description = 'Yatirim satis K/Z • $symbol'
            ..incomePlanId = null
            ..expensePlanId = null
            ..date = date
            ..createdAt = DateTime.now();
          // K/Z raporlarda gorunsun diye finans hareketi yazilir.
          // Nakit hesap bakiyesi ayrica degistirilmez; satis tutari zaten eklendi.
          await isar.financeTransactions.put(financeTx);
        }
      }

      await isar.accounts.put(cashAccount);
      await isar.accounts.put(investmentAccount);
      createdId = await isar.investmentTransactions.put(tx);
    });

    return createdId;
  }

  static Future<FifoSellPreview> previewSell({
    required int investmentAccountId,
    required String symbol,
    required double sellQuantity,
    required double sellUnitPrice,
  }) async {
    if (sellQuantity <= 0 || sellUnitPrice <= 0) {
      throw Exception('Geçerli miktar ve birim fiyat giriniz.');
    }
    return _calculateFifoSellPreview(
      isar: IsarService.isar,
      investmentAccountId: investmentAccountId,
      symbol: symbol,
      sellQuantity: sellQuantity,
      sellUnitPrice: sellUnitPrice,
    );
  }

  static Future<FifoSellPreview> _calculateFifoSellPreview({
    required Isar isar,
    required int investmentAccountId,
    required String symbol,
    required double sellQuantity,
    required double sellUnitPrice,
  }) async {
    final symbolUpper = symbol.trim().toUpperCase();
    final history = await isar.investmentTransactions
        .where()
        .filter()
        .investmentAccountIdEqualTo(investmentAccountId)
        .and()
        .symbolEqualTo(symbolUpper)
        .findAll();

    history.sort((a, b) {
      final byCreated = a.createdAt.compareTo(b.createdAt);
      if (byCreated != 0) return byCreated;
      return a.id.compareTo(b.id);
    });

    final lots = <_FifoLot>[];
    for (final tx in history) {
      final normalizedType = tx.type.trim().toLowerCase();
      if (normalizedType == 'buy' || normalizedType == 'alış' || normalizedType == 'alis') {
        if (tx.quantity > 0 && tx.unitPrice > 0) {
          lots.add(_FifoLot(qty: tx.quantity, unitCost: tx.unitPrice));
        }
        continue;
      }
      if (normalizedType == 'sell' ||
          normalizedType == 'satış' ||
          normalizedType == 'satis') {
        var remainingSell = tx.quantity;
        for (final lot in lots) {
          if (remainingSell <= 0) break;
          if (lot.qty <= 0) continue;
          final consumed = remainingSell <= lot.qty ? remainingSell : lot.qty;
          lot.qty -= consumed;
          remainingSell -= consumed;
        }
      }
    }

    var remaining = sellQuantity;
    var costBasis = 0.0;
    for (final lot in lots) {
      if (remaining <= 0) break;
      if (lot.qty <= 0) continue;
      final consumed = remaining <= lot.qty ? remaining : lot.qty;
      costBasis += consumed * lot.unitCost;
      remaining -= consumed;
    }

    if (remaining > 1e-9) {
      throw Exception('FIFO lot yetersiz: satış için yeterli alış lotu yok.');
    }

    final proceeds = sellQuantity * sellUnitPrice;
    return FifoSellPreview(
      costBasisTotal: costBasis,
      proceedsTotal: proceeds,
      realizedPnl: proceeds - costBasis,
    );
  }
}

class _FifoLot {
  double qty;
  final double unitCost;

  _FifoLot({
    required this.qty,
    required this.unitCost,
  });
}
