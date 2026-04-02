import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/finance_transaction.dart';
import '../models/investment_transaction.dart';
import 'account_service.dart';
import 'credit_card_installment_service.dart';
import 'credit_card_statement_service.dart';
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
  static String _pnlDescription(String symbol) =>
      'Yatırım satış K/Z • ${symbol.toUpperCase()}';

  static bool _matchesPnlDescription(String? description, String symbol) {
    final normalized = (description ?? '').trim();
    if (normalized.isEmpty) return false;
    final upperSymbol = symbol.toUpperCase();
    return normalized == 'Yatırım satış K/Z • $upperSymbol' ||
        normalized == 'Yatirim satis K/Z • $upperSymbol';
  }

  /// Yatirim hareketlerini tarihe gore yeni->eski sirada getirir.
  static Future<List<InvestmentTransaction>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.investmentTransactions.where().anyId().findAll();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  /// Belirli tarih araligindaki yatirim hareketlerini yeni->eski sirada getirir.
  static Future<List<InvestmentTransaction>> getByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final isar = IsarService.isar;
    final items = await isar.investmentTransactions
        .where()
        .filter()
        .dateBetween(start, end)
        .findAll();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  /// Alis/satis hareketini ekler; nakit ve yatirim hesap bakiyelerini ayni anda gunceller.
  static Future<int> addAndGetId({
    required int investmentAccountId,
    required int cashAccountId,
    required String symbol,
    required String type,
    required double quantity,
    required double unitPrice,
    required double total,
    required DateTime date,
    bool syncCreditCardStatement = true,
  }) async {
    if (investmentAccountId == cashAccountId) {
      throw Exception('Yatırım hesabı ve kaynak/hedef hesap aynı olamaz.');
    }
    if (type != 'buy' && type != 'sell') {
      throw Exception('Geçersiz işlem türü.');
    }
    final isar = IsarService.isar;
    late int createdId;
    late bool shouldSyncCreditCardStatement;
    late Account? creditCardAccountForSync;

    await isar.writeTxn(() async {
      final investmentAccount = await isar.accounts.get(investmentAccountId);
      final cashAccount = await isar.accounts.get(cashAccountId);

      if (investmentAccount == null || cashAccount == null) {
        throw Exception('Hesap bulunamadı.');
      }
      final isBalanceBackedBuy =
          type == 'buy' &&
          AccountService.isGhostAccount(cashAccount) &&
          total == 0 &&
          unitPrice == 0;
      if (investmentAccount.type != 'investment') {
        throw Exception('Seçilen yatırım hesabı geçersiz.');
      }
      if (cashAccount.type == 'investment') {
        throw Exception('Kaynak/Hedef hesap yatırım türünde olamaz.');
      }
      if (!investmentAccount.isActive || !cashAccount.isActive) {
        throw Exception('Pasif hesapta işlem yapılamaz.');
      }
      if (quantity <= 0 || unitPrice < 0 || total < 0) {
        throw Exception('Miktar pozitif, fiyat ve tutar negatif olamaz.');
      }
      if (!isBalanceBackedBuy && (unitPrice <= 0 || total <= 0)) {
        throw Exception('Miktar, fiyat ve tutar sıfırdan büyük olmalıdır.');
      }

      if (type == 'buy' &&
          !cashAccount.isCreditCard &&
          cashAccount.balance < total) {
        throw Exception('Kaynak hesap bakiyesi yetersiz.');
      }
      if (type == 'sell' && cashAccount.isCreditCard) {
        throw Exception('Satış işleminde hedef hesap kredi kartı olamaz.');
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
        shouldSyncCreditCardStatement =
            cashAccount.isCreditCard && syncCreditCardStatement;
        creditCardAccountForSync =
            shouldSyncCreditCardStatement ? cashAccount : null;
      } else {
        investmentAccount.balance -= quantity;
        cashAccount.balance += total;
        shouldSyncCreditCardStatement = false;
        creditCardAccountForSync = null;

        final pnl = sellPreview?.realizedPnl ?? 0;
        if (pnl.abs() > 1e-9) {
          final pair =
              await InvestmentOutcomeCategoryService.ensurePairForSymbol(
            isar: isar,
            symbol: symbol,
          );
          final financeTx = FinanceTransaction()
            ..accountId = cashAccountId
            ..categoryId = pnl >= 0 ? pair.income.id : pair.expense.id
            ..type = pnl >= 0 ? 'income' : 'expense'
            ..amount = pnl.abs()
            ..description = _pnlDescription(symbol)
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

    if (shouldSyncCreditCardStatement && creditCardAccountForSync != null) {
      await CreditCardStatementService.adjustExpenseImpact(
        creditCardAccount: creditCardAccountForSync!,
        transactionDate: date,
        deltaAmount: total,
      );
    }

    return createdId;
  }

  /// Eski islemi geri alip yeni degerleri uygulayarak yatirim hareketini gunceller.
  static Future<void> updateTransaction({
    required int transactionId,
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
    final isar = IsarService.isar;
    Account? oldCreditCardForStatementRevert;
    Account? newCreditCardForStatementApply;
    bool revertOldStatement = false;
    bool applyNewStatement = false;
    late DateTime oldDate;
    late double oldTotal;
    late String oldType;
    await isar.writeTxn(() async {
      final existing = await isar.investmentTransactions.get(transactionId);
      if (existing == null) {
        throw Exception('Yatırım işlemi bulunamadı.');
      }
      oldDate = existing.date;
      oldTotal = existing.total;
      oldType = existing.type;

      final accountIds = <int>{
        existing.investmentAccountId,
        existing.cashAccountId,
        investmentAccountId,
        cashAccountId,
      };
      final accountById = <int, Account>{};
      for (final id in accountIds) {
        final account = await isar.accounts.get(id);
        if (account == null) {
          throw Exception('Hesap bulunamadı.');
        }
        accountById[id] = account;
      }

      final oldInvestment = accountById[existing.investmentAccountId]!;
      final oldCash = accountById[existing.cashAccountId]!;
      if (existing.type == 'buy') {
        oldCash.balance += existing.total;
        oldInvestment.balance -= existing.quantity;
      } else {
        oldInvestment.balance += existing.quantity;
        oldCash.balance -= existing.total;
      }

      if (existing.type == 'sell' && existing.realizedPnl.abs() > 1e-9) {
        final oldFinance = await _findLinkedPnlFinanceTx(
          isar: isar,
          tx: existing,
        );
        if (oldFinance != null) {
          await isar.financeTransactions.delete(oldFinance.id);
        }
      }

      final newInvestment = accountById[investmentAccountId]!;
      final newCash = accountById[cashAccountId]!;
      if (newInvestment.type != 'investment') {
        throw Exception('Seçilen yatırım hesabı geçersiz.');
      }
      final isBalanceBackedBuy =
          type == 'buy' &&
          AccountService.isGhostAccount(newCash) &&
          total == 0 &&
          unitPrice == 0;
      if (newCash.type == 'investment') {
        throw Exception('Kaynak/Hedef hesap yatırım türünde olamaz.');
      }
      if (!newInvestment.isActive || !newCash.isActive) {
        throw Exception('Pasif hesapta işlem yapılamaz.');
      }
      if (quantity <= 0 || unitPrice < 0 || total < 0) {
        throw Exception('Miktar pozitif, fiyat ve tutar negatif olamaz.');
      }
      if (!isBalanceBackedBuy && (unitPrice <= 0 || total <= 0)) {
        throw Exception('Miktar, fiyat ve tutar sıfırdan büyük olmalıdır.');
      }
      if (type == 'buy' && !newCash.isCreditCard && newCash.balance < total) {
        throw Exception('Kaynak hesap bakiyesi yetersiz.');
      }
      if (type == 'sell' && newCash.isCreditCard) {
        throw Exception('Satış işleminde hedef hesap kredi kartı olamaz.');
      }
      if (type == 'sell' && newInvestment.balance < quantity) {
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
          excludeTransactionId: existing.id,
        );
      }

      existing
        ..investmentAccountId = investmentAccountId
        ..cashAccountId = cashAccountId
        ..symbol = symbol.trim().toUpperCase()
        ..type = type
        ..quantity = quantity
        ..unitPrice = unitPrice
        ..total = total
        ..costBasisTotal = sellPreview?.costBasisTotal ?? 0
        ..realizedPnl = sellPreview?.realizedPnl ?? 0
        ..date = date;

      revertOldStatement = oldType == 'buy' && oldCash.isCreditCard;
      oldCreditCardForStatementRevert = revertOldStatement ? oldCash : null;

      if (type == 'buy') {
        newCash.balance -= total;
        newInvestment.balance += quantity;
        applyNewStatement = newCash.isCreditCard;
        newCreditCardForStatementApply = applyNewStatement ? newCash : null;
      } else {
        newInvestment.balance -= quantity;
        newCash.balance += total;
        applyNewStatement = false;
        newCreditCardForStatementApply = null;

        final pnl = sellPreview?.realizedPnl ?? 0;
        if (pnl.abs() > 1e-9) {
          final pair =
              await InvestmentOutcomeCategoryService.ensurePairForSymbol(
            isar: isar,
            symbol: existing.symbol,
          );
          final financeTx = FinanceTransaction()
            ..accountId = cashAccountId
            ..categoryId = pnl >= 0 ? pair.income.id : pair.expense.id
            ..type = pnl >= 0 ? 'income' : 'expense'
            ..amount = pnl.abs()
            ..description = _pnlDescription(existing.symbol)
            ..incomePlanId = null
            ..expensePlanId = null
            ..date = date
            ..createdAt = DateTime.now();
          await isar.financeTransactions.put(financeTx);
        }
      }

      await isar.accounts.putAll(accountById.values.toList());
      await isar.investmentTransactions.put(existing);
    });

    if (revertOldStatement && oldCreditCardForStatementRevert != null) {
      await CreditCardStatementService.adjustExpenseImpact(
        creditCardAccount: oldCreditCardForStatementRevert!,
        transactionDate: oldDate,
        deltaAmount: -oldTotal,
      );
    }
    if (applyNewStatement && newCreditCardForStatementApply != null) {
      await CreditCardStatementService.adjustExpenseImpact(
        creditCardAccount: newCreditCardForStatementApply!,
        transactionDate: date,
        deltaAmount: total,
      );
    }
  }

  /// Yatirim hareketini ve bagli PnL kaydini geri sararak siler.
  static Future<void> deleteAndReturn(int transactionId) async {
    final isar = IsarService.isar;
    late InvestmentTransaction existing;
    late Account investmentAccount;
    late Account cashAccount;
    bool deleteCardInstallments = false;
    bool revertSingleStatement = false;

    existing = await isar.investmentTransactions.get(transactionId) ??
        (throw Exception('Yatırım işlemi bulunamadı.'));
    investmentAccount = await isar.accounts.get(existing.investmentAccountId) ??
        (throw Exception('Bağlı yatırım hesabı bulunamadı.'));
    cashAccount = await isar.accounts.get(existing.cashAccountId) ??
        (throw Exception('Bağlı hesap bulunamadı.'));

    if (existing.type == 'buy' && cashAccount.isCreditCard) {
      deleteCardInstallments =
          await CreditCardInstallmentService.hasInstallmentsForInvestment(
        existing.id,
      );
      revertSingleStatement = !deleteCardInstallments;
    }

    if (deleteCardInstallments) {
      await CreditCardInstallmentService.deleteByInvestmentTransactionId(
        investmentTransactionId: existing.id,
        creditCardAccount: cashAccount,
      );
    } else if (revertSingleStatement) {
      await CreditCardStatementService.adjustExpenseImpact(
        creditCardAccount: cashAccount,
        transactionDate: existing.date,
        deltaAmount: -existing.total,
      );
    }

    await isar.writeTxn(() async {
      if (existing.type == 'buy') {
        cashAccount.balance += existing.total;
        investmentAccount.balance -= existing.quantity;
      } else {
        investmentAccount.balance += existing.quantity;
        cashAccount.balance -= existing.total;
      }

      if (existing.type == 'sell' && existing.realizedPnl.abs() > 1e-9) {
        final pnlFinance = await _findLinkedPnlFinanceTx(
          isar: isar,
          tx: existing,
        );
        if (pnlFinance != null) {
          await isar.financeTransactions.delete(pnlFinance.id);
        }
      }

      await isar.accounts.put(cashAccount);
      await isar.accounts.put(investmentAccount);
      await isar.investmentTransactions.delete(existing.id);
    });
  }

  /// Satistan once FIFO maliyet ve gerceklesen kâr/zarar onizlemesi uretir.
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

  /// Acik lotlari FIFO mantigiyla gezerek satis maliyet tabanini hesaplar.
  static Future<FifoSellPreview> _calculateFifoSellPreview({
    required Isar isar,
    required int investmentAccountId,
    required String symbol,
    required double sellQuantity,
    required double sellUnitPrice,
    int? excludeTransactionId,
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
      if (excludeTransactionId != null && tx.id == excludeTransactionId) {
        continue;
      }
      final normalizedType = tx.type.trim().toLowerCase();
      if (normalizedType == 'buy' ||
          normalizedType == 'alış' ||
          normalizedType == 'alis') {
        if (tx.quantity > 0 && tx.unitPrice >= 0) {
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

  /// Satis hareketi icin uretilmis sentetik finans kaydini bulmaya calisir.
  static Future<FinanceTransaction?> _findLinkedPnlFinanceTx({
    required Isar isar,
    required InvestmentTransaction tx,
  }) async {
    if (tx.type != 'sell' || tx.realizedPnl.abs() <= 1e-9) return null;

    final expectedType = tx.realizedPnl >= 0 ? 'income' : 'expense';
    final expectedAmount = tx.realizedPnl.abs();

    final allFinance = await isar.financeTransactions.where().findAll();
    FinanceTransaction? best;
    var bestDelta = 1 << 62;

    for (final ft in allFinance) {
      if (ft.type != expectedType) continue;
      if (ft.accountId != tx.cashAccountId) continue;
      if ((ft.amount - expectedAmount).abs() > 1e-6) continue;
      if (!_matchesPnlDescription(ft.description, tx.symbol)) continue;
      if (!ft.date.isAtSameMomentAs(tx.date)) continue;

      final delta = (ft.createdAt.millisecondsSinceEpoch -
              tx.createdAt.millisecondsSinceEpoch)
          .abs();
      if (best == null || delta < bestDelta) {
        best = ft;
        bestDelta = delta;
      }
    }

    return best;
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
