import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/finance_transaction.dart';
import '../models/investment_transaction.dart';
import '../models/transfer_transaction.dart';

class AccountService {
  static const String _defaultCashName = 'CÜZDAN';
  static const String _defaultCashType = 'cash';
  static const String defaultBalanceName = 'HİBE,İLK KAYIT,DENGE HESABI';
  static const String balanceType = 'balance';
  static const String balanceSystemKey = 'balance_account';
  static const String bankSubtypeBankAccount = 'bank_account';
  static const String bankSubtypeCreditCard = 'credit_card';

  static bool isGhostAccount(Account account) => account.type == balanceType;

  static bool isProtectedBalanceAccount(Account account) =>
      account.isSystemGenerated &&
      account.systemKey == balanceSystemKey &&
      account.type == balanceType;

  static Future<void> _validateAccount(Account account) async {
    final isar = IsarService.isar;
    final name = account.name.trim();
    if (name.isEmpty) {
      throw Exception('Hesap adı zorunludur.');
    }

    final type = account.type.trim().toLowerCase();
    final validTypes = {'cash', 'bank', 'investment', balanceType};
    if (!validTypes.contains(type)) {
      throw Exception('Geçersiz hesap türü.');
    }

    account
      ..name = name
      ..type = type;

    if (type == balanceType) {
      account
        ..bankSubtype = null
        ..overdraftLimit = 0
        ..linkedBankAccountId = null
        ..statementDay = null
        ..paymentDueDay = null
        ..investmentSubtype = null
        ..investmentSymbol = null;
      return;
    }

    if (type == 'cash') {
      account
        ..bankSubtype = null
        ..overdraftLimit = 0
        ..linkedBankAccountId = null
        ..statementDay = null
        ..paymentDueDay = null
        ..investmentSubtype = null
        ..investmentSymbol = null
        ..name = name;
      return;
    }

    if (type == 'bank') {
      final normalizedSubtype = account.effectiveBankSubtype;
      final validBankSubtypes = {
        bankSubtypeBankAccount,
        bankSubtypeCreditCard,
      };
      if (!validBankSubtypes.contains(normalizedSubtype)) {
        throw Exception('Banka hesabı için geçerli alt tür seçiniz.');
      }

      account
        ..bankSubtype = normalizedSubtype
        ..investmentSubtype = null
        ..investmentSymbol = null;

      if (normalizedSubtype == bankSubtypeBankAccount) {
        if (account.overdraftLimit < 0) {
          throw Exception('Ek hesap tutarı negatif olamaz.');
        }
        final currentNegativeUsage = account.balance < 0 ? account.balance.abs() : 0.0;
        if (account.overdraftLimit + 1e-9 < currentNegativeUsage) {
          throw Exception(
            'Ek hesap tutarı, mevcut eksi bakiyeden küçük olamaz. '
            'Önce bakiyeyi azaltın ya da ek hesap limitini yeterli seviyede tutun.',
          );
        }
        account
          ..linkedBankAccountId = null
          ..statementDay = null
          ..paymentDueDay = null;
        return;
      }

      account.overdraftLimit = 0;

      final linkedBankAccountId = account.linkedBankAccountId;
      if (linkedBankAccountId == null) {
        throw Exception('Kredi kartı için bağlı banka hesabı seçiniz.');
      }
      if (account.id != Isar.autoIncrement &&
          linkedBankAccountId == account.id) {
        throw Exception('Kredi kartı kendi kendine bağlanamaz.');
      }

      final statementDay = account.statementDay;
      if (statementDay == null || statementDay < 1 || statementDay > 31) {
        throw Exception('Hesap kesim günü 1-31 arasında olmalıdır.');
      }

      final paymentDueDay = account.paymentDueDay;
      if (paymentDueDay == null || paymentDueDay < 1 || paymentDueDay > 31) {
        throw Exception('Son ödeme günü 1-31 arasında olmalıdır.');
      }

      final linkedAccount = await isar.accounts.get(linkedBankAccountId);
      if (linkedAccount == null ||
          !linkedAccount.isActive ||
          !linkedAccount.isBankAccount) {
        throw Exception(
          'Bağlı hesap, aktif bir banka hesabı olmalıdır.',
        );
      }
      return;
    }

    account
      ..bankSubtype = null
      ..overdraftLimit = 0
      ..linkedBankAccountId = null
      ..statementDay = null
      ..paymentDueDay = null;

    final validSubtypes = {'currency', 'metal', 'stock', 'crypto'};
    final subtype = account.investmentSubtype?.trim();
    if (subtype == null || !validSubtypes.contains(subtype)) {
      throw Exception('Yatırım hesabı için geçerli alt tür seçiniz.');
    }

    final symbol = account.investmentSymbol?.trim().toUpperCase() ?? '';
    if (symbol.isEmpty) {
      throw Exception('Yatırım hesabı için sembol seçiniz.');
    }

    account
      ..name = name
      ..investmentSubtype = subtype
      ..investmentSymbol = symbol;
  }

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

  static Future<void> ensureDefaultBalanceAccount() async {
    final isar = IsarService.isar;
    final allAccounts = await isar.accounts.where().anyId().findAll();
    Account? existing;
    for (final account in allAccounts) {
      if (account.systemKey == balanceSystemKey) {
        existing = account;
        break;
      }
      if (existing == null &&
          account.type == balanceType &&
          account.name == defaultBalanceName) {
        existing = account;
      }
    }

    if (existing == null) {
      final account = Account()
        ..name = defaultBalanceName
        ..type = balanceType
        ..balance = 0
        ..isActive = true
        ..isSystemGenerated = true
        ..systemKey = balanceSystemKey
        ..createdAt = DateTime.now();
      await isar.writeTxn(() async {
        await isar.accounts.put(account);
      });
      return;
    }

    final ensuredAccount = existing;
    await isar.writeTxn(() async {
      ensuredAccount
        ..name = defaultBalanceName
        ..type = balanceType
        ..bankSubtype = null
        ..linkedBankAccountId = null
        ..overdraftLimit = 0
        ..statementDay = null
        ..paymentDueDay = null
        ..investmentSubtype = null
        ..investmentSymbol = null
        ..isActive = true
        ..isSystemGenerated = true
        ..systemKey = balanceSystemKey;
      await isar.accounts.put(ensuredAccount);
    });
  }

  /// Yeni bir hesap kaydini kalici olarak yazar.
  static Future<void> addAccount(Account account) async {
    final isar = IsarService.isar;
    await _validateAccount(account);

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
    final existing = await isar.accounts.get(id);
    if (existing != null && isProtectedBalanceAccount(existing)) {
      throw Exception('DENGE HESABI silinemez.');
    }
    final used = await isAccountUsed(id);
    if (used) {
      final account = existing;
      if (account != null && account.isActive) {
        final hasOpenBalance = account.isCreditCard
            ? account.balance.abs() > 1e-9
            : account.balance > 0;
        if (hasOpenBalance) {
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
    await ensureDefaultBalanceAccount();
    try {
      return await isar.txn(() async {
        return await isar.accounts.where().anyId().findAll();
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

  static bool isCashflowAccount(Account account) {
    return account.type != 'investment' &&
        !account.isCreditCard &&
        !isGhostAccount(account);
  }

  static bool isExpensePaymentAccount(Account account) {
    return account.type != 'investment' && !isGhostAccount(account);
  }

  static bool isGhostSelectableCashflowAccount(Account account) {
    return account.type != 'investment' && !account.isCreditCard;
  }

  static bool isGhostSelectableExpenseAccount(Account account) {
    return account.type != 'investment';
  }

  static List<Account> sortWithGhostLast(Iterable<Account> accounts) {
    final items = accounts.toList();
    items.sort((a, b) {
      final aGhost = isGhostAccount(a);
      final bGhost = isGhostAccount(b);
      if (aGhost != bGhost) {
        return aGhost ? 1 : -1;
      }
      return a.name.compareTo(b.name);
    });
    return items;
  }

  static Future<List<Account>> getActiveCashflowAccounts() async {
    final all = await getActiveAccounts();
    return sortWithGhostLast(all.where(isCashflowAccount));
  }

  static Future<List<Account>> getActiveExpenseAccounts() async {
    final all = await getActiveAccounts();
    return sortWithGhostLast(all.where(isExpensePaymentAccount));
  }

  static Future<List<Account>> getActiveGhostSelectableCashflowAccounts() async {
    final all = await getActiveAccounts();
    return sortWithGhostLast(all.where(isGhostSelectableCashflowAccount));
  }

  static Future<List<Account>> getActiveGhostSelectableExpenseAccounts() async {
    final all = await getActiveAccounts();
    return sortWithGhostLast(all.where(isGhostSelectableExpenseAccount));
  }

  static Future<List<Account>> getActiveParentBankAccounts({
    int? excludeId,
  }) async {
    final all = await getActiveAccounts();
    return sortWithGhostLast(
      all.where((account) => account.isBankAccount && account.id != excludeId),
    );
  }

  /// Hesabin aktiflik durumunu is kurallarina uygun sekilde degistirir.
  static Future<void> setActive(int id, bool value) async {
    final isar = IsarService.isar;
    final account = await isar.accounts.get(id);
    if (account == null) return;
    if (!value && isProtectedBalanceAccount(account)) {
      throw Exception('DENGE HESABI pasif yapılamaz.');
    }
    final hasOpenBalance = account.isCreditCard
        ? account.balance.abs() > 1e-9
        : account.balance > 0;
    if (!value && hasOpenBalance) {
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
    final existing = await isar.accounts.get(account.id);
    if (existing != null && isProtectedBalanceAccount(existing)) {
      final name = account.name.trim();
      if (name.isEmpty) {
        throw Exception('Hesap adı zorunludur.');
      }
      existing
        ..name = name
        ..type = balanceType
        ..isActive = true
        ..isSystemGenerated = true
        ..systemKey = balanceSystemKey;
      await isar.writeTxn(() async {
        await isar.accounts.put(existing);
      });
      return;
    }
    await _validateAccount(account);

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
