import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/data/user/user_progress_data_source.dart';
import 'package:cesena_remembers/data/user/user_social_data_source.dart';

void main() {
  group('UserProgressDataSource', () {
    test('registers a zero-XP quiz completion in user, profile and ranking data', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('alice').set({
        'displayName': 'Alice',
        'displayNameNormalized': 'alice',
        'username': 'alice',
        'usernameNormalized': 'alice',
        'avatarId': 'soldato',
        'profileCompleted': true,
        'onboardingCompleted': true,
        'xp': 25,
        'visitedPoiIds': <String>[],
        'friends': <String>[],
        'unlockedAchievements': <String>[],
        'pendingAchievements': <String>[],
      });
      await firestore.collection('public_profiles').doc('alice').set({
        'displayName': 'Alice',
        'displayNameNormalized': 'alice',
        'username': 'alice',
        'usernameNormalized': 'alice',
        'avatarId': 'soldato',
        'friendsCount': 0,
      });

      final source = UserProgressDataSource(firestore: firestore);
      await source.registerQuizCompletion(
        uid: 'alice',
        poiId: 'rocca',
        xpGained: 0,
        correctAnswers: 0,
        totalQuestions: 3,
        tourElapsedSeconds: 0,
      );

      final user = (await firestore.collection('users').doc('alice').get()).data()!;
      final publicProfile =
          (await firestore.collection('public_profiles').doc('alice').get()).data()!;
      final stats =
          (await firestore.collection('friend_stats').doc('alice').get()).data()!;
      final leaderboard =
          (await firestore.collection('leaderboard').doc('alice').get()).data()!;

      expect(user['xp'], 25);
      expect(user['totalQuizCompleted'], 1);
      expect(user['totalCorrectAnswers'], 0);
      expect(user['visitedPoiIds'], contains('rocca'));
      expect(publicProfile['xp'], 25);
      expect(stats['xp'], 25);
      expect(stats['totalQuizCompleted'], 1);
      expect(leaderboard, containsPair('uid', 'alice'));
      expect(leaderboard, containsPair('xp', 25));
    });
  });

  group('UserSocialDataSource', () {
    test('writes a friend request to the sender, recipient and inbox', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('alice').set({
        'friends': <String>[],
        'sentFriendRequests': <String>[],
        'receivedFriendRequests': <String>[],
      });
      await firestore.collection('users').doc('bob').set({
        'friends': <String>[],
        'sentFriendRequests': <String>[],
        'receivedFriendRequests': <String>[],
      });
      await firestore.collection('public_profiles').doc('bob').set({
        'username': 'bob',
      });

      final source = UserSocialDataSource(firestore: firestore);
      await source.sendFriendRequest('alice', 'bob');

      final alice = (await firestore.collection('users').doc('alice').get()).data()!;
      final bob = (await firestore.collection('users').doc('bob').get()).data()!;
      final request = await firestore
          .collection('friend_requests')
          .doc('bob')
          .collection('inbox')
          .doc('alice')
          .get();

      expect(alice['sentFriendRequests'], contains('bob'));
      expect(bob['receivedFriendRequests'], contains('alice'));
      expect(request.exists, isTrue);
      expect(request.data()?['senderUid'], 'alice');
      expect(request.data()?['recipientUid'], 'bob');
    });

    test('accepts a request and mirrors reciprocal friendship projections', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('alice').set({
        'friends': <String>[],
        'sentFriendRequests': <String>['bob'],
        'receivedFriendRequests': <String>[],
        'unlockedAchievements': <String>[],
        'pendingAchievements': <String>[],
      });
      await firestore.collection('users').doc('bob').set({
        'friends': <String>[],
        'sentFriendRequests': <String>[],
        'receivedFriendRequests': <String>['alice'],
        'unlockedAchievements': <String>[],
        'pendingAchievements': <String>[],
      });
      for (final uid in ['alice', 'bob']) {
        await firestore.collection('friend_stats').doc(uid).set({
          'friends': <String>[],
        });
        await firestore.collection('public_profiles').doc(uid).set({
          'friendsCount': 0,
        });
      }
      await firestore
          .collection('friend_requests')
          .doc('bob')
          .collection('inbox')
          .doc('alice')
          .set({
        'senderUid': 'alice',
        'recipientUid': 'bob',
      });

      final source = UserSocialDataSource(firestore: firestore);
      await source.acceptFriendRequest('bob', 'alice');

      final alice = (await firestore.collection('users').doc('alice').get()).data()!;
      final bob = (await firestore.collection('users').doc('bob').get()).data()!;
      final aliceStats =
          (await firestore.collection('friend_stats').doc('alice').get()).data()!;
      final bobStats =
          (await firestore.collection('friend_stats').doc('bob').get()).data()!;
      final alicePublic =
          (await firestore.collection('public_profiles').doc('alice').get()).data()!;
      final bobPublic =
          (await firestore.collection('public_profiles').doc('bob').get()).data()!;
      final request = await firestore
          .collection('friend_requests')
          .doc('bob')
          .collection('inbox')
          .doc('alice')
          .get();

      expect(alice['friends'], contains('bob'));
      expect(bob['friends'], contains('alice'));
      expect(alice['sentFriendRequests'], isEmpty);
      expect(bob['receivedFriendRequests'], isEmpty);
      expect(aliceStats['friends'], contains('bob'));
      expect(bobStats['friends'], contains('alice'));
      expect(alicePublic['friendsCount'], 1);
      expect(bobPublic['friendsCount'], 1);
      expect(request.exists, isFalse);
    });
  });
}
