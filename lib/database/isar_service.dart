import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/finance_transaction.dart';
import '../models/investment_transaction.dart';
import '../models/income_category.dart';
import '../models/cari_card.dart';
import '../models/cari_transaction.dart';
import '../models/expense_plan.dart';
import '../models/income_plan.dart';
import '../models/transaction_attachment.dart';
import '../models/transfer_transaction.dart';
import '../models/user_profile.dart';
import '../models/tracked_currency.dart';
import '../models/tracked_currency_state.dart';
import '../models/tracked_metal.dart';
import '../models/tracked_metal_state.dart';
import '../models/tracked_stock.dart';
import '../models/tracked_stock_state.dart';
import '../models/tracked_crypto.dart';
import '../models/tracked_crypto_state.dart';

class IsarService {
  static late Isar isar;
  static bool get encryptedAtRest => false;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    for (final name in Isar.instanceNames) {
      await Isar.getInstance(name)?.close();
    }

    isar = await Isar.open(
      [
        AccountSchema,
        CategorySchema,
        FinanceTransactionSchema,
        InvestmentTransactionSchema,
        IncomeCategorySchema,
        CariCardSchema,
        CariTransactionSchema,
        ExpensePlanSchema,
        IncomePlanSchema,
        TransactionAttachmentSchema,
        TransferTransactionSchema,
        UserProfileSchema,
        TrackedCurrencySchema,
        TrackedCurrencyStateSchema,
        TrackedMetalSchema,
        TrackedMetalStateSchema,
        TrackedStockSchema,
        TrackedStockStateSchema,
        TrackedCryptoSchema,
        TrackedCryptoStateSchema,
      ],
      directory: dir.path,
    );
  }

  static Future<void> resetDatabase() async {
    for (final name in Isar.instanceNames) {
      await Isar.getInstance(name)?.close(deleteFromDisk: true);
    }
    await init();
  }
}
