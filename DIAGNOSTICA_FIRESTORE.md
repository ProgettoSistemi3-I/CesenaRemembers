DIAGNOSTICA FIRESTORE — CESENA REMEMBERS

Questo ZIP non cambia il comportamento dell'app normalmente: la connessione all'emulatore è attiva solo in DEBUG quando viene passato USE_FIRESTORE_EMULATOR=true.

PASSAGGI (Windows / PowerShell)
1. Estrai il progetto e apri PowerShell nella cartella che contiene firebase.json.
2. Avvia il Firestore Emulator:
   firebase emulators:start --only firestore --project cesenaremembers1945
3. In un secondo terminale, avvia l'app su un EMULATORE ANDROID:
   flutter run --dart-define=USE_FIRESTORE_EMULATOR=true --dart-define=FIRESTORE_EMULATOR_HOST=10.0.2.2
   Se usi un telefono fisico, imposta FIRESTORE_EMULATOR_HOST all'IP LAN del PC e rendi raggiungibile la porta 8080 nella rete locale.
4. Riprova il completamento del profilo con un account di test. La registrazione/autenticazione rimane Firebase Auth, mentre le scritture Firestore di questa build vanno SOLO all'emulatore locale, non al database reale.
5. Apri http://127.0.0.1:4000 e scegli Firestore > Requests. Seleziona la richiesta fallita: la traccia mostra quale espressione della regola restituisce false o genera errore.
6. Inviami il dettaglio della traccia relativa a users/{uid}, usernames/{username} e public_profiles/{uid}. Non pubblicare token, password o dati personali.

IMPORTANTE
- Usa una registrazione di test; l'emulatore è separato dal database di produzione.
- In esecuzioni normali, senza le due opzioni dart-define, l'app continua a usare Firestore di produzione.
- La console emulator UI normalmente si avvia sulla porta 4000; il Firestore emulator sulla 8080.
