import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_social_data_source.dart';

/// Firestore data source for user reports and block relationships.
///
/// A block is written before social cleanup. This makes the relationship
/// immediately authoritative for Firestore Rules, even if a subsequent
/// cleanup write fails and needs to be retried.
class UserModerationDataSource {
  UserModerationDataSource({
    required this._firestore,
    required this._social,
  });

  final FirebaseFirestore _firestore;
  final UserSocialDataSource _social;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _publicProfiles =>
      _firestore.collection('public_profiles');
  CollectionReference<Map<String, dynamic>> get _userBlocks =>
      _firestore.collection('user_blocks');
  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('user_reports');

  DocumentReference<Map<String, dynamic>> _blockRef(
    String blockerUid,
    String blockedUid,
  ) => _userBlocks.doc(blockerUid).collection('blocked').doc(blockedUid);

  Future<void> blockUser(String currentUid, String targetUid) async {
    if (currentUid.isEmpty || targetUid.isEmpty || currentUid == targetUid) {
      throw ArgumentError('Utente da bloccare non valido.');
    }

    final target = await _publicProfiles.doc(targetUid).get();
    if (!target.exists) {
      throw StateError('Profilo utente non disponibile.');
    }

    final blockRef = _blockRef(currentUid, targetUid);
    final existingBlock = await blockRef.get();
    if (!existingBlock.exists) {
      await blockRef.set({
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // The block is now active. Remove any existing social connection using
    // the narrowly-scoped operations that already have dedicated Rules.
    await _cleanupPeerConnections(currentUid, targetUid);
  }

  Future<void> _cleanupPeerConnections(
    String currentUid,
    String targetUid,
  ) async {
    var snapshot = await _users.doc(currentUid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      throw StateError('Profilo utente non disponibile.');
    }

    var data = snapshot.data()!;
    final sent = List<String>.from(data['sentFriendRequests'] ?? const []);
    if (sent.contains(targetUid)) {
      await _social.cancelFriendRequest(currentUid, targetUid);
      snapshot = await _users.doc(currentUid).get();
      data = snapshot.data() ?? const <String, dynamic>{};
    }

    final received = List<String>.from(
      data['receivedFriendRequests'] ?? const [],
    );
    if (received.contains(targetUid)) {
      await _social.rejectFriendRequest(currentUid, targetUid);
      snapshot = await _users.doc(currentUid).get();
      data = snapshot.data() ?? const <String, dynamic>{};
    }

    final friends = List<String>.from(data['friends'] ?? const []);
    if (friends.contains(targetUid)) {
      await _social.removeFriend(currentUid, targetUid);
    }
  }

  Future<void> unblockUser(String currentUid, String targetUid) async {
    if (currentUid.isEmpty || targetUid.isEmpty || currentUid == targetUid) {
      throw ArgumentError('Utente da sbloccare non valido.');
    }
    await _blockRef(currentUid, targetUid).delete();
  }

  Future<List<String>> getBlockedUserIds(String uid) async {
    if (uid.isEmpty) return const [];
    final snapshot = await _userBlocks
        .doc(uid)
        .collection('blocked')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.id).toList(growable: false);
  }

  Future<void> reportUser({
    required String reporterUid,
    required String reportedUid,
    required String reportedField,
    required String reason,
    required String details,
  }) async {
    const allowedFields = {'displayName', 'username'};
    const allowedReasons = {
      'inappropriate_name',
      'impersonation',
      'harassment',
      'spam',
      'other',
    };

    if (reporterUid.isEmpty ||
        reportedUid.isEmpty ||
        reporterUid == reportedUid ||
        !allowedFields.contains(reportedField) ||
        !allowedReasons.contains(reason)) {
      throw ArgumentError('Segnalazione non valida.');
    }

    final normalizedDetails = details.trim();
    if (normalizedDetails.length > 500) {
      throw ArgumentError('I dettagli superano il limite consentito.');
    }

    final targetSnapshot = await _publicProfiles.doc(reportedUid).get();
    if (!targetSnapshot.exists || targetSnapshot.data() == null) {
      throw StateError('Profilo utente non disponibile.');
    }

    final target = targetSnapshot.data()!;
    final reportedValue = reportedField == 'username'
        ? target['username'] as String
        : target['displayName'] as String;

    final reportRef = _reports.doc();
    await reportRef.set({
      'reporterUid': reporterUid,
      'reportedUid': reportedUid,
      'reportedField': reportedField,
      'reportedValue': reportedValue,
      'reportedDisplayName': target['displayName'],
      'reportedUsername': target['username'],
      'reason': reason,
      'details': normalizedDetails,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }
}
