import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../domain/usecases/user_profile_use_cases.dart';
import '../../injection_container.dart';
import 'shell_navigation_store.dart';
import 'notification_service.dart';

class PushNotificationService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String? _initializedUid;
  static String? _registeredToken;
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static StreamSubscription<RemoteMessage>? _openedSubscription;
  static StreamSubscription<RemoteMessage>? _foregroundSubscription;

  static Future<void> initializeAndSaveToken() async {
    final profiles = sl<UserProfileUseCases>();
    final uid = profiles.getCurrentUserUid();
    if (uid == null || uid.isEmpty) return;

    if (_initializedUid != uid) {
      final oldUid = _initializedUid;
      if (oldUid != null) {
        await _unregisterTokenForUid(oldUid, profiles, deleteFcmToken: false);
      }
      _initializedUid = uid;
    }

    try {
      final messaging = FirebaseMessaging.instance;
      final profile = await profiles.getUserProfile(uid);
      // Non chiedere il permesso di sistema quando l'utente ha disattivato
      // esplicitamente le notifiche nell'app.
      if (!profile.notificheEnabled) {
        await _unregisterTokenForUid(uid, profiles, deleteFcmToken: false);
        _setupNotificationListeners();
        return;
      }
      final permission = await messaging.requestPermission(
        alert: true, badge: true, sound: true,
      );
      if (permission.authorizationStatus != AuthorizationStatus.authorized) {
        await _unregisterTokenForUid(uid, profiles, deleteFcmToken: false);
        _setupNotificationListeners();
        return;
      }

      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await profiles.saveFcmToken(uid, token);
        _registeredToken = token;
      }
      _tokenRefreshSubscription ??= messaging.onTokenRefresh.listen((newToken) async {
        final activeUid = profiles.getCurrentUserUid();
        if (activeUid == null || activeUid.isEmpty) return;
        try {
          final activeProfile = await profiles.getUserProfile(activeUid);
          if (activeProfile.notificheEnabled) {
            await profiles.saveFcmToken(activeUid, newToken);
            _registeredToken = newToken;
          } else {
            await profiles.removeFcmToken(activeUid, newToken);
          }
        } catch (_) {
          // Push non deve impedire l'uso dell'app in caso di rete/permessi.
        }
      });
      _setupNotificationListeners();
    } catch (_) {
      // L'app resta utilizzabile anche se FCM non è disponibile.
    }
  }

  static Future<void> unregisterCurrentUser() async {
    final profiles = sl<UserProfileUseCases>();
    final uid = profiles.getCurrentUserUid();
    if (uid != null && uid.isNotEmpty) {
      await _unregisterTokenForUid(uid, profiles, deleteFcmToken: true);
    }
    _initializedUid = null;
  }

  static Future<void> _unregisterTokenForUid(
    String uid,
    UserProfileUseCases profiles, {
    required bool deleteFcmToken,
  }) async {
    final token = _registeredToken;
    if (token != null) {
      try {
        await profiles.removeFcmToken(uid, token);
      } catch (_) {}
    }
    if (deleteFcmToken) {
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {}
      _registeredToken = null;
    }
  }

  static void _setupNotificationListeners() {
    // In foreground FCM non mostra automaticamente la notifica di sistema:
    // la mostriamo qui. In background se ne occupa FCM, evitando il doppio invio
    // che si verificava ascoltando anche gli aggiornamenti Firestore in AuthGate.
    _foregroundSubscription ??= FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      unawaited(_showForegroundNotification(
        notification.title ?? 'Cesena Remembers',
        notification.body ?? '',
      ));
    });
    _openedSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationClick(message.data);
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _handleNotificationClick(message.data);
    });
  }


  static Future<void> _showForegroundNotification(String title, String body) async {
    final service = NotificationService();
    await service.init();
    await service.showLocalNotification(title, body);
  }

  static void _handleNotificationClick(Map<String, dynamic> data) {
    final notificationType = data['type'];
    if (notificationType == 'friend_request') {
      ShellNavigationStore.openFriendRequestsPanel.value = true;
      ShellNavigationStore.goToTab(2);
    } else if (notificationType == 'friend_accepted') {
      ShellNavigationStore.goToTab(1);
    }
  }
}
