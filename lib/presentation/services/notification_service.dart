import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _pluginInitialized = false;

  Future<void> init() async {
    // Il token FCM è gestito da PushNotificationService, associato all'UID
    // attivo; qui inizializziamo solo le notifiche locali.
    if (_pluginInitialized) return;
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (_) {},
    );
    _pluginInitialized = true;
  }

  Future<void> showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'social_channel',
      'Social Notifications',
      channelDescription: 'Notifiche per le interazioni sociali',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  Future<void> showFriendRequestNotification(
    int newRequestsCount, {
    required String title,
    required String languageCode,
  }) async {
    final body = languageCode == 'en'
        ? '$newRequestsCount new friend request${newRequestsCount == 1 ? '' : 's'} received.'
        : 'Hai ricevuto $newRequestsCount ${newRequestsCount == 1 ? 'nuova richiesta' : 'nuove richieste'} di amicizia.';
    await showLocalNotification(title, body);
  }
}
