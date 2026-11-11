import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cesena_remembers/l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'core/logging/app_logger.dart';
import 'core/logging/crashlytics_reporter.dart';
import 'injection_container.dart' as di;
import 'presentation/theme/app_palette.dart';
import 'presentation/theme/theme_controller.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/widgets/render_error_screen.dart';
import 'presentation/services/push_notification_service.dart';

const bool _useFirestoreEmulator = bool.fromEnvironment(
  'USE_FIRESTORE_EMULATOR',
  defaultValue: false,
);

const String _firestoreEmulatorHost = String.fromEnvironment(
  'FIRESTORE_EMULATOR_HOST',
  defaultValue: '127.0.0.1',
);

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);

        unawaited(
          CrashlyticsReporter.record(
            details.exception,
            details.stack ?? StackTrace.current,
            reason: 'Unhandled Flutter framework error',
            fatal: true,
          ),
        );
      };

      PlatformDispatcher.instance.onError = (error, stackTrace) {
        unawaited(
          CrashlyticsReporter.record(
            error,
            stackTrace,
            reason: 'Unhandled platform dispatcher error',
            fatal: true,
          ),
        );

        return true;
      };

      if (!kDebugMode) {
        ErrorWidget.builder = (_) => const RenderErrorScreen();
      }

      await _bootstrapAndRun();
    },
    (error, stackTrace) {
      unawaited(
        CrashlyticsReporter.record(
          error,
          stackTrace,
          reason: 'Unhandled asynchronous zone error',
          fatal: true,
        ),
      );
    },
  );
}

Future<void> _bootstrapAndRun() async {
  final result = await AppBootstrap.run();

  if (!result.success) {
    runApp(
      BootstrapErrorApp(
        errorMessage: result.message,
        onRetry: _bootstrapAndRun,
      ),
    );
    return;
  }

  runApp(const CesenaRemembersApp());
}

class AppBootstrapResult {
  const AppBootstrapResult.success() : success = true, message = null;

  const AppBootstrapResult.failure(this.message) : success = false;

  final bool success;
  final String? message;
}

class AppBootstrap {
  const AppBootstrap._();

  static Future<AppBootstrapResult> run() async {
    try {
      // 1. Firebase initialization.
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 2. Firebase App Check.
      // Debug/Profile: Debug provider.
      // Release: Play Integrity.
      final appCheckProvider = kReleaseMode
          ? AndroidProvider.playIntegrity
          : AndroidProvider.debug;

      debugPrint(
        '[AppCheck] Inizializzazione provider: '
        '${kReleaseMode ? "Play Integrity" : "Debug"}',
      );

      await FirebaseAppCheck.instance.activate(
        androidProvider: appCheckProvider,
      );

      debugPrint('[AppCheck] Provider attivato correttamente.');

      // 3. Crashlytics.
      await CrashlyticsReporter.initialize();

      // 4. Firestore Emulator.
      // Enabled only in DEBUG when explicitly requested
      // through dart-define.
      if (kDebugMode && _useFirestoreEmulator) {
        final host = _firestoreEmulatorHost.trim();

        if (host.isEmpty) {
          throw StateError('FIRESTORE_EMULATOR_HOST non può essere vuoto.');
        }

        FirebaseFirestore.instance.useFirestoreEmulator(
          host,
          8080,
          sslEnabled: false,
          automaticHostMapping: false,
        );

        debugPrint(
          '[Firebase] Firestore Emulator attivo su $host:8080 '
          '(automaticHostMapping: false)',
        );
      }

      // 5. Firebase Messaging.
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 6. Dependency Injection.
      await di.init();

      // 7. Theme initialization.
      try {
        await di.sl<ThemeController>().initTheme();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Theme initialization failed during bootstrap',
          error: error,
          stackTrace: stackTrace,
          name: 'AppBootstrap',
        );
      }

      return const AppBootstrapResult.success();
    } catch (error, stackTrace) {
      await CrashlyticsReporter.record(
        error,
        stackTrace,
        reason: 'Application bootstrap failed',
        fatal: true,
      );

      return AppBootstrapResult.failure(error.toString());
    }
  }
}

class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({
    super.key,
    this.errorMessage,
    required this.onRetry,
  });

  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 54,
                  color: AppPalette.olive,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Impossibile avviare l\'app\nUnable to start the app',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (kDebugMode && errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(errorMessage!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPalette.olive,
                  ),
                  child: const Text('Riprova / Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CesenaRemembersApp extends StatelessWidget {
  const CesenaRemembersApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = di.sl<ThemeController>();
    final localeNotifier = di.sl<ValueNotifier<Locale>>();

    return ListenableBuilder(
      listenable: Listenable.merge([themeCtrl, localeNotifier]),
      builder: (context, _) {
        final isDark = themeCtrl.isDarkModeEffective;

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: PushNotificationService.navigatorKey,
          scaffoldMessengerKey: PushNotificationService.scaffoldMessengerKey,
          title: 'Cesena Remembers 1945',
          themeMode: themeCtrl.themeMode,
          theme: AppPalette.lightTheme,
          darkTheme: AppPalette.darkTheme,
          locale: localeNotifier.value,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const SplashScreen(),
        );
      },
    );
  }
}
