import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/services/achievement_service.dart';

class UserProgressDataSource {
  UserProgressDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _publicProfiles =>
      _firestore.collection('public_profiles');

  Stream<List<Map<String, dynamic>>> getLeaderboardStream({int limit = 50}) {
    return _publicProfiles.orderBy('xp', descending: true).limit(limit).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
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
        'unlockedAchievements': alreadyUnlocked,
        'pendingAchievements': nextPending,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      transaction.set(userRef, nextUserFields, SetOptions(merge: true));

      // La classifica e i profili pubblici usano una proiezione senza email,
      // preferenze, richieste di amicizia o token FCM.
      final currentPublic = publicSnapshot.data() ?? <String, dynamic>{};
      transaction.set(publicRef, {
        'displayName': data['displayName'] ?? currentPublic['displayName'] ?? 'Utente',
        'displayNameNormalized': data['displayNameNormalized'] ?? currentPublic['displayNameNormalized'] ?? 'utente',
        'username': data['username'] ?? currentPublic['username'] ?? '',
        'usernameNormalized': data['usernameNormalized'] ?? currentPublic['usernameNormalized'] ?? '',
        'avatarId': data['avatarId'] ?? currentPublic['avatarId'] ?? 'soldato',
        'profileCompleted': data['profileCompleted'] == true,
        'onboardingCompleted': data['onboardingCompleted'] == true,
        'xp': nextXp,
        'leaderboardScore': nextXp,
        'visitedPoiIds': visitedPoiIds,
        'unlockedAchievements': alreadyUnlocked,
        'maxQuizScore': nextMaxQuizScore,
        'totalQuizCompleted': nextQuizCompleted,
        'totalToursCompleted': nextToursCompleted,
        'totalCorrectAnswers': nextCorrectAnswers,
        'bestTourTimeSeconds': nextBestTourTime,
        'maxSingleTourXp': nextMaxSingleTourXp,
        'friends': List<String>.from(data['friends'] ?? currentPublic['friends'] ?? const []),
      }, SetOptions(merge: true));
    });
  }

  Future<void> unlockPendingAchievement(String uid, String achievementId) async {
    final userRef = _users.doc(uid);
    final publicRef = _publicProfiles.doc(uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final publicSnapshot = await transaction.get(publicRef);
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
        if (publicSnapshot.exists) {
          transaction.update(publicRef, {
            'unlockedAchievements': unlocked,
          });
        }
      }
    });
  }
}

