import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/cari_card.dart';
import '../models/cari_transaction.dart';
import '../models/transaction_attachment.dart';

class CariTransactionService {
  static void _validateCariType(String type) {
    if (type != 'debt' && type != 'collection') {
      throw Exception('Geçersiz cari işlem türü.');
    }
  }

  static void _validateCariAccount(Account account) {
    if (account.type == 'investment') {
      throw Exception('Cari işlemler yatırım hesabına kaydedilemez.');
    }
    if (!account.isActive) {
      throw Exception('Pasif hesapta işlem yapılamaz.');
    }
  }

  static void _validateCariCard({
    required CariCard card,
    required double amount,
    required double? quantity,
    required double? unitPrice,
  }) {
    if (!card.isActive) {
      throw Exception('Pasif cari kart ile işlem yapılamaz.');
    }
    if (amount <= 0) {
      throw Exception('Cari işlem tutarı sıfırdan büyük olmalıdır.');
    }
    final isForeign = card.currencyType == 'foreign';
    if (isForeign) {
      if (quantity == null || quantity <= 0) {
        throw Exception('Yabancı cari işlem için geçerli miktar giriniz.');
      }
      if (unitPrice == null || unitPrice <= 0) {
        throw Exception('Yabancı cari işlem için geçerli birim fiyat gerekli.');
      }
    }
  }

  /// Cari hareketleri tarihe gore yeni->eski sirada dondurur.
  static Future<List<CariTransaction>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.cariTransactions.where().anyId().findAll();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  /// Belirli tarih araligindaki cari hareketleri yeni->eski sirada dondurur.
  static Future<List<CariTransaction>> getByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final isar = IsarService.isar;
    final items = await isar.cariTransactions
        .where()
        .filter()
        .dateBetween(start, end)
        .findAll();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  /// Cari borc kaydi olusturmak icin kolay sarmalayici metottur.
  static Future<void> addDebt({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  }) async {
    await addDebtAndGetId(
      cariCardId: cariCardId,
      accountId: accountId,
      amount: amount,
      quantity: quantity,
      unitPrice: unitPrice,
      date: date,
      description: description,
    );
  }

  /// Cari borc kaydini ekler ve bagli hesabin bakiyesini ayni transaction icinde azaltir.
  static Future<int> addDebtAndGetId({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  }) async {
    _validateCariType('debt');
    final isar = IsarService.isar;
    late int createdId;

    await isar.writeTxn(() async {
      final card = await isar.cariCards.get(cariCardId);
      final account = await isar.accounts.get(accountId);
      if (card == null) throw Exception('Cari kart bulunamadı.');
      if (account == null) throw Exception('Hesap bulunamadı.');
      _validateCariCard(
        card: card,
        amount: amount,
        quantity: quantity,
        unitPrice: unitPrice,
      );
      _validateCariAccount(account);
      if (account.balance + 1e-9 < amount) {
        throw Exception('Hesap bakiyesi bu cari çıkış için yetersiz.');
      }

      final tx = CariTransaction()
        ..cariCardId = cariCardId
        ..accountId = accountId
        ..type = 'debt'
        ..amount = amount
        ..quantity = quantity
        ..unitPrice = unitPrice
        ..date = date
        ..description = description?.trim().isEmpty == true
            ? null
            : description?.trim()
        ..createdAt = DateTime.now();

      account.balance -= amount;

      createdId = await isar.cariTransactions.put(tx);
      await isar.accounts.put(account);
    });

    return createdId;
  }

  /// Tahsilat kaydi icin kolay sarmalayici metottur.
  static Future<void> addCollection({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  }) async {
    await addCollectionAndGetId(
      cariCardId: cariCardId,
      accountId: accountId,
      amount: amount,
      quantity: quantity,
      unitPrice: unitPrice,
      date: date,
      description: description,
    );
  }

  /// Tahsilat kaydini ekler ve bagli hesabin bakiyesini ayni transaction icinde artirir.
  static Future<int> addCollectionAndGetId({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  }) async {
    _validateCariType('collection');
    final isar = IsarService.isar;
    late int createdId;

    await isar.writeTxn(() async {
      final card = await isar.cariCards.get(cariCardId);
      final account = await isar.accounts.get(accountId);
      if (card == null) throw Exception('Cari kart bulunamadı.');
      if (account == null) throw Exception('Hesap bulunamadı.');
      _validateCariCard(
        card: card,
        amount: amount,
        quantity: quantity,
        unitPrice: unitPrice,
      );
      _validateCariAccount(account);

      final tx = CariTransaction()
        ..cariCardId = cariCardId
        ..accountId = accountId
        ..type = 'collection'
        ..amount = amount
        ..quantity = quantity
        ..unitPrice = unitPrice
        ..date = date
        ..description = description?.trim().isEmpty == true
            ? null
            : description?.trim()
        ..createdAt = DateTime.now();

      account.balance += amount;

      createdId = await isar.cariTransactions.put(tx);
      await isar.accounts.put(account);
    });

    return createdId;
  }

  /// Cari hareket degisince eski ve yeni hesap bakiyelerini yeniden dengeler.
  static Future<void> updateTransaction({
    required int transactionId,
    required int cariCardId,
    required int accountId,
    required String type, // debt / collection
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  }) async {
    _validateCariType(type);
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      final oldTx = await isar.cariTransactions.get(transactionId);
      if (oldTx == null) throw Exception('Cari işlem bulunamadı.');
      final card = await isar.cariCards.get(cariCardId);
      if (card == null) throw Exception('Cari kart bulunamadı.');
      _validateCariCard(
        card: card,
        amount: amount,
        quantity: quantity,
        unitPrice: unitPrice,
      );

      final oldType = oldTx.type;
      final oldAmount = oldTx.amount;

      final oldAccount = await isar.accounts.get(oldTx.accountId);
      if (oldAccount == null) throw Exception('Hesap bulunamadı.');
      _validateCariAccount(oldAccount);

      Account? newAccount;
      if (oldTx.accountId != accountId) {
        newAccount = await isar.accounts.get(accountId);
        if (newAccount == null) throw Exception('Hesap bulunamadı.');
        _validateCariAccount(newAccount);
      }

      if (newAccount == null) {
        if (oldType == 'collection') {
          oldAccount.balance -= oldAmount;
        } else {
          oldAccount.balance += oldAmount;
        }
        if (type == 'collection') {
          if (amount <= 0) {
            throw Exception('Cari işlem tutarı sıfırdan büyük olmalıdır.');
          }
          oldAccount.balance += amount;
        } else {
          if (amount <= 0) {
            throw Exception('Cari işlem tutarı sıfırdan büyük olmalıdır.');
          }
          if (oldAccount.balance + 1e-9 < amount) {
            throw Exception('Hesap bakiyesi bu cari çıkış için yetersiz.');
          }
          oldAccount.balance -= amount;
        }
        await isar.accounts.put(oldAccount);
      } else {
        if (oldType == 'collection') {
          oldAccount.balance -= oldAmount;
        } else {
          oldAccount.balance += oldAmount;
        }
        if (type == 'collection') {
          if (amount <= 0) {
            throw Exception('Cari işlem tutarı sıfırdan büyük olmalıdır.');
          }
          newAccount.balance += amount;
        } else {
          if (amount <= 0) {
            throw Exception('Cari işlem tutarı sıfırdan büyük olmalıdır.');
          }
          if (newAccount.balance + 1e-9 < amount) {
            throw Exception('Hesap bakiyesi bu cari çıkış için yetersiz.');
          }
          newAccount.balance -= amount;
        }
        await isar.accounts.put(oldAccount);
        await isar.accounts.put(newAccount);
      }

      oldTx
        ..cariCardId = cariCardId
        ..accountId = accountId
        ..type = type
        ..amount = amount
        ..quantity = quantity
        ..unitPrice = unitPrice
        ..date = date
        ..description = description?.trim().isEmpty == true
            ? null
            : description?.trim();

      await isar.cariTransactions.put(oldTx);
    });
  }

  /// Cari hareketi silmeden once hesap bakiyesini geri sarar ve ekleri temizler.
  static Future<CariTransaction> deleteAndReturn(int transactionId) async {
    final isar = IsarService.isar;
    late CariTransaction deleted;

    await isar.writeTxn(() async {
      final tx = await isar.cariTransactions.get(transactionId);
      if (tx == null) throw Exception('Cari işlem bulunamadı.');

      final account = await isar.accounts.get(tx.accountId);
      if (account == null) throw Exception('Hesap bulunamadı.');

      if (tx.type == 'collection') {
        account.balance -= tx.amount;
      } else {
        account.balance += tx.amount;
      }
      await isar.accounts.put(account);
      final attachmentIds = await isar.transactionAttachments
          .where()
          .filter()
          .ownerTypeEqualTo('cari')
          .and()
          .ownerIdEqualTo(tx.id)
          .idProperty()
          .findAll();
      if (attachmentIds.isNotEmpty) {
        await isar.transactionAttachments.deleteAll(attachmentIds);
      }
      await isar.cariTransactions.delete(tx.id);
      deleted = tx;
    });

    return deleted;
  }
}
