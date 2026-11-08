import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/userprofile.dart';
import '../../../domain/usecases/user_moderation_use_cases.dart';
import '../../../domain/usecases/user_social_use_cases.dart';
import '../../../injection_container.dart';
import '../../theme/app_palette.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  bool _loading = true;
  bool _working = false;
  String? _error;
  List<String> _blockedIds = const [];
  Map<String, UserProfile> _profiles = const {};

  bool get _isEnglish =>
      Localizations.localeOf(context).languageCode == 'en';

  String _t(String it, String en) => _isEnglish ? en : it;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.isEmpty) {
        throw StateError('Utente non autenticato.');
      }
      final moderation = sl<UserModerationUseCases>();
      final ids = await moderation.getBlockedUserIds(uid);
      final social = sl<UserSocialUseCases>();
      List<UserProfile> profiles;
      try {
        profiles = await social.getUsersByIds(ids);
      } catch (_) {
        // A blocked account may have been deleted or suspended. Keep the
        // safety list usable so the owner can still remove that block entry.
        profiles = [];
        for (final id in ids) {
          try {
            profiles.addAll(await social.getUsersByIds([id]));
          } catch (_) {
            // The UID remains visible and can still be unblocked below.
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _blockedIds = ids;
        _profiles = {for (final profile in profiles) profile.uid: profile};
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _t(
          'Impossibile caricare gli utenti bloccati.',
          'Unable to load blocked users.',
        );
      });
    }
  }

  Future<void> _unblock(String targetUid) async {
    if (_working) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t('Sbloccare utente?', 'Unblock user?')),
        content: Text(_t(
          'Lo sblocco non ripristina automaticamente amicizie o richieste precedenti.',
          'Unblocking does not restore previous friendships or requests.',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_t('Annulla', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_t('Sblocca', 'Unblock')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _working = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await sl<UserModerationUseCases>().unblockUser(uid, targetUid);
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t(
            'Impossibile sbloccare questo utente.',
            'Unable to unblock this user.',
          )),
          backgroundColor: AppPalette.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('Utenti bloccati', 'Blocked users')),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppPalette.olive),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: _load,
                          child: Text(_t('Riprova', 'Retry')),
                        ),
                      ],
                    ),
                  ),
                )
              : _blockedIds.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _t(
                            'Non hai bloccato nessun utente.',
                            'You have not blocked anyone.',
                          ),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: _blockedIds.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final uid = _blockedIds[index];
                        final profile = _profiles[uid];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppPalette.danger.withValues(alpha: 0.12),
                            child: const Icon(
                              Icons.block,
                              color: AppPalette.danger,
                            ),
                          ),
                          title: Text(
                            profile?.displayName ??
                                _t('Utente non disponibile', 'Unavailable user'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            profile == null
                                ? uid
                                : '@${profile.username}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: TextButton(
                            onPressed: _working ? null : () => _unblock(uid),
                            child: Text(_t('Sblocca', 'Unblock')),
                          ),
                        );
                      },
                    ),
    );
  }
}
