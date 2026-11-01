import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/userprofile.dart';
import '../../domain/usecases/user_profile_use_cases.dart';
import '../../domain/usecases/user_progress_use_cases.dart';
import '../../domain/usecases/user_social_use_cases.dart';

class LeaderboardEntry {
  final String uid;
  final String displayName;
  final String username;
  final String avatarId;
  final int xp;
  final int rank;

  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.avatarId,
    required this.xp,
    required this.rank,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> data, int rank) {
    return LeaderboardEntry(
      uid: data['uid'] as String,
      displayName: (data['displayName'] as String?)?.trim().isNotEmpty == true
          ? (data['displayName'] as String).trim()
          : 'default_user',
      username: (data['username'] as String?)?.trim() ?? '',
      avatarId: (data['avatarId'] as String?)?.trim().isNotEmpty == true
          ? (data['avatarId'] as String).trim()
          : 'military_tech',
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      rank: rank,
    );
  }
}

class SocialController extends ChangeNotifier {
  SocialController({
    required UserProfileUseCases profileUseCases,
    required UserProgressUseCases progressUseCases,
    required UserSocialUseCases socialUseCases,
  }) : _profileUseCases = profileUseCases,
       _progressUseCases = progressUseCases,
       _socialUseCases = socialUseCases {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  final UserProfileUseCases _profileUseCases;
  final UserProgressUseCases _progressUseCases;
  final UserSocialUseCases _socialUseCases;
  StreamSubscription<List<Map<String, dynamic>>>? _leaderboardSub;
  StreamSubscription<UserProfile?>? _profileSub;
  StreamSubscription<User?>? _authSub;
  String? _leaderboardUid;
  UserProfile? _currentUserProfile;
  int? _currentUserRank;
  String? _rankedUserId;
  int? _rankedUserXp;
  int _rankRequestToken = 0;
  Timer? _searchDebounce;
  bool _isDisposed = false;
  int? _lastObservedFriendCount;

  List<LeaderboardEntry> leaderboard = [];
  bool isLeaderboardLoading = true;

  // RIMOSSA LA VARIABILE FISSA LeaderboardEntry? currentUserEntry;

  List<UserProfile> searchResults = [];
  bool isSearching = false;
  String? errorMessage;
  bool requiresMoreSearchChars = false;
  String _lastIssuedQuery = '';
  int _searchSequence = 0;

  // Esponiamo l'ID corrente alla UI senza usare FirebaseAuth
  String get currentUserId => _profileUseCases.getCurrentUserUid() ?? '';

  LeaderboardEntry? get currentUserEntry {
    final myUid = currentUserId;
    if (myUid.isEmpty) return null;
    try {
      return leaderboard.firstWhere((e) => e.uid == myUid);
    } catch (_) {
      final p = _currentUserProfile;
      if (p != null) {
        return LeaderboardEntry(
          uid: p.uid,
          displayName: p.displayName,
          username: p.username,
          avatarId: p.avatarId,
          xp: p.xp,
          rank: _currentUserRank ?? 0,
        );
      }
      return null;
    }
  }

  Future<void> _refreshCurrentUserRank(
    String uid,
    int xp, {
    bool force = false,
  }) async {
    if (!force && _rankedUserId == uid && _rankedUserXp == xp && _currentUserRank != null) {
      return;
    }
    final token = ++_rankRequestToken;
    _rankedUserId = uid;
    _rankedUserXp = xp;
    try {
      final rank = await _progressUseCases.getLeaderboardRank(uid: uid);
      if (_isDisposed || token != _rankRequestToken || currentUserId != uid) return;
      _currentUserRank = rank ?? 0;
    } catch (_) {
      if (_isDisposed || token != _rankRequestToken || currentUserId != uid) return;
      _currentUserRank = 0;
    }
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  void _onAuthChanged(User? user) {
    final uid = user?.uid;
    if (uid == _leaderboardUid) return;
    _leaderboardSub?.cancel();
    _leaderboardSub = null;
    _profileSub?.cancel();
    _profileSub = null;
    _currentUserProfile = null;
    _lastObservedFriendCount = null;
    _currentUserRank = null;
    _rankedUserId = null;
    _rankedUserXp = null;
    _rankRequestToken++;
    _leaderboardUid = uid;
    leaderboard = [];
    errorMessage = null;
    isLeaderboardLoading = uid != null;
    if (uid != null) {
      _startLeaderboardListener();
      _startProfileListener(uid);
    }
    _safeNotifyListeners();
  }

  void _startProfileListener(String uid) {
    _profileSub?.cancel();
    _profileSub = _profileUseCases.getUserProfileStream(uid).listen((profile) {
      _currentUserProfile = profile;
      if (profile != null) {
        final friendCount = profile.friends.length;
        if (_lastObservedFriendCount == null ||
            friendCount > _lastObservedFriendCount!) {
          unawaited(
            _progressUseCases.ensureFriendAchievements(uid: uid).catchError(
              (Object error, StackTrace stackTrace) {
                // Il prossimo aggiornamento profilo riproverà il controllo.
              },
            ),
          );
        }
        _lastObservedFriendCount = friendCount;
      }
      if (profile != null && !leaderboard.any((entry) => entry.uid == profile.uid)) {
        unawaited(_refreshCurrentUserRank(profile.uid, profile.xp));
      }
      _safeNotifyListeners();
    });
  }

  void _startLeaderboardListener() {
    if (currentUserId.isEmpty) {
      leaderboard = [];
      isLeaderboardLoading = false;
      _safeNotifyListeners();
      return;
    }
    _leaderboardSub?.cancel();
    _leaderboardSub = _progressUseCases
        .getLeaderboardStream(uid: currentUserId, limit: 50)
        .listen(
          (docsData) {
            leaderboard = docsData
                .asMap()
                .entries
                .map((entry) {
                  return LeaderboardEntry.fromMap(entry.value, entry.key + 1);
                })
                .toList(growable: false);
            isLeaderboardLoading = false;
            final myIndex = leaderboard.indexWhere((entry) => entry.uid == currentUserId);
            if (myIndex >= 0) {
              _currentUserRank = myIndex + 1;
            } else if (_currentUserProfile != null) {
              unawaited(_refreshCurrentUserRank(
                _currentUserProfile!.uid,
                _currentUserProfile!.xp,
                force: true,
              ));
            }
            _safeNotifyListeners();
          },
          onError: (error) {
            isLeaderboardLoading = false;
            errorMessage = 'errorLoadLeaderboard';
            _leaderboardSub = null; // Firestore termina lo stream dopo un errore di permessi.
            _safeNotifyListeners();
          },
        );
  }

  void retryLeaderboard() {
    _leaderboardSub?.cancel();
    _leaderboardSub = null;
    errorMessage = null;
    isLeaderboardLoading = currentUserId.isNotEmpty;
    _safeNotifyListeners();
    _startLeaderboardListener();
  }

  Future<void> search(String query) async {
    _searchDebounce?.cancel();
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty || normalizedQuery.length < 2) {
      _lastIssuedQuery = '';
      searchResults = [];
      isSearching = false;
      errorMessage = null;
      requiresMoreSearchChars =
          normalizedQuery.isNotEmpty && normalizedQuery.length < 2;
      _safeNotifyListeners();
      return;
    }
    requiresMoreSearchChars = false;

    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (_isDisposed) return;
      if (normalizedQuery == _lastIssuedQuery) return;

      _lastIssuedQuery = normalizedQuery;
      isSearching = true;
      errorMessage = null;
      _safeNotifyListeners();

      final searchId = ++_searchSequence;
      try {
        final results = await _socialUseCases.searchUsers(normalizedQuery);
        if (_isDisposed || searchId != _searchSequence) return;
        searchResults = results;
      } catch (e) {
        if (_isDisposed || searchId != _searchSequence) return;
        errorMessage = 'errorSearch';
      } finally {
        if (!_isDisposed && searchId == _searchSequence) {
          isSearching = false;
          _safeNotifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchDebounce?.cancel();
    _leaderboardSub?.cancel();
    _profileSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  Future<List<UserProfile>> loadUsersList(List<String> uids) async {
    if (uids.isEmpty) return [];
    return await _socialUseCases.getUsersByIds(uids);
  }

  Future<bool> handleFriendAction(String action, String targetUid) async {
    final cUid = currentUserId;
    if (cUid.isEmpty) return false;

    try {
      switch (action) {
        case 'send':
          await _socialUseCases.sendFriendRequest(cUid, targetUid);
          break;
        case 'cancel':
          await _socialUseCases.cancelFriendRequest(cUid, targetUid);
          break;
        case 'accept':
          await _socialUseCases.acceptFriendRequest(cUid, targetUid);
          break;
        case 'reject':
          await _socialUseCases.rejectFriendRequest(cUid, targetUid);
          break;
        case 'remove':
          await _socialUseCases.removeFriend(cUid, targetUid);
          break;
      }
      return true;
    } catch (e) {
      errorMessage = 'errorAction';
      _safeNotifyListeners();
      return false;
    }
  }
}
