import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'alarm_model.dart';
import 'notification_service.dart';

class AlarmProvider extends ChangeNotifier {
  List<AlarmModel> _alarms = [];
  List<AlarmModel> get alarms => _alarms;

  final NotificationService _notificationService = NotificationService();

  bool _notificationsInitialized = false;
  bool _timezoneSet = false;

  // Keep pending alarms until notifications + timezone are ready
  final List<AlarmModel> _pendingAlarms = [];

  String? selectedLocation;

  AlarmProvider() {
    _initNotifications();
  }

  // Initialization
  Future<void> _initNotifications() async {
    await _notificationService.init();
    _notificationsInitialized = _notificationService.isInitialized;

    // Load saved alarms after notifications are initialized
    await loadAlarms();

    _timezoneSet = true;

    // Schedule all enabled alarms + pending alarms
    await _rescheduleEnabledAndPendingAlarms();
  }

  Future<void> _rescheduleEnabledAndPendingAlarms() async {
    if (!_notificationsInitialized || !_timezoneSet) return;

    // Schedule enabled alarms from storage
    for (var alarm in _alarms) {
      if (alarm.isEnabled) {
        await _scheduleNotification(alarm);
      }
    }

    // Schedule any pending alarms that were added before init
    for (var p in _pendingAlarms) {
      if (p.isEnabled) await _scheduleNotification(p);
    }
    _pendingAlarms.clear();
  }

  // CRUD
  void addAlarm(DateTime alarmTime) {
    final model = AlarmModel(time: alarmTime, isEnabled: true);
    _alarms.add(model);
    _alarms.sort((a, b) => a.time.compareTo(b.time));
    saveAlarms();

    if (_notificationsInitialized && _timezoneSet) {
      _scheduleNotification(model);
    } else {
      _pendingAlarms.add(model);
    }

    notifyListeners();
  }

  void toggleAlarm(int index) {
    if (index < 0 || index >= _alarms.length) return;

    final alarm = _alarms[index];
    alarm.isEnabled = !alarm.isEnabled;
    saveAlarms();

    if (alarm.isEnabled) {
      if (_notificationsInitialized && _timezoneSet) {
        _scheduleNotification(alarm);
      } else {
        _pendingAlarms.add(alarm);
      }
    } else {
      _cancelNotification(alarm);
      _pendingAlarms.removeWhere((a) => a.time == alarm.time);
    }

    notifyListeners();
  }

  Future<void> deleteAlarm(int index) async {
    if (index < 0 || index >= _alarms.length) return;

    final alarm = _alarms[index];
    await _cancelNotification(alarm);

    _pendingAlarms.removeWhere((a) => a.time == alarm.time);

    _alarms.removeAt(index);
    await saveAlarms();
    notifyListeners();
  }

  Future<void> removeAlarm(int index) => deleteAlarm(index);

  void setLocation(String location) {
    selectedLocation = location;
    notifyListeners();
  }

  // Persistence
  Future<void> loadAlarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? alarmsJson = prefs.getString('alarms');

    if (alarmsJson != null) {
      List<dynamic> list = jsonDecode(alarmsJson);
      _alarms = list.map((e) => AlarmModel.fromJson(e)).toList();
    } else {
      _alarms = [];
    }

    notifyListeners();
  }

  Future<void> saveAlarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String alarmsJson = jsonEncode(_alarms.map((e) => e.toJson()).toList());
    await prefs.setString('alarms', alarmsJson);
  }

  // -------------------- Notifications --------------------
  Future<void> _scheduleNotification(AlarmModel alarm) async {
    if (!_notificationsInitialized || !_timezoneSet) return;

    int id = alarm.time.millisecondsSinceEpoch.remainder(100000);

    final now = DateTime.now();
    DateTime scheduledDate = alarm.time.isBefore(now)
        ? alarm.time.add(Duration(days: 1))
        : alarm.time;

    await _notificationService.scheduleNotification(
      dateTime: scheduledDate,
      id: id,
      title: 'Alarm',
      body:
          'It\'s time: ${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}',
    );
  }

  Future<void> _cancelNotification(AlarmModel alarm) async {
    int id = alarm.time.millisecondsSinceEpoch.remainder(100000);
    await _notificationService.cancelNotification(id);
  }
}
