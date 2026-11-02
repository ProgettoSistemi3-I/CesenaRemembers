import 'package:flutter/material.dart';
import '../pages/map/map_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/settings/settings_page.dart';
import 'shell_navigation_store.dart';
import '../pages/social/social_page.dart';
import 'push_notification_service.dart';
import 'location_preference_store.dart';
import '../../l10n/app_localizations.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.gpsEnabled});

  final bool gpsEnabled;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MapPage(),
    SocialPage(),
    ProfilePage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // La preferenza arriva dal profilo già caricato da AuthGate: inizializzala
    // prima che IndexedStack crei MapPage e avvii il controllo dei permessi.
    LocationPreferenceStore.setGpsEnabled(widget.gpsEnabled);
    // Evita che il tab statico di una sessione precedente sopravviva al logout.
    ShellNavigationStore.tabIndex.value = 0;
    _currentIndex = 0;
    ShellNavigationStore.tabIndex.addListener(_onTabIndexChanged);
    _initializeNotifications();
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gpsEnabled != widget.gpsEnabled) {
      LocationPreferenceStore.setGpsEnabled(widget.gpsEnabled);
    }
  }

  void _initializeNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PushNotificationService.initializeAndSaveToken();
      // La posizione viene richiesta solo quando l'utente avvia un tour
      // o usa il comando "centra su di me".

    });
  }

  @override
  void dispose() {
    ShellNavigationStore.tabIndex.removeListener(_onTabIndexChanged);
    super.dispose();
  }

  void _onTabIndexChanged() {
    if (!mounted) return;
    setState(() => _currentIndex = ShellNavigationStore.tabIndex.value);
  }

  void _onTapBottomBar(int index) {
    ShellNavigationStore.goToTab(index);
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTapBottomBar,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: AppLocalizations.of(context)!.navMap,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: AppLocalizations.of(context)!.navCommunity,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: AppLocalizations.of(context)!.navProfile,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: AppLocalizations.of(context)!.navSettings,
          ),
        ],
      ),
    );
  }
}
