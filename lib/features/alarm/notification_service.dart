import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;

    // initialize timezone
    tz.initializeTimeZones();
    try {
      String tzName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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
    _isInitialized = true;
  }

  Future<void> scheduleNotification({
    required DateTime dateTime,
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) return;

    final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) return;
    await _notificationPlugin.cancel(id);
  }
}
