# Cesena Remembers Notifier Service

Questo è un microservizio Node.js dockerizzato che ascolta le modifiche al database Firestore e invia notifiche Push (FCM) ai dispositivi quando ricevono una richiesta di amicizia.

## Istruzioni per l'Avvio

1. **Scarica la Service Account Key:**
   - Vai sulla Console di Firebase.
   - Apri "Impostazioni progetto" -> "Account di servizio".
   - Clicca su "Genera nuova chiave privata".
   - Rinomina il file scaricato in `serviceAccountKey.json` e posizionalo in questa cartella (accanto a `index.js`). Il file è escluso dal contesto di build Docker e viene montato in sola lettura dal compose. **Non aggiungerlo mai a Git e non inserirlo nell'immagine.**

2. **Avvia il servizio tramite Docker Compose:**
   Dal percorso `server_docker` (dove si trova `docker-compose.yml`), dopo aver creato la chiave:
   ```bash
   docker compose up -d --build notifier-service
   ```
   Per controllare lo stato e i log:
   ```bash
   docker compose ps notifier-service
   docker compose logs -f notifier-service
   ```
   Il compose monta `./notifier-service/serviceAccountKey.json` in `/usr/src/app/serviceAccountKey.json:ro`. Se il file manca, Docker Compose non potrà avviare il servizio.

## Come Funziona
Il server ascolta in Firestore soltanto `receivedFriendRequests`, `sentFriendRequests`, `friends`, `fcmTokens` e `preferences.notifiche`: non carica il campo email né gli altri dati del profilo. Le notifiche vengono inviate solo quando la preferenza è attiva. I token rifiutati da FCM come non validi o non più registrati vengono rimossi dal documento utente. La cache locale viene inizializzata senza invii al primo snapshot.
