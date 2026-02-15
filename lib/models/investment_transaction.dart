import 'package:isar/isar.dart';

part 'investment_transaction.g.dart';

@collection
class InvestmentTransaction {
  Id id = Isar.autoIncrement;

  late int investmentAccountId;

  late int cashAccountId;

  late String symbol; 
  // GOLD, SILVER, USD, EUR

  late String type; 
  // buy / sell

  late double quantity;

  late double unitPrice; 
  // TL bazlı

  late double total; 
  // quantity * unitPrice

  double costBasisTotal = 0;
  // Sell işleminde FIFO maliyet toplamı (TL)

  double realizedPnl = 0;
  // Sell işleminde gerçekleşen kar/zarar (TL)

  late DateTime date;

  late DateTime createdAt;
}
