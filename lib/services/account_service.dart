import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/finance_transaction.dart';
import '../models/investment_transaction.dart';
import '../models/transfer_transaction.dart';

class AccountService {
  static const String _defaultCashName = 'CÜZDAN';
  static const String _defaultCashType = 'cash';

  /// Uygulamanin her zaman kullanabilecegi varsayilan cüzdan hesabini garanti eder.
  static Future<void> ensureDefaultCashAccount() async {
    final isar = IsarService.isar;
    final existing = await isar.accounts
        .where()
        .filter()
        .typeEqualTo(_defaultCashType)
        .and()
        .nameEqualTo(_defaultCashName)
        .findAll();

    if (existing.isEmpty) {
      final account = Account()
        ..name = _defaultCashName
        ..type = _defaultCashType
        ..investmentSymbol = null
        ..balance = 0
        ..isActive = true
        ..createdAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.accounts.put(account);
      });
      return;
    }

    final first = existing.first;
    if (!first.isActive) {
      await isar.writeTxn(() async {
        first.isActive = true;
        await isar.accounts.put(first);
      });
    }
  }

  /// Yeni bir hesap kaydini kalici olarak yazar.
  static Future<void> addAccount(Account account) async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      await isar.accounts.put(account);
    });
  }
  
  /// Hesabin baska hareketler tarafindan kullanilip kullanilmadigini kontrol eder.
  static Future<bool> isAccountUsed(int id) async {
    final isar = IsarService.isar;

    final financeCount = await isar.financeTransactions
        .where()
        .filter()
        .accountIdEqualTo(id)
        .count();

    final investmentCount = await isar.investmentTransactions
        .where()
        .filter()
        .investmentAccountIdEqualTo(id)
        .or()
        .cashAccountIdEqualTo(id)
        .count();

    final transferCount = await isar.transferTransactions
        .where()
        .filter()
        .fromAccountIdEqualTo(id)
        .or()
        .toAccountIdEqualTo(id)
        .count();

    return financeCount > 0 || investmentCount > 0 || transferCount > 0;
  }

  /// Kullanilan hesaplari silmek yerine kosullara gore pasife alir.
  static Future<bool> deleteAccount(int id) async {
    final isar = IsarService.isar;
    final used = await isAccountUsed(id);
    if (used) {
      final account = await isar.accounts.get(id);
      if (account != null && account.isActive) {
        if (account.balance > 0) {
          throw Exception('Bakiyesi 0\'dan büyük hesap pasife alınamaz.');
        }
        await isar.writeTxn(() async {
          account.isActive = false;
          await isar.accounts.put(account);
        });
      }
      return false;
    }

    await isar.writeTxn(() async {
      await isar.accounts.delete(id);
    });
    return true;
  }

  /// Tum hesaplari getirir; gerekirse bozuk kayitlari temizleyerek toparlanir.
  static Future<List<Account>> getAllAccounts() async {
    final isar = IsarService.isar;
    await ensureDefaultCashAccount();
    try {
      return await isar.txn(() async {
        return await isar.accounts
            .where()
            .anyId()
            .findAll();
      });
    } catch (_) {
      await _cleanupCorruptedAccounts();
      return await isar.accounts.where().anyId().findAll();
    }
  }

  /// Sadece aktif hesaplari UI'da listelemek icin filtreler.
  static Future<List<Account>> getActiveAccounts() async {
    final all = await getAllAccounts();
    return all.where((a) => a.isActive).toList();
  }

  /// Hesabin aktiflik durumunu is kurallarina uygun sekilde degistirir.
  static Future<void> setActive(int id, bool value) async {
    final isar = IsarService.isar;
    final account = await isar.accounts.get(id);
    if (account == null) return;
    if (!value && account.balance > 0) {
      throw Exception('Bakiyesi 0\'dan büyük hesap pasife alınamaz.');
    }

    await isar.writeTxn(() async {
      account.isActive = value;
      await isar.accounts.put(account);
    });
  }

  /// Mevcut hesap kaydini gunceller.
  static Future<void> updateAccount(Account account) async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      await isar.accounts.put(account);
    });
  }

  /// Eski/hatali schema nedeniyle okunamayan hesaplari temizleyip sorguyu kurtarir.
  static Future<void> _cleanupCorruptedAccounts() async {
    final isar = IsarService.isar;
    final ids = await isar.accounts.where().idProperty().findAll();
    final badIds = <int>[];

    for (final id in ids) {
      try {
        await isar.accounts.get(id);
      } catch (_) {
        badIds.add(id);
      }
    }

    if (badIds.isEmpty) return;

    await isar.writeTxn(() async {
      for (final id in badIds) {
        await isar.accounts.delete(id);
      }
    });
  }
}
