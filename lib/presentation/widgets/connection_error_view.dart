import 'package:flutter/material.dart';
import 'package:cesena_remembers/l10n/app_localizations.dart';
import '../theme/app_palette.dart';

class ConnectionErrorView extends StatelessWidget {
  const ConnectionErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.olive.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.cloud_off_rounded, size: 44, color: AppPalette.olive),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.connectionErrorTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.connectionErrorBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.buttonRetry),
                style: FilledButton.styleFrom(backgroundColor: AppPalette.olive),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
