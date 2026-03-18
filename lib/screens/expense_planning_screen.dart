import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../models/expense_plan.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../services/expense_plan_service.dart';
import '../theme/app_colors.dart';
import '../utils/navigation_helpers.dart';
import '../utils/planning_standard.dart';
import '../utils/turkish_money_input_formatter.dart';
import '../utils/turkish_upper_case_formatter.dart';

class ExpensePlanningScreen extends StatefulWidget {
  const ExpensePlanningScreen({super.key});

  @override
  State<ExpensePlanningScreen> createState() => _ExpensePlanningScreenState();
}

class _ExpensePlanningScreenState extends State<ExpensePlanningScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _askingDue = false;
  bool _dueCheckDone = false;
  bool _formExpanded = true;

  List<Account> _accounts = [];
  List<Category> _categories = [];
  List<ExpensePlan> _plans = [];

  int? _selectedAccountId;
  int? _selectedCategoryId;
  String _recurrencePreset = 'monthly';
  String _periodType = 'monthly';
  int _frequency = 1;
  int _reminderMinutesBefore = 10;
  DateTime _startDate = DateTime.now();
  int _selectedWeekday = DateTime.now().weekday;
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime? _endDate;
  int? _initialAccountId;
  int? _initialCategoryId;
  String _initialRecurrencePreset = 'monthly';
  String _initialPeriodType = 'monthly';
  int _initialFrequency = 1;
  int _initialReminderMinutesBefore = 10;
  DateTime? _initialStartDate;
  int? _initialSelectedWeekday;
  TimeOfDay? _initialSelectedTime;
  DateTime? _initialEndDate;
  String _initialAmountText = '';
  String _initialDescText = '';
  bool _initialFormExpanded = true;
  bool _draftBaselineInitialized = false;

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Plan, hesap ve kategori verilerini yukleyip gerekiyorsa bugunluk kontrol yapar.
  Future<void> _load({bool checkDue = false}) async {
    setState(() => _loading = true);

    await CategoryService.seedExpenseDefaultsIfEmpty();

    final accounts = await AccountService.getActiveCashflowAccounts();
    final categories = await CategoryService.getActiveManualExpenseCategories();
    final plans = await ExpensePlanService.getAll();

    if (!mounted) return;
    setState(() {
      _accounts = accounts;
      _categories = categories;
      _plans = plans;
      _selectedAccountId = accounts.isNotEmpty
          ? (_selectedAccountId ?? accounts.first.id)
          : null;
      _selectedCategoryId = categories.isNotEmpty
          ? (_selectedCategoryId ?? categories.first.id)
          : null;
      if (!_draftBaselineInitialized) {
        _captureDraftBaseline();
        _draftBaselineInitialized = true;
      }
      _loading = false;
    });

    if (checkDue && !_dueCheckDone) {
      _dueCheckDone = true;
      _checkDuePlans();
    }
  }

  void _captureDraftBaseline() {
    _initialAccountId = _selectedAccountId;
    _initialCategoryId = _selectedCategoryId;
    _initialRecurrencePreset = _recurrencePreset;
    _initialPeriodType = _periodType;
    _initialFrequency = _frequency;
    _initialReminderMinutesBefore = _reminderMinutesBefore;
    _initialStartDate = _startDate;
    _initialSelectedWeekday = _selectedWeekday;
    _initialSelectedTime = _selectedTime;
    _initialEndDate = _endDate;
    _initialAmountText = _amountController.text;
    _initialDescText = _descController.text;
    _initialFormExpanded = _formExpanded;
  }

  bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _sameTime(TimeOfDay? a, TimeOfDay? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.hour == b.hour && a.minute == b.minute;
  }

  bool _hasUnsavedDraft() {
    if (_loading) return false;
    return _selectedAccountId != _initialAccountId ||
        _selectedCategoryId != _initialCategoryId ||
        _recurrencePreset != _initialRecurrencePreset ||
        _periodType != _initialPeriodType ||
        _frequency != _initialFrequency ||
        _reminderMinutesBefore != _initialReminderMinutesBefore ||
        !_sameDay(_startDate, _initialStartDate) ||
        _selectedWeekday != _initialSelectedWeekday ||
        !_sameTime(_selectedTime, _initialSelectedTime) ||
        !_sameDay(_endDate, _initialEndDate) ||
        _amountController.text.trim() != _initialAmountText.trim() ||
        _descController.text.trim() != _initialDescText.trim() ||
        _formExpanded != _initialFormExpanded;
  }

  Future<bool> _confirmDiscardDraft() async {
    if (!_hasUnsavedDraft()) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Taslak Kaydedilmedi'),
        content: const Text(
          'Yeni plan formundaki değişiklikler kaybolacak. Çıkmak istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çık'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handleExitToDashboard() async {
    final shouldLeave = await _confirmDiscardDraft();
    if (!mounted || !shouldLeave) return;
    popToDashboard(context);
  }

  // Vadesi gelen gider planlari icin kullanicidan tamamla/ertele/iptal karari alir.
  Future<void> _checkDuePlans() async {
    if (_askingDue) return;

    final due = await ExpensePlanService.getDuePlans(DateTime.now());
    if (!mounted || due.isEmpty) return;

    _askingDue = true;
    try {
      for (final plan in due) {
        if (!mounted) break;
        await _askForDuePlan(plan);
      }
    } finally {
      _askingDue = false;
      if (mounted) {
        await _load();
      }
    }
  }

  Future<void> _askForDuePlan(ExpensePlan plan) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Gider Planı Hatırlatma'),
          content: Text(
            '"${_categoryName(plan.expenseCategoryId)}" planı bugün için bekliyor.\n'
            'Tutar: ${_fmtAmount(plan.amount)} TL\n'
            'Hesap: ${_accountName(plan.accountId)}\n\n'
            'Bu gider gerçekleşti mi?',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked == null) return;
                await ExpensePlanService.postpone(plan, picked);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Şu tarihe ertele'),
            ),
            TextButton(
              onPressed: () async {
                await ExpensePlanService.cancel(plan);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('İptal Et'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expense,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await ExpensePlanService.markCompleted(plan);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Evet, Gerçekleşti'),
            ),
          ],
        );
      },
    );
  }

  // Baslangic veya bitis tarihi secimini ayni helper ile yonetir.
  Future<void> _pickDate({required bool start}) async {
    final current = start ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  // Hatirlatma saatini form state'ine yazar.
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked == null) return;
    setState(() => _selectedTime = picked);
  }

  DateTime _nextWeekdayDate(int weekday, DateTime from) {
    final base = DateTime(from.year, from.month, from.day);
    final offset = (weekday - base.weekday + 7) % 7;
    return base.add(Duration(days: offset));
  }

  DateTime _buildPlanStartDate() {
    if (_periodType == 'weekly') {
      return _nextWeekdayDate(_selectedWeekday, _startDate);
    }
    if (_periodType == 'daily') {
      return DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
    }
    return DateTime(_startDate.year, _startDate.month, _startDate.day);
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  String _fmtTime(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _weekdayLabel(int weekday) {
    if (weekday == DateTime.monday) return 'Pazartesi';
    if (weekday == DateTime.tuesday) return 'Salı';
    if (weekday == DateTime.wednesday) return 'Çarşamba';
    if (weekday == DateTime.thursday) return 'Perşembe';
    if (weekday == DateTime.friday) return 'Cuma';
    if (weekday == DateTime.saturday) return 'Cumartesi';
    return 'Pazar';
  }

  String _fmtAmount(double value) {
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

  String _planSummary(ExpensePlan plan) {
    return PlanningStandard.planSummary(
      periodType: plan.periodType,
      frequency: plan.frequency,
      reminderMinutesBefore: plan.reminderMinutesBefore,
    );
  }

  List<DateTime> _previewDatesForForm() {
    return PlanningStandard.previewDates(
      startDate: _buildPlanStartDate(),
      periodType: _periodType,
      frequency:
          _periodType == 'monthly' || _periodType == 'yearly' ? _frequency : 1,
      endDate: _endDate,
    );
  }

  List<DateTime> _datesToPersist() {
    final startDate = _buildPlanStartDate();
    if (_endDate == null || _periodType == 'once') {
      return [startDate];
    }

    return PlanningStandard.previewDates(
      startDate: startDate,
      periodType: _periodType,
      frequency:
          _periodType == 'monthly' || _periodType == 'yearly' ? _frequency : 1,
      endDate: _endDate,
      maxCount: 1000,
    );
  }

  List<DateTime> _previewDatesForPlan(ExpensePlan plan) {
    return PlanningStandard.previewDates(
      startDate: plan.startDate,
      periodType: plan.periodType,
      frequency: plan.frequency,
      endDate: plan.endDate,
    );
  }

  Widget _buildPreviewWrap(List<DateTime> dates) {
    if (dates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: dates
          .map(
            (date) => Chip(
              visualDensity: VisualDensity.compact,
              label: Text(_fmtDate(date)),
            ),
          )
          .toList(),
    );
  }

  void _applyRecurrencePreset(String preset) {
    _recurrencePreset = preset;
    if (preset == 'custom') {
      if (_periodType == 'once') {
        _periodType = 'monthly';
      }
      return;
    }

    _periodType = preset;
    _frequency = 1;
    _reminderMinutesBefore = preset == 'daily' ? 10 : 0;
    if (preset == 'weekly') {
      _selectedWeekday = _startDate.weekday;
    } else if (preset == 'daily') {
      _selectedTime = TimeOfDay.fromDateTime(_buildPlanStartDate());
    }
  }

  String _accountName(int id) {
    for (final a in _accounts) {
      if (a.id == id) return a.name;
    }
    return 'Hesap #$id';
  }

  String _categoryName(int id) {
    for (final c in _categories) {
      if (c.id == id) return c.name;
    }
    return 'Kategori #$id';
  }

  // Gider planini create/update mantigiyla kaydeder.
  Future<void> _savePlan() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null || _selectedCategoryId == null) {
      _showSnack('Hesap ve kategori seçiniz.');
      return;
    }

    final amount = TurkishMoneyInputFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnack('Geçerli bir tutar giriniz.');
      return;
    }

    setState(() => _saving = true);
    try {
      final datesToPersist = _datesToPersist();
      final normalizedEndDate = _endDate == null
          ? null
          : DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
      final shouldExpandRecurring =
          normalizedEndDate != null && _periodType != 'once';

      for (final dueDate in datesToPersist) {
        final plan = ExpensePlan()
          ..accountId = _selectedAccountId!
          ..expenseCategoryId = _selectedCategoryId!
          ..amount = amount
          ..description = _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim()
          ..periodType = shouldExpandRecurring ? 'once' : _periodType
          ..frequency = shouldExpandRecurring
              ? 1
              : (_periodType == 'monthly' || _periodType == 'yearly'
                  ? _frequency
                  : 1)
          ..reminderMinutesBefore = shouldExpandRecurring
              ? 0
              : (_periodType == 'daily' ? _reminderMinutesBefore : 0)
          ..startDate = dueDate
          ..endDate = shouldExpandRecurring ? null : normalizedEndDate
          ..nextDueDate = dueDate
          ..isActive = true
          ..createdAt = DateTime.now();

        await ExpensePlanService.save(plan);
      }
      if (!mounted) return;

      _amountController.clear();
      _descController.clear();
      _recurrencePreset = 'monthly';
      _frequency = 1;
      _reminderMinutesBefore = 10;
      _periodType = 'monthly';
      _startDate = DateTime.now();
      _selectedWeekday = DateTime.now().weekday;
      _selectedTime = TimeOfDay.now();
      _endDate = null;

      await _load();
      if (!mounted) return;
      _captureDraftBaseline();
      _showSnack(
        shouldExpandRecurring
            ? '${datesToPersist.length} gider planı kaydedildi.'
            : 'Gider planı kaydedildi.',
      );
    } catch (e) {
      _showSnack('Kayıt hatası: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !_hasUnsavedDraft(),
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldLeave = await _confirmDiscardDraft();
          if (!context.mounted || !shouldLeave) return;
          Navigator.of(context).pop();
        },
        child: Scaffold(
          drawer: buildAppMenuDrawer(),
          appBar: AppBar(
            leading: buildMenuLeading(),
            title: const Text('Gider Planlama'),
            actions: [
              IconButton(
                onPressed: () => _load(checkDue: true),
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                icon: const Icon(Icons.home_outlined),
                tooltip: 'Ana Ekran',
                onPressed: _handleExitToDashboard,
              ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : (_accounts.isEmpty || _categories.isEmpty)
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Planlama için en az bir aktif hesap ve aktif gider tipi gerekli.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.tune),
                                title: const Text(
                                  'Yeni Gider Planı',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                trailing: Icon(
                                  _formExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onTap: () {
                                  setState(() {
                                    _formExpanded = !_formExpanded;
                                  });
                                },
                              ),
                              if (_formExpanded)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        DropdownButtonFormField<int>(
                                          initialValue: _selectedCategoryId,
                                          decoration: const InputDecoration(
                                            labelText: 'Gider Tipi',
                                          ),
                                          items: _categories
                                              .map(
                                                (c) => DropdownMenuItem<int>(
                                                  value: c.id,
                                                  child: Text(c.name),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) => setState(
                                              () => _selectedCategoryId = v),
                                          validator: (v) => v == null
                                              ? 'Gider tipi seçiniz.'
                                              : null,
                                        ),
                                        const SizedBox(height: 10),
                                        DropdownButtonFormField<int>(
                                          initialValue: _selectedAccountId,
                                          decoration: const InputDecoration(
                                            labelText: 'Hangi Hesaptan Çıkacak',
                                          ),
                                          items: _accounts
                                              .map(
                                                (a) => DropdownMenuItem<int>(
                                                  value: a.id,
                                                  child: Text(a.name),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) => setState(
                                              () => _selectedAccountId = v),
                                          validator: (v) => v == null
                                              ? 'Hesap seçiniz.'
                                              : null,
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: _amountController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: const [
                                            TurkishMoneyInputFormatter()
                                          ],
                                          decoration: const InputDecoration(
                                              labelText: 'Tutar (TL)'),
                                          validator: (v) {
                                            final p = TurkishMoneyInputFormatter
                                                .parse(v ?? '');
                                            if (p == null || p <= 0) {
                                              return 'Geçerli tutar giriniz.';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        DropdownButtonFormField<String>(
                                          initialValue: _recurrencePreset,
                                          decoration: const InputDecoration(
                                            labelText: 'Yineleme',
                                          ),
                                          items: PlanningStandard
                                              .recurrencePresetItems(),
                                          onChanged: (v) {
                                            if (v == null) return;
                                            setState(() =>
                                                _applyRecurrencePreset(v));
                                          },
                                        ),
                                        if (_recurrencePreset == 'custom') ...[
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: DropdownButtonFormField<
                                                    String>(
                                                  initialValue: _periodType,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Plan Dönemi',
                                                  ),
                                                  items: PlanningStandard
                                                      .periodItems(),
                                                  onChanged: (v) {
                                                    if (v == null) return;
                                                    setState(() {
                                                      _periodType = v;
                                                      if (_periodType ==
                                                          'weekly') {
                                                        _frequency = 1;
                                                        _reminderMinutesBefore =
                                                            0;
                                                        _selectedWeekday =
                                                            _startDate.weekday;
                                                      } else if (_periodType ==
                                                          'daily') {
                                                        _frequency = 1;
                                                        _reminderMinutesBefore =
                                                            _reminderMinutesBefore ==
                                                                    0
                                                                ? 10
                                                                : _reminderMinutesBefore;
                                                        _selectedTime = TimeOfDay
                                                            .fromDateTime(
                                                                _buildPlanStartDate());
                                                      } else {
                                                        final maxFreq =
                                                            PlanningStandard
                                                                .maxFrequencyForPeriod(
                                                                    _periodType);
                                                        if (_frequency >
                                                            maxFreq) {
                                                          _frequency = maxFreq;
                                                        }
                                                        _reminderMinutesBefore =
                                                            0;
                                                      }
                                                      _recurrencePreset =
                                                          'custom';
                                                    });
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: PlanningStandard
                                                        .usesReminderSelector(
                                                            _periodType)
                                                    ? DropdownButtonFormField<
                                                        int>(
                                                        initialValue:
                                                            _reminderMinutesBefore,
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Hatırlatma',
                                                        ),
                                                        items: PlanningStandard
                                                            .dailyReminderItems(),
                                                        onChanged: (v) {
                                                          if (v == null) return;
                                                          setState(() =>
                                                              _reminderMinutesBefore =
                                                                  v);
                                                        },
                                                      )
                                                    : PlanningStandard
                                                            .disablesFrequencySelector(
                                                                _periodType)
                                                        ? InputDecorator(
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Sıklık',
                                                            ),
                                                            child: const Text(
                                                                'Haftalık planda pasif'),
                                                          )
                                                        : DropdownButtonFormField<
                                                            int>(
                                                            initialValue:
                                                                _frequency,
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Sıklık',
                                                            ),
                                                            items: PlanningStandard
                                                                .frequencyItemsForPeriod(
                                                                    _periodType),
                                                            onChanged: (v) {
                                                              if (v == null) {
                                                                return;
                                                              }
                                                              setState(() {
                                                                _frequency = v;
                                                                _recurrencePreset =
                                                                    'custom';
                                                              });
                                                            },
                                                          ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _periodType == 'weekly'
                                                  ? DropdownButtonFormField<
                                                      int>(
                                                      initialValue:
                                                          _selectedWeekday,
                                                      decoration:
                                                          const InputDecoration(
                                                              labelText:
                                                                  'Hafta Günü'),
                                                      items: List.generate(
                                                        7,
                                                        (i) => DropdownMenuItem<
                                                            int>(
                                                          value: i + 1,
                                                          child: Text(
                                                              _weekdayLabel(
                                                                  i + 1)),
                                                        ),
                                                      ),
                                                      onChanged: (v) {
                                                        if (v == null) return;
                                                        setState(() =>
                                                            _selectedWeekday =
                                                                v);
                                                      },
                                                    )
                                                  : InkWell(
                                                      onTap:
                                                          _periodType == 'daily'
                                                              ? _pickTime
                                                              : () => _pickDate(
                                                                  start: true),
                                                      child: InputDecorator(
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              _periodType ==
                                                                      'daily'
                                                                  ? 'Saat'
                                                                  : 'Başlama',
                                                        ),
                                                        child: Text(
                                                          _periodType == 'daily'
                                                              ? _fmtTime(
                                                                  _selectedTime)
                                                              : _fmtDate(
                                                                  _startDate),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () =>
                                                    _pickDate(start: false),
                                                child: InputDecorator(
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText:
                                                              'Bitiş (opsiyonel)'),
                                                  child: Text(_endDate == null
                                                      ? '-'
                                                      : _fmtDate(_endDate!)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: _descController,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          inputFormatters: const [
                                            TurkishUpperCaseFormatter()
                                          ],
                                          maxLines: 2,
                                          decoration: const InputDecoration(
                                            labelText: 'Açıklama (opsiyonel)',
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            _endDate == null
                                                ? 'Önizleme: ilk 12 plan tarihi'
                                                : 'Önizleme: ${_previewDatesForForm().length} plan kaydedilecek',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        _buildPreviewWrap(
                                            _previewDatesForForm()),
                                        const SizedBox(height: 14),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.expense,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed:
                                                _saving ? null : _savePlan,
                                            child: Text(_saving
                                                ? 'Kaydediliyor...'
                                                : 'Planı Kaydet'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Aktif Gider Planları',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        ..._plans.where((p) => p.isActive).map((p) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                        '${_categoryName(p.expenseCategoryId)} • ${_fmtAmount(p.amount)} TL'),
                                    subtitle: Text(
                                      'Sonraki Tarih: ${_fmtDate(p.nextDueDate)}\n'
                                      'Hesap: ${_accountName(p.accountId)} • ${_planSummary(p)}',
                                    ),
                                    isThreeLine: true,
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (v) async {
                                        if (v == 'done') {
                                          await ExpensePlanService
                                              .markCompleted(p);
                                        } else if (v == 'postpone') {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: p.nextDueDate
                                                .add(const Duration(days: 1)),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null) {
                                            await ExpensePlanService.postpone(
                                              p,
                                              picked,
                                            );
                                          }
                                        } else if (v == 'cancel') {
                                          await ExpensePlanService.cancel(p);
                                        } else if (v == 'delete') {
                                          await ExpensePlanService.delete(p.id);
                                        }

                                        if (!mounted) return;
                                        await _load();
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                            value: 'done',
                                            child: Text('Gerçekleşti')),
                                        PopupMenuItem(
                                            value: 'postpone',
                                            child: Text('Ertele')),
                                        PopupMenuItem(
                                            value: 'cancel',
                                            child: Text('İptal Et')),
                                        PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Sil')),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Gelecek plan tarihleri',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  _buildPreviewWrap(_previewDatesForPlan(p)),
                                ],
                              ),
                            ),
                          );
                        }),
                        if (_plans.where((p) => p.isActive).isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Aktif gider planı yok.'),
                            ),
                          ),
                      ],
                    ),
        ));
  }
}
