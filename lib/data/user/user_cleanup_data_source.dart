import 'package:cloud_firestore/cloud_firestore.dart';

class UserCleanupDataSource {
  UserCleanupDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _usernames =>
      _firestore.collection('usernames');
  CollectionReference<Map<String, dynamic>> get _publicProfiles =>
      _firestore.collection('public_profiles');
  CollectionReference<Map<String, dynamic>> get _friendStats =>
      _firestore.collection('friend_stats');

  Future<void> deleteUserData({required String uid}) async {
    final userRef = _users.doc(uid);
    final snapshot = await userRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final normalizedUsername = (data['usernameNormalized'] as String?)?.trim();

    final List<String> myFriends = List<String>.from(data['friends'] ?? []);
    final List<String> iSentRequestsTo = List<String>.from(
      data['sentFriendRequests'] ?? [],
    );
    final List<String> theySentRequestsToMe = List<String>.from(
      data['receivedFriendRequests'] ?? [],
    );

    // Le relazioni vengono rimosse in sequenza: ogni batch modifica al massimo
    // quattro documenti, evitando limiti transazionali e corse sul documento owner.
    // Gli errori non vengono ignorati: se un peer non è aggiornabile, non si
    // procede a cancellare l'account lasciando richieste/amicizie fantasma.
    for (final friendUid in myFriends) {
      final batch = _firestore.batch();
      batch.update(userRef, {
        'friends': FieldValue.arrayRemove([friendUid]),
        'lastFriendActionPeerUid': friendUid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.update(_friendStats.doc(uid), {
        'friends': FieldValue.arrayRemove([friendUid]),
      });
      batch.update(_users.doc(friendUid), {
        'friends': FieldValue.arrayRemove([uid]),
        'lastFriendActionPeerUid': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.update(_friendStats.doc(friendUid), {
        'friends': FieldValue.arrayRemove([uid]),
      });
      await batch.commit();
    }

    for (final targetUid in iSentRequestsTo) {
      final batch = _firestore.batch();
      batch.delete(_firestore.collection('friend_requests').doc(targetUid)
          .collection('inbox').doc(uid));
      batch.update(userRef, {
        'sentFriendRequests': FieldValue.arrayRemove([targetUid]),
        'lastFriendActionPeerUid': targetUid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.update(_users.doc(targetUid), {
        'receivedFriendRequests': FieldValue.arrayRemove([uid]),
        'lastFriendActionPeerUid': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    }

    for (final requesterUid in theySentRequestsToMe) {
      final batch = _firestore.batch();
      batch.delete(_firestore.collection('friend_requests').doc(uid)
          .collection('inbox').doc(requesterUid));
      batch.update(userRef, {
        'receivedFriendRequests': FieldValue.arrayRemove([requesterUid]),
        'lastFriendActionPeerUid': requesterUid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.update(_users.doc(requesterUid), {
        'sentFriendRequests': FieldValue.arrayRemove([uid]),
        'lastFriendActionPeerUid': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    }

    final finalBatch = _firestore.batch();
    finalBatch.delete(userRef);
    finalBatch.delete(_publicProfiles.doc(uid));
    finalBatch.delete(_friendStats.doc(uid));
    if (normalizedUsername != null && normalizedUsername.isNotEmpty) {
      final usernameDoc = await _usernames.doc(normalizedUsername).get();
      if (usernameDoc.exists) {
        finalBatch.delete(_usernames.doc(normalizedUsername));
      }
    }
    await finalBatch.commit();
  }
}
