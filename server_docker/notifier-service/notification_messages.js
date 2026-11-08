const FRIEND_NOTIFICATION_MESSAGES = Object.freeze({
  friend_request: Object.freeze({
    it: Object.freeze({
      title: 'Nuova richiesta di amicizia',
      body: 'Qualcuno vuole stringere amicizia con te su Cesena Remembers!'
    }),
    en: Object.freeze({
      title: 'New friend request',
      body: 'Someone wants to connect with you on Cesena Remembers!'
    })
  }),
  friend_accepted: Object.freeze({
    it: Object.freeze({
      title: 'Nuova amicizia!',
      body: 'La tua richiesta di amicizia è stata accettata.'
    }),
    en: Object.freeze({
      title: 'New friendship!',
      body: 'Your friend request was accepted.'
    })
  })
});

function buildFriendNotification(type, languageCode = 'it') {
  const language = typeof languageCode === 'string' &&
      languageCode.toLowerCase().startsWith('en')
    ? 'en'
    : 'it';
  const message = FRIEND_NOTIFICATION_MESSAGES[type]?.[language];

  if (!message) {
    throw new Error(`Unsupported friend notification type: ${type}`);
  }

  return { ...message, type };
}

module.exports = { buildFriendNotification };
