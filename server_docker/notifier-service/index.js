const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
const { buildFriendNotification } = require('./notification_messages');

const keyPath = path.join(__dirname, 'serviceAccountKey.json');
if (!fs.existsSync(keyPath)) {
  console.error("ERRORE CRITICO: il file 'serviceAccountKey.json' non è presente.");
  console.error("Crea la chiave Firebase Admin e montala in sola lettura tramite docker-compose.yml.");
  process.exit(1);
}

const serviceAccount = require(keyPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const usersCache = new Map();

console.log("Notifier Cesena Remembers avviato: ascolto selettivo delle modifiche utenti.");

// La projection evita di leggere email e gli altri campi privati/non necessari.
const usersQuery = db.collection('users');

usersQuery.onSnapshot(async snapshot => {
  for (const change of snapshot.docChanges()) {
    const userId = change.doc.id;
    if (change.type === 'removed') {
      usersCache.delete(userId);
      continue;
    }
    const data = change.doc.data() || {};
    const receivedRequests = data.receivedFriendRequests || [];
    const sentRequests = data.sentFriendRequests || [];
    const friends = data.friends || [];
    const fcmTokens = data.fcmTokens || [];
    const languageCode = data.preferences?.languageCode || 'it';
    // I profili legacy senza la preferenza conservano il default applicativo: true.
    const notificationsEnabled =
      data.preferences?.notifiche === true &&
      data.preferences?.notificheConsenso === true &&
      data.preferences?.notificheConsensoAt != null;

    const previousState = usersCache.get(userId);
    usersCache.set(userId, {
      receivedRequests: [...receivedRequests],
      friends: [...friends],
      sentRequests: [...sentRequests]
    });

    // I documenti iniziali servono solo a popolare la cache.
    if (change.type !== 'modified' || !previousState || !notificationsEnabled) {
      continue;
    }

    // Compare UIDs, not just array lengths: simultaneous changes must not
    // hide a request or trigger duplicate notifications.
    const newRequestSenders = receivedRequests.filter(
      senderUid => !previousState.receivedRequests.includes(senderUid)
    );
    for (const senderUid of newRequestSenders) {
      if (await hasBlockBetween(userId, senderUid)) continue;
      await inviaNotifica(
        userId,
        fcmTokens,
        buildFriendNotification('friend_request', languageCode)
      );
    }

    const newFriends = friends.filter(
      friendUid => !previousState.friends.includes(friendUid)
    );
    const acceptedFriends = newFriends.filter(
      friendUid => previousState.sentRequests.includes(friendUid)
    );
    for (const friendUid of acceptedFriends) {
      if (await hasBlockBetween(userId, friendUid)) continue;
      await inviaNotifica(
        userId,
        fcmTokens,
        buildFriendNotification('friend_accepted', languageCode)
      );
    }
  }
}, error => {
  console.error('Errore durante l\'ascolto selettivo di Firestore:', error);
});

async function hasBlockBetween(uidA, uidB) {
  const [blockerBlock, reciprocalBlock] = await Promise.all([
    db.doc(`user_blocks/${uidA}/blocked/${uidB}`).get(),
    db.doc(`user_blocks/${uidB}/blocked/${uidA}`).get()
  ]);
  return blockerBlock.exists || reciprocalBlock.exists;
}

async function inviaNotifica(userId, tokens, payload) {
  if (!Array.isArray(tokens) || tokens.length === 0) {
    console.log(`Nessun token FCM per l'utente ${userId}; notifica ignorata.`);
    return;
  }

  const message = {
    notification: {
      title: payload.title,
      body: payload.body
    },
    data: {
      title: payload.title,
      body: payload.body,
      type: payload.type,
      recipientUid: userId
    },
    tokens
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(
      `Notifica "${payload.title}" inviata: ${response.successCount}/${tokens.length} dispositivi.`
    );

    const invalidTokens = response.responses
      .map((result, index) => ({
        token: tokens[index],
        code: result.error?.code
      }))
      .filter(item =>
        item.code === 'messaging/registration-token-not-registered' ||
        item.code === 'messaging/invalid-registration-token'
      )
      .map(item => item.token);

    if (invalidTokens.length > 0) {
      const userRef = db.collection('users').doc(userId);
      // Le Firestore Rules consentono una sola rimozione di token per scrittura.
      for (const invalidToken of invalidTokens) {
        await userRef.update({
          fcmTokens: admin.firestore.FieldValue.arrayRemove(invalidToken),
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }
      console.log(`Rimossi ${invalidTokens.length} token FCM non validi per ${userId}.`);
    }
  } catch (error) {
    console.error("Errore durante l'invio o la pulizia dei token FCM:", error);
  }
}
