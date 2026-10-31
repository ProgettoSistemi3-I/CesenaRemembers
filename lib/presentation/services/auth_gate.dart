import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/userprofile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/user_profile_use_cases.dart';
import '../../injection_container.dart';
import '../pages/login_page.dart';
import '../pages/onboarding/onboarding_page.dart';
import '../pages/profile/profile_setup_page.dart';
import '../theme/theme_controller.dart';
import 'package:cesena_remembers/l10n/app_localizations.dart';
import '../widgets/connection_error_view.dart';
import 'main_shell.dart';
import 'notification_service.dart';
import 'push_notification_service.dart';
import 'shell_navigation_store.dart';
import '../widgets/glass_snackbar.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _bannedAccountWasDetected = false;
  String? _lastAuthenticatedUid;

  void _onBannedAccountDetected() {
    if (mounted) setState(() => _bannedAccountWasDetected = true);
  }

  @override
  Widget build(BuildContext context) {
    final repository = sl<AuthRepository>();

    return StreamBuilder<AppUser?>(
      stream: repository.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final appUser = snapshot.data;
        if (appUser == null) {
          ShellNavigationStore.deletingAccount.value = false;
          final showBannedMessage = _bannedAccountWasDetected;
          return LoginPage(showBannedAccount: showBannedMessage);
        }
        if (_lastAuthenticatedUid != appUser.id) {
          _lastAuthenticatedUid = appUser.id;
          _bannedAccountWasDetected = false;
        }
        return _AuthenticatedGate(
          appUser: appUser,
          onBannedAccount: _onBannedAccountDetected,
        );
      },
    );
  }
}

class _AuthenticatedGate extends StatefulWidget {
  const _AuthenticatedGate({
    required this.appUser,
    required this.onBannedAccount,
  });

  final AppUser appUser;
  final VoidCallback onBannedAccount;

  @override
  State<_AuthenticatedGate> createState() => _AuthenticatedGateState();
}

class _AuthenticatedGateState extends State<_AuthenticatedGate> {
  static const _profileTimeoutDuration = Duration(seconds: 12);

  late final UserProfileUseCases _profileUseCases;
  late final AuthRepository _authRepository;
  late Future<void> _ensureFuture;
  late Stream<UserProfile?> _profileStream;
  StreamSubscription<UserProfile?>? _profileSubscription;
  Timer? _profileTimeout;
  bool _profileTimedOut = false;
  bool _notificationsStarted = false;
  int _previousPendingAchievementsCount = -1;

  @override
  void initState() {
    super.initState();
    _profileUseCases = sl<UserProfileUseCases>();
    _authRepository = sl<AuthRepository>();
    _profileStream = _profileUseCases.getUserProfileStream(widget.appUser.id);
    _ensureFuture = _checkBanAndInit();
    _startProfileTimeout();
  }

  void _startProfileTimeout() {
    _profileTimeout?.cancel();
    _profileTimeout = Timer(_profileTimeoutDuration, () {
      if (mounted) setState(() => _profileTimedOut = true);
    });
  }

  void _retry() {
    setState(() {
      _profileTimedOut = false;
      _profileStream = _profileUseCases.getUserProfileStream(widget.appUser.id);
      _ensureFuture = _checkBanAndInit();
    });
    _startProfileTimeout();
  }

  Future<void> _checkBanAndInit() async {
    // Offline il controllo ban "fallisce aperto": le Security Rules restano
    // la protezione reale lato server.
    var isBanned = false;
    try {
      isBanned = await _profileUseCases.isUserBanned(widget.appUser.id);
    } catch (e, st) {
      AppLogger.error(
        'Ban check skipped',
        error: e,
        stackTrace: st,
        name: 'AuthGate',
      );
    }
    if (isBanned) {
      widget.onBannedAccount();
      await _authRepository.signOut();
      throw const _BannedFromFirestoreException();
    }

    // Se il documento non può essere creato/letto, non proseguire mostrando
    // il form: il completamento del profilo richiede questo documento oppure
    // usa il percorso atomico di create previsto dalle Firestore Rules.
    try {
      await _profileUseCases.ensureUserDocument(
        uid: widget.appUser.id,
        email: widget.appUser.email,
      );
    } catch (e, st) {
      AppLogger.error(
        'ensureUserDocument failed',
        error: e,
        stackTrace: st,
        name: 'AuthGate',
      );
      rethrow;
    }

    unawaited(sl<ThemeController>().refreshFromProfile().catchError((_) {}));
    _startNotifications();
  }

  void _startNotifications() {
    if (_notificationsStarted) return;
    _notificationsStarted = true;
    unawaited(_initNotifications());
  }

  Future<void> _initNotifications() async {
    final notificationService = NotificationService();
    try {
      await notificationService.init();
    } catch (e, st) {
      AppLogger.error(
        'Notification init failed',
        error: e,
        stackTrace: st,
        name: 'AuthGate',
      );
    }
    if (!mounted) return;

    _profileSubscription = _profileUseCases
        .getUserProfileStream(widget.appUser.id)
        .listen(
          (profile) {
            if (profile == null || !mounted) return;

            final currentPending = profile.pendingAchievements.length;
            if (_previousPendingAchievementsCount != -1 &&
                currentPending > _previousPendingAchievementsCount) {
              final messenger =
                  PushNotificationService.scaffoldMessengerKey.currentState;
              final ctx =
                  PushNotificationService.navigatorKey.currentContext ??
                  context;
              if (messenger != null && ctx.mounted) {
                final topMargin = MediaQuery.of(ctx).size.height - 150;
                showGlassSnackBar(
                  ctx,
                  message: AppLocalizations.of(ctx)!.achievementUnlockedSnack,
                  type: GlassSnackType.success,
                  icon: Icons.emoji_events,
                  duration: const Duration(seconds: 10),
                  margin: EdgeInsets.only(
                    bottom: topMargin > 0 ? topMargin : 600,
                    left: 16,
                    right: 16,
                  ),
                  onTap: () => ShellNavigationStore.goToTab(2),
                );
              }
            }
            _previousPendingAchievementsCount = currentPending;
          },
          onError: (Object e, StackTrace st) {
            AppLogger.error(
              'Profile stream error',
              error: e,
              stackTrace: st,
              name: 'AuthGate',
            );
          },
        );
  }

  @override
  void dispose() {
    _profileTimeout?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }

  Widget _loading() =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ShellNavigationStore.deletingAccount,
      builder: (context, deleting, _) {
        if (deleting) return _loading();
        return _buildGate(context);
      },
    );
  }

  Widget _buildGate(BuildContext context) {
    return FutureBuilder<void>(
      future: _ensureFuture,
      builder: (context, ensure) {
        if (ensure.hasError && ensure.error is _BannedFromFirestoreException) {
          return _loading(); // lo stream auth riporta alla LoginPage
        }
        if (ensure.connectionState != ConnectionState.done) return _loading();
        if (ensure.hasError) {
          return Scaffold(body: ConnectionErrorView(onRetry: _retry));
        }

        return StreamBuilder<UserProfile?>(
          stream: _profileStream,
          builder: (context, snap) {
            final profile = snap.data;
            if (profile == null) {
              if (snap.hasError || _profileTimedOut) {
                return Scaffold(body: ConnectionErrorView(onRetry: _retry));
              }
              return _loading();
            }

            if (!profile.profileCompleted) {
              return ProfileSetupPage(
                uid: widget.appUser.id,
                email: widget.appUser.email,
                suggestedName: widget.appUser.displayName,
              );
            }
            if (!profile.onboardingCompleted) {
              return OnboardingPage(uid: widget.appUser.id);
            }
            return const MainShell();
          },
        );
      },
    );
  }
}

class _BannedFromFirestoreException implements Exception {
  const _BannedFromFirestoreException();
}
