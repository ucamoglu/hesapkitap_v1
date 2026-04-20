import 'dart:typed_data';

import 'package:flutter/material.dart';

class DashboardViewData {
  final int totalAccounts;
  final int cashBankAccounts;
  final int investmentAccounts;
  final double totalBalance;
  final double cashTotal;
  final double bankTotal;
  final double investmentCurrentTotal;
  final double activeAssetTotal;
  final bool hasMissingInvestmentPrice;
  final double cariReceivableTotal;
  final double cariDebtTotal;
  final double cariNetTotal;
  final List<TrackedQuoteRow> trackedQuotes;
  final double plannedIncomeTotal;
  final double plannedExpenseTotal;
  final List<TodayPlanRow> todayPlans;
  final List<AccountPreviewRow> cashPreviewRows;
  final List<AccountPreviewRow> bankPreviewRows;
  final List<AccountPreviewRow> investmentPreviewRows;
  final List<AccountPreviewRow> assetPreviewRows;
  final int activeSubscriptionCount;
  final int dueSubscriptionCount;
  final List<SubscriptionReminderRow> subscriptionPreviewRows;
  final List<CariPreviewRow> cariPreviewRows;
  final String profileName;
  final Uint8List? profilePhoto;

  const DashboardViewData({
    required this.totalAccounts,
    required this.cashBankAccounts,
    required this.investmentAccounts,
    required this.totalBalance,
    required this.cashTotal,
    required this.bankTotal,
    required this.investmentCurrentTotal,
    required this.activeAssetTotal,
    required this.hasMissingInvestmentPrice,
    required this.cariReceivableTotal,
    required this.cariDebtTotal,
    required this.cariNetTotal,
    required this.trackedQuotes,
    required this.plannedIncomeTotal,
    required this.plannedExpenseTotal,
    required this.todayPlans,
    required this.cashPreviewRows,
    required this.bankPreviewRows,
    required this.investmentPreviewRows,
    required this.assetPreviewRows,
    required this.activeSubscriptionCount,
    required this.dueSubscriptionCount,
    required this.subscriptionPreviewRows,
    required this.cariPreviewRows,
    required this.profileName,
    required this.profilePhoto,
  });

  factory DashboardViewData.initial() {
    return const DashboardViewData(
      totalAccounts: 0,
      cashBankAccounts: 0,
      investmentAccounts: 0,
      totalBalance: 0,
      cashTotal: 0,
      bankTotal: 0,
      investmentCurrentTotal: 0,
      activeAssetTotal: 0,
      hasMissingInvestmentPrice: false,
      cariReceivableTotal: 0,
      cariDebtTotal: 0,
      cariNetTotal: 0,
      trackedQuotes: <TrackedQuoteRow>[],
      plannedIncomeTotal: 0,
      plannedExpenseTotal: 0,
      todayPlans: <TodayPlanRow>[],
      cashPreviewRows: <AccountPreviewRow>[],
      bankPreviewRows: <AccountPreviewRow>[],
      investmentPreviewRows: <AccountPreviewRow>[],
      assetPreviewRows: <AccountPreviewRow>[],
      activeSubscriptionCount: 0,
      dueSubscriptionCount: 0,
      subscriptionPreviewRows: <SubscriptionReminderRow>[],
      cariPreviewRows: <CariPreviewRow>[],
      profileName: 'Kullanıcı Profili',
      profilePhoto: null,
    );
  }
}

class TrackedQuoteRow {
  final String market;
  final String code;
  final String name;
  final double? sell;

  const TrackedQuoteRow({
    required this.market,
    required this.code,
    required this.name,
    required this.sell,
  });
}

class AccountPreviewRow {
  final String name;
  final String? summaryName;
  final String valueText;
  final String? subtitle;
  final String? groupLabel;
  final Color color;

  const AccountPreviewRow({
    required this.name,
    this.summaryName,
    required this.valueText,
    required this.color,
    this.subtitle,
    this.groupLabel,
  });
}

class CariPreviewRow {
  final String ownerName;
  final String currencyLabel;
  final double net;

  const CariPreviewRow({
    required this.ownerName,
    required this.currencyLabel,
    required this.net,
  });
}

class TodayPlanRow {
  final String typeLabel;
  final double amount;
  final DateTime dueDate;
  final String description;
  final Color color;
  final String statusLabel;
  final Color statusColor;

  const TodayPlanRow({
    required this.typeLabel,
    required this.amount,
    required this.dueDate,
    required this.description,
    required this.color,
    required this.statusLabel,
    required this.statusColor,
  });
}

class SubscriptionReminderRow {
  final String title;
  final String caption;
  final String dateLabel;
  final DateTime reminderDate;
  final bool isDue;

  const SubscriptionReminderRow({
    required this.title,
    required this.caption,
    required this.dateLabel,
    required this.reminderDate,
    required this.isDue,
  });
}
