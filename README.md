# Cesena Remembers

App Flutter educativa/gamificata per esplorare luoghi storici di Cesena con percorso su mappa, quiz e profilo utente.

## Architettura

Il progetto segue una struttura a layer ispirata a DDD/Clean Architecture:

- `lib/domain`
  - `entities`: modelli di dominio puri.
  - `repositories`: contratti astratti.
  - `usecases`: orchestrazione dei comportamenti applicativi.
  - `services`: logica di dominio (tour routing/scoring).
- `lib/data`
  - implementazioni concrete dei repository.
  - data source utente e seed locali dei POI.
- `lib/presentation`
  - pagine Flutter, widget e controller UI.
- `lib/core`
  - utilità trasversali (logging).

Dependency injection centralizzata in `lib/injection_container.dart` con `get_it`.

## Runtime e modalità operative

L'app usa:
- Firebase (auth + firestore)
- Mappe tile esterne
- Backend quiz AI (endpoint HTTP configurato internamente nel repository quiz)

### Quiz: fallback resiliente

Se il backend quiz non è disponibile, l'app usa automaticamente le domande seed locali (`HistoricPlacesSeed`) e mostra un avviso esplicito in UI: domande non personalizzate + difficoltà locale.

## Setup sviluppo

Prerequisiti:
- Flutter SDK (versione compatibile con `pubspec.yaml`)
- Dart SDK (incluso in Flutter)
- Configurazione Firebase valida per le piattaforme target

Comandi principali:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
# release firmata, solo dopo aver configurato android/key.properties
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

## Setup produzione (linee guida)

- Verificare credenziali Firebase e file piattaforma (`google-services.json`, `GoogleService-Info.plist`).
- Validare disponibilità endpoint backend quiz.
- Eseguire quality gate minimo:
  - `flutter analyze`
  - `flutter test`
  - smoke test navigazione login → mappa → quiz → profilo.

## Qualità del codice

Pratiche adottate:
- separazione use case/repository/controller;
- riduzione commenti temporanei e marker di debug;
- logging strutturato via `dart:developer`.

## Licenza

Repository privato / uso interno progetto.


## Pubblicazione Android e Firestore (controlli pre-release)

### Migrazione obbligatoria prima delle nuove Rules

La nuova app separa i dati in tre raccolte: `users/{uid}` contiene dati privati e stato applicativo; `public_profiles/{uid}` contiene soltanto nome visualizzato, username e avatar per la ricerca; `friend_stats/{uid}` contiene XP, progressi, achievement e lista amici, leggibili dal proprietario e dagli amici reciproci. La query globale delle statistiche è disabilitata. I profili già presenti devono essere migrati prima di distribuire le nuove Rules. Prima di distribuire `firestore.rules`, esegui la migrazione una volta con una credenziale Admin SDK conservata fuori da questa cartella:

```bash
python -m pip install firebase-admin
# Linux/macOS
export GOOGLE_APPLICATION_CREDENTIALS="/percorso/protetto/service-account.json"
python scripts/migrate_public_profiles.py --project-id cesenaremembers1945
# dopo aver controllato l'anteprima e fatto un backup Firestore:
python scripts/migrate_public_profiles.py --project-id cesenaremembers1945 --apply
```

Su PowerShell usa `$env:GOOGLE_APPLICATION_CREDENTIALS="C:\percorso\protetto\service-account.json"` e gli stessi comandi Python. Senza `--apply` lo script è solo dry-run. Prima fai un backup: con `--apply` normalizza e sostituisce i documenti `users/{uid}` completati e le relative proiezioni pubbliche, rimuovendo i campi legacy non previsti dallo schema; ripulisce i profili incompleti, riallinea gli indici username e ricrea solo richieste di amicizia reciproche e rimuove le proiezioni pubbliche, gli indici username e le relazioni dei profili presenti in `banned_users` (senza cancellare i documenti privati/Auth degli account bannati). Se trova un profilo completato non valido o username duplicati si ferma senza scrivere: correggi i dati segnalati, ripeti il dry-run e applica solo quando il riepilogo è coerente. Poi distribuisci le regole con `firebase deploy --only firestore:rules` (Firebase CLI autenticata sul progetto corretto). Non caricare mai la chiave Admin nel repository o nell'APK.

L'output del dry-run mostra anche il numero di amici reciproci per username e quanti `friend_stats` mancano. La classifica è volutamente limitata a te e ai tuoi amici con relazione reciproca: se compare soltanto il tuo account, controlla prima che la migrazione sia stata eseguita con `--apply`, che il tuo username abbia almeno un amico reciproco nel riepilogo e che anche il documento `friend_stats` del suo account sia presente. Non aggiungere una query globale su `friend_stats`: violerebbe la privacy richiesta.

Le regole del completamento profilo sono state alleggerite: verificano l'esistenza delle proiezioni nel commit, mentre le regole dedicate di `public_profiles`, `friend_stats` e `usernames` verificano che i dati corrispondano. Nei profili incompleti esistenti vengono controllate le sole chiavi modificate, così i campi legacy non toccati non bloccano l'onboarding. È previsto anche un percorso sicuro per creare nello stesso commit il documento utente completo se `ensureUserDocument` non lo ha creato.

Le richieste di amicizia sono in `friend_requests/{destinatario}/inbox/{mittente}`. Le Rules impediscono letture del documento privato degli altri utenti e limitano le modifiche social cross-account ai soli UID dell'utente autenticato. Le Rules non hanno cicli/istruzioni iterative; le liste dinamiche sono limitate a 100, 200 o 500 elementi. Attenzione: il limite reale di Firestore per le letture `get/exists` nelle Rules è 10 per singola operazione e 20 per richiesta multi-documento/batch, non 1.000 iterazioni; i rami sociali vanno comunque verificati con l'emulatore.

### Build release Android

La release richiede un tuo keystore e `android/key.properties`, escluso dal repository. Il campo `storeFile` è relativo alla cartella `android/app` se usi un percorso relativo; se il keystore è fuori dal progetto, usa un percorso assoluto. Non includere keystore o file di servizio in uno ZIP pubblico. Prima di caricare l'AAB in Play Console, completa la firma release, verifica il Firebase project e l'OAuth client/SHA-1 in Google Cloud Console, compila la sezione Data Safety, inserisci l'URL pubblico di privacy e di eliminazione account e specifica il titolare del trattamento nell'informativa.

### Limiti da tenere presenti

L'endpoint quiz resta HTTP come richiesto; l'app Android consente il cleartext soltanto per `pascal.ispascalcomandini.it`, non globalmente. Il server applica un limite base per IP e non usa nome/descrizione inviati dal client per generare il prompt. Non trasmettere token Firebase su questo endpoint HTTP. La limitazione per IP non sostituisce autenticazione a livello di rete, HTTPS e rate limiting al reverse proxy. Con Docker, imposta `FORWARDED_ALLOW_IPS` nell’ambiente del server al solo IP/gateway del proxy che si collega al container (ad esempio ngrok o il reverse proxy effettivo): il valore predefinito `127.0.0.1` è valido soltanto se il proxy raggiunge Uvicorn da localhost. Non impostare `*` su un servizio raggiungibile direttamente da Internet, perché consentirebbe di falsificare `X-Forwarded-For`.

Le Rules limitano gli incrementi XP per singola scrittura, ma il punteggio è ancora calcolato dal client: non è anti-cheat completo. Per una classifica affidabile, la registrazione definitiva di XP e achievement deve essere spostata su un backend fidato con Firebase Admin SDK.


### Prima della pubblicazione: elementi che richiedono ancora un'azione del titolare

- Esegui e verifica la migrazione `public_profiles` prima di pubblicare le nuove Rules; il client da solo non può migrare i documenti già su Firebase.
- `xp` e statistiche sono ancora registrati dal client. Le Rules limitano l'incremento a 80 XP, applicano un intervallo minimo di 5 secondi e impediscono di dichiarare il tour completo senza tutte le tappe e una durata minima; non è comunque anti-cheat completo. La soluzione definitiva è assegnare il punteggio in un backend attendibile con Firebase Admin SDK.
- In `web/legal/privacy.html` inserisci l'identità e i recapiti effettivi del titolare del trattamento e verifica con il responsabile del progetto finalità, basi giuridiche, destinatari e tempi di conservazione. Compila anche Data Safety e il modulo di cancellazione account nella Play Console. L'URL di cancellazione fornito dal sito va pubblicato su un dominio accessibile.
- Il rate limit del quiz è per IP e non equivale ad autenticazione; il quiz resta in HTTP come richiesto, quindi un intermediario di rete può alterare richieste/risposte. Non inviare token di autenticazione o segreti su quell'endpoint.
- Attiva Firebase App Check (Play Integrity) dopo aver verificato che la versione Play sia registrata; prima fai test in monitoraggio e poi enforcement.
- Prima di `flutter build appbundle --release`, crea `android/key.properties` con la chiave upload che possiedi già e conserva il keystore fuori dal repository. Il file non viene incluso nello ZIP.
- Qui non è stato possibile eseguire `flutter analyze`, test Flutter, né compilare APK/AAB perché Flutter SDK/Gradle/Firebase CLI non sono presenti nell'ambiente di verifica.


### Build Android con configurazione mappa

Le chiavi pubbliche dei provider mappa e il client ID OAuth vanno passati anche alla build Android tramite `--dart-define`; non vengono letti automaticamente dal file Codemagic iOS:

```bash
flutter build appbundle --release \
  --dart-define=GOOGLE_WEB_CLIENT_ID="$GOOGLE_WEB_CLIENT_ID" \
  --dart-define=STADIA_MAPS_API_KEY="$STADIA_MAPS_API_KEY" \
  --dart-define=MAPBOX_ACCESS_TOKEN="$MAPBOX_ACCESS_TOKEN" \
  --dart-define=CARTO_API_KEY="$CARTO_API_KEY"
```

Usa token pubblici con restrizioni di dominio/app appropriate. Non inserire chiavi server o credenziali Firebase Admin nell'app.

## Classifica globale e statistiche riservate

La classifica è globale: la raccolta `leaderboard` contiene esclusivamente `uid` e `xp`, ed è interrogabile dagli utenti autenticati con un limite massimo di 50 risultati. L'app arricchisce ogni riga con `displayName`, `username` e `avatarId` letti da `public_profiles`. Le statistiche dettagliate (`visitedPoiIds`, achievement, risultati quiz, tempi e lista amici) restano in `friend_stats` e sono leggibili soltanto dal proprietario e dagli amici reciproci.

Per popolare la nuova proiezione sui profili già migrati, configura `GOOGLE_APPLICATION_CREDENTIALS` con un service account protetto fuori dal repository ed esegui prima la simulazione:

```powershell
python scripts/backfill_global_leaderboard.py --project-id cesenaremembers1945
```

Dopo aver verificato il numero di profili, applica il backfill:

```powershell
python scripts/backfill_global_leaderboard.py --project-id cesenaremembers1945 --apply
```

Solo dopo il backfill distribuisci le nuove regole:

```powershell
firebase deploy --only firestore:rules
```

Le nuove versioni dell'app creano e aggiornano il documento `leaderboard/{uid}` nella stessa transazione che aggiorna XP. La cancellazione account rimuove anche il relativo documento dalla classifica.
