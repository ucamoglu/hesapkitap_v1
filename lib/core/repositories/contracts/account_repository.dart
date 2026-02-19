import '../../../models/account.dart';

abstract class AccountRepository {
  Future<void> ensureDefaultCashAccount();
  Future<List<Account>> getAll();
  Future<List<Account>> getActive();
  Future<void> add(Account account);
  Future<void> update(Account account);
  Future<void> setActive(int id, bool value);
  Future<bool> delete(int id);
}
