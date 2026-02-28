import 'package:flutter/material.dart';

import 'income_expense_transactions_screen.dart';

class CariTransactionsScreen extends StatelessWidget {
  const CariTransactionsScreen({super.key});

  @override
  // Cari hareketler bu rotada tam ekran detay yerine ilgili hesap ekranina acilir.
  Widget build(BuildContext context) {
    return const IncomeExpenseTransactionsScreen(
      onlyCariTransactions: true,
      screenTitle: 'Cari Kart İşlemleri',
    );
  }
}
