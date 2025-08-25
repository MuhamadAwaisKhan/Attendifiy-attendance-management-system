// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   /// Initialize Notification Service
//   static Future<void> init() async {
//     // Android Initialization
//     const AndroidInitializationSettings androidInit =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     // iOS Initialization
//     const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
//
//     // Combine both
//     const InitializationSettings initSettings =
//     InitializationSettings(android: androidInit, iOS: iosInit);
//
//     // Initialize plugin
//     await _notificationsPlugin.initialize(initSettings);
//
//     // Request Permissions for Android 13+
//     if (await Permission.notification.isDenied) {
//       await Permission.notification.request();
//     }
//
//     // Request Permissions for iOS
//     await _notificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }
//
//   /// Show Notification
//   static Future<void> showNotification(String title, String body) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'leave_channel', // Channel ID
//       'Leave Notifications', // Channel Name
//       channelDescription: 'Notifications for attendance and leaves',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//     );
//
//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
//
//     const NotificationDetails notificationDetails =
//     NotificationDetails(android: androidDetails, iOS: iosDetails);
//
//     await _notificationsPlugin.show(
//       0, // Notification ID
//       title,
//       body,
//       notificationDetails,
//     );
//   }
// }
