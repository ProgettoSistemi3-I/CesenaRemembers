import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/services/achievement_service.dart';

class UserProgressDataSource {
  UserProgressDataSource({required this._firestore});

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _publicProfiles =>
      _firestore.collection('public_profiles');
  CollectionReference<Map<String, dynamic>> get _friendStats =>
      _firestore.collection('friend_stats');
  CollectionReference<Map<String, dynamic>> get _leaderboard =>
      _firestore.collection('leaderboard');

  /// Shared ordering keeps the visible leaderboard and rank calculation in
  /// sync, including the ascending document-ID tie-break for equal XP.
  Query<Map<String, dynamic>> get _orderedLeaderboard => _leaderboard
      .orderBy('xp', descending: true)
      .orderBy(FieldPath.documentId);

  /// Classifica globale: legge UID/XP e arricchisce la Top 50 con il profilo.
  /// La proiezione pubblica espone solo gli aggregati della hero card;
  /// le statistiche dettagliate restano in friend_stats.
  Stream<List<Map<String, dynamic>>> getLeaderboardStream({
    required String uid,
    int limit = 50,
  }) {
    return _orderedLeaderboard
        .limit(limit.clamp(1, 50))
        .snapshots()
        .asyncMap((snapshot) async {
          final rows = await Future.wait(snapshot.docs.map((doc) async {
            try {
              final publicSnapshot = await _publicProfiles.doc(doc.id).get();
              if (!publicSnapshot.exists || publicSnapshot.data() == null) {
                return null;
              }
              return <String, dynamic>{
                ...publicSnapshot.data()!,
                'uid': doc.id,
                'xp': (doc.data()['xp'] as num?)?.toInt() ?? 0,
              };
            } catch (e, stackTrace) {
              AppLogger.error(
                'Impossibile recuperare public_profile per uid=${doc.id} (utente bannato o permessi negati): $e',
                error: e,
                stackTrace: stackTrace,
                name: 'UserProgressDataSource',
              );
              return null;
            }
          }));
          return rows.whereType<Map<String, dynamic>>().toList(growable: false);
        });
  }

  /// Rango globale reale: pagine da massimo 50, compatibili con Firestore Rules.
  /// Legge solo UID e XP, non i profili o le statistiche degli altri utenti.
  Future<int?> getLeaderboardRank({required String uid}) async {
    final baseQuery = _orderedLeaderboard;
    var query = baseQuery.limit(50);
    var rank = 0;
    while (true) {
      final page = await query.get();
      for (final doc in page.docs) {
        rank++;
        if (doc.id == uid) return rank;
      }
      if (page.docs.length < 50) return null;
      query = baseQuery.startAfterDocument(page.docs.last).limit(50);
    }
  }

  /// Ricalcola in modo idempotente gli achievement legati al numero di amici.
  /// Viene chiamato sul documento del proprietario quando il suo stream profilo
  /// rileva una variazione della lista amici (e anche alla prima snapshot, per
  /// recuperare eventuali badge maturati mentre l'app era chiusa).
  Future<void> ensureFriendAchievements({required String uid}) async {
    final userRef = _users.doc(uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() ?? <String, dynamic>{};
      final friends = List<String>.from(data['friends'] ?? const []);
      final unlocked = List<String>.from(
        data['unlockedAchievements'] ?? const [],
      );
      final pending = List<String>.from(
        data['pendingAchievements'] ?? const [],
      );
      final awards = AchievementService.evaluateOnFriendAdded(
        alreadyUnlocked: [...unlocked, ...pending],
        friendCount: friends.length,
      );
      if (awards.isEmpty) return;

      transaction.update(userRef, {
        'pendingAchievements': FieldValue.arrayUnion(awards),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// [isTourComplete] deve essere true solo sull'ultima tappa del tour,
  /// quando si vuole registrare il tempo totale e valutare gli achievement
  /// legati al completamento del tour intero.
  Future<void> registerQuizCompletion({
    required String uid,
    required String poiId,
    required int xpGained,
    required int correctAnswers,
    required int totalQuestions,
    required int tourElapsedSeconds,
    bool isTourComplete = false,
    int? tourTotalXp,
    int? tourCorrectAnswers,
    int? tourTotalQuestions,
  }) async {
    final userRef = _users.doc(uid);
    final publicRef = _publicProfiles.doc(uid);
    final statsRef = _friendStats.doc(uid);
    final leaderboardRef = _leaderboard.doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final publicSnapshot = await transaction.get(publicRef);
      final data = snapshot.data() ?? <String, dynamic>{};

      // ── Visited POIs ───────────────────────────────────────────────────
      final visitedPoiIds = List<String>.from(
        data['visitedPoiIds'] ?? const [],
      );
      final isFirstVisit = !visitedPoiIds.contains(poiId);
      if (isFirstVisit) visitedPoiIds.add(poiId);

      // ── XP ────────────────────────────────────────────────────────────
      final currentXp = (data['xp'] as num?)?.toInt() ?? 0;
      final nextXp = currentXp + xpGained;

      // ── Max XP in un singolo tour ─────────────────────────────────────
      final currentMaxSingleTourXp =
          (data['maxSingleTourXp'] as num?)?.toInt() ?? 0;
      final xpForCompletedTour = tourTotalXp ?? xpGained;
      final nextMaxSingleTourXp = isTourComplete &&
              xpForCompletedTour > currentMaxSingleTourXp
          ? xpForCompletedTour
          : currentMaxSingleTourXp;

      // ── Quiz stats ────────────────────────────────────────────────────
      final currentMaxQuizScore = (data['maxQuizScore'] as num?)?.toInt() ?? 0;
      final currentQuizCompleted =
          (data['totalQuizCompleted'] as num?)?.toInt() ?? 0;
      final currentToursCompleted =
          (data['totalToursCompleted'] as num?)?.toInt() ?? 0;
      final currentCorrectAnswers =
          (data['totalCorrectAnswers'] as num?)?.toInt() ?? 0;
      final nextQuizCompleted = currentQuizCompleted + 1;
      final nextToursCompleted = isTourComplete ? currentToursCompleted + 1 : currentToursCompleted;
      final nextCorrectAnswers = currentCorrectAnswers + correctAnswers;
      final quizScorePercent = totalQuestions <= 0
          ? 0
          : ((correctAnswers / totalQuestions) * 100).round();

      // ── Best tour time ─────────────────────────────────────────────────
      final currentBestTourTime =
          (data['bestTourTimeSeconds'] as num?)?.toInt() ?? 0;
      final nextBestTourTime = isTourComplete && tourElapsedSeconds > 0
          ? (currentBestTourTime == 0 || tourElapsedSeconds < currentBestTourTime
              ? tourElapsedSeconds
              : currentBestTourTime)
          : currentBestTourTime;

      // ── Achievements ───────────────────────────────────────────────────
      final alreadyUnlocked = List<String>.from(
        data['unlockedAchievements'] ?? const [],
      );
      final alreadyPending = List<String>.from(
        data['pendingAchievements'] ?? const [],
      );

      final newUnlocks = AchievementService.evaluateOnQuizCompletion(
        alreadyUnlocked: [...alreadyUnlocked, ...alreadyPending],
        visitedPoiIds: visitedPoiIds,
        totalQuizCompleted: nextQuizCompleted,
        totalToursCompleted: nextToursCompleted,
        totalXp: nextXp,
        // Sul completamento confrontiamo tutte le risposte del tour, non solo
        // quelle dell'ultima tappa.
        correctAnswers: isTourComplete
            ? (tourCorrectAnswers ?? correctAnswers)
            : correctAnswers,
        totalQuestions: isTourComplete
            ? (tourTotalQuestions ?? totalQuestions)
            : totalQuestions,
        tourElapsedSeconds: tourElapsedSeconds,
        bestTourTimeSeconds: nextBestTourTime,
        isTourComplete: isTourComplete,
      );
      
      final nextPending = [...alreadyPending, ...newUnlocks];

      // ── Write ─────────────────────────────────────────────────────────
      final nextMaxQuizScore = quizScorePercent > currentMaxQuizScore
          ? quizScorePercent
          : currentMaxQuizScore;
      final nextUserFields = <String, dynamic>{
        'visitedPoiIds': visitedPoiIds,
        'xp': nextXp,
        'leaderboardScore': nextXp,
        'maxSingleTourXp': nextMaxSingleTourXp,
        'maxQuizScore': nextMaxQuizScore,
        'totalQuizCompleted': nextQuizCompleted,
        'totalToursCompleted': nextToursCompleted,
        'totalCorrectAnswers': nextCorrectAnswers,
        'bestTourTimeSeconds': nextBestTourTime,
        'pendingAchievements': nextPending,
        'lastProgressAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      transaction.set(userRef, nextUserFields, SetOptions(merge: true));

      // Le campi di progressione non vengono più copiati nel profilo ricercabile.
      final currentPublic = publicSnapshot.data() ?? <String, dynamic>{};
      transaction.set(publicRef, {
        'displayName': data['displayName'] ?? currentPublic['displayName'] ?? 'Utente',
        'displayNameNormalized': data['displayNameNormalized'] ?? currentPublic['displayNameNormalized'] ?? 'utente',
        'username': data['username'] ?? currentPublic['username'] ?? '',
        'usernameNormalized': data['usernameNormalized'] ?? currentPublic['usernameNormalized'] ?? '',
        'avatarId': data['avatarId'] ?? currentPublic['avatarId'] ?? 'soldato',
        'xp': nextXp,
        'friendsCount': List<String>.from(data['friends'] ?? const []).length,
        'totalToursCompleted': nextToursCompleted,
        'profileCompleted': data['profileCompleted'] == true,
        'onboardingCompleted': data['onboardingCompleted'] == true,
      });
      transaction.set(leaderboardRef, {'uid': uid, 'xp': nextXp});
      transaction.set(statsRef, {
        'xp': nextXp,
        'visitedPoiIds': visitedPoiIds,
        'unlockedAchievements': alreadyUnlocked,
        'maxQuizScore': nextMaxQuizScore,
        'totalQuizCompleted': nextQuizCompleted,
        'totalToursCompleted': nextToursCompleted,
        'totalCorrectAnswers': nextCorrectAnswers,
        'bestTourTimeSeconds': nextBestTourTime,
        'maxSingleTourXp': nextMaxSingleTourXp,
        'friends': List<String>.from(data['friends'] ?? const []),
      });
    });
  }

  Future<void> unlockPendingAchievement(String uid, String achievementId) async {
    final userRef = _users.doc(uid);
    final statsRef = _friendStats.doc(uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() ?? {};
      final pending = List<String>.from(data['pendingAchievements'] ?? []);
      final unlocked = List<String>.from(data['unlockedAchievements'] ?? []);

      if (pending.contains(achievementId)) {
        pending.remove(achievementId);
        if (!unlocked.contains(achievementId)) {
          unlocked.add(achievementId);
        }

        transaction.update(userRef, {
          'pendingAchievements': pending,
          'unlockedAchievements': unlocked,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(statsRef, {
          'unlockedAchievements': unlocked,
        });
      }
    });
  }
}

