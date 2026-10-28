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

La nuova app separa i dati privati (`users/{uid}`: email, preferenze, token FCM e richieste) dalla proiezione pubblica (`public_profiles/{uid}`: profilo, amici e statistiche). Prima di distribuire `firestore.rules`, esegui la migrazione una volta con una credenziale Admin SDK conservata fuori da questa cartella:

```bash
python -m pip install firebase-admin
# Linux/macOS
export GOOGLE_APPLICATION_CREDENTIALS="/percorso/protetto/service-account.json"
python scripts/migrate_public_profiles.py --project-id cesenaremembers1945
# dopo aver controllato l'anteprima e fatto un backup Firestore:
python scripts/migrate_public_profiles.py --project-id cesenaremembers1945 --apply
```

Su PowerShell usa `$env:GOOGLE_APPLICATION_CREDENTIALS="C:\percorso\protetto\service-account.json"` e gli stessi comandi Python. Senza `--apply` lo script è solo dry-run. Prima fai un backup: con `--apply` normalizza e sostituisce i documenti `users/{uid}` completati e le relative proiezioni pubbliche, rimuovendo i campi legacy non previsti dallo schema; ripulisce i profili incompleti, riallinea gli indici username e ricrea solo richieste di amicizia reciproche. Se trova un profilo completato non valido o username duplicati si ferma senza scrivere: correggi i dati segnalati, ripeti il dry-run e applica solo quando il riepilogo è coerente. Poi distribuisci le regole con `firebase deploy --only firestore:rules` (Firebase CLI autenticata sul progetto corretto). Non caricare mai la chiave Admin nel repository o nell'APK.

Le richieste di amicizia sono in `friend_requests/{destinatario}/inbox/{mittente}`. Le Rules impediscono letture del documento privato degli altri utenti e limitano le modifiche social cross-account ai soli UID dell'utente autenticato.

### Build release Android

La release richiede un tuo keystore e `android/key.properties`, escluso dal repository. Il campo `storeFile` è relativo alla cartella `android/app` se usi un percorso relativo; se il keystore è fuori dal progetto, usa un percorso assoluto. Non includere keystore o file di servizio in uno ZIP pubblico. Prima di caricare l'AAB in Play Console, completa la firma release, verifica il Firebase project e l'OAuth client/SHA-1 in Google Cloud Console, compila la sezione Data Safety, inserisci l'URL pubblico di privacy e di eliminazione account e specifica il titolare del trattamento nell'informativa.

### Limiti da tenere presenti

L'endpoint quiz resta HTTP come richiesto; l'app Android consente il cleartext soltanto per `pascal.ispascalcomandini.it`, non globalmente. Il server applica un limite base per IP e non usa nome/descrizione inviati dal client per generare il prompt. Non trasmettere token Firebase su questo endpoint HTTP. La limitazione per IP non sostituisce autenticazione a livello di rete, HTTPS e rate limiting al reverse proxy.

Le Rules limitano gli incrementi XP per singola scrittura, ma il punteggio è ancora calcolato dal client: non è anti-cheat completo. Per una classifica affidabile, la registrazione definitiva di XP e achievement deve essere spostata su un backend fidato con Firebase Admin SDK.


### Prima della pubblicazione: elementi che richiedono ancora un'azione del titolare

- Esegui e verifica la migrazione `public_profiles` prima di pubblicare le nuove Rules; il client da solo non può migrare i documenti già su Firebase.
- `xp` e statistiche sono ancora registrati dal client e le Rules limitano l'incremento per singola scrittura, ma non eliminano il cheating tramite richieste ripetute. La soluzione definitiva è assegnare il punteggio in un backend attendibile con Firebase Admin SDK.
- In `web/legal/privacy.html` inserisci il nome/ente effettivo del titolare e verifica con il responsabile del progetto finalità, basi giuridiche, destinatari e tempi di conservazione. Compila anche Data Safety e il modulo di cancellazione account nella Play Console. L'URL di cancellazione fornito dal sito va pubblicato su un dominio accessibile.
- Il rate limit del quiz è per IP e non equivale ad autenticazione; il quiz resta in HTTP come richiesto, quindi un intermediario di rete può alterare richieste/risposte. Non inviare token di autenticazione o segreti su quell'endpoint.
- Attiva Firebase App Check (Play Integrity) dopo aver verificato che la versione Play sia registrata; prima fai test in monitoraggio e poi enforcement.
- Prima di `flutter build appbundle --release`, crea `android/key.properties` con la chiave upload che possiedi già e conserva il keystore fuori dal repository. Il file non viene incluso nello ZIP.
- Qui non è possibile eseguire `flutter analyze`, test Flutter, né compilare APK/AAB perché Flutter SDK/Gradle/Firebase CLI non sono presenti nell'ambiente di verifica.
