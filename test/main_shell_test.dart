import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:cesena_remembers/l10n/app_localizations.dart';
import 'package:cesena_remembers/presentation/services/main_shell.dart';
import 'package:cesena_remembers/presentation/services/shell_navigation_store.dart';

void main() {
  testWidgets('MainShell resets all account-scoped navigation flags', (
    tester,
  ) async {
    ShellNavigationStore.deletingAccount.value = true;
    ShellNavigationStore.locationPermissionChanged.value = 5;
    ShellNavigationStore.tabIndex.value = 3;
    ShellNavigationStore.focusGpsToggleInSettings.value = true;
    ShellNavigationStore.openFriendRequestsPanel.value = true;
    ShellNavigationStore.scrollToAchievements.value = true;

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: MainShell(
          gpsEnabled: false,
          startupInitializer: () async {},
          pages: const [
            Text('Map test page'),
            Text('Community test page'),
            Text('Profile test page'),
            Text('Settings test page'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(ShellNavigationStore.deletingAccount.value, isFalse);
    expect(ShellNavigationStore.locationPermissionChanged.value, 0);
    expect(ShellNavigationStore.tabIndex.value, 0);
    expect(ShellNavigationStore.focusGpsToggleInSettings.value, isFalse);
    expect(ShellNavigationStore.openFriendRequestsPanel.value, isFalse);
    expect(ShellNavigationStore.scrollToAchievements.value, isFalse);
    expect(find.text('Map test page'), findsOneWidget);
  });
}
