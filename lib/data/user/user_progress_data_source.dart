import 'dart:async';

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
  CollectionReference<Map<String, dynamic>> get _friendStats =>
      _firestore.collection('friend_stats');

  /// Classifica privata: ascolta solo il documento dell'utente e i documenti
  /// friend_stats dei suoi amici. Non esegue query globali sulle statistiche.
  Stream<List<Map<String, dynamic>>> getLeaderboardStream({
    required String uid,
    int limit = 50,
  }) {
    late final StreamController<List<Map<String, dynamic>>> controller;
    final subscriptions = <String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>{};
    final entries = <String, Map<String, dynamic>>{};
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? userSubscription;
    var cancelled = false;

    void emit() {
      if (cancelled || controller.isClosed) return;
      final sorted = entries.values.toList()
        ..sort((a, b) => ((b['xp'] as num?)?.toInt() ?? 0)
            .compareTo((a['xp'] as num?)?.toInt() ?? 0));
      controller.add(sorted.take(limit).toList(growable: false));
    }

    Future<void> attach(String friendUid) async {
      subscriptions[friendUid] = _friendStats.doc(friendUid).snapshots().listen(
        (statsSnapshot) async {
          if (!statsSnapshot.exists || statsSnapshot.data() == null) {
            entries.remove(friendUid);
            emit();
            return;
          }
          try {
            final publicSnapshot = await _publicProfiles.doc(friendUid).get();
            if (!publicSnapshot.exists || publicSnapshot.data() == null) {
              entries.remove(friendUid);
            } else {
              entries[friendUid] = {
                ...publicSnapshot.data()!,
                ...statsSnapshot.data()!,
                'uid': friendUid,
              };
            }
            emit();
          } catch (error, stackTrace) {
            if (!controller.isClosed) controller.addError(error, stackTrace);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          // Una relazione non più valida (ad esempio dopo un ban o una
          // rimozione) esclude soltanto quell'utente dalla classifica.
          entries.remove(friendUid);
          emit();
        },
      );
    }

    void syncFriends(List<String> friendUids) {
      final desired = <String>{uid, ...friendUids.where((id) => id.isNotEmpty && id != uid)};
      for (final existingUid in subscriptions.keys.toList()) {
        if (!desired.contains(existingUid)) {
          subscriptions.remove(existingUid)?.cancel();
          entries.remove(existingUid);
        }
      }
      for (final friendUid in desired) {
        if (!subscriptions.containsKey(friendUid)) {
          attach(friendUid);
        }
      }
      emit();
    }

    controller = StreamController<List<Map<String, dynamic>>>(
      onListen: () {
        userSubscription = _users.doc(uid).snapshots().listen(
          (userSnapshot) {
            if (!userSnapshot.exists) {
              syncFriends(const []);
              return;
            }
            final friendUids = List<String>.from(
              userSnapshot.data()?['friends'] ?? const [],
            );
            syncFriends(friendUids);
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!controller.isClosed) controller.addError(error, stackTrace);
          },
        );
      },
      onCancel: () async {
        cancelled = true;
        await userSubscription?.cancel();
        for (final subscription in subscriptions.values) {
          await subscription.cancel();
        }
        subscriptions.clear();
        entries.clear();
      },
    );
    return controller.stream;
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
        'profileCompleted': data['profileCompleted'] == true,
        'onboardingCompleted': data['onboardingCompleted'] == true,
      });
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

