const fs = require('node:fs');
const path = require('node:path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
} = require('firebase/firestore');

const projectId = 'demo-cesena-remembers';
const rules = fs.readFileSync(
  path.resolve(__dirname, '../../firestore.rules'),
  'utf8',
);

let testEnv;

async function seedProfiles() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/alice'), {
      friends: [],
      sentFriendRequests: ['bob'],
      receivedFriendRequests: [],
    });
    await setDoc(doc(db, 'users/bob'), {
      friends: [],
      sentFriendRequests: [],
      receivedFriendRequests: ['alice'],
    });
    await setDoc(doc(db, 'public_profiles/alice'), {
      displayName: 'Alice',
      username: 'alice',
    });
    await setDoc(doc(db, 'public_profiles/bob'), {
      displayName: 'Bob',
      username: 'bob',
    });
  });
}

function aliceDb() {
  return testEnv.authenticatedContext('alice').firestore();
}

function bobDb() {
  return testEnv.authenticatedContext('bob').firestore();
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules,
    },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await seedProfiles();
});

after(async () => {
  await testEnv?.cleanup();
});

test('a user can create, read and remove their own block entry', async () => {
  const aliceBlock = doc(aliceDb(), 'user_blocks/alice/blocked/bob');

  await assertSucceeds(setDoc(aliceBlock, {
    createdAt: serverTimestamp(),
  }));
  await assertSucceeds(getDoc(aliceBlock));
  await assertSucceeds(deleteDoc(aliceBlock));
});

test('another user cannot inspect or remove someone else\'s block entry', async () => {
  const aliceBlock = doc(aliceDb(), 'user_blocks/alice/blocked/bob');

  await assertSucceeds(setDoc(aliceBlock, {
    createdAt: serverTimestamp(),
  }));

  await assertFails(getDoc(doc(bobDb(), 'user_blocks/alice/blocked/bob')));
  await assertFails(getDocs(collection(bobDb(), 'user_blocks/alice/blocked')));
  await assertFails(deleteDoc(doc(bobDb(), 'user_blocks/alice/blocked/bob')));
});

test('a blocked relationship prevents creating a friend request', async () => {
  await assertSucceeds(setDoc(
    doc(aliceDb(), 'user_blocks/alice/blocked/bob'),
    { createdAt: serverTimestamp() },
  ));

  await assertFails(setDoc(
    doc(aliceDb(), 'friend_requests/bob/inbox/alice'),
    {
      senderUid: 'alice',
      recipientUid: 'bob',
      createdAt: serverTimestamp(),
    },
  ));
});

test('a friend request remains possible when neither user has blocked the other', async () => {
  await assertSucceeds(setDoc(
    doc(aliceDb(), 'friend_requests/bob/inbox/alice'),
    {
      senderUid: 'alice',
      recipientUid: 'bob',
      createdAt: serverTimestamp(),
    },
  ));
});

test('a valid user report can be created but is not readable by app clients', async () => {
  const report = doc(collection(aliceDb(), 'user_reports'));

  await assertSucceeds(setDoc(report, {
    reporterUid: 'alice',
    reportedUid: 'bob',
    reportedField: 'username',
    reportedValue: 'bob',
    reportedDisplayName: 'Bob',
    reportedUsername: 'bob',
    reason: 'inappropriate_name',
    details: 'The username is inappropriate.',
    createdAt: serverTimestamp(),
    status: 'pending',
  }));

  await assertFails(getDoc(report));
  await assertFails(getDocs(collection(aliceDb(), 'user_reports')));
});

test('a user cannot forge a report for another reporter or change its status', async () => {
  const forgedReport = doc(collection(aliceDb(), 'user_reports'));

  await assertFails(setDoc(forgedReport, {
    reporterUid: 'bob',
    reportedUid: 'alice',
    reportedField: 'displayName',
    reportedValue: 'Alice',
    reportedDisplayName: 'Alice',
    reportedUsername: 'alice',
    reason: 'other',
    details: '',
    createdAt: serverTimestamp(),
    status: 'pending',
  }));

  const validReport = doc(collection(aliceDb(), 'user_reports'));
  await assertSucceeds(setDoc(validReport, {
    reporterUid: 'alice',
    reportedUid: 'bob',
    reportedField: 'displayName',
    reportedValue: 'Bob',
    reportedDisplayName: 'Bob',
    reportedUsername: 'bob',
    reason: 'other',
    details: '',
    createdAt: serverTimestamp(),
    status: 'pending',
  }));

  await assertFails(updateDoc(validReport, { status: 'dismissed' }));
  await assertFails(deleteDoc(validReport));
});
