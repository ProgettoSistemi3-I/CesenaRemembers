import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

enum GlassSnackType {
  success,
  error,
  info,
  xp,
  achievement,
  friend,
}

OverlayEntry? _activeGlassBanner;
Timer? _glassBannerTimer;

/// Shows a prominent in-app banner below the status bar.
/// A new banner replaces the previous one so important events stay readable.
void showGlassSnackBar(
  BuildContext context, {
  required String message,
  String? title,
  GlassSnackType type = GlassSnackType.info,
  IconData? icon,
  Duration duration = const Duration(seconds: 4),
  VoidCallback? onTap,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  _removeActiveGlassBanner();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (overlayContext) {
      final topInset = MediaQuery.paddingOf(overlayContext).top;
      return Positioned(
        top: topInset + 12,
        left: 16,
        right: 16,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, -12 * (1 - value)),
                  child: child,
                ),
              ),
              child: Semantics(
                liveRegion: true,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap == null
                        ? null
                        : () {
                            _removeGlassBanner(entry);
                            onTap();
                          },
                    borderRadius: BorderRadius.circular(20),
                    child: _GlassSnackContent(
                      title: title,
                      message: message,
                      accentColor: _accentFor(type),
                      icon: icon ?? _iconFor(type),
                      isDark:
                          Theme.of(overlayContext).brightness == Brightness.dark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  _activeGlassBanner = entry;
  overlay.insert(entry);
  _glassBannerTimer = Timer(duration, () => _removeGlassBanner(entry));
}

void _removeActiveGlassBanner() {
  final current = _activeGlassBanner;
  if (current != null) _removeGlassBanner(current);
}

void _removeGlassBanner(OverlayEntry entry) {
  _glassBannerTimer?.cancel();
  if (identical(_activeGlassBanner, entry)) {
    _activeGlassBanner = null;
  }
  if (entry.mounted) entry.remove();
  entry.dispose();
}

Color _accentFor(GlassSnackType type) {
  switch (type) {
    case GlassSnackType.success:
      return AppPalette.olive;
    case GlassSnackType.error:
      return AppPalette.danger;
    case GlassSnackType.info:
      return AppPalette.moss;
    case GlassSnackType.xp:
    case GlassSnackType.achievement:
      return AppPalette.tan;
    case GlassSnackType.friend:
      return AppPalette.moss;
  }
}

IconData _iconFor(GlassSnackType type) {
  switch (type) {
    case GlassSnackType.success:
      return Icons.check_circle_outline_rounded;
    case GlassSnackType.error:
      return Icons.error_outline_rounded;
    case GlassSnackType.info:
      return Icons.place_rounded;
    case GlassSnackType.xp:
      return Icons.bolt_rounded;
    case GlassSnackType.achievement:
      return Icons.emoji_events_rounded;
    case GlassSnackType.friend:
      return Icons.people_alt_rounded;
  }
}

class _GlassSnackContent extends StatelessWidget {
  const _GlassSnackContent({
    required this.title,
    required this.message,
    required this.accentColor,
    required this.icon,
    required this.isDark,
  });

  final String? title;
  final String message;
  final Color accentColor;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final foreground = isDark ? Colors.white : const Color(0xFF18201C);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17211F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.72),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.24),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.24 : 0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.trim().isNotEmpty)
                  Text(
                    title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      height: 1.2,
                    ),
                  ),
                if (message.trim().isNotEmpty) ...[
                  if (title != null && title!.trim().isNotEmpty)
                    const SizedBox(height: 4),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground.withValues(alpha: 0.82),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
