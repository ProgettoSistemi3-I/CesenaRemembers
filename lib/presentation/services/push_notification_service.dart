import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/usecases/user_profile_use_cases.dart';
import '../../injection_container.dart';
import 'shell_navigation_store.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    final activeUid = FirebaseAuth.instance.currentUser?.uid;
    if (activeUid == null || message.data['recipientUid'] != activeUid) return;
    // Le notifiche FCM con payload "notification" vengono mostrate dal sistema
    // operativo in background: evita di mostrarle una seconda volta come locali.
    if (message.notification != null) return;
    final title = message.data['title'] as String? ?? 'Cesena Remembers';
    final body = message.data['body'] as String? ?? '';
    if (body.isEmpty) return;
    final service = NotificationService();
    await service.init();
    await service.showLocalNotification(title, body);
  } catch (error, stackTrace) {
    AppLogger.error(
      'FCM background message handler failed',
      error: error,
      stackTrace: stackTrace,
      name: 'PushNotificationService',
    );
  }
}

class PushNotificationService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String? _initializedUid;
  static String? _registeredToken;
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static StreamSubscription<RemoteMessage>? _openedSubscription;
  static StreamSubscription<RemoteMessage>? _foregroundSubscription;

  static Future<void> initializeAndSaveToken({
    bool requestPermissionIfNeeded = true,
  }) async {
    final profiles = sl<UserProfileUseCases>();
    final uid = profiles.getCurrentUserUid();
    if (uid == null || uid.isEmpty) return;

    final messaging = FirebaseMessaging.instance;

    if (_initializedUid != uid) {
      final oldUid = _initializedUid;
      if (oldUid != null) {
        await messaging.setAutoInitEnabled(false);
        await _unregisterTokenForUid(oldUid, profiles, deleteFcmToken: true);
      }
      _initializedUid = uid;
    }

    try {
      final profile = await profiles.getUserProfile(uid);
      // Non chiedere il permesso di sistema quando l'utente ha disattivato
      // esplicitamente le notifiche nell'app.
      if (!profile.notificheEnabled) {
        await messaging.setAutoInitEnabled(false);
        await _unregisterTokenForUid(uid, profiles, deleteFcmToken: true);
        _setupNotificationListeners();
        return;
      }
      var authorizationStatus =
          (await messaging.getNotificationSettings()).authorizationStatus;
      if (authorizationStatus != AuthorizationStatus.authorized &&
          requestPermissionIfNeeded) {
        final permission = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        authorizationStatus = permission.authorizationStatus;
      }
      if (authorizationStatus != AuthorizationStatus.authorized) {
        await messaging.setAutoInitEnabled(false);
        await _unregisterTokenForUid(uid, profiles, deleteFcmToken: true);
        _setupNotificationListeners();
        return;
      }

      // Re-enable FCM registration only after explicit in-app consent and
      // the operating-system permission have both been granted.
      await messaging.setAutoInitEnabled(true);
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
        } catch (error, stackTrace) {
          AppLogger.error(
            'FCM token refresh handling failed',
            error: error,
            stackTrace: stackTrace,
            name: 'PushNotificationService',
          );
          // Push non deve impedire l'uso dell'app in caso di rete/permessi.
        }
      });
      _setupNotificationListeners();
    } catch (error, stackTrace) {
      AppLogger.error(
        'FCM initialization failed; app remains usable without push',
        error: error,
        stackTrace: stackTrace,
        name: 'PushNotificationService',
      );
    }
  }

  static Future<void> unregisterCurrentUser() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.setAutoInitEnabled(false);
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
    final tokensToRemove = <String>{};
    final cachedToken = _registeredToken;
    if (cachedToken != null && cachedToken.isNotEmpty) {
      tokensToRemove.add(cachedToken);
    }

    try {
      // Read only tokens already persisted after a prior explicit opt-in.
      // Do not call FirebaseMessaging.getToken() while opted out: that would
      // create or access an installation identifier without consent.
      final profile = await profiles.getUserProfile(uid);
      tokensToRemove.addAll(
        profile.fcmTokens.where((token) => token.isNotEmpty),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unable to load saved FCM tokens during unregistration',
        error: error,
        stackTrace: stackTrace,
        name: 'PushNotificationService',
      );
    }

    for (final token in tokensToRemove) {
      try {
        await profiles.removeFcmToken(uid, token);
      } catch (error, stackTrace) {
        AppLogger.error(
          'Unable to remove an FCM token from the user profile',
          error: error,
          stackTrace: stackTrace,
          name: 'PushNotificationService',
        );
      }
    }

    if (deleteFcmToken) {
      // Delete only when a previous, consented registration is known.
      if (tokensToRemove.isNotEmpty) {
        try {
          await FirebaseMessaging.instance.deleteToken();
        } catch (error, stackTrace) {
          AppLogger.error(
            'Unable to delete the local FCM token',
            error: error,
            stackTrace: stackTrace,
            name: 'PushNotificationService',
          );
        }
      }
      _registeredToken = null;
    }
  }

  static void _setupNotificationListeners() {
    // In foreground FCM non mostra automaticamente la notifica di sistema:
    // la mostriamo qui. In background se ne occupa FCM, evitando il doppio invio
    // che si verificava ascoltando anche gli aggiornamenti Firestore in AuthGate.
    _foregroundSubscription ??= FirebaseMessaging.onMessage.listen((message) {
      final recipientUid = message.data['recipientUid'] as String?;
      final activeUid = FirebaseAuth.instance.currentUser?.uid;
      if (recipientUid != null && recipientUid != activeUid) return;

      final title = message.notification?.title ??
          message.data['title'] as String? ??
          'Cesena Remembers';
      final body = message.notification?.body ??
          message.data['body'] as String? ??
          '';
      if (body.isEmpty) return;
      unawaited(_showForegroundNotification(title, body));
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
