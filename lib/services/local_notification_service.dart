import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:isar/isar.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../database/isar_service.dart';
import '../models/expense_plan.dart';
import '../models/income_plan.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static int _idForIncomePlan(int planId) => 500000 + planId;
  static int _idForExpensePlan(int planId) => 600000 + planId;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  static Future<void> scheduleOrCancelIncomePlan(IncomePlan plan) async {
    await init();

    final notificationId = _idForIncomePlan(plan.id);
    await _plugin.cancel(notificationId);

    if (!plan.isActive) return;
    if (plan.endDate != null && plan.nextDueDate.isAfter(plan.endDate!)) return;

    var target = DateTime(
      plan.nextDueDate.year,
      plan.nextDueDate.month,
      plan.nextDueDate.day,
      9,
      0,
    );

    final now = DateTime.now();
    if (target.isBefore(now)) {
      target = now.add(const Duration(seconds: 10));
    }

    final tzTarget = tz.TZDateTime.from(target, tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'income_plan_channel',
        'Gelir Planı Bildirimleri',
        channelDescription: 'Gelir planı hatırlatma bildirimleri',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      notificationId,
      'Gelir Planı Hatırlatma',
      'Planlı gelir zamanı geldi. Gerçekleşti mi kontrol edin.',
      tzTarget,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> cancelIncomePlan(int planId) async {
    await init();
    await _plugin.cancel(_idForIncomePlan(planId));
  }

  static Future<void> scheduleOrCancelExpensePlan(ExpensePlan plan) async {
    await init();

    final notificationId = _idForExpensePlan(plan.id);
    await _plugin.cancel(notificationId);

    if (!plan.isActive) return;
    if (plan.endDate != null && plan.nextDueDate.isAfter(plan.endDate!)) return;

    var target = DateTime(
      plan.nextDueDate.year,
      plan.nextDueDate.month,
      plan.nextDueDate.day,
      9,
      0,
    );

    final now = DateTime.now();
    if (target.isBefore(now)) {
      target = now.add(const Duration(seconds: 10));
    }

    final tzTarget = tz.TZDateTime.from(target, tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'expense_plan_channel',
        'Gider Planı Bildirimleri',
        channelDescription: 'Gider planı hatırlatma bildirimleri',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      notificationId,
      'Gider Planı Hatırlatma',
      'Planlı gider zamanı geldi. Gerçekleşti mi kontrol edin.',
      tzTarget,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> cancelExpensePlan(int planId) async {
    await init();
    await _plugin.cancel(_idForExpensePlan(planId));
  }

  static Future<void> syncIncomePlanNotifications() async {
    await init();

    final isar = IsarService.isar;
    final plans = await isar.incomePlans.where().anyId().findAll();

    for (final plan in plans) {
      await scheduleOrCancelIncomePlan(plan);
    }
  }

  static Future<void> syncExpensePlanNotifications() async {
    await init();

    final isar = IsarService.isar;
    final plans = await isar.expensePlans.where().anyId().findAll();

    for (final plan in plans) {
      await scheduleOrCancelExpensePlan(plan);
    }
  }
}
