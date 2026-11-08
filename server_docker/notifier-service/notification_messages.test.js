const assert = require('node:assert/strict');
const test = require('node:test');

const { buildFriendNotification } = require('./notification_messages');

test('friend request notification is localized in English', () => {
  assert.deepEqual(buildFriendNotification('friend_request', 'en'), {
    title: 'New friend request',
    body: 'Someone wants to connect with you on Cesena Remembers!',
    type: 'friend_request'
  });
});

test('friend acceptance notification supports regional English locales', () => {
  assert.deepEqual(buildFriendNotification('friend_accepted', 'en-GB'), {
    title: 'New friendship!',
    body: 'Your friend request was accepted.',
    type: 'friend_accepted'
  });
});

test('Italian is preserved as the default and for unsupported languages', () => {
  assert.deepEqual(buildFriendNotification('friend_request', 'it'), {
    title: 'Nuova richiesta di amicizia',
    body: 'Qualcuno vuole stringere amicizia con te su Cesena Remembers!',
    type: 'friend_request'
  });
  assert.deepEqual(buildFriendNotification('friend_accepted', 'fr'), {
    title: 'Nuova amicizia!',
    body: 'La tua richiesta di amicizia è stata accettata.',
    type: 'friend_accepted'
  });
});

test('unsupported notification types fail explicitly', () => {
  assert.throws(
    () => buildFriendNotification('unknown', 'en'),
    /Unsupported friend notification type/
  );
});
