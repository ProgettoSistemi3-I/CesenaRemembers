import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cesena_remembers/l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'presentation/theme/app_palette.dart';
import 'presentation/theme/theme_controller.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kDebugMode) {
    ErrorWidget.builder = (_) => const SizedBox.shrink();
  }
  await _bootstrapAndRun();
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
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // DIAGNOSTICA TEMPORANEA: usare solo con --dart-define in debug.
      // Di default l'app continua a usare Firestore di produzione.
      if (kDebugMode && const bool.fromEnvironment('USE_FIRESTORE_EMULATOR')) {
        const emulatorHost = String.fromEnvironment(
          'FIRESTORE_EMULATOR_HOST',
          defaultValue: '127.0.0.1',
        );

        FirebaseFirestore.instance.useFirestoreEmulator(
          emulatorHost,
          8080,
          automaticHostMapping: false,
        );

        debugPrint(
          '[FIRESTORE DIAGNOSTIC] Emulator attivo: $emulatorHost:8080',
        );
      }

      await di.init();
      try {
        await di.sl<ThemeController>().initTheme();
      } catch (_) {}

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
      return const AppBootstrapResult.success();
    } catch (e) {
      return AppBootstrapResult.failure(e.toString());
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
