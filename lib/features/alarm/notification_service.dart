import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  factory NotificationService() => instance;

  final FlutterLocalNotificationsPlugin _notificationPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    await _configureLocalTimezone();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationPlugin.initialize(settings);
    await _requestPlatformPermissions();
    _isInitialized = true;
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(timezoneInfo.identifier);
      tz.setLocalLocation(location);
      debugPrint('NotificationService timezone: ${timezoneInfo.identifier}');
    } catch (e) {
      debugPrint('NotificationService timezone fallback to UTC: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> _requestPlatformPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notificationPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
      return;
    }

    if (Platform.isIOS) {
      await _notificationPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> scheduleNotification({
    required DateTime dateTime,
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      debugPrint('NotificationService.scheduleNotification skipped: not initialized');
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      category: AndroidNotificationCategory.alarm,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationPlugin.cancel(id);
      await _notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint(
        'NotificationService scheduled id=$id at $scheduledDate (local: ${tz.local.name})',
      );
    } catch (e, stackTrace) {
      debugPrint('NotificationService.scheduleNotification failed: $e');
      debugPrint('$stackTrace');
    }
  }

  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) return;
    await _notificationPlugin.cancel(id);
  }
}
