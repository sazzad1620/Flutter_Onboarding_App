import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class AlarmProvider extends ChangeNotifier {
  List<DateTime> _alarms = [];
  List<DateTime> get alarms => _alarms;

  List<bool> _toggles = [];
  List<bool> get toggles => _toggles;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _notificationsInitialized = false;
  bool _timezoneSet = false;
  final List<DateTime> _pendingAlarms = [];

  String? selectedLocation;

  AlarmProvider() {
    _initNotifications();
    _setTimezoneAutomatically();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
    _notificationsInitialized = true;

    // Load saved alarms after notifications are initialized
    await loadAlarms();
  }

  Future<void> _setTimezoneAutomatically() async {
    tz.initializeTimeZones();
    try {
      String tzName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    _timezoneSet = true;

    // Schedule any pending alarms
    for (var alarm in _alarms) {
      _scheduleNotification(alarm);
    }
  }

  void addAlarm(DateTime alarm) {
    _alarms.add(alarm);
    _toggles.add(true); // default on
    _alarms.sort();
    saveAlarms();

    if (_notificationsInitialized && _timezoneSet) {
      _scheduleNotification(alarm);
    } else {
      _pendingAlarms.add(alarm);
    }

    notifyListeners();
  }

  void toggleAlarm(int index) {
    if (index < 0 || index >= _toggles.length) return;

    _toggles[index] = !_toggles[index];
    saveAlarms();
    notifyListeners();
  }

  void setLocation(String location) {
    selectedLocation = location;
    notifyListeners();
  }

  Future<void> loadAlarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? alarmsJson = prefs.getString('alarms');
    String? togglesJson = prefs.getString('toggles');

    if (alarmsJson != null) {
      List<dynamic> list = jsonDecode(alarmsJson);
      _alarms = list.map((e) => DateTime.parse(e)).toList();
    }

    if (togglesJson != null) {
      List<dynamic> list = jsonDecode(togglesJson);
      _toggles = list.map((e) => e as bool).toList();
    } else {
      _toggles = List<bool>.filled(_alarms.length, true);
    }

    // Schedule all enabled alarms
    for (int i = 0; i < _alarms.length; i++) {
      if (_toggles[i]) _scheduleNotification(_alarms[i]);
    }

    notifyListeners();
  }

  Future<void> saveAlarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String alarmsJson = jsonEncode(
      _alarms.map((e) => e.toIso8601String()).toList(),
    );
    await prefs.setString('alarms', alarmsJson);

    String togglesJson = jsonEncode(_toggles);
    await prefs.setString('toggles', togglesJson);
  }

  void _scheduleNotification(DateTime alarm) async {
    if (!_notificationsInitialized || !_timezoneSet) return;

    int id = alarm.millisecondsSinceEpoch.remainder(100000);

    final now = DateTime.now();
    DateTime scheduledDate = alarm.isBefore(now)
        ? alarm.add(Duration(days: 1))
        : alarm;

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alarm_channel',
          'Alarms',
          channelDescription: 'Channel for alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Alarm',
      'It\'s time: ${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}',
      tzScheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
