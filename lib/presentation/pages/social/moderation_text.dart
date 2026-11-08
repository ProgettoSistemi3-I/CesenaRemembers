import 'package:flutter/widgets.dart';

/// Small, local bilingual helper for the moderation UI.
class ModerationText {
  const ModerationText._();

  static String of(
    BuildContext context, {
    required String it,
    required String en,
  }) {
    return Localizations.localeOf(context).languageCode == 'en' ? en : it;
  }
}
