import 'package:flutter/material.dart';

import '../../../core/logging/crashlytics_reporter.dart';
import '../../../domain/usecases/user_preferences_use_cases.dart';
import '../../../injection_container.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/location_permission_service.dart';
import '../../services/location_preference_store.dart';
import '../../services/push_notification_service.dart';
import '../../theme/app_palette.dart';

/// Three explicit, independent choices shown after the profile is created.
class ConsentOnboardingPage extends StatefulWidget {
  const ConsentOnboardingPage({super.key, required this.uid});

  final String uid;

  @override
  State<ConsentOnboardingPage> createState() => _ConsentOnboardingPageState();
}

class _ConsentOnboardingPageState extends State<ConsentOnboardingPage> {
  int _step = 0;
  bool _working = false;
  String? _error;

  Future<void> _choose(bool enabled) async {
    if (_working) return;

    setState(() {
      _working = true;
      _error = null;
    });

    try {
      final preferences = sl<UserPreferencesUseCases>();

      switch (_step) {
        case 0:
          // Save the in-app choice first. FCM asks Android only when enabled.
          await preferences.updatePreferences(
            uid: widget.uid,
            notifiche: enabled,
          );
          await PushNotificationService.initializeAndSaveToken();
          break;

        case 1:
          var gpsEnabled = false;
          if (enabled) {
            final status = await const LocationPermissionService()
                .ensureLocationAccess();
            // The runtime permission may be granted while the device GPS
            // switch is off. Keep the user's choice; the map can explain that
            // the system location service must be enabled when needed.
            gpsEnabled = status == LocationAccessStatus.granted ||
                status == LocationAccessStatus.serviceDisabled;
          }

          await preferences.updatePreferences(
            uid: widget.uid,
            gps: gpsEnabled,
          );
          LocationPreferenceStore.setGpsEnabled(gpsEnabled);
          break;

        case 2:
          // Persist explicit consent before allowing Crashlytics collection.
          await preferences.updatePreferences(
            uid: widget.uid,
            crashlytics: enabled,
            permissionsSetupCompleted: true,
          );
          await CrashlyticsReporter.setCollectionEnabled(
            enabled,
            // Never upload a report created before this explicit choice.
            discardUnsentReports: true,
          );
          break;
      }

      if (!mounted) return;
      if (_step < 2) {
        setState(() {
          _step++;
          _working = false;
        });
      }
      // On the last step AuthGate observes permissionsSetupCompleted and
      // replaces this page with the product walkthrough or the main app.
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _working = false;
        _error = AppLocalizations.of(context)!.consentSaveError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final steps = [
      _ConsentStepData(
        icon: Icons.notifications_active_rounded,
        accent: AppPalette.tan,
        tag: l10n.consentNotificationsTag,
        title: l10n.consentNotificationsTitle,
        description: l10n.consentNotificationsBody,
        note: l10n.consentNotificationsNote,
        accept: l10n.consentNotificationsAccept,
        decline: l10n.consentNotificationsDecline,
      ),
      _ConsentStepData(
        icon: Icons.location_on_rounded,
        accent: AppPalette.moss,
        tag: l10n.consentLocationTag,
        title: l10n.consentLocationTitle,
        description: l10n.consentLocationBody,
        note: l10n.consentLocationNote,
        accept: l10n.consentLocationAccept,
        decline: l10n.consentLocationDecline,
      ),
      _ConsentStepData(
        icon: Icons.bug_report_rounded,
        accent: AppPalette.olive,
        tag: l10n.consentDiagnosticsTag,
        title: l10n.consentDiagnosticsTitle,
        description: l10n.consentDiagnosticsBody,
        note: l10n.consentDiagnosticsNote,
        accept: l10n.consentDiagnosticsAccept,
        decline: l10n.consentDiagnosticsDecline,
      ),
    ];
    final step = steps[_step];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0C0F0D)
            : const Color(0xFFF5F1EB),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    if (_step > 0)
                      IconButton(
                        onPressed: _working
                            ? null
                            : () => setState(() {
                                  _step--;
                                  _error = null;
                                }),
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: MaterialLocalizations.of(context)
                            .backButtonTooltip,
                      )
                    else
                      const SizedBox(width: 48),
                    const Spacer(),
                    Text(
                      'CESENA REMEMBERS',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '0${_step + 1} / 03',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 4,
                        margin: EdgeInsets.only(right: index == 2 ? 0 : 7),
                        decoration: BoxDecoration(
                          color: index <= _step
                              ? step.accent
                              : theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: SingleChildScrollView(
                      key: ValueKey(_step),
                      padding: const EdgeInsets.only(top: 24, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: step.accent.withValues(
                                  alpha: isDark ? 0.15 : 0.12,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 132,
                                  height: 132,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: step.accent.withValues(
                                      alpha: isDark ? 0.23 : 0.18,
                                    ),
                                    border: Border.all(
                                      color: step.accent.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    step.icon,
                                    size: 66,
                                    color: step.accent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            step.tag,
                            style: TextStyle(
                              color: step.accent,
                              letterSpacing: 1.8,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            step.title,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 30,
                              height: 1.12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            step.description,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: step.accent.withValues(
                                alpha: isDark ? 0.10 : 0.08,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: step.accent.withValues(alpha: 0.16),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 19,
                                  color: step.accent,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    step.note,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _working ? null : () => _choose(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: step.accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          step.accent.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: _working
                        ? const SizedBox(
                            height: 21,
                            width: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            step.accept,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _working ? null : () => _choose(false),
                  child: Text(
                    step.decline,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsentStepData {
  const _ConsentStepData({
    required this.icon,
    required this.accent,
    required this.tag,
    required this.title,
    required this.description,
    required this.note,
    required this.accept,
    required this.decline,
  });

  final IconData icon;
  final Color accent;
  final String tag;
  final String title;
  final String description;
  final String note;
  final String accept;
  final String decline;
}
