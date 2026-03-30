import '../../../models/account.dart';
import '../../../services/account_service.dart';
import '../../sync/sync_change_tracker.dart';
import '../contracts/account_repository.dart';

class LocalAccountRepository implements AccountRepository {
  LocalAccountRepository({
    SyncChangeTracker? changeTracker,
  }) : _changeTracker = changeTracker ?? SyncChangeTracker();

  final SyncChangeTracker _changeTracker;

  @override
  Future<void> add(Account account) async {
    await AccountService.addAccount(account);
    await _changeTracker.markUpsert(
      entityType: 'account',
      localId: account.id,
    );
  }

  @override
  Future<bool> delete(int id) async {
    final deleted = await AccountService.deleteAccount(id);
    if (deleted) {
      await _changeTracker.markDelete(
        entityType: 'account',
        localId: id,
      );
    } else {
      await _changeTracker.markUpsert(
        entityType: 'account',
        localId: id,
      );
    }
    return deleted;
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
  Future<void> setActive(int id, bool value) async {
    await AccountService.setActive(id, value);
    await _changeTracker.markUpsert(
      entityType: 'account',
      localId: id,
    );
  }

  @override
  Future<void> update(Account account) async {
    await AccountService.updateAccount(account);
    await _changeTracker.markUpsert(
      entityType: 'account',
      localId: account.id,
    );
  }
}
