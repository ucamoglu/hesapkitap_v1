import '../../../models/account.dart';
import '../../../services/account_service.dart';
import '../contracts/account_repository.dart';

class LocalAccountRepository implements AccountRepository {
  const LocalAccountRepository();

  @override
  Future<void> add(Account account) {
    return AccountService.addAccount(account);
  }

  @override
  Future<bool> delete(int id) {
    return AccountService.deleteAccount(id);
  }

  @override
  Future<void> ensureDefaultCashAccount() {
    return AccountService.ensureDefaultCashAccount();
  }

  @override
  Future<List<Account>> getActive() {
    return AccountService.getActiveAccounts();
  }

  @override
  Future<List<Account>> getAll() {
    return AccountService.getAllAccounts();
  }

  @override
  Future<void> setActive(int id, bool value) {
    return AccountService.setActive(id, value);
  }

  @override
  Future<void> update(Account account) {
    return AccountService.updateAccount(account);
  }
}
