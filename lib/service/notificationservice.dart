import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static int _notificationId = 0;

  /// Initialize Notification Service
  static Future<void> initNotification() async {
    if (_isInitialized) return;

    // Android Initialization
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine both
    const InitializationSettings initSettings =
    InitializationSettings(android: androidInitSettings, iOS: iosInit);

    // Initialize plugin
    await _notificationsPlugin.initialize(initSettings);

    _isInitialized = true;
  }

  /// Request notification permissions
  /// For Android, we'll just create the notification channel
  /// Android 13+ permissions need to be handled by the app separately
  static Future<void> requestPermissions() async {
    try {
      // Create notification channel (required for Android 8.0+)
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'leave_channel', // id
        'Leave Notifications', // title
        description: 'Notifications for attendance and leaves',
        importance: Importance.high,
      );

      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(channel);

      print("Notification channel created");
    } catch (e) {
      print("Error creating notification channel: $e");
    }
  }

  /// Notification details
  static NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'leave_channel', // must match channel id above
        'Leave Notifications',
        channelDescription: 'Notifications for attendance and leaves',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Show Notification
  static Future<void> showNotification(String title, String body) async {
    try {
      _notificationId++;
      await _notificationsPlugin.show(
        _notificationId,
        title,
        body,
        _notificationDetails(),
      );
      print("Notification shown: $title - $body");
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // This method might not be available in all versions
      // We'll just return true as a fallback
      return await androidPlugin?.areNotificationsEnabled() ?? true;
    } catch (e) {
      print("Error checking notification status: $e");
      return true; // Assume enabled if we can't check
    }
  }
}