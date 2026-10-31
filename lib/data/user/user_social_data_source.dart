import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/userprofile.dart';
import '../../domain/services/achievement_service.dart';
import '../../models/user_model.dart';

class UserSocialDataSource {
  UserSocialDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _publicProfiles => _firestore.collection('public_profiles');
  CollectionReference<Map<String, dynamic>> get _friendStats => _firestore.collection('friend_stats');
  CollectionReference<Map<String, dynamic>> get _friendRequestRoots => _firestore.collection('friend_requests');

  DocumentReference<Map<String, dynamic>> _requestRef(String recipientUid, String senderUid) =>
      _friendRequestRoots.doc(recipientUid).collection('inbox').doc(senderUid);

  Future<void> sendFriendRequest(String currentUid, String targetUid) async {
    if (currentUid == targetUid) throw ArgumentError('Non puoi aggiungere te stesso.');
    await _firestore.runTransaction((tx) async {
      final currentRef = _users.doc(currentUid);
      final targetPublicRef = _publicProfiles.doc(targetUid);
      final reverseRequestRef = _requestRef(currentUid, targetUid);
      final outgoingRequestRef = _requestRef(targetUid, currentUid);
      final currentSnap = await tx.get(currentRef);
      final targetPublicSnap = await tx.get(targetPublicRef);
      final reverseSnap = await tx.get(reverseRequestRef);
      if (!currentSnap.exists || !targetPublicSnap.exists) {
        throw StateError('Profilo utente non disponibile.');
      }
      final current = currentSnap.data()!;
      final currentFriends = List<String>.from(current['friends'] ?? const []);
      final currentSent = List<String>.from(current['sentFriendRequests'] ?? const []);
      if (currentFriends.contains(targetUid) || currentSent.contains(targetUid)) return;
      if (reverseSnap.exists || List<String>.from(current['receivedFriendRequests'] ?? const []).contains(targetUid)) {
        throw StateError('L’utente ti ha già inviato una richiesta.');
      }
      tx.set(outgoingRequestRef, {
        'senderUid': currentUid,
        'recipientUid': targetUid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(currentRef, {
        'sentFriendRequests': FieldValue.arrayUnion([targetUid]),
        'lastFriendActionPeerUid': targetUid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Nessun read del documento privato del destinatario: viene modificato
      // solo il suo array richieste, validato in modo stretto dalle Rules.
      tx.update(_users.doc(targetUid), {
        'receivedFriendRequests': FieldValue.arrayUnion([currentUid]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> cancelFriendRequest(String currentUid, String targetUid) async {
    final batch = _firestore.batch();
    batch.update(_users.doc(currentUid), {
      'sentFriendRequests': FieldValue.arrayRemove([targetUid]),
      'lastFriendActionPeerUid': targetUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_users.doc(targetUid), {
      'receivedFriendRequests': FieldValue.arrayRemove([currentUid]),
      'lastFriendActionPeerUid': currentUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.delete(_requestRef(targetUid, currentUid));
    await batch.commit();
  }

  Future<void> acceptFriendRequest(String currentUid, String requesterUid) async {
    if (currentUid == requesterUid) throw ArgumentError('Richiesta non valida.');
    final currentRef = _users.doc(currentUid);
    final requestRef = _requestRef(currentUid, requesterUid);
    await _firestore.runTransaction((tx) async {
      final currentSnap = await tx.get(currentRef);
      final requestSnap = await tx.get(requestRef);
      if (!currentSnap.exists || !requestSnap.exists) {
        throw StateError('Profilo o richiesta non disponibile.');
      }
      final current = currentSnap.data()!;
      final currentReceived = List<String>.from(current['receivedFriendRequests'] ?? const []);
      if (!currentReceived.contains(requesterUid)) {
        throw StateError('La richiesta non è più disponibile.');
      }

      final currentFriends = List<String>.from(current['friends'] ?? const []);
      if (currentFriends.contains(requesterUid)) return;

      final currentUnlocked = List<String>.from(current['unlockedAchievements'] ?? const []);
      final currentPending = List<String>.from(current['pendingAchievements'] ?? const []);
      final currentAwards = AchievementService.evaluateOnFriendAdded(
        alreadyUnlocked: [...currentUnlocked, ...currentPending],
        friendCount: currentFriends.length + 1,
      );

      tx.update(currentRef, {
        'receivedFriendRequests': FieldValue.arrayRemove([requesterUid]),
        'friends': FieldValue.arrayUnion([requesterUid]),
        'lastFriendActionPeerUid': requesterUid,
        if (currentAwards.isNotEmpty) 'pendingAchievements': FieldValue.arrayUnion(currentAwards),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(_users.doc(requesterUid), {
        'sentFriendRequests': FieldValue.arrayRemove([currentUid]),
        'friends': FieldValue.arrayUnion([currentUid]),
        'lastFriendActionPeerUid': currentUid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(_friendStats.doc(currentUid), {
        'friends': FieldValue.arrayUnion([requesterUid]),
      });
      tx.update(_friendStats.doc(requesterUid), {
        'friends': FieldValue.arrayUnion([currentUid]),
      });
      tx.delete(requestRef);
    });
  }

  Future<void> rejectFriendRequest(String currentUid, String requesterUid) async {
    final batch = _firestore.batch();
    batch.update(_users.doc(currentUid), {
      'receivedFriendRequests': FieldValue.arrayRemove([requesterUid]),
      'lastFriendActionPeerUid': requesterUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_users.doc(requesterUid), {
      'sentFriendRequests': FieldValue.arrayRemove([currentUid]),
      'lastFriendActionPeerUid': currentUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.delete(_requestRef(currentUid, requesterUid));
    await batch.commit();
  }

  Future<void> removeFriend(String currentUid, String friendUid) async {
    if (currentUid == friendUid) return;
    final batch = _firestore.batch();
    batch.update(_users.doc(currentUid), {
      'friends': FieldValue.arrayRemove([friendUid]),
      'lastFriendActionPeerUid': friendUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_users.doc(friendUid), {
      'friends': FieldValue.arrayRemove([currentUid]),
      'lastFriendActionPeerUid': currentUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_friendStats.doc(currentUid), {
      'friends': FieldValue.arrayRemove([friendUid]),
    });
    batch.update(_friendStats.doc(friendUid), {
      'friends': FieldValue.arrayRemove([currentUid]),
    });
    await batch.commit();
  }

  Future<List<UserProfile>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];
    final result = <UserProfile>[];
    for (var i = 0; i < uids.length; i += 10) {
      final chunk = uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10);
      final snap = await _publicProfiles.where(FieldPath.documentId, whereIn: chunk).limit(chunk.length).get();
      result.addAll(snap.docs.map((doc) => UserModel.fromJson(doc.data(), doc.id)));
    }
    return result;
  }

  Future<bool> checkAreFriends(String currentUid, String targetUid) async {
    if (currentUid == targetUid) return false;
    final doc = await _users.doc(currentUid).get();
    if (!doc.exists) return false;
    return List<String>.from(doc.data()?['friends'] ?? const []).contains(targetUid);
  }
}
