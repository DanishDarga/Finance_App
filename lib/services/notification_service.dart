import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/bill.dart';
import '../core/constants.dart';

/// Service for handling local notifications
class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    tz.initializeTimeZones();
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Request notification permissions
  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Schedule a notification for a bill reminder
  /// 
  /// The notification will be scheduled [billReminderDaysBefore] days
  /// before the bill's due date at [billReminderHour]:00 AM
  void scheduleBillNotification(Bill bill) {
    if (bill.id == null) return;

    // Schedule notification N days before the due date at 10:00 AM
    final notificationTime = bill.dueDate
        .subtract(Duration(days: AppConstants.billReminderDaysBefore))
        .copyWith(
          hour: AppConstants.billReminderHour,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );

    final scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);

    _flutterLocalNotificationsPlugin.zonedSchedule(
      bill.id.hashCode,
      'Upcoming Bill Reminder',
      'Your bill for "${bill.name}" of ${AppConstants.currencySymbol}${bill.amount} is due in ${AppConstants.billReminderDaysBefore} days.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.billNotificationChannelId,
          AppConstants.billNotificationChannelName,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a scheduled bill notification
  void cancelBillNotification(Bill bill) {
    if (bill.id == null) return;
    _flutterLocalNotificationsPlugin.cancel(bill.id.hashCode);
  }
  /// Show an immediate budget alert notification
  Future<void> showBudgetAlert(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Notifications for budget limits',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // Unique ID
      title,
      body,
      details,
    );
  }
}
