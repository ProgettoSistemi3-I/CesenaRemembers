import assert from 'node:assert/strict';
import { after, before, beforeEach, test } from 'node:test';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  collection,
  deleteDoc,
  doc,
  documentId,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';
import { readFileSync } from 'node:fs';

const PROJECT_ID = 'demo-cesenaremembers';
const RULES = readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8');
const NOW = Timestamp.fromDate(new Date('2026-11-08T12:00:00.000Z'));

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules: RULES,
    },
  });
});

after(async () => {
  if (testEnv) await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

function makeUser(uid, overrides = {}) {
  const displayName = uid.toUpperCase() + ' Example';
  const base = {
    email: uid + '@example.test',
    createdAt: NOW,
    updatedAt: NOW,
    termsAcceptedAt: NOW,
    termsVersionAccepted: '2026-11-06',
    privacyNoticeAcknowledgedAt: NOW,
    privacyNoticeVersionAcknowledged: '2026-11-08',
    ageConfirmedAt: NOW,
    agePolicyVersionConfirmed: '14-plus-v1',
    profileCompletedAt: NOW,
    displayName,
    displayNameNormalized: displayName.toLowerCase(),
    username: uid,
    usernameNormalized: uid,
    avatarId: 'soldato',
    profileCompleted: true,
    onboardingCompleted: true,
    xp: 0,
    leaderboardScore: 0,
    visitedPoiIds: [],
    unlockedAchievements: [],
    pendingAchievements: [],
    maxQuizScore: 0,
    totalQuizCompleted: 0,
    totalToursCompleted: 0,
    totalCorrectAnswers: 0,
    bestTourTimeSeconds: 0,
    maxSingleTourXp: 0,
    friends: [],
    sentFriendRequests: [],
    receivedFriendRequests: [],
    fcmTokens: [],
    preferences: {
      notifiche: false,
      notificheConsenso: false,
      permissionsSetupCompleted: true,
      crashlyticsEnabled: false,
      modalitaNotte: false,
      posizioneGps: true,
      languageCode: 'it',
    },
  };
  const user = { ...base, ...overrides };
  if (!Object.prototype.hasOwnProperty.call(overrides, 'leaderboardScore')) {
    user.leaderboardScore = user.xp;
  }
  return user;
}

function publicProfileFor(user) {
  return {
    displayName: user.displayName,
    displayNameNormalized: user.displayNameNormalized,
    username: user.username,
    usernameNormalized: user.usernameNormalized,
    avatarId: user.avatarId,
    profileCompleted: user.profileCompleted,
    onboardingCompleted: user.onboardingCompleted,
    xp: user.xp,
    friendsCount: user.friends.length,
    totalToursCompleted: user.totalToursCompleted,
  };
}

function friendStatsFor(user) {
  return {
    xp: user.xp,
    visitedPoiIds: user.visitedPoiIds,
    unlockedAchievements: user.unlockedAchievements,
    maxQuizScore: user.maxQuizScore,
    totalQuizCompleted: user.totalQuizCompleted,
    totalToursCompleted: user.totalToursCompleted,
    totalCorrectAnswers: user.totalCorrectAnswers,
    bestTourTimeSeconds: user.bestTourTimeSeconds,
    maxSingleTourXp: user.maxSingleTourXp,
    friends: user.friends,
  };
}

async function seedDocs(entries) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const database = context.firestore();
    const batch = writeBatch(database);
    for (const [path, data] of entries) {
      batch.set(doc(database, ...path.split('/')), data);
    }
    await batch.commit();
  });
}

async function seedCompleteUser(uid, overrides = {}) {
  const user = makeUser(uid, overrides);
  await seedDocs([
    ['users/' + uid, user],
    ['public_profiles/' + uid, publicProfileFor(user)],
    ['friend_stats/' + uid, friendStatsFor(user)],
    ['leaderboard/' + uid, { uid, xp: user.xp }],
    ['usernames/' + user.usernameNormalized, {
      uid,
      username: user.usernameNormalized,
      createdAt: NOW,
    }],
  ]);
  return user;
}

function authenticatedDb(uid, email = uid + '@example.test') {
  return testEnv.authenticatedContext(uid, { email }).firestore();
}

// Use only inside post-condition assertions: production clients must never
// read another account's private user document to verify a social batch.
async function getDocAdmin(path) {
  let snapshot;
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const database = context.firestore();
    snapshot = await getDoc(doc(database, ...path.split('/')));
  });
  return snapshot;
}

function friendAcceptanceBatch(database, award) {
  const batch = writeBatch(database);
  batch.update(doc(database, 'users', 'alice'), {
    receivedFriendRequests: [],
    friends: ['bob'],
    pendingAchievements: award ? [award] : [],
    lastFriendActionPeerUid: 'bob',
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(database, 'users', 'bob'), {
    sentFriendRequests: [],
    friends: ['alice'],
    lastFriendActionPeerUid: 'alice',
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(database, 'friend_stats', 'alice'), { friends: ['bob'] });
  batch.update(doc(database, 'friend_stats', 'bob'), { friends: ['alice'] });
  batch.update(doc(database, 'public_profiles', 'alice'), { friendsCount: 1 });
  batch.update(doc(database, 'public_profiles', 'bob'), { friendsCount: 1 });
  batch.delete(doc(database, 'friend_requests', 'alice', 'inbox', 'bob'));
  return batch;
}

async function seedPendingFriendRequest() {
  await seedCompleteUser('alice', { receivedFriendRequests: ['bob'] });
  await seedCompleteUser('bob', { sentFriendRequests: ['alice'] });
  await seedDocs([[
    'friend_requests/alice/inbox/bob',
    { senderUid: 'bob', recipientUid: 'alice', createdAt: NOW },
  ]]);
}


test('sign-in records Terms, Privacy notice and minimum-age declaration with server timestamps', async () => {
  const database = authenticatedDb('alice');
  const userRef = doc(database, 'users', 'alice');

  await assertSucceeds(setDoc(userRef, {
    email: 'alice@example.test',
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    termsAcceptedAt: serverTimestamp(),
    termsVersionAccepted: '2026-11-06',
    privacyNoticeAcknowledgedAt: serverTimestamp(),
    privacyNoticeVersionAcknowledged: '2026-11-08',
    ageConfirmedAt: serverTimestamp(),
    agePolicyVersionConfirmed: '14-plus-v1',
  }));

  const saved = await getDoc(userRef);
  assert.equal(saved.data().termsVersionAccepted, '2026-11-06');
  assert.equal(saved.data().privacyNoticeVersionAcknowledged, '2026-11-08');
  assert.equal(saved.data().agePolicyVersionConfirmed, '14-plus-v1');
  assert.ok(saved.data().termsAcceptedAt instanceof Timestamp);
  assert.ok(saved.data().privacyNoticeAcknowledgedAt instanceof Timestamp);
  assert.ok(saved.data().ageConfirmedAt instanceof Timestamp);

  await assertFails(setDoc(doc(authenticatedDb('bob'), 'users', 'bob'), {
    email: 'bob@example.test',
    createdAt: NOW,
    updatedAt: NOW,
    termsAcceptedAt: NOW,
    termsVersionAccepted: '2026-11-06',
    privacyNoticeAcknowledgedAt: NOW,
    privacyNoticeVersionAcknowledged: '2026-11-08',
    ageConfirmedAt: NOW,
    agePolicyVersionConfirmed: '14-plus-v1',
  }));
});

test('legal acceptance updates are owner-only, versioned and server-timestamped', async () => {
  await seedCompleteUser('alice');
  const database = authenticatedDb('alice');
  const userRef = doc(database, 'users', 'alice');

  await assertSucceeds(updateDoc(userRef, {
    termsAcceptedAt: serverTimestamp(),
    termsVersionAccepted: '2026-11-06',
    privacyNoticeAcknowledgedAt: serverTimestamp(),
    privacyNoticeVersionAcknowledged: '2026-11-08',
    ageConfirmedAt: serverTimestamp(),
    agePolicyVersionConfirmed: '14-plus-v1',
    updatedAt: serverTimestamp(),
  }));

  await assertFails(updateDoc(userRef, {
    termsAcceptedAt: serverTimestamp(),
    termsVersionAccepted: 'unknown-version',
    privacyNoticeAcknowledgedAt: serverTimestamp(),
    privacyNoticeVersionAcknowledged: '2026-11-08',
    ageConfirmedAt: serverTimestamp(),
    agePolicyVersionConfirmed: '14-plus-v1',
    updatedAt: serverTimestamp(),
  }));

  await assertFails(updateDoc(
    doc(authenticatedDb('bob'), 'users', 'alice'),
    {
      termsAcceptedAt: serverTimestamp(),
      termsVersionAccepted: '2026-11-06',
      privacyNoticeAcknowledgedAt: serverTimestamp(),
      privacyNoticeVersionAcknowledged: '2026-11-08',
      ageConfirmedAt: serverTimestamp(),
      agePolicyVersionConfirmed: '14-plus-v1',
      updatedAt: serverTimestamp(),
    },
  ));
});

test('private user documents are owner-only and cannot be listed', async () => {
  await seedCompleteUser('alice');
  const aliceDb = authenticatedDb('alice');
  const bobDb = authenticatedDb('bob');

  const ownSnapshot = await assertSucceeds(getDoc(doc(aliceDb, 'users', 'alice')));
  assert.equal(ownSnapshot.exists(), true);
  await assertFails(getDoc(doc(bobDb, 'users', 'alice')));
  await assertFails(getDocs(collection(aliceDb, 'users')));
});

test('public profiles and leaderboard are readable only by authenticated, bounded queries', async () => {
  await seedCompleteUser('alice');
  const readerDb = authenticatedDb('reader');
  const anonymousDb = testEnv.unauthenticatedContext().firestore();

  await assertSucceeds(getDoc(doc(readerDb, 'public_profiles', 'alice')));
  await assertSucceeds(getDoc(doc(readerDb, 'leaderboard', 'alice')));
  await assertSucceeds(getDocs(query(collection(readerDb, 'public_profiles'), limit(50))));
  await assertSucceeds(getDocs(query(collection(readerDb, 'leaderboard'), limit(50))));
  await assertFails(getDoc(doc(anonymousDb, 'public_profiles', 'alice')));
  await assertFails(getDocs(query(collection(readerDb, 'public_profiles'), limit(51))));
  await assertFails(getDocs(query(collection(readerDb, 'leaderboard'), limit(51))));
});

test('leaderboard ties are ordered deterministically by ascending document ID', async () => {
  await seedCompleteUser('zoe', { xp: 300 });
  await seedCompleteUser('alice', { xp: 300 });
  await seedCompleteUser('bob', { xp: 300 });
  const readerDb = authenticatedDb('reader');

  const snapshot = await assertSucceeds(getDocs(query(
    collection(readerDb, 'leaderboard'),
    orderBy('xp', 'desc'),
    orderBy(documentId(), 'asc'),
    limit(50),
  )));

  assert.deepEqual(snapshot.docs.map((item) => item.id), ['alice', 'bob', 'zoe']);
});

test('friend statistics require ownership or a reciprocal friendship', async () => {
  await seedCompleteUser('alice', { friends: ['bob'] });
  await seedCompleteUser('bob');
  const aliceDb = authenticatedDb('alice');
  const bobDb = authenticatedDb('bob');

  await assertSucceeds(getDoc(doc(aliceDb, 'friend_stats', 'alice')));
  await assertFails(getDoc(doc(bobDb, 'friend_stats', 'alice')));

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const database = context.firestore();
    await updateDoc(doc(database, 'users', 'bob'), { friends: ['alice'] });
    await updateDoc(doc(database, 'friend_stats', 'bob'), { friends: ['alice'] });
  });

  await assertSucceeds(getDoc(doc(bobDb, 'friend_stats', 'alice')));
});

test('banned accounts cannot read protected user or public-profile data', async () => {
  await seedCompleteUser('alice');
  await seedDocs([['banned_users/alice', { reason: 'test-ban' }]]);
  const aliceDb = authenticatedDb('alice');
  const bobDb = authenticatedDb('bob');

  await assertSucceeds(getDoc(doc(aliceDb, 'banned_users', 'alice')));
  await assertFails(getDoc(doc(aliceDb, 'users', 'alice')));
  await assertFails(getDoc(doc(bobDb, 'public_profiles', 'alice')));
});

test('initial profile onboarding atomically creates private, public, stats and username documents', async () => {
  const initialProfile = makeUser('alice');
  await seedDocs([['users/alice', {
    email: 'alice@example.test',
    createdAt: NOW,
    updatedAt: NOW,
  }]]);
  const database = authenticatedDb('alice');
  const batch = writeBatch(database);

  batch.update(doc(database, 'users', 'alice'), initialProfile);
  batch.set(doc(database, 'usernames', 'alice'), {
    uid: 'alice',
    username: 'alice',
    createdAt: serverTimestamp(),
  });
  batch.set(doc(database, 'public_profiles', 'alice'), publicProfileFor(initialProfile));
  batch.set(doc(database, 'friend_stats', 'alice'), friendStatsFor(initialProfile));

  await assertSucceeds(batch.commit());
  await assertSucceeds(setDoc(doc(database, 'leaderboard', 'alice'), {
    uid: 'alice',
    xp: 0,
  }));

  const publicSnapshot = await assertSucceeds(getDoc(doc(database, 'public_profiles', 'alice')));
  assert.equal(publicSnapshot.data().usernameNormalized, 'alice');
});

test('a complete progress update synchronizes all projections in one atomic batch', async () => {
  await seedCompleteUser('alice');
  const database = authenticatedDb('alice');
  const batch = writeBatch(database);

  batch.update(doc(database, 'users', 'alice'), {
    visitedPoiIds: ['rocca'],
    xp: 20,
    leaderboardScore: 20,
    maxQuizScore: 100,
    totalQuizCompleted: 1,
    totalCorrectAnswers: 3,
    pendingAchievements: ['first_visit', 'first_quiz'],
    lastProgressAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(database, 'public_profiles', 'alice'), { xp: 20 });
  batch.update(doc(database, 'friend_stats', 'alice'), {
    visitedPoiIds: ['rocca'],
    xp: 20,
    maxQuizScore: 100,
    totalQuizCompleted: 1,
    totalCorrectAnswers: 3,
  });
  batch.update(doc(database, 'leaderboard', 'alice'), { xp: 20 });

  await assertSucceeds(batch.commit());

  const user = await getDoc(doc(database, 'users', 'alice'));
  const stats = await getDoc(doc(database, 'friend_stats', 'alice'));
  const leaderboard = await getDoc(doc(database, 'leaderboard', 'alice'));
  assert.equal(user.data().xp, 20);
  assert.deepEqual(user.data().visitedPoiIds, ['rocca']);
  assert.equal(stats.data().totalQuizCompleted, 1);
  assert.equal(leaderboard.data().xp, 20);
});

test('progress rules reject an XP increase above the per-completion cap even when mirrors agree', async () => {
  await seedCompleteUser('alice');
  const database = authenticatedDb('alice');
  const batch = writeBatch(database);

  batch.update(doc(database, 'users', 'alice'), {
    xp: 81,
    leaderboardScore: 81,
    lastProgressAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(database, 'public_profiles', 'alice'), { xp: 81 });
  batch.update(doc(database, 'friend_stats', 'alice'), { xp: 81 });
  batch.update(doc(database, 'leaderboard', 'alice'), { xp: 81 });

  await assertFails(batch.commit());
  const user = await getDoc(doc(database, 'users', 'alice'));
  assert.equal(user.data().xp, 0);
});

test('friend requests can be created only with matching sender and recipient mutations', async () => {
  await seedCompleteUser('alice');
  await seedCompleteUser('bob');
  const database = authenticatedDb('alice');
  const batch = writeBatch(database);

  batch.set(doc(database, 'friend_requests', 'bob', 'inbox', 'alice'), {
    senderUid: 'alice',
    recipientUid: 'bob',
    createdAt: serverTimestamp(),
  });
  batch.update(doc(database, 'users', 'alice'), {
    sentFriendRequests: ['bob'],
    lastFriendActionPeerUid: 'bob',
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(database, 'users', 'bob'), {
    receivedFriendRequests: ['alice'],
    updatedAt: serverTimestamp(),
  });

  await assertSucceeds(batch.commit());
});

test('friend-request cancellation keeps both user arrays and inbox document consistent', async () => {
  await seedCompleteUser('alice', { sentFriendRequests: ['bob'] });
  await seedCompleteUser('bob', { receivedFriendRequests: ['alice'] });
  await seedDocs([[
    'friend_requests/bob/inbox/alice',
    { senderUid: 'alice', recipientUid: 'bob', createdAt: NOW },
  ]]);
  const database = authenticatedDb('alice');
  const batch = writeBatch(database);

  batch.update(doc(database, 'users', 'alice'), {
    sentFriendRequests: [],
    lastFriendActionPeerUid: 'bob',
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(database, 'users', 'bob'), {
    receivedFriendRequests: [],
    lastFriendActionPeerUid: 'alice',
    updatedAt: serverTimestamp(),
  });
  batch.delete(doc(database, 'friend_requests', 'bob', 'inbox', 'alice'));

  await assertSucceeds(batch.commit());
});

test('friend-request rejection is authorized for the recipient and remains atomic', async () => {
  await seedCompleteUser('alice', { sentFriendRequests: ['bob'] });
  await seedCompleteUser('bob', { receivedFriendRequests: ['alice'] });
  await seedDocs([[
    'friend_requests/bob/inbox/alice',
    { senderUid: 'alice', recipientUid: 'bob', createdAt: NOW },
  ]]);
  const database = authenticatedDb('bob');
  const batch = writeBatch(database);

  batch.update(doc(database, 'users', 'bob'), {
    receivedFriendRequests: [],
    lastFriendActionPeerUid: 'alice',
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(database, 'users', 'alice'), {
    sentFriendRequests: [],
    lastFriendActionPeerUid: 'bob',
    updatedAt: serverTimestamp(),
  });
  batch.delete(doc(database, 'friend_requests', 'bob', 'inbox', 'alice'));

  await assertSucceeds(batch.commit());
});

test('friend acceptance synchronizes both users, stats, public counts and request deletion atomically', async () => {
  await seedPendingFriendRequest();
  const database = authenticatedDb('alice');

  await assertSucceeds(friendAcceptanceBatch(database, 'friend_1').commit());

  const alice = await getDocAdmin('users/alice');
  const bob = await getDocAdmin('users/bob');
  const aliceStats = await getDocAdmin('friend_stats/alice');
  const bobStats = await getDocAdmin('friend_stats/bob');
  const alicePublic = await getDocAdmin('public_profiles/alice');
  const bobPublic = await getDocAdmin('public_profiles/bob');
  const request = await getDocAdmin('friend_requests/alice/inbox/bob');

  assert.deepEqual(alice.data().friends, ['bob']);
  assert.deepEqual(bob.data().friends, ['alice']);
  assert.deepEqual(aliceStats.data().friends, ['bob']);
  assert.deepEqual(bobStats.data().friends, ['alice']);
  assert.equal(alicePublic.data().friendsCount, 1);
  assert.equal(bobPublic.data().friendsCount, 1);
  assert.equal(request.exists(), false);
});

test('friend acceptance cannot award the five-friend achievement to an account with one friend', async () => {
  await seedPendingFriendRequest();
  const database = authenticatedDb('alice');

  await assertFails(friendAcceptanceBatch(database, 'friend_5').commit());

  const alice = await getDoc(doc(database, 'users', 'alice'));
  const request = await getDoc(doc(database, 'friend_requests', 'alice', 'inbox', 'bob'));
  assert.deepEqual(alice.data().friends, []);
  assert.equal(request.exists(), true);
});

test('friend removal updates both private lists, friend stats and public counts atomically', async () => {
  await seedCompleteUser('alice', { friends: ['bob'] });
  await seedCompleteUser('bob', { friends: ['alice'] });
  const database = authenticatedDb('alice');
  const batch = writeBatch(database);

  batch.update(doc(database, 'users', 'alice'), {
    friends: [],
    lastFriendActionPeerUid: 'bob',
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(database, 'users', 'bob'), {
    friends: [],
    lastFriendActionPeerUid: 'alice',
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(database, 'friend_stats', 'alice'), { friends: [] });
  batch.update(doc(database, 'friend_stats', 'bob'), { friends: [] });
  batch.update(doc(database, 'public_profiles', 'alice'), { friendsCount: 0 });
  batch.update(doc(database, 'public_profiles', 'bob'), { friendsCount: 0 });

  await assertSucceeds(batch.commit());

  assert.deepEqual((await getDocAdmin('users/alice')).data().friends, []);
  assert.deepEqual((await getDocAdmin('users/bob')).data().friends, []);
  assert.equal((await getDocAdmin('public_profiles/alice')).data().friendsCount, 0);
  assert.equal((await getDocAdmin('public_profiles/bob')).data().friendsCount, 0);
});

test('achievement claiming can move one pending achievement to the unlocked mirror', async () => {
  await seedCompleteUser('alice', { pendingAchievements: ['first_quiz'] });
  const database = authenticatedDb('alice');
  const batch = writeBatch(database);

  batch.update(doc(database, 'users', 'alice'), {
    pendingAchievements: [],
    unlockedAchievements: ['first_quiz'],
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(database, 'friend_stats', 'alice'), {
    unlockedAchievements: ['first_quiz'],
  });

  await assertSucceeds(batch.commit());
});

test('achievement claiming cannot unlock an achievement that was never pending', async () => {
  await seedCompleteUser('alice', { pendingAchievements: ['first_quiz'] });
  const database = authenticatedDb('alice');
  const batch = writeBatch(database);

  batch.update(doc(database, 'users', 'alice'), {
    pendingAchievements: [],
    unlockedAchievements: ['xp_500'],
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(database, 'friend_stats', 'alice'), {
    unlockedAchievements: ['xp_500'],
  });

  await assertFails(batch.commit());
});

test('Crashlytics consent requires a timestamp and valid preference shape', async () => {
  const user = await seedCompleteUser('alice');
  const database = authenticatedDb('alice');
  const invalidPreferences = {
    ...user.preferences,
    crashlyticsEnabled: true,
  };

  await assertFails(updateDoc(doc(database, 'users', 'alice'), {
    preferences: invalidPreferences,
  }));

  await assertSucceeds(updateDoc(doc(database, 'users', 'alice'), {
    preferences: {
      ...invalidPreferences,
      crashlyticsConsentAt: NOW,
    },
  }));
});

test('account deletion can remove all owner projections in one final atomic batch', async () => {
  await seedCompleteUser('alice');
  const database = authenticatedDb('alice');
  const batch = writeBatch(database);

  batch.delete(doc(database, 'users', 'alice'));
  batch.delete(doc(database, 'public_profiles', 'alice'));
  batch.delete(doc(database, 'friend_stats', 'alice'));
  batch.delete(doc(database, 'leaderboard', 'alice'));
  batch.delete(doc(database, 'usernames', 'alice'));

  await assertSucceeds(batch.commit());

  assert.equal((await getDoc(doc(database, 'users', 'alice'))).exists(), false);
  assert.equal((await getDoc(doc(database, 'public_profiles', 'alice'))).exists(), false);
  assert.equal((await getDoc(doc(database, 'friend_stats', 'alice'))).exists(), false);
  assert.equal((await getDoc(doc(database, 'leaderboard', 'alice'))).exists(), false);
  assert.equal((await getDoc(doc(database, 'usernames', 'alice'))).exists(), false);
});

// ---------------------------------------------------------------------------
// User reporting and blocking
// ---------------------------------------------------------------------------

test('a user can create, inspect and remove only their own block entry', async () => {
  await seedCompleteUser('alice');
  await seedCompleteUser('bob');
  const aliceDb = authenticatedDb('alice');
  const bobDb = authenticatedDb('bob');
  const aliceBlock = doc(aliceDb, 'user_blocks', 'alice', 'blocked', 'bob');

  await assertSucceeds(setDoc(aliceBlock, { createdAt: serverTimestamp() }));
  await assertSucceeds(getDoc(aliceBlock));
  await assertSucceeds(getDocs(collection(aliceDb, 'user_blocks', 'alice', 'blocked')));
  await assertFails(getDoc(doc(bobDb, 'user_blocks', 'alice', 'blocked', 'bob')));
  await assertFails(getDocs(collection(bobDb, 'user_blocks', 'alice', 'blocked')));
  await assertFails(deleteDoc(doc(bobDb, 'user_blocks', 'alice', 'blocked', 'bob')));
  await assertSucceeds(deleteDoc(aliceBlock));
});

test('a block in either direction prevents a new friend request', async () => {
  await seedCompleteUser('alice');
  await seedCompleteUser('bob');
  const aliceDb = authenticatedDb('alice');
  const bobDb = authenticatedDb('bob');

  await assertSucceeds(setDoc(
    doc(aliceDb, 'user_blocks', 'alice', 'blocked', 'bob'),
    { createdAt: serverTimestamp() },
  ));
  await assertFails(setDoc(
    doc(bobDb, 'friend_requests', 'alice', 'inbox', 'bob'),
    {
      senderUid: 'bob',
      recipientUid: 'alice',
      createdAt: serverTimestamp(),
    },
  ));

  await assertSucceeds(deleteDoc(
    doc(aliceDb, 'user_blocks', 'alice', 'blocked', 'bob'),
  ));
  await assertSucceeds(setDoc(
    doc(bobDb, 'user_blocks', 'bob', 'blocked', 'alice'),
    { createdAt: serverTimestamp() },
  ));
  await assertFails(setDoc(
    doc(aliceDb, 'friend_requests', 'bob', 'inbox', 'alice'),
    {
      senderUid: 'alice',
      recipientUid: 'bob',
      createdAt: serverTimestamp(),
    },
  ));
});

test('a block prevents both sides of a friend acceptance batch', async () => {
  await seedPendingFriendRequest();
  const aliceDb = authenticatedDb('alice');

  await assertSucceeds(setDoc(
    doc(aliceDb, 'user_blocks', 'alice', 'blocked', 'bob'),
    { createdAt: serverTimestamp() },
  ));
  await assertFails(friendAcceptanceBatch(aliceDb, 'friend_1').commit());

  const alice = await getDocAdmin('users/alice');
  const bob = await getDocAdmin('users/bob');
  assert.deepEqual(alice.data().friends, []);
  assert.deepEqual(bob.data().friends, []);
});

test('a blocked reciprocal friend cannot read detailed friend statistics', async () => {
  await seedCompleteUser('alice', { friends: ['bob'] });
  await seedCompleteUser('bob', { friends: ['alice'] });
  const aliceDb = authenticatedDb('alice');
  const bobDb = authenticatedDb('bob');

  await assertSucceeds(setDoc(
    doc(aliceDb, 'user_blocks', 'alice', 'blocked', 'bob'),
    { createdAt: serverTimestamp() },
  ));

  // Blocking does not affect the owner's access to their own statistics.
  await assertSucceeds(getDoc(doc(aliceDb, 'friend_stats', 'alice')));
  await assertFails(getDoc(doc(bobDb, 'friend_stats', 'alice')));
});

test('blocking still permits removal of an existing pending friend request', async () => {
  await seedCompleteUser('alice', { receivedFriendRequests: ['bob'] });
  await seedCompleteUser('bob', { sentFriendRequests: ['alice'] });
  await seedDocs([[
    'friend_requests/alice/inbox/bob',
    { senderUid: 'bob', recipientUid: 'alice', createdAt: NOW },
  ]]);
  const aliceDb = authenticatedDb('alice');

  await assertSucceeds(setDoc(
    doc(aliceDb, 'user_blocks', 'alice', 'blocked', 'bob'),
    { createdAt: serverTimestamp() },
  ));

  const batch = writeBatch(aliceDb);
  batch.update(doc(aliceDb, 'users', 'alice'), {
    receivedFriendRequests: [],
    lastFriendActionPeerUid: 'bob',
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(aliceDb, 'users', 'bob'), {
    sentFriendRequests: [],
    lastFriendActionPeerUid: 'alice',
    updatedAt: serverTimestamp(),
  });
  batch.delete(doc(aliceDb, 'friend_requests', 'alice', 'inbox', 'bob'));

  await assertSucceeds(batch.commit());
  assert.equal((await getDocAdmin('friend_requests/alice/inbox/bob')).exists(), false);
});

test('valid profile reports are private and clients cannot modify or delete them', async () => {
  await seedCompleteUser('alice');
  const bob = await seedCompleteUser('bob');
  const aliceDb = authenticatedDb('alice');
  const report = doc(collection(aliceDb, 'user_reports'));

  await assertSucceeds(setDoc(report, {
    reporterUid: 'alice',
    reportedUid: 'bob',
    reportedField: 'username',
    reportedValue: bob.username,
    reportedDisplayName: bob.displayName,
    reportedUsername: bob.username,
    reason: 'inappropriate_name',
    details: 'Please review this username.',
    createdAt: serverTimestamp(),
    status: 'pending',
  }));

  await assertFails(getDoc(report));
  await assertFails(getDocs(collection(aliceDb, 'user_reports')));
  await assertFails(updateDoc(report, { status: 'reviewed' }));
  await assertFails(deleteDoc(report));
});

test('clients cannot forge reports, report themselves or submit oversized details', async () => {
  await seedCompleteUser('alice');
  const bob = await seedCompleteUser('bob');
  const aliceDb = authenticatedDb('alice');

  const forged = doc(collection(aliceDb, 'user_reports'));
  await assertFails(setDoc(forged, {
    reporterUid: 'bob',
    reportedUid: 'alice',
    reportedField: 'displayName',
    reportedValue: 'ALICE Example',
    reportedDisplayName: 'ALICE Example',
    reportedUsername: 'alice',
    reason: 'other',
    details: '',
    createdAt: serverTimestamp(),
    status: 'pending',
  }));

  const selfReport = doc(collection(aliceDb, 'user_reports'));
  await assertFails(setDoc(selfReport, {
    reporterUid: 'alice',
    reportedUid: 'alice',
    reportedField: 'displayName',
    reportedValue: 'ALICE Example',
    reportedDisplayName: 'ALICE Example',
    reportedUsername: 'alice',
    reason: 'other',
    details: '',
    createdAt: serverTimestamp(),
    status: 'pending',
  }));

  const oversized = doc(collection(aliceDb, 'user_reports'));
  await assertFails(setDoc(oversized, {
    reporterUid: 'alice',
    reportedUid: 'bob',
    reportedField: 'username',
    reportedValue: bob.username,
    reportedDisplayName: bob.displayName,
    reportedUsername: bob.username,
    reason: 'other',
    details: 'x'.repeat(501),
    createdAt: serverTimestamp(),
    status: 'pending',
  }));
});

test('blocking still permits removing an existing reciprocal friendship', async () => {
  await seedCompleteUser('alice', { friends: ['bob'] });
  await seedCompleteUser('bob', { friends: ['alice'] });
  const aliceDb = authenticatedDb('alice');

  await assertSucceeds(setDoc(
    doc(aliceDb, 'user_blocks', 'alice', 'blocked', 'bob'),
    { createdAt: serverTimestamp() },
  ));

  const batch = writeBatch(aliceDb);
  batch.update(doc(aliceDb, 'users', 'alice'), {
    friends: [],
    lastFriendActionPeerUid: 'bob',
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(aliceDb, 'users', 'bob'), {
    friends: [],
    lastFriendActionPeerUid: 'alice',
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(aliceDb, 'friend_stats', 'alice'), { friends: [] });
  batch.update(doc(aliceDb, 'friend_stats', 'bob'), { friends: [] });
  batch.update(doc(aliceDb, 'public_profiles', 'alice'), { friendsCount: 0 });
  batch.update(doc(aliceDb, 'public_profiles', 'bob'), { friendsCount: 0 });

  await assertSucceeds(batch.commit());
  assert.deepEqual((await getDocAdmin('users/alice')).data().friends, []);
  assert.deepEqual((await getDocAdmin('users/bob')).data().friends, []);
});

test('all supported report reasons are accepted for a valid profile snapshot', async () => {
  await seedCompleteUser('alice');
  const bob = await seedCompleteUser('bob');
  const aliceDb = authenticatedDb('alice');
  const reasons = [
    'inappropriate_name',
    'impersonation',
    'harassment',
    'spam',
    'other',
  ];

  for (const reason of reasons) {
    const report = doc(collection(aliceDb, 'user_reports'));
    await assertSucceeds(setDoc(report, {
      reporterUid: 'alice',
      reportedUid: 'bob',
      reportedField: 'displayName',
      reportedValue: bob.displayName,
      reportedDisplayName: bob.displayName,
      reportedUsername: bob.username,
      reason,
      details: '',
      createdAt: serverTimestamp(),
      status: 'pending',
    }));
  }
});

test('a report cannot replace the reported profile snapshot with forged values', async () => {
  await seedCompleteUser('alice');
  const bob = await seedCompleteUser('bob');
  const aliceDb = authenticatedDb('alice');
  const report = doc(collection(aliceDb, 'user_reports'));

  await assertFails(setDoc(report, {
    reporterUid: 'alice',
    reportedUid: 'bob',
    reportedField: 'displayName',
    reportedValue: 'Fake Profile',
    reportedDisplayName: 'Fake Profile',
    reportedUsername: bob.username,
    reason: 'other',
    details: '',
    createdAt: serverTimestamp(),
    status: 'pending',
  }));
});

