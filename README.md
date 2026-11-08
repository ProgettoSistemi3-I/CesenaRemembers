# Cesena Remembers

**Tour storico interattivo di Cesena — esplora i luoghi, scopri la storia e mettiti alla prova.**

Cesena Remembers 1945 è un'applicazione mobile educativa che accompagna alla scoperta di luoghi e testimonianze storiche della città di Cesena attraverso una mappa interattiva, percorsi a piedi, contenuti storico-culturali e quiz gamificati.

<p align="center">
  <img src="web/loginView.jpg" alt="Anteprima di Cesena Remembers" width="720">
</p>

<p align="center">
  <a href="https://cesenaremembers.com">Sito ufficiale</a> ·
  <a href="https://cesenaremembers.com/legal/privacy.html">Privacy</a> ·
  <a href="https://cesenaremembers.com/legal/terms.html">Termini d'uso</a> ·
  <a href="https://cesenaremembers.com/legal/delete-account.html">Eliminazione account</a>
</p>

---

## Indice

- [Panoramica](#panoramica)
- [Funzionalità](#funzionalità)
- [Stack tecnologico](#stack-tecnologico)
- [Architettura del progetto](#architettura-del-progetto)
- [Backend e servizi](#backend-e-servizi)
- [Modello dati e sicurezza](#modello-dati-e-sicurezza)
- [Requisiti](#requisiti)
- [Configurazione locale](#configurazione-locale)
- [Build e pubblicazione Android](#build-e-pubblicazione-android)
- [Firebase e manutenzione](#firebase-e-manutenzione)
- [Test e controlli](#test-e-controlli)
- [Documentazione e riferimenti](#documentazione-e-riferimenti)
- [Licenza](#licenza)

## Panoramica

L'app combina esplorazione geografica e apprendimento: l'utente consulta i punti di interesse, organizza un tour, raggiunge le tappe con il supporto GPS e affronta quiz legati ai luoghi visitati. I risultati contribuiscono a progressi, XP, trofei e classifica.

Il catalogo storico attualmente integrato comprende dieci luoghi:

- Abbazia di Santa Maria del Monte
- Chiesa e Convento dell'Osservanza
- Chiesa di San Rocco
- Chiesa di Santa Cristina
- Palazzo del Ridotto
- Palazzo Fantaguzzi
- Rocca Malatestiana
- Rifugi antiaerei della Rocca
- Stabilimento Arrigoni
- Stazione ferroviaria di Cesena

L'applicazione e i contenuti dell'interfaccia sono disponibili in italiano e inglese.

## Funzionalità

### Mappa e tour

- Mappa interattiva con punti di interesse, schede informative e immagini.
- Posizione dell'utente tramite GPS, previa autorizzazione e attivazione dell'opzione nell'app.
- Tour guidati con tappe, distanza, indicazione della tappa corrente e possibilità di riordinare le tappe successive.
- Percorsi pedonali calcolati tramite Mapbox Directions.
- Stili cartografici standard, scuro e satellitare, con attribuzioni dei rispettivi fornitori.
- Aggiornamento automatico del percorso durante un tour attivo quando cambia la posizione dell'utente o la destinazione.

### Quiz e gamification

- Quiz contestuali ai luoghi visitati, con tre domande per sessione.
- Generazione lato server a partire da schede storiche locali e fatti verificati.
- Controlli strutturali e di coerenza delle domande prima che vengano restituite al client.
- Livelli di difficoltà legati ai progressi dell'utente.
- Calcolo di XP, risultati dei quiz, statistiche di tour e trofei.
- Fallback locale: se il servizio remoto non è disponibile o restituisce un risultato non valido, l'app propone le domande statiche incluse nel client e segnala che non sono personalizzate.

### Account e community

- Accesso tramite Google Sign-In e Firebase Authentication.
- Profilo con username, nome visualizzato, avatar, XP, progressi e trofei.
- Richieste di amicizia, accettazione/rifiuto e rimozione delle amicizie.
- Profili pubblici e classifica globale.
- Statistiche dettagliate consultabili dal proprietario e dagli amici reciproci.
- Notifiche push per nuove richieste di amicizia e richieste accettate.

### Preferenze e controllo dell'account

- Tema chiaro e scuro.
- Lingua italiana o inglese.
- Preferenze GPS e notifiche.
- Consultazione di Privacy Policy e Termini d'uso.
- Eliminazione dell'account dall'app e istruzioni pubbliche per richiederla anche senza accesso.

## Stack tecnologico

| Area | Tecnologie |
|---|---|
| App mobile | Flutter, Dart, Material |
| Navigazione e mappe | `flutter_map`, `latlong2`, `geolocator`, `flutter_map_location_marker` |
| Cartografia | CARTO, Stadia Maps (Alidade Smooth Dark e Alidade Satellite) |
| Routing pedonale | Mapbox Directions API |
| Backend applicativo | Firebase Authentication, Cloud Firestore, Firebase Cloud Messaging |
| Diagnostica e protezione | Firebase Crashlytics, Firebase App Check / Play Integrity |
| Stato e dependency injection | Controller applicativi, Use Case, `get_it` |
| API quiz | Python 3.11, FastAPI, Pydantic, HTTPX, Uvicorn |
| Generazione quiz | API LLM compatibili con il protocollo OpenAI Chat Completions |
| Push notifications | Node.js, Firebase Admin SDK, Firebase Cloud Messaging |
| Deployment | Docker Compose, Nginx, HTTPS/TLS |
| Automazione release Android | GitHub Actions |

### Licenze, attribuzioni e cache cartografica

- **CARTO:** la mappa standard usa tile raster CARTO e mostra l'attribuzione a CARTO e OpenStreetMap. La build riceve la variabile `CARTO_API_KEY`.
- **Stadia Maps:** le mappe scura e satellitare usano rispettivamente Alidade Smooth Dark e Alidade Satellite sugli endpoint UE. La vista satellitare mostra l'attribuzione richiesta a CNES, Airbus DS e PlanetObserver (dati Copernicus), oltre ai crediti Stadia Maps, OpenMapTiles e OpenStreetMap. Riferimenti: [Alidade Satellite](https://docs.stadiamaps.com/map-styles/alidade-satellite/) e [attribuzioni](https://docs.stadiamaps.com/attribution/).
- **Piano Stadia:** i termini pubblicati con efficacia dal 9 novembre 2026 riservano il piano gratuito a utilizzi di valutazione e non commerciali. La FAQ Stadia contempla espressamente progetti accademici non commerciali svolti da studenti, docenti e personale di istituti/programmi educativi. Un'app che genera ricavi (per esempio tramite pubblicità o monetizzazione) o è gestita da un'organizzazione for-profit richiede un abbonamento a pagamento. La pubblicazione su uno store, da sola, non basta a qualificare con certezza il caso: per un'app distribuita pubblicamente è prudente chiedere conferma scritta a Stadia Maps descrivendo titolarità, finalità, pubblico e assenza/presenza di ricavi. L'account Stadia deve inoltre essere creato e gestito in conformità alla sezione 6 dei termini: per titolari dell'account tra 13 e 18 anni deve crearlo un genitore/tutore legale, che accetta i termini. Non condividere chiavi o abbonamenti tra prodotti o soggetti distinti. Riferimenti: [Terms of Service effective 9 November 2026](https://stadiamaps.com/terms-of-service/versions/2026-11-09/) e [FAQ](https://stadiamaps.com/faqs).
- **Cache tile:** il client usa una cache LRU esclusivamente in memoria da 8 MB con `CachePolicy.request`, governata dagli header HTTP. Non implementa una cache persistente o un archivio offline delle tile Stadia. I termini Stadia consentono la cache locale lato client entro la durata indicata dagli header HTTP (o sette giorni se assenti); la cache offline mobile è soggetta a limiti distinti.
- **Esri World Imagery:** non è più utilizzato dall'app. Il precedente endpoint pubblico ArcGIS World Imagery è stato rimosso perché la raggiungibilità senza token non dimostra il diritto di incorporare il servizio in un'app pubblica. Le condizioni Esri limitano l'uso gratuito previsto dai termini alle finalità non commerciali e richiedono una licenza specifica per l'uso commerciale; inoltre le immagini di terze parti possono avere ulteriori condizioni. Non essendo disponibile una licenza specifica del progetto verificata, la vista satellitare è stata sostituita con Alidade Satellite. Riferimento: [Esri Web Site and Services Terms](https://www.esri.com/it-it/legal/terms/web-site-service).

Le dipendenze Dart e i relativi vincoli sono definiti in [`pubspec.yaml`](pubspec.yaml); quelle Python in [`server_docker/quiz-service/requirements.txt`](server_docker/quiz-service/requirements.txt).

## Architettura del progetto

Il client Flutter adotta una struttura a livelli ispirata a Clean Architecture e Domain-Driven Design. L'obiettivo è isolare le regole applicative e i contratti dai dettagli infrastrutturali e dalla UI.

```text
lib/
├── config/                 Configurazione runtime tramite dart-define
├── core/                   Logging e diagnostica trasversale
├── domain/
│   ├── entities/           Entità e modelli di dominio
│   ├── repositories/        Contratti dei repository
│   ├── services/           Servizi e regole di dominio
│   ├── usecases/            Casi d'uso applicativi
│   └── validation/         Validazioni di dominio
├── data/
│   ├── network/            Client HTTP e certificate pinning
│   ├── seeds/              Contenuti locali e quiz di fallback
│   ├── user/               Data source Firestore per profili, progressi e social
│   └── *.dart              Implementazioni concrete dei repository
├── models/                 Modelli di serializzazione
├── presentation/
│   ├── controllers/        Coordinamento dello stato delle schermate
│   ├── pages/              Schermate e flussi UI
│   ├── services/           Servizi di presentazione e integrazioni UI
│   ├── theme/              Tema e palette
│   └── widgets/            Componenti riutilizzabili
├── l10n/                   Risorse di localizzazione IT/EN
├── firebase_options.dart   Configurazione Firebase generata
├── injection_container.dart Composition root e registrazione get_it
└── main.dart               Bootstrap dell'applicazione
```

### Dipendenze tra i livelli

- **Presentation** gestisce schermate, interazioni e controller; invoca i casi d'uso senza contenere direttamente l'accesso a Firestore.
- **Domain** contiene entità, interfacce dei repository, servizi e Use Case; non dipende dai dettagli Firebase o dalla UI.
- **Data** implementa i contratti del Domain e incapsula Firebase, HTTP, seed locali e altri provider esterni.
- **Dependency injection** è centralizzata in `lib/injection_container.dart` tramite `get_it`.

Il punto di ingresso inizializza Firebase, App Check, Crashlytics, Messaging e dependency injection prima di mostrare la schermata iniziale.

## Backend e servizi

Il codice server relativo a Cesena Remembers è organizzato sotto [`server_docker/`](server_docker/).

### Quiz API

Percorso: [`server_docker/quiz-service/`](server_docker/quiz-service/)

Il servizio FastAPI espone l'endpoint:

```http
POST /api/generate-quiz
GET  /health
```

La richiesta contiene l'identificativo del POI, l'XP corrente e la lingua. Gli identificativi sono verificati rispetto alla whitelist caricata dalle schede presenti in `facts/`: il contesto storico usato per generare le domande proviene dalle schede server-side, non dal nome o dalla descrizione ricevuti dal client.

Per ogni richiesta il servizio seleziona fatti verificati, invoca il provider LLM, valida le domande e restituisce HTTP 200 soltanto quando sono disponibili tre domande valide. In caso contrario restituisce un errore HTTP non-200, così il client può attivare il fallback locale.

Le schede in `facts/` sono mantenute nel repository e caricate in memoria all'avvio. Attualmente sono presenti dieci schede, una per ciascun POI. Le modalità e il formato per aggiornarle sono descritti in [`facts/README.md`](server_docker/quiz-service/facts/README.md).

Il provider è configurabile tramite variabili d'ambiente. Sono previsti preset per Groq, Gemini e Cerebras, oltre a un endpoint compatibile OpenAI configurabile. Il preset predefinito è Groq con modello `openai/gpt-oss-120b`.

Variabili principali:

| Variabile | Significato |
|---|---|
| `LLM_PROVIDER` | Provider da utilizzare (`groq`, `gemini`, `cerebras`, `openai_compatible`) |
| `GROQ_API_KEY` / `GEMINI_API_KEY` / `CEREBRAS_API_KEY` | Chiave del provider selezionato |
| `LLM_API_KEY` | Chiave generica, utile anche per provider compatibili OpenAI |
| `LLM_BASE_URL` | URL base personalizzato del provider |
| `LLM_MODEL` | Modello da utilizzare |
| `LLM_TIMEOUT_S` | Timeout della singola chiamata al modello |
| `REQUEST_DEADLINE_S` | Budget massimo per la generazione della risposta |
| `MAX_LLM_CALLS` | Numero massimo di chiamate al modello |
| `QUIZ_OPTIONS` | Numero di opzioni per domanda: 3 o 4 |
| `FACTS_PER_PROMPT` | Numero massimo di fatti inseriti nel prompt |

Configurazione locale: creare `server_docker/quiz-service/.env` e inserire soltanto le variabili necessarie. Il file è escluso da Git e dal contesto Docker. Non inserire chiavi reali in questo README o in altri file versionati.

### Notifiche push

Percorso: [`server_docker/notifier-service/`](server_docker/notifier-service/)

Il servizio Node.js utilizza Firebase Admin SDK e osserva in modo selettivo i campi Firestore necessari alla gestione delle notifiche social. Invia messaggi FCM per nuove richieste di amicizia e richieste accettate, rispettando la preferenza notifiche dell'utente e rimuovendo i token FCM non più validi.

La service account key deve essere presente esclusivamente sul server nel percorso previsto dal Compose (`server_docker/notifier-service/serviceAccountKey.json`), montata in sola lettura. È esclusa dal repository e dall'immagine Docker.

### Nginx, TLS e rete Docker

Il gateway Nginx riceve le richieste HTTPS sulla porta `8000` e inoltra `/api/generate-quiz` al servizio FastAPI. Il container quiz non pubblica direttamente la propria porta sull'host: comunica con Nginx attraverso la rete Docker dedicata `quiz-backend`.

Il client utilizza HTTPS e un certificato server incluso nell'app (`assets/certs/server.crt`) come trust anchor dedicato. La chiave privata TLS (`server.key`) deve rimanere sul server e non deve essere aggiunta a Git. La sostituzione del certificato richiede un aggiornamento coordinato del server e della versione dell'app distribuita.

## Modello dati e sicurezza

Le regole di accesso sono definite in [`firestore.rules`](firestore.rules) e devono essere considerate parte integrante dell'applicazione.

| Collezione | Contenuto e accesso previsto |
|---|---|
| `users/{uid}` | Dati privati dell'account e stato applicativo; lettura del documento riservata al proprietario. |
| `public_profiles/{uid}` | Nome visualizzato, username, avatar e riepiloghi pubblici; consultabili dagli utenti autenticati secondo le Rules. |
| `friend_stats/{uid}` | Statistiche dettagliate e lista amici; leggibili dal proprietario e dagli amici con relazione reciproca. La query/lista globale è disabilitata. |
| `leaderboard/{uid}` | Proiezione minima per la classifica globale; le query sono limitate a 50 risultati. |
| `usernames/{username}` | Indice univoco username; non è consentita la lettura globale della collezione. |
| `friend_requests/{recipientUid}/inbox/{senderUid}` | Richieste di amicizia organizzate per destinatario. |
| `banned_users/{uid}` | Record di moderazione gestiti lato amministrativo; il client non può crearli, modificarli o eliminarli. |

La classifica è globale, mentre le statistiche dettagliate restano riservate. Il profilo pubblico può essere consultato da qualsiasi account autenticato, anche minorenne: non inserire nei campi pubblici nome completo, scuola, recapiti o altre informazioni identificative.

### Aspetti di sicurezza da non confondere

- Le Firestore Security Rules verificano le scritture e limitano i campi modificabili, ma non trasformano il punteggio calcolato dal client in un sistema anti-cheat completo. L'assegnazione definitiva di XP e trofei dovrebbe essere demandata a un backend fidato per una protezione più forte.
- Il rate limit del quiz riduce gli abusi e le richieste eccessive, ma non equivale ad autenticazione dell'utente.
- `FORWARDED_ALLOW_IPS=*` nel container quiz è coerente soltanto finché Nginx resta l'unico peer sulla rete Docker dedicata. Non collegare container non fidati a `quiz-backend`.
- App Check usa il provider Debug nelle build debug e Play Integrity nelle build release Android. L'enforcement va configurato e verificato nella Firebase Console prima di considerarlo operativo.
- La dichiarazione di età mostrata durante l'onboarding è autodichiarata: non costituisce verifica documentale dell'età.
- Le chiavi Admin SDK, le chiavi private TLS, i keystore Android e i segreti dei provider non devono essere committati né inclusi nell'APK.

## Requisiti

Per sviluppare il client:

- Flutter SDK con Dart compatibile con il vincolo `^3.10.4` dichiarato in `pubspec.yaml`.
- Android SDK e Java 17 per compilare l'app Android.
- Un progetto Firebase configurato per le piattaforme che si desidera eseguire.
- Credenziali/API key dei servizi cartografici e OAuth richiesti dall'ambiente.

Per lavorare sui servizi server:

- Python 3.11 per il servizio quiz.
- Docker Engine e Docker Compose per il deployment containerizzato.
- Node.js 18 per lo sviluppo locale del notifier.
- Firebase CLI per emulatori e distribuzione delle Firestore Rules.

## Configurazione locale

### 1. Clonare il repository e installare le dipendenze

```bash
git clone https://github.com/ProgettoSistemi3-I/CesenaRemembers.git
cd CesenaRemembers
flutter pub get
flutter gen-l10n
```

### 2. Configurare Firebase

Il progetto utilizza Firebase Authentication, Cloud Firestore, Cloud Messaging, Crashlytics e App Check. Verificare che:

1. Il progetto Firebase corretto sia selezionato nella console.
2. Google Sign-In sia abilitato in Authentication.
3. `android/app/google-services.json` corrisponda al progetto e all'application ID configurati.
4. `lib/firebase_options.dart` sia aggiornato per le piattaforme effettivamente utilizzate.
5. Le Firestore Security Rules distribuite corrispondano a `firestore.rules`.

Non copiare nel repository service account Admin SDK o altre credenziali private.

### 3. Configurare i parametri runtime

I parametri per OAuth e provider cartografici vengono letti tramite `--dart-define` e non sono salvati nei sorgenti Dart.

Esempio per Linux/macOS:

```bash
flutter run \
  --dart-define=GOOGLE_WEB_CLIENT_ID="$GOOGLE_WEB_CLIENT_ID" \
  --dart-define=STADIA_MAPS_API_KEY="$STADIA_MAPS_API_KEY" \
  --dart-define=MAPBOX_ACCESS_TOKEN="$MAPBOX_ACCESS_TOKEN" \
  --dart-define=CARTO_API_KEY="$CARTO_API_KEY"
```

Su PowerShell è possibile passare gli stessi parametri in un unico comando:

```powershell
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=$env:GOOGLE_WEB_CLIENT_ID --dart-define=STADIA_MAPS_API_KEY=$env:STADIA_MAPS_API_KEY --dart-define=MAPBOX_ACCESS_TOKEN=$env:MAPBOX_ACCESS_TOKEN --dart-define=CARTO_API_KEY=$env:CARTO_API_KEY
```

Il servizio quiz utilizza per impostazione predefinita `https://pascal.ispascalcomandini.it:8000`. Per un ambiente differente è possibile impostare `QUIZ_API_BASE_URL` tramite `--dart-define`.

### 4. Avviare l'app

```bash
flutter run
```

### 5. Utilizzare Firestore Emulator (sviluppo)

`firebase.json` configura l'emulatore Firestore sulla porta `8080`. Avviare l'emulatore:

```bash
firebase emulators:start --only firestore
```

Poi avviare l'app in debug abilitando esplicitamente l'emulatore:

```bash
flutter run --dart-define=USE_FIRESTORE_EMULATOR=true --dart-define=FIRESTORE_EMULATOR_HOST=127.0.0.1
```

Per l'emulatore Android usare normalmente `10.0.2.2` come host, perché `127.0.0.1` nel dispositivo emulato identifica il dispositivo stesso. Su un dispositivo fisico utilizzare l'indirizzo LAN raggiungibile del computer che esegue l'emulatore.

## Build e pubblicazione Android

### Build locale

Per una build release firmata è necessario predisporre `android/key.properties` e il keystore di upload. Entrambi devono rimanere fuori dal versionamento.

Esempio di build Android App Bundle:

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols \
  --dart-define=GOOGLE_WEB_CLIENT_ID="$GOOGLE_WEB_CLIENT_ID" \
  --dart-define=STADIA_MAPS_API_KEY="$STADIA_MAPS_API_KEY" \
  --dart-define=MAPBOX_ACCESS_TOKEN="$MAPBOX_ACCESS_TOKEN" \
  --dart-define=CARTO_API_KEY="$CARTO_API_KEY"
```

Conservare i simboli generati da `--split-debug-info` in un archivio privato per poter simbolicare eventuali crash. Non distribuire il keystore o `key.properties`.

### GitHub Actions

Il workflow [`.github/workflows/android-release.yml`](.github/workflows/android-release.yml):

- può essere avviato manualmente da GitHub Actions;
- parte automaticamente quando viene pubblicato un tag con prefisso `v` (ad esempio `v1.0.1`);
- installa Java 17 e Flutter stable;
- costruisce un APK release firmato;
- carica l'APK come artifact e, quando eseguito su un tag, lo allega a una GitHub Release.

Secrets richiesti dal workflow:

- `KEYSTORE_BASE64`
- `KEY_ALIAS`
- `KEY_PASSWORD`
- `STORE_PASSWORD`
- `GOOGLE_WEB_CLIENT_ID`
- `STADIA_MAPS_API_KEY`
- `MAPBOX_ACCESS_TOKEN`
- `CARTO_API_KEY`

Il workflow crea un artifact/GitHub Release: non carica automaticamente il bundle su Google Play Console. La pubblicazione sullo store richiede il relativo passaggio in Play Console. Il file `codemagic.yaml` contiene inoltre un workflow iOS che produce un pacchetto non firmato; non equivale a una release iOS pronta per la distribuzione.

## Firebase e manutenzione

### Distribuzione delle Firestore Rules

Da eseguire soltanto dopo avere verificato progetto e ambiente di destinazione:

```bash
firebase login
firebase deploy --project cesenaremembers1945 --only firestore:rules
```

### Migrazione e proiezioni utente

Quando si modifica lo schema dei profili o delle proiezioni, le versioni già presenti su Firestore potrebbero richiedere una migrazione prima della distribuzione delle nuove Rules. Gli script amministrativi sono in `scripts/`: `migrate_public_profiles.py` migra i documenti e le proiezioni, mentre `backfill_global_leaderboard.py` popola la classifica globale.

Questi script utilizzano Firebase Admin SDK. Eseguire prima la modalità dry-run prevista dallo script, verificare i conteggi, predisporre un backup e utilizzare `--apply` soltanto dopo aver controllato l'anteprima. La chiave Admin deve essere conservata fuori dal repository.

### Ban e retention

- `scripts/ban_user.py` gestisce il ban e la pulizia delle proiezioni pubbliche collegate all'account.
- `scripts/purge_expired_bans.py` individua i record di moderazione scaduti; la modalità predefinita è dry-run.
- La retention configurata nel codice non sostituisce l'approvazione della relativa policy né la pianificazione effettiva del job di pulizia.

Consultare [`RELEASE_READINESS.md`](RELEASE_READINESS.md) prima di ogni release: contiene le verifiche manuali legali, privacy, infrastrutturali, di sicurezza e di distribuzione ancora da completare.

## Test e controlli

### Flutter

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

### Quiz API

```bash
cd server_docker/quiz-service
python -m pip install -r requirements.txt
python -m pip install pytest
python -m pytest -q tests
```

Il workflow GitHub Actions esegue anche `flutter analyze`, l'intera suite `flutter test` e il controllo sintattico del notifier a ogni push su `main` e sui branch `fix/**`, oltre che prima delle release. Lo stesso job rigenera le localizzazioni dagli ARB e aggiorna nel branch di revisione i file Dart generati e il lockfile. I test del servizio quiz usano un provider LLM fittizio e verificano il contratto HTTP, i dieci POI, i parametri, la validazione delle risposte, il fallback tramite errori non-200 e i timeout senza richiedere una vera chiave LLM.

### Verifiche di release

Prima di distribuire una versione controllare almeno:

- login Google e creazione/completamento profilo;
- mappa, permessi GPS, cambio stile, avvio/interruzione tour e navigazione tra tappe;
- quiz remoto, fallback locale e salvataggio del risultato;
- profilo, trofei, classifica globale, richieste e rimozione amicizie;
- notifiche in foreground, background e dopo il riavvio;
- disattivazione notifiche e rimozione dei token FCM;
- eliminazione account e verifica delle proiezioni residue;
- Firestore Rules con account proprietario, account terzo, account bannato e amici reciproci;
- build release firmata, App Check/Play Integrity e configurazione Data Safety in Play Console.

## Documentazione e riferimenti

| Documento | Descrizione |
|---|---|
| [`RELEASE_READINESS.md`](RELEASE_READINESS.md) | Checklist pre-release e attività operative da chiudere |
| [`DIAGNOSTICA_FIRESTORE.md`](DIAGNOSTICA_FIRESTORE.md) | Note di diagnostica Firestore |
| [`firestore.rules`](firestore.rules) | Regole di accesso al database |
| [`firebase.json`](firebase.json) | Configurazione Firebase ed emulatori |
| [`firestore.indexes.json`](firestore.indexes.json) | Indici compositi Firestore richiesti dalle query |
| [`server_docker/quiz-service/facts/README.md`](server_docker/quiz-service/facts/README.md) | Formato e criteri delle schede storiche per i quiz |
| [`server_docker/notifier-service/README.md`](server_docker/notifier-service/README.md) | Configurazione e avvio del servizio notifiche |
| [`web/legal/`](web/legal/) | Privacy, Termini e istruzioni di eliminazione account in italiano e inglese |

**Sito:** [cesenaremembers.com](https://cesenaremembers.com)  
**Contatto:** [cesenaremembers@gmail.com](mailto:cesenaremembers@gmail.com)  
**Nome pubblico sviluppatore Google Play:** OstoDev

## Licenza

Al momento il repository non contiene un file `LICENSE`. La disponibilità pubblica del codice su GitHub non implica automaticamente una licenza di riutilizzo, modifica o redistribuzione. Per utilizzare o integrare il software in altri progetti è necessario ottenere un'autorizzazione esplicita dai titolari dei relativi diritti.
