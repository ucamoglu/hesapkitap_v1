import '../../../models/account.dart';

abstract class AccountRepository {
  // Varsayilan cüzdan hesabinin her zaman mevcut olmasini garanti eder.
  Future<void> ensureDefaultCashAccount();
  // Tum hesaplari dondurur.
  Future<List<Account>> getAll();
  // Yalnizca aktif hesaplari filtreler.
  Future<List<Account>> getActive();
  // Yeni hesap ekler.
  Future<void> add(Account account);
  // Hesap bilgilerini gunceller.
  Future<void> update(Account account);
  // Hesabi aktif/pasif hale getirir.
  Future<void> setActive(int id, bool value);
  // Hesabi is kurallarina gore siler veya pasife alir.
  Future<bool> delete(int id);
}
