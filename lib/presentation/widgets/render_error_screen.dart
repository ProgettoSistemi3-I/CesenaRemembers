import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../pages/splash_screen.dart';
import '../services/push_notification_service.dart';
import 'package:cesena_remembers/l10n/app_localizations.dart';

/// A safe replacement for Flutter's technical rendering-error widget.
///
/// It deliberately does not display [FlutterErrorDetails], which can contain
/// implementation details. The retry action resets the navigation stack to
/// the splash screen so the user can re-enter the app without restarting it.
class RenderErrorScreen extends StatelessWidget {
  const RenderErrorScreen({super.key, this.onRetry});

  /// Optional retry override for widget tests or embedding contexts.
  final VoidCallback? onRetry;

  void _restartFromSplash() {
    final navigator = PushNotificationService.navigatorKey.currentState;
    if (navigator == null) return;

    unawaited(
      navigator
          .pushAndRemoveUntil<void>(
            MaterialPageRoute<void>(
              builder: (_) => const SplashScreen(),
            ),
            (_) => false,
          )
          .then<void>((_) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final localeCode =
        Localizations.maybeLocaleOf(context)?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final isEnglish = localeCode.toLowerCase() == 'en';
    final errorMessage = l10n?.renderErrorMessage ??
        (isEnglish
            ? 'An error occurred while displaying this screen. Return to the home screen and try again.'
            : 'Si è verificato un problema durante la visualizzazione. Torna alla schermata iniziale e riprova.');
    final retryLabel = l10n?.buttonRetry ?? (isEnglish ? 'Try again' : 'Riprova');

    return Material(
      color: colors.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: colors.error,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onRetry ?? _restartFromSplash,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(retryLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
