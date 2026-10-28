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

    final List<Future<void>> cleanupTasks = [];

    // Per ogni relazione, aggiorna la copia privata e quella pubblica nello
    // stesso batch: evita che le Rules vedano per un istante copie discordanti.
    for (final friendUid in myFriends) {
      cleanupTasks.add(() async {
        final batch = _firestore.batch();
        // Rimuove la relazione da entrambe le parti nella stessa scrittura:
        // le Rules non consentono di alterare unilateralmente il profilo altrui.
        batch.update(userRef, {
          'friends': FieldValue.arrayRemove([friendUid]),
          'lastFriendActionPeerUid': friendUid,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        batch.update(_publicProfiles.doc(uid), {
          'friends': FieldValue.arrayRemove([friendUid]),
        });
        batch.update(_users.doc(friendUid), {
          'friends': FieldValue.arrayRemove([uid]),
          'lastFriendActionPeerUid': uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        batch.update(_publicProfiles.doc(friendUid), {
          'friends': FieldValue.arrayRemove([uid]),
        });
        try { await batch.commit(); } catch (_) { /* un profilo già eliminato non deve bloccare la cancellazione */ }
      }());
    }
    for (final targetUid in iSentRequestsTo) {
      cleanupTasks.add(() async {
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
        try { await batch.commit(); } catch (_) { /* richiesta o destinatario già assenti */ }
      }());
    }
    for (final requesterUid in theySentRequestsToMe) {
      cleanupTasks.add(() async {
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
        try { await batch.commit(); } catch (_) { /* richiesta o mittente già assenti */ }
      }());
    }

    await Future.wait(cleanupTasks);

    final finalBatch = _firestore.batch();
    finalBatch.delete(userRef);
    finalBatch.delete(_publicProfiles.doc(uid));
    if (normalizedUsername != null && normalizedUsername.isNotEmpty) {
      try {
        final usernameDoc = await _usernames.doc(normalizedUsername).get();
        if (usernameDoc.exists) finalBatch.delete(_usernames.doc(normalizedUsername));
      } catch (_) { /* l'indice potrebbe essere già assente in profili legacy */ }
    }
    await finalBatch.commit();
  }
}
