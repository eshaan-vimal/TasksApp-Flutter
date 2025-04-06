import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;


class NotificationService 
{
  final _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInit = false;

  static final NotificationService _instance = NotificationService._internal();
  NotificationService._internal();

  factory NotificationService() => _instance;


  Future<void> init() async
  {
    if (_isInit)
    {
      return;
    }

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('notification_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final bool? initResult = await _notificationsPlugin.initialize(
      initSettings,
      // onDidReceiveBackgroundNotificationResponse: (_) {},
    );

    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null)
    {
      await android.requestNotificationsPermission();
    }

    final ios = _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null)
    {
      await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _isInit = true;
    print("Notification service initialiazed: $initResult");
  }


  Future<void> scheduleNotification ({
    required String taskId,
    required String title,
    required String description,
    required DateTime dueAt,
  }) async
  {
    if (!_isInit)
    {
      await init();
    }

    final notifTime = dueAt.subtract(const Duration(minutes: 20));

    if (notifTime.isBefore(DateTime.now()))
    {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for upcoming tasks',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xff121212),
      icon: 'notification_icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
      sound: 'default',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try
    {
      await _notificationsPlugin.zonedSchedule(
        taskId.hashCode,
        'Upcoming Task',
        '"$title: $description" is due in 20 mins',
        tz.TZDateTime.from(notifTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: dueAt.toIso8601String(),        
      );
      print("Notification scheduled");
    }
    catch (error)
    {
      print(error);
    }
  }


  Future<void> cancelNotification (String taskId) async
  {
    if (!_isInit)
    {
      return;
    }

    try
    {
      await _notificationsPlugin.cancel(taskId.hashCode);
      print("Notification cancelled");
    }
    catch (error)
    {
      print(error);
    }
  }
}