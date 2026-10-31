const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const keyPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || path.join(__dirname, 'serviceAccountKey.json');
if (!fs.existsSync(keyPath)) {
  console.error('Credenziali Firebase non trovate. Monta il service account come secret read-only.');
  process.exit(1);
}

const serviceAccount = require(keyPath);
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();
const users = db.collection('users');

console.log("Notifier avviato: ascolto degli eventi nella collection group 'inbox'.");

let initialSnapshot = true;
db.collectionGroup('inbox').onSnapshot(async (snapshot) => {
  // La prima snapshot contiene richieste già esistenti: non inviare notifiche retroattive.
  if (initialSnapshot) {
    initialSnapshot = false;
    return;
  }

  for (const change of snapshot.docChanges()) {
    const request = change.doc.data() || {};
    const senderUid = request.senderUid;
    const recipientUid = request.recipientUid;
    if (!senderUid || !recipientUid || senderUid === recipientUid) continue;

    if (change.type === 'added') {
      await sendToUser(recipientUid, {
        title: 'Nuova richiesta di amicizia',
        body: 'Hai ricevuto una richiesta di amicizia su Cesena Remembers.',
        type: 'friend_request',
      });
    } else if (change.type === 'removed') {
      // La richiesta rimossa corrisponde a un'accettazione solo se il mittente
      // risulta ora amico del destinatario; rifiuti, annullamenti e cancellazioni
      // account non generano questa notifica.
      try {
        const senderSnapshot = await users.doc(senderUid).get();
        const sender = senderSnapshot.data() || {};
        const accepted = (sender.friends || []).includes(recipientUid) &&
          !(sender.sentFriendRequests || []).includes(recipientUid);
        if (accepted) {
          await sendToUser(senderUid, {
            title: 'Nuova amicizia',
            body: 'La tua richiesta di amicizia è stata accettata.',
            type: 'friend_accepted',
          });
        }
      } catch (error) {
        console.error('Errore nel controllo di una richiesta rimossa:', error.message);
      }
    }
  }
}, (error) => {
  console.error('Errore durante l’ascolto delle richieste:', error);
});

async function sendToUser(userId, payload) {
  try {
    const snapshot = await users.doc(userId).get();
    if (!snapshot.exists) return;
    const data = snapshot.data() || {};
    if (data.preferences?.notifiche === false) return;
    const tokens = Array.isArray(data.fcmTokens) ? data.fcmTokens.filter(Boolean) : [];
    if (tokens.length === 0) return;

    const response = await admin.messaging().sendEachForMulticast({
      notification: { title: payload.title, body: payload.body },
      data: { type: payload.type },
      tokens,
    });

    const invalidTokens = [];
    response.responses.forEach((item, index) => {
      const code = item.error?.code || '';
      if (!item.success && (
        code.includes('registration-token-not-registered') ||
        code.includes('invalid-registration-token')
      )) {
        invalidTokens.push(tokens[index]);
      }
    });
    if (invalidTokens.length) {
      await users.doc(userId).update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
      });
    }
  } catch (error) {
    console.error(`Errore invio notifica a ${userId}:`, error.message);
  }
}
