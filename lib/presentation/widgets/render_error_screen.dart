import 'dart:async';

import 'package:flutter/material.dart';

import '../pages/splash_screen.dart';
import '../services/push_notification_service.dart';

/// A safe replacement for Flutter's technical rendering-error widget.
///
/// It deliberately does not display [FlutterErrorDetails], which can contain
/// implementation details. The retry action resets the navigation stack to
/// the splash screen so the user can re-enter the app without restarting it.
class RenderErrorScreen extends StatelessWidget {
  const RenderErrorScreen({super.key});

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
                    'Si è verificato un problema durante la visualizzazione.\n'
                    'Torna alla schermata iniziale e riprova.\n\n'
                    'An error occurred while displaying this screen. '
                    'Return to the home screen and try again.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _restartFromSplash,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Riprova / Try again'),
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
