import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../models/credit_card_installment.dart';
import '../models/credit_card_payment.dart';
import '../models/credit_card_statement_adjustment.dart';
import '../models/credit_card_statement.dart';
import '../models/finance_transaction.dart';
import '../models/investment_transaction.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../services/credit_card_installment_service.dart';
import '../services/credit_card_payment_service.dart';
import '../services/credit_card_statement_adjustment_service.dart';
import '../services/credit_card_statement_service.dart';
import '../services/finance_transaction_service.dart';
import '../services/investment_transaction_service.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_money_input_formatter.dart';

class CreditCardStatementsScreen extends StatefulWidget {
  const CreditCardStatementsScreen({super.key});

  @override
  State<CreditCardStatementsScreen> createState() =>
      _CreditCardStatementsScreenState();
}

class _CreditCardStatementsScreenState
    extends State<CreditCardStatementsScreen> {
  static const _selectedAccent = Color(0xFFE38B2C);
  static const _selectedAccentSoft = Color(0xFFFFF1E2);
  bool _loading = true;
  String? _error;
  List<CreditCardStatement> _statements = [];
  Map<int, Account> _accountsById = {};
  Map<String, List<CreditCardInstallment>> _installmentsByStatementKey = {};
  Map<int, FinanceTransaction> _financeById = {};
  Map<int, InvestmentTransaction> _investmentById = {};
  Map<int, Category> _expenseCategoryById = {};
  Map<int, List<CreditCardPayment>> _paymentsByStatementId = {};
  Map<int, List<CreditCardStatementAdjustment>> _adjustmentsByStatementId = {};
  int? _selectedCardAccountId;
  int? _selectedStatementId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        CreditCardStatementService.getAll(),
        AccountService.getAllAccounts(),
        CreditCardInstallmentService.getAll(),
        FinanceTransactionService.getAll(),
        InvestmentTransactionService.getAll(),
        CategoryService.getAllExpenseCategories(),
        AccountService.getActiveParentBankAccounts(),
      ]);
      final statements = results[0] as List<CreditCardStatement>;
      final accounts = results[1] as List<Account>;
      final installments = results[2] as List<CreditCardInstallment>;
      final financeTransactions = results[3] as List<FinanceTransaction>;
      final investmentTransactions = results[4] as List<InvestmentTransaction>;
      final expenseCategories = results[5] as List<Category>;
      final paymentSourceAccounts = results[6] as List<Account>;
      final paymentsByStatementId = <int, List<CreditCardPayment>>{};
      final adjustmentsByStatementId =
          <int, List<CreditCardStatementAdjustment>>{};
      for (final statement in statements) {
        final payments = await CreditCardPaymentService.getByStatementId(
          statement.id,
        );
        paymentsByStatementId[statement.id] = payments;
        final adjustments =
            await CreditCardStatementAdjustmentService.getByStatementId(
          statement.id,
        );
        adjustmentsByStatementId[statement.id] = adjustments;
      }
      if (!mounted) return;
      final installmentsByStatementKey =
          <String, List<CreditCardInstallment>>{};
      for (final installment in installments) {
        final key = _statementKey(
          installment.creditCardAccountId,
          installment.statementDate,
        );
        installmentsByStatementKey.putIfAbsent(key, () => []).add(installment);
      }
      for (final list in installmentsByStatementKey.values) {
        list.sort((a, b) {
          final aOwner =
              a.financeTransactionId ?? a.investmentTransactionId ?? 0;
          final bOwner =
              b.financeTransactionId ?? b.investmentTransactionId ?? 0;
          final ownerCompare = aOwner.compareTo(bOwner);
          if (ownerCompare != 0) return ownerCompare;
          return a.installmentNumber.compareTo(b.installmentNumber);
        });
      }
      setState(() {
        _statements = statements;
        _accountsById = {
          for (final account in accounts.where((a) => a.isCreditCard))
            account.id: account,
        };
        _installmentsByStatementKey = installmentsByStatementKey;
        _financeById = {
          for (final transaction in financeTransactions)
            transaction.id: transaction,
        };
        _investmentById = {
          for (final transaction in investmentTransactions)
            transaction.id: transaction,
        };
        _expenseCategoryById = {
          for (final category in expenseCategories) category.id: category,
        };
        _paymentsByStatementId = paymentsByStatementId;
        _adjustmentsByStatementId = adjustmentsByStatementId;
        for (final account in paymentSourceAccounts) {
          _accountsById[account.id] = account;
        }
        final availableCardIds = statements
            .map((s) => s.creditCardAccountId)
            .toSet()
            .toList()
          ..sort();
        if (availableCardIds.isNotEmpty) {
          final fallbackCardId = availableCardIds.first;
          _selectedCardAccountId =
              availableCardIds.contains(_selectedCardAccountId)
                  ? _selectedCardAccountId
                  : fallbackCardId;
          final cardStatements = _statementsForCard(_selectedCardAccountId!);
          if (cardStatements.isNotEmpty) {
            _selectedStatementId =
                cardStatements.any((s) => s.id == _selectedStatementId)
                    ? _selectedStatementId
                    : cardStatements.first.id;
          } else {
            _selectedStatementId = null;
          }
        } else {
          _selectedCardAccountId = null;
          _selectedStatementId = null;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().contains('Missing TypeSchema in Isar.open')
          ? 'Kredi kartı şeması henüz çalışan oturuma yüklenmemiş. Lütfen bir kez hot restart (R) yapıp tekrar deneyin.'
          : 'Kredi kartı ekstreleri yüklenemedi: $e';
      setState(() {
        _error = message;
        _loading = false;
      });
    }
  }

  String _fmtMoney(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final b = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final fromRight = intPart.length - i;
      b.write(intPart[i]);
      if (fromRight > 1 && fromRight % 3 == 1) b.write('.');
    }
    return '${b.toString()},$decPart';
  }

  String _fmtDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }

  String _fmtQuantity(double value) {
    final fixed = value.toStringAsFixed(4);
    final normalized = fixed.replaceFirst(RegExp(r'([.,]?)0+$'), '');
    final parts = normalized.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '';

    final b = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final fromRight = intPart.length - i;
      b.write(intPart[i]);
      if (fromRight > 1 && fromRight % 3 == 1) b.write('.');
    }
    if (decPart.isEmpty) return b.toString();
    return '${b.toString()},$decPart';
  }

  String _statementKey(int accountId, DateTime statementDate) {
    final day = statementDate.day.toString().padLeft(2, '0');
    final month = statementDate.month.toString().padLeft(2, '0');
    return '$accountId-${statementDate.year}-$month-$day';
  }

  String _lineLabel(CreditCardInstallment installment) {
    final financeId = installment.financeTransactionId;
    final investmentId = installment.investmentTransactionId;
    final finance = financeId == null ? null : _financeById[financeId];
    if (finance != null) {
      return _financeTitle(finance);
    }
    if (financeId != null) {
      return 'Gider #$financeId';
    }
    final investment =
        investmentId == null ? null : _investmentById[investmentId];
    if (investment != null) {
      final symbol = investment.symbol.trim().toUpperCase();
      return 'Yatırım Alışı${symbol.isNotEmpty ? ' • $symbol' : ''}';
    }
    return 'Kart Taksidi';
  }

  String _financeTitle(FinanceTransaction tx) {
    final categoryName = _expenseCategoryById[tx.categoryId]?.name.trim();
    if (categoryName != null && categoryName.isNotEmpty) {
      return categoryName;
    }
    return 'Tek Çekim Gider';
  }

  String? _financeDescription(FinanceTransaction tx) {
    final description = tx.description?.trim();
    if (description == null || description.isEmpty) {
      return null;
    }
    return description;
  }

  String _adjustmentDirectionLabel(String direction) {
    if (direction == CreditCardStatementAdjustmentService.increaseDirection) {
      return 'Ekstreyi artır';
    }
    return 'Ekstreyi azalt';
  }

  String _signedAdjustmentText(CreditCardStatementAdjustment adjustment) {
    final sign = adjustment.direction ==
            CreditCardStatementAdjustmentService.increaseDirection
        ? '+'
        : '-';
    return '$sign${_fmtMoney(adjustment.amount)} TL';
  }

  String _adjustmentTitle(CreditCardStatementAdjustment adjustment) {
    final financeId = adjustment.financeTransactionId;
    if (financeId != null) {
      final finance = _financeById[financeId];
      if (finance != null) {
        return _financeTitle(finance);
      }
    }
    return _adjustmentDirectionLabel(adjustment.direction);
  }

  String _adjustmentDescription(CreditCardStatementAdjustment adjustment) {
    final financeId = adjustment.financeTransactionId;
    if (financeId != null) {
      final finance = _financeById[financeId];
      if (finance != null) {
        return _financeDescription(finance) ?? 'Manuel ekstre düzeltmesi';
      }
    }
    return adjustment.note?.trim().isNotEmpty == true
        ? adjustment.note!.trim()
        : 'Manuel ekstre düzeltmesi';
  }

  List<int> _availableCardIds() {
    final ids = _statements.map((s) => s.creditCardAccountId).toSet().toList()
      ..sort();
    return ids;
  }

  List<CreditCardStatement> _statementsForCard(int cardAccountId) {
    final items = _statements
        .where((s) => s.creditCardAccountId == cardAccountId)
        .toList()
      ..sort((a, b) => a.statementDate.compareTo(b.statementDate));
    return items;
  }

  CreditCardStatement? _selectedStatement() {
    final statementId = _selectedStatementId;
    if (statementId == null) return null;
    for (final statement in _statements) {
      if (statement.id == statementId) return statement;
    }
    return null;
  }

  bool _isWithinStatementPeriod(DateTime value, CreditCardStatement statement) {
    return !value.isBefore(statement.periodStart) &&
        !value.isAfter(statement.periodEnd);
  }

  List<FinanceTransaction> _singleChargeFinanceTransactions(
    CreditCardStatement statement,
    List<CreditCardInstallment> installments,
  ) {
    final installmentFinanceIds = installments
        .map((item) => item.financeTransactionId)
        .whereType<int>()
        .toSet();
    final items = _financeById.values
        .where(
          (tx) =>
              tx.accountId == statement.creditCardAccountId &&
              tx.type == 'expense' &&
              !installmentFinanceIds.contains(tx.id) &&
              _isWithinStatementPeriod(tx.date, statement),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  List<InvestmentTransaction> _singleChargeInvestmentTransactions(
    CreditCardStatement statement,
    List<CreditCardInstallment> installments,
  ) {
    final installmentInvestmentIds = installments
        .map((item) => item.investmentTransactionId)
        .whereType<int>()
        .toSet();
    final items = _investmentById.values
        .where(
          (tx) =>
              tx.cashAccountId == statement.creditCardAccountId &&
              tx.type == 'buy' &&
              !installmentInvestmentIds.contains(tx.id) &&
              _isWithinStatementPeriod(tx.date, statement),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  void _selectCard(int cardAccountId) {
    final cardStatements = _statementsForCard(cardAccountId);
    setState(() {
      _selectedCardAccountId = cardAccountId;
      _selectedStatementId =
          cardStatements.isNotEmpty ? cardStatements.first.id : null;
    });
  }

  void _selectStatement(CreditCardStatement statement) {
    setState(() {
      _selectedCardAccountId = statement.creditCardAccountId;
      _selectedStatementId = statement.id;
    });
  }

  double _remainingAmount(CreditCardStatement statement) {
    return (statement.totalAmount - statement.paidAmount)
        .clamp(0, double.infinity)
        .toDouble();
  }

  Widget _statusBadge(CreditCardStatement statement) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _statementStatusColor(statement).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statementStatus(statement),
        style: TextStyle(
          color: _statementStatusColor(statement),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCardSummaryTab() {
    final cardIds = _availableCardIds();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cardIds.length,
      itemBuilder: (context, index) {
        final cardId = cardIds[index];
        final account = _accountsById[cardId];
        final statements = _statementsForCard(cardId);
        final totalRemaining = statements.fold<double>(
          0,
          (sum, item) => sum + _remainingAmount(item),
        );
        final latestStatement = statements.isNotEmpty ? statements.first : null;
        final selected = cardId == _selectedCardAccountId;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: selected ? _selectedAccentSoft : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: selected
                  ? _selectedAccent.withValues(alpha: 0.6)
                  : Colors.black12,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _selectCard(cardId),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          account?.name ?? 'Kredi Kartı #$cardId',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle, color: _selectedAccent),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _summaryChip(
                        label: 'Toplam Borç',
                        value: '${_fmtMoney(totalRemaining)} TL',
                      ),
                      _summaryChip(
                        label: 'Dönem',
                        value: '${statements.length}',
                      ),
                      _summaryChip(
                        label: 'Açık Dönem',
                        value:
                            '${statements.where((s) => _remainingAmount(s) > 1e-9).length}',
                      ),
                    ],
                  ),
                  if (latestStatement != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Son dönem: ${_fmtDate(latestStatement.periodStart)} - ${_fmtDate(latestStatement.periodEnd)}',
                    ),
                    Text(
                      'Son ödeme: ${_fmtDate(latestStatement.dueDate)}',
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodsTab() {
    final cardId = _selectedCardAccountId;
    if (cardId == null) {
      return const Center(child: Text('Gösterilecek kart bulunamadı.'));
    }
    final cardStatements = _statementsForCard(cardId);
    final account = _accountsById[cardId];
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _selectedAccentSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _selectedAccent.withValues(alpha: 0.35)),
          ),
          child: Text(
            'Seçili Kart: ${account?.name ?? 'Kredi Kartı #$cardId'}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cardStatements.length,
            itemBuilder: (context, index) {
              final statement = cardStatements[index];
              final selected = statement.id == _selectedStatementId;
              final payments = _paymentsByStatementId[statement.id] ??
                  const <CreditCardPayment>[];
              final adjustments = _adjustmentsByStatementId[statement.id] ??
                  const <CreditCardStatementAdjustment>[];
              final installments = _installmentsByStatementKey[_statementKey(
                    statement.creditCardAccountId,
                    statement.statementDate,
                  )] ??
                  const <CreditCardInstallment>[];
              final installmentTotal = installments.fold<double>(
                0,
                (sum, item) => sum + item.amount,
              );
              final singleChargeTotal =
                  (statement.totalAmount - installmentTotal)
                      .clamp(0, double.infinity)
                      .toDouble();
              final remaining = _remainingAmount(statement);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: selected ? _selectedAccentSoft : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: selected
                        ? _selectedAccent.withValues(alpha: 0.75)
                        : Colors.black12,
                    width: selected ? 1.8 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _selectStatement(statement),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Dönem: ${_fmtDate(statement.periodStart)} - ${_fmtDate(statement.periodEnd)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (selected) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle,
                                  color: _selectedAccent),
                            ],
                            _statusBadge(statement),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Kesim: ${_fmtDate(statement.statementDate)}'),
                        Text('Son Ödeme: ${_fmtDate(statement.dueDate)}'),
                        const SizedBox(height: 8),
                        Text(
                            'Ekstre Tutarı: ${_fmtMoney(statement.totalAmount)} TL'),
                        Text('Ödenen: ${_fmtMoney(statement.paidAmount)} TL'),
                        Text(
                          'Kalan Borç: ${_fmtMoney(remaining)} TL',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (selected)
                              _summaryChip(
                                label: 'Seçim',
                                value: 'Aktif',
                              ),
                            _summaryChip(
                              label: 'Taksitli',
                              value: '${_fmtMoney(installmentTotal)} TL',
                            ),
                            _summaryChip(
                              label: 'Tek Çekim',
                              value: '${_fmtMoney(singleChargeTotal)} TL',
                            ),
                            _summaryChip(
                              label: 'Hareket',
                              value:
                                  '${installments.length + payments.length + adjustments.length}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (remaining > 1e-9)
                              OutlinedButton.icon(
                                onPressed: () => _showPaymentSheet(statement),
                                icon: const Icon(
                                  Icons.account_balance_wallet_outlined,
                                ),
                                label: const Text('Ödeme Yap'),
                              ),
                            if (remaining > 1e-9) const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () => _showAdjustmentSheet(statement),
                              icon: const Icon(Icons.tune),
                              label: const Text('Fark İşle'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovementsTab() {
    final statement = _selectedStatement();
    if (statement == null) {
      return const Center(
          child: Text('Hareket görmek için bir dönem seçiniz.'));
    }
    final account = _accountsById[statement.creditCardAccountId];
    final installments = _installmentsByStatementKey[_statementKey(
          statement.creditCardAccountId,
          statement.statementDate,
        )] ??
        const <CreditCardInstallment>[];
    final singleChargeFinance =
        _singleChargeFinanceTransactions(statement, installments);
    final singleChargeInvestments =
        _singleChargeInvestmentTransactions(statement, installments);
    final payments =
        _paymentsByStatementId[statement.id] ?? const <CreditCardPayment>[];
    final adjustments = _adjustmentsByStatementId[statement.id] ??
        const <CreditCardStatementAdjustment>[];

    final movementTiles = <Widget>[
      for (final tx in singleChargeFinance)
        _movementRow(
          color: Colors.redAccent,
          dateText: _fmtDate(tx.date),
          category: _financeTitle(tx),
          description: _financeDescription(tx) ?? 'Tek çekim gider yansıması',
          trailing: '+${_fmtMoney(tx.amount)} TL',
        ),
      for (final tx in singleChargeInvestments)
        _movementRow(
          color: Colors.blueAccent,
          dateText: _fmtDate(tx.date),
          category: 'Yatırım',
          description:
              '${tx.symbol.trim().toUpperCase()} • ${_fmtQuantity(tx.quantity)} adet',
          trailing: '+${_fmtMoney(tx.total)} TL',
        ),
      for (final installment in installments)
        _movementRow(
          color: Colors.deepPurple,
          dateText: _fmtDate(installment.installmentDate),
          category: _lineLabel(installment),
          description:
              'Taksit ${installment.installmentNumber}/${installment.installmentCount}',
          trailing: '+${_fmtMoney(installment.amount)} TL',
        ),
      for (final payment in payments)
        _movementRow(
          color: Colors.green,
          dateText: _fmtDate(payment.paymentDate),
          category: 'Kart Ödemesi',
          description:
              '${_accountsById[payment.bankAccountId]?.name ?? 'Banka #${payment.bankAccountId}'}${payment.note?.trim().isNotEmpty == true ? ' • ${payment.note!.trim()}' : ''}',
          trailing: '-${_fmtMoney(payment.amount)} TL',
        ),
      for (final adjustment in adjustments)
        _movementRow(
          color: Colors.amber.shade800,
          dateText: _fmtDate(adjustment.adjustmentDate),
          category: _adjustmentTitle(adjustment),
          description: _adjustmentDescription(adjustment),
          trailing: _signedAdjustmentText(adjustment),
        ),
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account?.name ??
                    'Kredi Kartı #${statement.creditCardAccountId}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Seçili Dönem: ${_fmtDate(statement.periodStart)} - ${_fmtDate(statement.periodEnd)}',
              ),
              Text('Kesim: ${_fmtDate(statement.statementDate)}'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (movementTiles.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Bu döneme ait hareket bulunmuyor.',
              textAlign: TextAlign.center,
            ),
          )
        else
          ...movementTiles,
      ],
    );
  }

  Widget _movementRow({
    required Color color,
    required String dateText,
    required String category,
    required String description,
    required String trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(
            dateText,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 15),
                children: [
                  TextSpan(
                    text: category,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' • '),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            trailing,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: bold),
    );

    pw.Widget infoRow(String label, String value, {bool strong = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 92,
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  font: strong ? bold : font,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                value,
                style: pw.TextStyle(font: strong ? bold : font),
              ),
            ),
          ],
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          final selectedStatement = _selectedStatement();
          final statementsForReport = selectedStatement != null
              ? <CreditCardStatement>[selectedStatement]
              : _statements;
          final widgets = <pw.Widget>[
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(_selectedAccentSoft.toARGB32()),
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(
                  color: PdfColor.fromInt(_selectedAccent.toARGB32()),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Kredi Kartı Hesap Ekstresi',
                        style: pw.TextStyle(font: bold, fontSize: 18),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Rapor Tarihi: ${_fmtDate(DateTime.now())}'),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(_selectedAccent.toARGB32()),
                      borderRadius: pw.BorderRadius.circular(999),
                    ),
                    child: pw.Text(
                      'HesapKitap',
                      style: pw.TextStyle(
                        font: bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
          ];

          for (final statement in statementsForReport) {
            final account = _accountsById[statement.creditCardAccountId];
            final payments = _paymentsByStatementId[statement.id] ??
                const <CreditCardPayment>[];
            final adjustments = _adjustmentsByStatementId[statement.id] ??
                const <CreditCardStatementAdjustment>[];
            final installments = _installmentsByStatementKey[_statementKey(
                  statement.creditCardAccountId,
                  statement.statementDate,
                )] ??
                const <CreditCardInstallment>[];
            final installmentTotal = installments.fold<double>(
              0,
              (sum, item) => sum + item.amount,
            );
            final singleChargeTotal = (statement.totalAmount - installmentTotal)
                .clamp(0, double.infinity)
                .toDouble();
            final remaining = (statement.totalAmount - statement.paidAmount)
                .clamp(0, double.infinity)
                .toDouble();
            final movementRows = <List<String>>[
              ...installments.map(
                (installment) => [
                  _fmtDate(installment.installmentDate),
                  _lineLabel(installment),
                  'Taksit ${installment.installmentNumber}/${installment.installmentCount}',
                  '+${_fmtMoney(installment.amount)} TL',
                ],
              ),
              ...payments.map((payment) {
                final bankAccount = _accountsById[payment.bankAccountId];
                final note = payment.note?.trim();
                return [
                  _fmtDate(payment.paymentDate),
                  'Kart Ödemesi',
                  '${bankAccount?.name ?? 'Banka'}${note != null && note.isNotEmpty ? ' • $note' : ''}',
                  '-${_fmtMoney(payment.amount)} TL',
                ];
              }),
              ...adjustments.map((adjustment) => [
                    _fmtDate(adjustment.adjustmentDate),
                    _adjustmentTitle(adjustment),
                    _adjustmentDescription(adjustment),
                    _signedAdjustmentText(adjustment),
                  ]),
            ];

            widgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 14),
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      account?.name ??
                          'Kredi Kartı #${statement.creditCardAccountId}',
                      style: pw.TextStyle(font: bold, fontSize: 15),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          infoRow(
                            'Dönem',
                            '${_fmtDate(statement.periodStart)} - ${_fmtDate(statement.periodEnd)}',
                            strong: true,
                          ),
                          infoRow('Kesim', _fmtDate(statement.statementDate)),
                          infoRow('Son Ödeme', _fmtDate(statement.dueDate)),
                          infoRow(
                            'Durum',
                            _statementStatus(statement),
                          ),
                          infoRow(
                            'Ekstre Tutarı',
                            '${_fmtMoney(statement.totalAmount)} TL',
                          ),
                          infoRow(
                            'Ödenen',
                            '${_fmtMoney(statement.paidAmount)} TL',
                          ),
                          infoRow(
                            'Kalan Borç',
                            '${_fmtMoney(remaining)} TL',
                            strong: true,
                          ),
                          infoRow(
                            'Taksitli',
                            '${_fmtMoney(installmentTotal)} TL',
                          ),
                          infoRow(
                            'Tek Çekim',
                            '${_fmtMoney(singleChargeTotal)} TL',
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Dönem Hareketleri',
                      style: pw.TextStyle(font: bold, fontSize: 12),
                    ),
                    pw.SizedBox(height: 6),
                    if (movementRows.isEmpty)
                      pw.Text('Bu döneme ait hareket bulunmuyor.')
                    else
                      pw.TableHelper.fromTextArray(
                        headers: const [
                          'Tarih',
                          'Kategori',
                          'Açıklama',
                          'Tutar'
                        ],
                        data: movementRows,
                        headerStyle: pw.TextStyle(
                          font: bold,
                          fontSize: 9,
                          color: PdfColors.white,
                        ),
                        cellStyle: pw.TextStyle(font: font, fontSize: 8),
                        headerDecoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(_selectedAccent.toARGB32()),
                        ),
                        cellAlignment: pw.Alignment.centerLeft,
                        headerAlignment: pw.Alignment.centerLeft,
                        border: pw.TableBorder.all(color: PdfColors.grey300),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1.1),
                          1: const pw.FlexColumnWidth(1.6),
                          2: const pw.FlexColumnWidth(2.7),
                          3: const pw.FlexColumnWidth(1.1),
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          return widgets;
        },
      ),
    );

    return doc.save();
  }

  void _openPdfPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          drawer: buildAppMenuDrawer(),
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('PDF Rapor'),
            actions: [buildHomeAction(context)],
          ),
          body: PdfPreview(
            build: _buildPdf,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowSharing: true,
            allowPrinting: true,
            pdfFileName: 'kredi_karti_ekstreleri.pdf',
          ),
        ),
      ),
    );
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _statementStatus(CreditCardStatement statement) {
    final today = _dateOnly(DateTime.now());
    final start = _dateOnly(statement.periodStart);
    final end = _dateOnly(statement.periodEnd);

    if (today.isBefore(start)) {
      return 'Gelecek Dönem';
    }
    if (today.isAfter(end)) {
      return 'Pasif Dönem';
    }
    return 'Aktif Dönem';
  }

  Color _statementStatusColor(CreditCardStatement statement) {
    final status = _statementStatus(statement);
    if (status == 'Aktif Dönem') return Colors.redAccent;
    if (status == 'Gelecek Dönem') return Colors.indigo;
    return Colors.black54;
  }

  Future<void> _showPaymentSheet(CreditCardStatement statement) async {
    final cardAccount = _accountsById[statement.creditCardAccountId];
    if (cardAccount == null) return;
    final paymentAccounts = await AccountService.getActiveParentBankAccounts();
    if (!mounted) return;

    final amountController = TextEditingController();
    final noteController = TextEditingController();
    int? selectedBankAccountId =
        paymentAccounts.any((a) => a.id == cardAccount.linkedBankAccountId)
            ? cardAccount.linkedBankAccountId
            : (paymentAccounts.isNotEmpty ? paymentAccounts.first.id : null);
    DateTime paymentDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: paymentDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked == null) return;
              setState(() {
                paymentDate = picked;
              });
            }

            final remaining = (statement.totalAmount - statement.paidAmount)
                .clamp(0, double.infinity)
                .toDouble();
            return AlertDialog(
              title: const Text('Ekstre Ödeme'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Kalan borç: ${_fmtMoney(remaining)} TL',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: selectedBankAccountId,
                      items: paymentAccounts
                          .map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(
                                '${a.name} • ${_fmtMoney(a.balance)} TL',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBankAccountId = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Ödeme Hesabı',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: const [TurkishMoneyInputFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Ödeme Tutarı',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ödeme Tarihi',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_fmtDate(paymentDate)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Not (opsiyonel)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: paymentAccounts.isEmpty
                      ? null
                      : () async {
                          final amount = TurkishMoneyInputFormatter.parse(
                            amountController.text,
                          );
                          if (selectedBankAccountId == null) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ödeme hesabı seçiniz.'),
                              ),
                            );
                            return;
                          }
                          if (amount == null || amount <= 0) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Geçerli bir ödeme tutarı giriniz.'),
                              ),
                            );
                            return;
                          }
                          try {
                            await CreditCardPaymentService.payStatement(
                              statementId: statement.id,
                              bankAccountId: selectedBankAccountId!,
                              amount: amount,
                              paymentDate: paymentDate,
                              note: noteController.text,
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            await _load();
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Ekstre ödemesi kaydedildi.'),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text('Ödeme hatası: $e')),
                            );
                          }
                        },
                  child: const Text('Öde'),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
    noteController.dispose();
  }

  Future<void> _showAdjustmentSheet(CreditCardStatement statement) async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    var direction = CreditCardStatementAdjustmentService.increaseDirection;
    DateTime adjustmentDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: dialogContext,
                initialDate: adjustmentDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked == null) return;
              setState(() {
                adjustmentDate = picked;
              });
            }

            return AlertDialog(
              title: const Text('Ekstre Fark İşle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Banka ekstresi ile uygulamadaki ekstre arasında fark varsa bu ekrana manuel düzeltme girebilirsiniz.',
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: direction,
                      items: const [
                        DropdownMenuItem(
                          value: 'increase',
                          child: Text('Bankada daha yüksek'),
                        ),
                        DropdownMenuItem(
                          value: 'decrease',
                          child: Text('Bankada daha düşük'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          direction = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Fark Yönü',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: const [TurkishMoneyInputFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Fark Tutarı',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Düzeltme Tarihi',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_fmtDate(adjustmentDate)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Sebep / Not',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amount = TurkishMoneyInputFormatter.parse(
                      amountController.text,
                    );
                    if (amount == null || amount <= 0) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Geçerli bir fark tutarı giriniz.'),
                        ),
                      );
                      return;
                    }
                    try {
                      await CreditCardStatementAdjustmentService.addAdjustment(
                        statementId: statement.id,
                        amount: amount,
                        direction: direction,
                        adjustmentDate: adjustmentDate,
                        note: noteController.text,
                      );
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      await _load();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ekstre farkı işlendi.'),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Düzeltme hatası: $e')),
                      );
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: buildAppMenuDrawer(),
        appBar: AppBar(
          leading: buildMenuLeading(),
          title: const Text('Kredi Kartı Ekstreleri'),
          actions: [
            if (!_loading && _error == null && _statements.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: 'PDF',
                onPressed: _openPdfPreview,
              ),
            buildHomeAction(context),
          ],
          bottom: (!_loading && _error == null && _statements.isNotEmpty)
              ? const TabBar(
                  tabs: [
                    Tab(text: 'Kartlar'),
                    Tab(text: 'Dönemler'),
                    Tab(text: 'Hareketler'),
                  ],
                )
              : null,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _statements.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Henüz oluşmuş kredi kartı ekstresi yok.\nKredi kartıyla gider kaydı yaptığınızda burada listelenecek.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : TabBarView(
                        children: [
                          _buildCardSummaryTab(),
                          _buildPeriodsTab(),
                          _buildMovementsTab(),
                        ],
                      ),
      ),
    );
  }

  Widget _summaryChip({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
