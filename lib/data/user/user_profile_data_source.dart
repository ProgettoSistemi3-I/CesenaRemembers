import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/userprofile.dart';
import '../../domain/validation/profile_validation.dart';
import '../../models/user_model.dart';

class UserProfileDataSource {
  UserProfileDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _usernames =>
      _firestore.collection('usernames');
  CollectionReference<Map<String, dynamic>> get _publicProfiles =>
      _firestore.collection('public_profiles');

  /// I documenti pubblici non contengono email, token FCM, preferenze o richieste di amicizia.
  /// La copia viene aggiornata nella stessa transazione/batch del documento privato.
  Map<String, dynamic> _publicProfilePayload(Map<String, dynamic> data) => {
    'displayName': data['displayName'] ?? 'Utente',
    'displayNameNormalized': data['displayNameNormalized'] ??
        (data['displayName'] ?? 'Utente').toString().toLowerCase(),
    'username': data['username'] ?? '',
    'usernameNormalized': data['usernameNormalized'] ?? '',
    'avatarId': data['avatarId'] ?? 'soldato',
    'profileCompleted': data['profileCompleted'] == true,
    'onboardingCompleted': data['onboardingCompleted'] == true,
    'xp': (data['xp'] as num?)?.toInt() ?? 0,
    'leaderboardScore': (data['leaderboardScore'] as num?)?.toInt() ??
        (data['xp'] as num?)?.toInt() ?? 0,
    'visitedPoiIds': List<String>.from(data['visitedPoiIds'] ?? const []),
    'unlockedAchievements': List<String>.from(
      data['unlockedAchievements'] ?? const [],
    ),
    'maxQuizScore': (data['maxQuizScore'] as num?)?.toInt() ?? 0,
    'totalQuizCompleted': (data['totalQuizCompleted'] as num?)?.toInt() ?? 0,
    'totalToursCompleted': (data['totalToursCompleted'] as num?)?.toInt() ?? 0,
    'totalCorrectAnswers': (data['totalCorrectAnswers'] as num?)?.toInt() ?? 0,
    'bestTourTimeSeconds': (data['bestTourTimeSeconds'] as num?)?.toInt() ?? 0,
    'maxSingleTourXp': (data['maxSingleTourXp'] as num?)?.toInt() ?? 0,
    'friends': List<String>.from(data['friends'] ?? const []),
  };

  String? getCurrentUserUid() => FirebaseAuth.instance.currentUser?.uid;

  Future<UserProfile> getUserProfile(String uid) async {
    // I dati completi (email, preferenze e token FCM) sono leggibili solo dal
    // proprietario. Per gli altri profili leggiamo esclusivamente la proiezione pubblica.
    final isOwner = getCurrentUserUid() == uid;
    final snapshot = isOwner
        ? await _users.doc(uid).get()
        : await _publicProfiles.doc(uid).get();

    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception('Profilo utente non trovato per uid: $uid');
    }

    return UserModel.fromJson(snapshot.data()!, snapshot.id);
  }

  Stream<UserProfile?> getUserProfileStream(String uid) {
    final isOwner = getCurrentUserUid() == uid;
    final source = isOwner ? _users.doc(uid).snapshots() : _publicProfiles.doc(uid).snapshots();
    return source.map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromJson(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  Future<void> ensureUserDocument({
    required String uid,
    required String email,
  }) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) {
      return;
    }
    await _users.doc(uid).set({
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> completeInitialProfile({
    required String uid,
    required String email,
    required String username,
    required String displayName,
    required String avatarId,
  }) async {
    if (!ProfileValidation.isValidDisplayName(displayName)) {
      throw Exception('INVALID_DISPLAY_NAME');
    }
    if (ProfileValidation.hasOffensiveDisplayName(displayName)) {
      throw Exception('OFFENSIVE_DISPLAY_NAME');
    }
    if (!ProfileValidation.isValidUsername(username)) {
      throw Exception('INVALID_USERNAME');
    }
    if (ProfileValidation.hasOffensiveUsername(username)) {
      throw Exception('OFFENSIVE_USERNAME');
    }

    final normalizedUsername = ProfileValidation.normalizeUsername(username);
    final userRef = _users.doc(uid);
    final usernameRef = _usernames.doc(normalizedUsername);

    try {
      await _firestore.runTransaction((transaction) async {
        final existingUsername = await transaction.get(usernameRef);
        if (existingUsername.exists) {
          final ownerUid = existingUsername.data()?['uid'];
          if (ownerUid != uid) {
            throw Exception('USERNAME_NOT_AVAILABLE');
          }
        }

        final existingUser = await transaction.get(userRef);
        final existingData = existingUser.data() ?? <String, dynamic>{};

        final alreadyCompleted = existingData['profileCompleted'] == true;
        if (alreadyCompleted) {
          return;
        }

        // Se l'indice esiste già ed è di questo UID, non eseguire un update:
        // le Rules rendono immutabile l'indice username dopo la creazione.
        if (!existingUsername.exists) {
          transaction.set(usernameRef, {
            'uid': uid,
            'username': normalizedUsername,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        final completedPayload = _buildCompletedProfilePayload(
          existingData: existingData,
          email: email,
          username: username,
          normalizedUsername: normalizedUsername,
          displayName: displayName,
          avatarId: avatarId,
        );
        transaction.set(userRef, completedPayload, SetOptions(merge: true));
        transaction.set(
          _publicProfiles.doc(uid),
          _publicProfilePayload({...existingData, ...completedPayload}),
          SetOptions(merge: true),
        );
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('USERNAME_INDEX_PERMISSION_DENIED');
      }
      rethrow;
    }
  }

  Map<String, dynamic> _buildCompletedProfilePayload({
    required Map<String, dynamic> existingData,
    required String email,
    required String username,
    required String normalizedUsername,
    required String displayName,
    required String avatarId,
  }) {
    final existingPrefs = Map<String, dynamic>.from(
      existingData['preferences'] as Map<String, dynamic>? ?? const {},
    );

    return {
      'email': email,
      'displayName': displayName.trim(),
      'displayNameNormalized': displayName.trim().toLowerCase(),
      'username': normalizedUsername,
      'usernameNormalized': normalizedUsername,
      'avatarId': avatarId,
      'profileCompleted': true,
      'onboardingCompleted': existingData['onboardingCompleted'] == true,
      'profileCompletedAt': FieldValue.serverTimestamp(),
      'xp': (existingData['xp'] as num?)?.toInt() ?? 0,
      'visitedPoiIds': List<String>.from(existingData['visitedPoiIds'] ?? []),
      'unlockedAchievements': List<String>.from(
        existingData['unlockedAchievements'] ?? [],
      ),
      'pendingAchievements': List<String>.from(
        existingData['pendingAchievements'] ?? [],
      ),
      'maxQuizScore': (existingData['maxQuizScore'] as num?)?.toInt() ?? 0,
      'totalQuizCompleted':
          (existingData['totalQuizCompleted'] as num?)?.toInt() ?? 0,
      'totalToursCompleted':
          (existingData['totalToursCompleted'] as num?)?.toInt() ?? 0,
      'totalCorrectAnswers':
          (existingData['totalCorrectAnswers'] as num?)?.toInt() ?? 0,
      'bestTourTimeSeconds':
          (existingData['bestTourTimeSeconds'] as num?)?.toInt() ?? 0,
      'maxSingleTourXp':
          (existingData['maxSingleTourXp'] as num?)?.toInt() ?? 0,
      // La classifica deriva sempre dall'XP: evita divergenze da vecchi dati.
      'leaderboardScore': (existingData['xp'] as num?)?.toInt() ?? 0,
      'friends': List<String>.from(existingData['friends'] ?? []),
      'sentFriendRequests': List<String>.from(
        existingData['sentFriendRequests'] ?? [],
      ),
      'receivedFriendRequests': List<String>.from(
        existingData['receivedFriendRequests'] ?? [],
      ),
      'fcmTokens': List<String>.from(existingData['fcmTokens'] ?? []),
      'preferences': {
        'notifiche': existingPrefs['notifiche'] ?? true,
        'modalitaNotte': existingPrefs['modalitaNotte'] ?? false,
        'posizioneGps': existingPrefs['posizioneGps'] ?? true,
      },
      'createdAt': existingData['createdAt'] ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> updateProfileBasics({
    required String uid,
    String? displayName,
    String? avatarId,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null && displayName.trim().isNotEmpty) {
      if (!ProfileValidation.isValidDisplayName(displayName)) {
        throw Exception('INVALID_DISPLAY_NAME');
      }
      if (ProfileValidation.hasOffensiveDisplayName(displayName)) {
        throw Exception('OFFENSIVE_DISPLAY_NAME');
      }
      updates['displayName'] = displayName.trim();
      updates['displayNameNormalized'] = displayName.trim().toLowerCase();
    }
    if (avatarId != null && avatarId.trim().isNotEmpty) {
      updates['avatarId'] = avatarId.trim();
    }

    final batch = _firestore.batch();
    batch.update(_users.doc(uid), updates);
    final publicUpdates = <String, dynamic>{};
    if (updates.containsKey('displayName')) {
      publicUpdates['displayName'] = updates['displayName'];
      publicUpdates['displayNameNormalized'] = updates['displayNameNormalized'];
    }
    if (updates.containsKey('avatarId')) {
      publicUpdates['avatarId'] = updates['avatarId'];
    }
    if (publicUpdates.isNotEmpty) {
      batch.update(_publicProfiles.doc(uid), publicUpdates);
    }
    await batch.commit();
  }

  Future<bool> isUsernameAvailable(String username) async {
    final normalizedUsername = ProfileValidation.normalizeUsername(username);
    final snapshot = await _usernames.doc(normalizedUsername).get();
    return !snapshot.exists;
  }

  Future<void> updatePreferences({
    required String uid,
    bool? notifiche,
    bool? darkMode,
    bool? gps,
  }) async {
    final Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (notifiche != null) updates['preferences.notifiche'] = notifiche;
    if (darkMode != null) updates['preferences.modalitaNotte'] = darkMode;
    if (gps != null) updates['preferences.posizioneGps'] = gps;

    await _users.doc(uid).update(updates);
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  Future<List<UserProfile>> searchUsers(String query) async {
    final rawQuery = query.trim();
    final cleanQuery = rawQuery.toLowerCase();
    final capitalizedQuery = _capitalize(rawQuery);

    if (cleanQuery.length < 2) return [];

    try {
      // Riduciamo letture duplicate: eseguiamo solo varianti realmente diverse.
      final displayNameProbes = <String>{rawQuery, capitalizedQuery}
        ..removeWhere((value) => value.trim().isEmpty);

      final queries = <Future<QuerySnapshot<Map<String, dynamic>>>>[
        _publicProfiles
            .where('usernameNormalized', isGreaterThanOrEqualTo: cleanQuery)
            .where('usernameNormalized', isLessThanOrEqualTo: '$cleanQuery\uf8ff')
            .limit(10)
            .get(),
        _publicProfiles
            .where('displayNameNormalized', isGreaterThanOrEqualTo: cleanQuery)
            .where('displayNameNormalized', isLessThanOrEqualTo: '$cleanQuery\uf8ff')
            .limit(10)
            .get(),
      ];

      for (final probe in displayNameProbes) {
        queries.add(
          _publicProfiles
              .where('displayName', isGreaterThanOrEqualTo: probe)
              .where('displayName', isLessThanOrEqualTo: '$probe\uf8ff')
              .limit(10)
              .get(),
        );
      }

      final results = await Future.wait(queries);

      // Merge + dedup per uid
      final seen = <String>{};
      final merged = <UserProfile>[];
      for (final snapshot in results) {
        for (final doc in snapshot.docs) {
          if (seen.add(doc.id)) {
            merged.add(UserModel.fromJson(doc.data(), doc.id));
          }
        }
      }
      return merged;
    } catch (e) {
      throw Exception('Errore durante la ricerca utenti: $e');
    }
  }

  Future<void> markOnboardingCompleted(String uid) async {
    final batch = _firestore.batch();
    final update = {
      'onboardingCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    batch.update(_users.doc(uid), update);
    batch.update(_publicProfiles.doc(uid), update);
    await batch.commit();
  }

  Future<void> saveFcmToken(String uid, String token) async {
    try {
      final ref = _users.doc(uid);
      final snapshot = await ref.get();
      if (!snapshot.exists) return;
      final existing = List<String>.from(snapshot.data()?['fcmTokens'] ?? const []);
      if (existing.contains(token)) return;
      await ref.update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Impossibile salvare il token FCM: $e');
    }
  }

  Future<void> removeFcmToken(String uid, String token) async {
    final ref = _users.doc(uid);
    final snapshot = await ref.get();
    if (!snapshot.exists) return;
    final existing = List<String>.from(snapshot.data()?['fcmTokens'] ?? const []);
    if (!existing.contains(token)) return;
    await ref.update({
      'fcmTokens': FieldValue.arrayRemove([token]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
