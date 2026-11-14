import 'package:material_ui/material_ui.dart';

import 'package:cesena_remembers/l10n/app_localizations.dart';
import 'package:cesena_remembers/l10n/l10n_extensions.dart';

import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/userprofile.dart';

import '../../../domain/usecases/user_profile_use_cases.dart';
import '../../../domain/usecases/user_moderation_use_cases.dart';
import 'moderation_text.dart';

import '../../../injection_container.dart';

import '../../controllers/social_controller.dart';

import '../../services/shell_navigation_store.dart';

import '../../theme/app_palette.dart';

import '../profile/avatar_catalog.dart';

import '../../../domain/services/achievement_service.dart';

class PublicProfilePage extends StatefulWidget {
  final String uid;

  final String fallbackName;

  final String fallbackUsername;

  const PublicProfilePage({
    super.key,

    required this.uid,

    required this.fallbackName,

    required this.fallbackUsername,
  });

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  UserProfile? _targetProfile;
  UserProfile? _myProfile;

  bool _isLoading = true;
  bool _isFriendActionInProgress = false;
  bool _isBlockedByMe = false;
  bool _isModerationInProgress = false;

  String? _loadError;

  late final SocialController _socialCtrl;

  @override
  void initState() {
    super.initState();

    _socialCtrl = sl<SocialController>();

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;

      _loadError = null;
    });

    try {
      final profiles = sl<UserProfileUseCases>();
      final profile = await profiles.getUserProfile(widget.uid);
      final myUid = _socialCtrl.currentUserId;
      final myProfile = myUid.isEmpty ? null : await profiles.getUserProfile(myUid);
      final blockedIds = myUid.isEmpty
          ? const <String>[]
          : await sl<UserModerationUseCases>().getBlockedUserIds(myUid);

      if (!mounted) return;

      setState(() {
        _targetProfile = profile;
        _myProfile = myProfile;
        _isBlockedByMe = blockedIds.contains(widget.uid);

        _isLoading = false;

        _loadError = null;
      });
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unable to load a public profile',
        error: error,
        stackTrace: stackTrace,
        name: 'PublicProfilePage',
      );
      if (!mounted) return;

      setState(() {
        _isLoading = false;

        _loadError = 'error_load_profile';
      });
    }
  }

  void _onFriendAction(String action) async {
    if (_isFriendActionInProgress) return;

    final myUid = _socialCtrl.currentUserId;
    final target = _targetProfile;
    final me = _myProfile;
    if (target == null || me == null || myUid.isEmpty) return;

    _isFriendActionInProgress = true;

    final previousTargetFriends = List<String>.from(target.friends);
    final previousMyFriends = List<String>.from(me.friends);
    final previousSent = List<String>.from(me.sentFriendRequests);
    final previousReceived = List<String>.from(me.receivedFriendRequests);

    // Aggiornamento ottimistico: il pulsante cambia immediatamente senza
    // sostituire l'intera pagina con il loader.
    setState(() {
      switch (action) {
        case 'send':
          if (!me.sentFriendRequests.contains(widget.uid)) {
            me.sentFriendRequests.add(widget.uid);
          }
          break;
        case 'cancel':
          me.sentFriendRequests.remove(widget.uid);
          break;
        case 'accept':
          me.receivedFriendRequests.remove(widget.uid);
          if (!me.friends.contains(widget.uid)) me.friends.add(widget.uid);
          if (!target.friends.contains(myUid)) target.friends.add(myUid);
          break;
        case 'reject':
          me.receivedFriendRequests.remove(widget.uid);
          break;
        case 'remove':
          me.friends.remove(widget.uid);
          target.friends.remove(myUid);
          break;
      }
    });

    final success = await _socialCtrl.handleFriendAction(action, widget.uid);
    if (!mounted) return;

    if (success) {
      // Invio e annullamento modificano soltanto lo stato delle richieste:
      // il profilo già in memoria contiene la nuova situazione, quindi non
      // serve ricaricarlo da Firestore (e mostrare il loader a tutta pagina).
      if (action == 'send' || action == 'cancel') {
        _isFriendActionInProgress = false;
        return;
      }

      // Accept/remove aggiornano anche statistiche e amicizie reciproche:
      // in questi casi manteniamo il refresh dal server.
      await _loadProfile();
      if (!mounted) return;
      _isFriendActionInProgress = false;
      return;
    }

    setState(() {
      target.friends
        ..clear()
        ..addAll(previousTargetFriends);
      me.friends
        ..clear()
        ..addAll(previousMyFriends);
      me.sentFriendRequests
        ..clear()
        ..addAll(previousSent);
      me.receivedFriendRequests
        ..clear()
        ..addAll(previousReceived);
      _isFriendActionInProgress = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.errorOperationFailed),
        backgroundColor: AppPalette.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleModerationMenu(String action) async {
    if (action == 'report') {
      await _showReportDialog();
    } else if (action == 'block') {
      await _confirmAndBlock();
    } else if (action == 'unblock') {
      await _unblockTarget();
    }
  }

  Future<void> _showReportDialog() async {
    final target = _targetProfile;
    final reporterUid = _socialCtrl.currentUserId;
    if (target == null || reporterUid.isEmpty) return;

    String reportedField = 'displayName';
    String reason = 'inappropriate_name';
    String details = '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isEnglish =
              Localizations.localeOf(context).languageCode == 'en';
          String t(String it, String en) => isEnglish ? en : it;

          return AlertDialog(
            title: Text(t('Segnala profilo', 'Report profile')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t(
                    'Quale contenuto vuoi segnalare?',
                    'Which profile content do you want to report?',
                  )),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: reportedField,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'displayName',
                        child: Text(t('Nome visualizzato', 'Display name')),
                      ),
                      DropdownMenuItem(
                        value: 'username',
                        child: Text(t('Username', 'Username')),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => reportedField = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(t('Motivo della segnalazione', 'Reason for reporting')),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: reason,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'inappropriate_name',
                        child: Text(t('Nome o username inappropriato', 'Inappropriate name or username')),
                      ),
                      DropdownMenuItem(
                        value: 'impersonation',
                        child: Text(t('Impersonificazione', 'Impersonation')),
                      ),
                      DropdownMenuItem(
                        value: 'harassment',
                        child: Text(t('Molestie o bullismo', 'Harassment or bullying')),
                      ),
                      DropdownMenuItem(
                        value: 'spam',
                        child: Text(t('Spam', 'Spam')),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text(t('Altro', 'Other')),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setDialogState(() => reason = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    maxLength: 500,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: t(
                        'Ulteriori dettagli (facoltativi)',
                        'Additional details (optional)',
                      ),
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    onChanged: (value) => details = value,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(t('Annulla', 'Cancel')),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(dialogContext, true),
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: Text(t('Invia', 'Submit')),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await sl<UserModerationUseCases>().reportUser(
        reporterUid: reporterUid,
        reportedUid: target.uid,
        reportedField: reportedField,
        reason: reason,
        details: details,
      );
      if (!mounted) return;
      final isEnglish = Localizations.localeOf(context).languageCode == 'en';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish
              ? 'Report sent. Thank you.'
              : 'Segnalazione inviata. Grazie.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unable to submit a user report',
        error: error,
        stackTrace: stackTrace,
        name: 'PublicProfilePage',
      );
      if (!mounted) return;
      final isEnglish = Localizations.localeOf(context).languageCode == 'en';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish
              ? 'Unable to send the report. Please try again.'
              : 'Impossibile inviare la segnalazione. Riprova.'),
          backgroundColor: AppPalette.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmAndBlock() async {
    final target = _targetProfile;
    if (target == null || _isModerationInProgress) return;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEnglish ? 'Block user?' : 'Bloccare questo utente?'),
        content: Text(isEnglish
            ? 'They will no longer be able to send you friend requests. Any existing friendship or pending request will be removed. You can unblock them in Settings.'
            : 'Non potrà più inviarti richieste di amicizia. Le amicizie e le richieste in sospeso verranno rimosse. Potrai sbloccarlo dalle Impostazioni.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(isEnglish ? 'Cancel' : 'Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppPalette.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(isEnglish ? 'Block' : 'Blocca'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isModerationInProgress = true);
    try {
      await sl<UserModerationUseCases>().blockUser(
        _socialCtrl.currentUserId,
        target.uid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish ? 'User blocked.' : 'Utente bloccato.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unable to complete user block',
        error: error,
        stackTrace: stackTrace,
        name: 'PublicProfilePage',
      );
      var blockWasCreated = false;
      try {
        blockWasCreated = (await sl<UserModerationUseCases>()
                .getBlockedUserIds(_socialCtrl.currentUserId))
            .contains(target.uid);
      } catch (_) {
        // The original error remains the most useful diagnostic.
      }
      if (!mounted) return;
      setState(() {
        _isModerationInProgress = false;
        _isBlockedByMe = blockWasCreated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(blockWasCreated
              ? (isEnglish
                  ? 'The block is active, but some existing social data could not be cleaned up. Please retry later.'
                  : 'Il blocco è attivo, ma non è stato possibile ripulire tutti i dati social. Riprova più tardi.')
              : (isEnglish
                  ? 'Unable to block this user. Please try again.'
                  : 'Impossibile bloccare questo utente. Riprova.')),
          backgroundColor: AppPalette.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (blockWasCreated) await _loadProfile();
      return;
    }
    if (mounted) setState(() => _isModerationInProgress = false);
  }

  Future<void> _unblockTarget() async {
    final target = _targetProfile;
    if (target == null || _isModerationInProgress) return;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    setState(() => _isModerationInProgress = true);
    try {
      await sl<UserModerationUseCases>().unblockUser(
        _socialCtrl.currentUserId,
        target.uid,
      );
      if (!mounted) return;
      setState(() => _isBlockedByMe = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish ? 'User unblocked.' : 'Utente sbloccato.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unable to unblock user',
        error: error,
        stackTrace: stackTrace,
        name: 'PublicProfilePage',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish
              ? 'Unable to unblock this user.'
              : 'Impossibile sbloccare questo utente.'),
          backgroundColor: AppPalette.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isModerationInProgress = false);
    }
  }

  // Visualizza la lista amici dell'utente

  void _showFriendsList(List<String> friendUids, ThemeData theme) async {
    final users = await _socialCtrl.loadUsersList(friendUids);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,

      backgroundColor: theme.colorScheme.surface,

      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),

      builder: (_) => _buildUserListSheet(
        AppLocalizations.of(
          context,
        )!.socialFriendsOf(_targetProfile!.displayName),

        users,

        theme,
      ),
    );
  }

  Widget _buildUserListSheet(
    String title,

    List<UserProfile> users,

    ThemeData theme,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,

      minChildSize: 0.3,

      maxChildSize: 0.9,

      expand: false,

      builder: (_, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),

            // Drag handle
            Container(
              width: 40,

              height: 4,

              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),

                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              title,

              style: TextStyle(
                fontSize: 20,

                fontWeight: FontWeight.bold,

                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            Divider(
              color: theme.colorScheme.surfaceContainerHighest,

              height: 1,
            ),

            if (users.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.socialNoUserFound,

                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,

                  itemCount: users.length,

                  padding: const EdgeInsets.symmetric(vertical: 8),

                  itemBuilder: (context, i) {
                    final u = users[i];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,

                        vertical: 4,
                      ),

                      leading: CircleAvatar(
                        radius: 24,

                        backgroundColor: AppPalette.tan.withValues(alpha: 0.2),
                        backgroundImage: AssetImage(
                          avatarById(u.avatarId).assetPath,
                        ),
                      ),

                      title: Text(
                        u.displayName,

                        style: TextStyle(
                          color: theme.colorScheme.onSurface,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Text(
                        '@${u.username}',

                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      trailing: Icon(
                        Icons.chevron_right,

                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),

                      onTap: () {
                        Navigator.pop(context); // Chiude la bottom sheet

                        if (u.uid == _socialCtrl.currentUserId) {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);

                          ShellNavigationStore.goToTab(2);

                          return;
                        }

                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) => PublicProfilePage(
                              uid: u.uid,

                              fallbackName: u.displayName,

                              fallbackUsername: u.username,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,

        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),

        body: const Center(
          child: CircularProgressIndicator(color: AppPalette.olive),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,

        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),

        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),

                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Icon(
                    Icons.error_outline,

                    color: theme.colorScheme.error,

                    size: 48,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    AppLocalizations.of(context)!.errorLoadProfile,

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,

                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 24),

                  FilledButton.icon(
                    onPressed: _loadProfile,

                    icon: const Icon(Icons.refresh),

                    label: Text(AppLocalizations.of(context)!.buttonRetry),

                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,

                      foregroundColor: theme.colorScheme.onError,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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

    final profile = _targetProfile!;

    final avatar = avatarById(profile.avatarId);

    final myUid = _socialCtrl.currentUserId;

    final myProfile = _myProfile;
    final isFriend = myProfile?.friends.contains(profile.uid) == true ||
        profile.friends.contains(myUid);
    final requestSent = myProfile?.sentFriendRequests.contains(profile.uid) == true;
    final requestReceived = myProfile?.receivedFriendRequests.contains(profile.uid) == true;

    final bestTourTimeLabel = profile.bestTourTimeSeconds > 0
        ? '${profile.bestTourTimeSeconds ~/ 60}m ${profile.bestTourTimeSeconds % 60}s'
        : '--';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,

        scrolledUnderElevation: 0,

        title: Text(
          widget.fallbackUsername.startsWith('@')
              ? widget.fallbackUsername
              : '@${widget.fallbackUsername}',

          style: TextStyle(
            color: theme.colorScheme.onSurface,

            fontWeight: FontWeight.bold,

            letterSpacing: 0.5,
          ),
        ),

        centerTitle: true,

        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: myUid == profile.uid
            ? const []
            : [
                PopupMenuButton<String>(
                  enabled: !_isModerationInProgress,
                  tooltip: ModerationText.of(
                    context,
                    it: 'Opzioni profilo',
                    en: 'Profile options',
                  ),
                  onSelected: _handleModerationMenu,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          const Icon(Icons.flag_outlined, color: AppPalette.danger),
                          const SizedBox(width: 12),
                          Text(ModerationText.of(
                            context,
                            it: 'Segnala profilo',
                            en: 'Report profile',
                          )),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _isBlockedByMe ? 'unblock' : 'block',
                      child: Row(
                        children: [
                          Icon(
                            _isBlockedByMe ? Icons.person_add_alt_1 : Icons.block,
                            color: AppPalette.danger,
                          ),
                          const SizedBox(width: 12),
                          Text(ModerationText.of(
                            context,
                            it: _isBlockedByMe ? 'Sblocca utente' : 'Blocca utente',
                            en: _isBlockedByMe ? 'Unblock user' : 'Block user',
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),

        child: Column(
          children: [
            // Header Profilo
            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),

              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light
                    ? Colors.white
                    : theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),

                borderRadius: BorderRadius.circular(32),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: theme.brightness == Brightness.light ? 0.04 : 0.2,
                    ),

                    blurRadius: 24,

                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                children: [
                  CircleAvatar(
                    radius: 56,

                    backgroundColor: avatar.background,
                    backgroundImage: AssetImage(avatar.assetPath),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    profile.displayName,

                    style: TextStyle(
                      fontSize: 26,

                      fontWeight: FontWeight.w800,

                      color: theme.colorScheme.onSurface,

                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,

                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Text(
                      '@${profile.username}',

                      style: TextStyle(
                        fontSize: 14,

                        fontWeight: FontWeight.w600,

                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Bottoni Amicizia
                  if (myUid != profile.uid) ...[
                    if (_isBlockedByMe)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          ModerationText.of(
                            context,
                            it: 'Hai bloccato questo utente.',
                            en: 'You have blocked this user.',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (isFriend)
                      FilledButton.tonalIcon(
                        onPressed: () => _onFriendAction('remove'),

                        icon: const Icon(Icons.person_remove_rounded, size: 20),

                        label: Text(
                          AppLocalizations.of(context)!.removeFriendship,

                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        style: FilledButton.styleFrom(
                          backgroundColor: AppPalette.danger.withValues(
                            alpha: 0.1,
                          ),

                          foregroundColor: AppPalette.danger,

                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,

                            vertical: 12,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      )
                    else if (requestSent)
                      FilledButton.tonalIcon(
                        onPressed: () => _onFriendAction('cancel'),

                        icon: const Icon(Icons.how_to_reg_rounded, size: 20),

                        label: Text(
                          AppLocalizations.of(context)!.socialRequestSent,

                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        style: FilledButton.styleFrom(
                          backgroundColor: AppPalette.tan.withValues(
                            alpha: 0.2,
                          ),

                          foregroundColor: AppPalette.olive,

                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,

                            vertical: 12,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      )
                    else if (requestReceived)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _onFriendAction('accept'),

                              style: FilledButton.styleFrom(
                                backgroundColor: AppPalette.olive,

                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),

                              child: Text(
                                AppLocalizations.of(context)!.socialAccept,

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _onFriendAction('reject'),

                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppPalette.danger,

                                side: BorderSide(
                                  color: AppPalette.danger.withValues(
                                    alpha: 0.5,
                                  ),

                                  width: 1.5,
                                ),

                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),

                              child: Text(
                                AppLocalizations.of(context)!.socialReject,

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      FilledButton.icon(
                        onPressed: () => _onFriendAction('send'),

                        icon: const Icon(Icons.person_add_rounded, size: 20),

                        label: Text(
                          AppLocalizations.of(context)!.socialAddFriend,

                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        style: FilledButton.styleFrom(
                          backgroundColor: AppPalette.olive,

                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,

                            vertical: 12,
                          ),

                          elevation: 2,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),
                  ],

                  // Hero card pubblica: solo conteggi aggregati, senza dati di dettaglio.
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),

                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                      children: [
                        Expanded(
                          child: _buildMiniStat(
                            AppLocalizations.of(context)!.publicStatFriends,

                            profile.friendsCount.toString(),

                            theme,

                            onTap: isFriend || myUid == profile.uid
                                ? () => _showFriendsList(profile.friends, theme)
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.socialMustBeFriend,
                                        ),

                                        behavior: SnackBarBehavior.floating,

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                          ),
                        ),

                        Container(
                          height: 32,

                          width: 1.5,

                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.2,
                          ),
                        ),

                        Expanded(
                          child: _buildMiniStat(
                            AppLocalizations.of(context)!.publicStatPoints,

                            profile.xp.toString(),

                            theme,
                          ),
                        ),

                        Container(
                          height: 32,

                          width: 1.5,

                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.2,
                          ),
                        ),

                        Expanded(
                          child: _buildMiniStat(
                            AppLocalizations.of(context)!.tourLabel,

                            profile.totalToursCompleted.toString(),

                            theme,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (isFriend || myUid == profile.uid) ...[
              _SectionLabel(AppLocalizations.of(context)!.publicStatDetailed),

              const SizedBox(height: 16),

              // Grid Statistiche
              GridView.count(
                crossAxisCount: 2,

                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                crossAxisSpacing: 16,

                mainAxisSpacing: 16,

                childAspectRatio: 1.25,

                children: [
                  _buildStatCard(
                    AppLocalizations.of(context)!.publicStatAchievements,

                    '${profile.achievementsCount}',

                    Icons.emoji_events_rounded,

                    AppPalette.olive,

                    theme,
                  ),

                  _buildStatCard(
                    AppLocalizations.of(context)!.publicStatBestScore,

                    '${profile.maxQuizScore}%',

                    Icons.bolt_rounded,

                    Colors.orange.shade400,

                    theme,
                  ),

                  _buildStatCard(
                    AppLocalizations.of(context)!.publicStatSites,

                    '${profile.visitedCount}',

                    Icons.map_rounded,

                    AppPalette.moss,

                    theme,
                  ),

                  _buildStatCard(
                    AppLocalizations.of(context)!.publicStatQuiz,

                    '${profile.totalQuizCompleted}',

                    Icons.fact_check_rounded,

                    AppPalette.tan,

                    theme,
                  ),

                  _buildStatCard(
                    AppLocalizations.of(context)!.publicStatBestTime,

                    bestTourTimeLabel,

                    Icons.timer_rounded,

                    Colors.blue.shade400,

                    theme,
                  ),

                  _buildStatCard(
                    AppLocalizations.of(context)!.publicStatCorrectAnswers,

                    '${profile.totalCorrectAnswers}',

                    Icons.check_circle_rounded,

                    AppPalette.moss,

                    theme,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Achievement Grid ────────────────────────────────────────
              _SectionLabel(AppLocalizations.of(context)!.sectionAchievements),

              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.78,
                ),
                itemCount: AchievementService.all.length,
                itemBuilder: (context, i) {
                  final ach = AchievementService.all[i];
                  final isUnlocked = profile.unlockedAchievements.contains(
                    ach.id,
                  );
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(
                            24,
                            20,
                            24,
                            8,
                          ),
                          title: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipOval(
                                child: SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: isUnlocked
                                      ? Image.asset(
                                          ach.assetPath,
                                          fit: BoxFit.cover,
                                        )
                                      : ColorFiltered(
                                          colorFilter:
                                              const ColorFilter.matrix([
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0.3,
                                                0,
                                              ]),
                                          child: Image.asset(
                                            ach.assetPath,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isUnlocked
                                    ? AppLocalizations.of(
                                        context,
                                      )!.achievementTitle(ach.id)
                                    : '???',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          content: Text(
                            isUnlocked
                                ? AppLocalizations.of(
                                    context,
                                  )!.achievementDescription(ach.id)
                                : AppLocalizations.of(
                                    context,
                                  )!.achievementDescription(ach.id),
                            style: TextStyle(
                              color: isUnlocked
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context)!.buttonOk),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: isUnlocked ? 1.0 : 0.55,
                          child: ClipOval(
                            child: isUnlocked
                                ? Image.asset(
                                    ach.assetPath,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.matrix([
                                      0.2126,
                                      0.7152,
                                      0.0722,
                                      0,
                                      0,
                                      0.2126,
                                      0.7152,
                                      0.0722,
                                      0,
                                      0,
                                      0.2126,
                                      0.7152,
                                      0.0722,
                                      0,
                                      0,
                                      0,
                                      0,
                                      0,
                                      1,
                                      0,
                                    ]),
                                    child: Image.asset(
                                      ach.assetPath,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isUnlocked
                              ? AppLocalizations.of(
                                  context,
                                )!.achievementTitle(ach.id)
                              : '???',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isUnlocked
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isUnlocked
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.45,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ] else ...[
              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),

                      theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.2,
                      ),
                    ],

                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(28),

                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),

                    width: 1,
                  ),
                ),

                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,

                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),

                            blurRadius: 10,

                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Icon(
                        Icons.lock_rounded,

                        size: 32,

                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      AppLocalizations.of(context)!.publicStatsPrivateTitle,

                      style: TextStyle(
                        fontSize: 20,

                        fontWeight: FontWeight.w800,

                        color: theme.colorScheme.onSurface,

                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      AppLocalizations.of(context)!.publicStatsPrivateBody,

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 15,

                        height: 1.4,

                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    String label,

    String value,

    ThemeData theme, {

    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(12),

      child: Column(
        children: [
          Text(
            value,

            style: TextStyle(
              fontSize: 20,

              fontWeight: FontWeight.w900,

              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,

            style: TextStyle(
              fontSize: 12,

              fontWeight: FontWeight.w600,

              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,

    String value,

    IconData icon,

    Color color,

    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? Colors.white
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),

        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),

            blurRadius: 16,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Container(
            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: color, size: 22),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                value,

                style: TextStyle(
                  fontSize: 22,

                  fontWeight: FontWeight.w800,

                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                label,

                style: TextStyle(
                  fontSize: 13,

                  color: theme.colorScheme.onSurfaceVariant,

                  fontWeight: FontWeight.w600,
                ),

                maxLines: 1,

                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,

      child: Row(
        children: [
          Container(
            width: 4,

            height: 20,

            margin: const EdgeInsets.only(right: 12),

            decoration: BoxDecoration(
              color: AppPalette.olive,

              borderRadius: BorderRadius.circular(4),
            ),
          ),

          Text(
            text,

            style: TextStyle(
              fontSize: 18,

              fontWeight: FontWeight.w800,

              color: theme.colorScheme.onSurface,

              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
