DIAGNOSTICA FIRESTORE — CESENA REMEMBERS

La connessione all'emulatore è attiva solo nelle build DEBUG avviate con
USE_FIRESTORE_EMULATOR=true. Senza questo parametro l'app continua a usare
Firestore di produzione.

PASSAGGI (Windows / PowerShell, telefono Android fisico collegato via USB)

1. Apri PowerShell nella cartella che contiene firebase.json e avvia Firestore:
   firebase emulators:start --only firestore --project cesenaremembers1945

2. In un SECONDO terminale configura il reverse ADB:
   adb reverse tcp:8080 tcp:8080
   adb reverse --list
   L'output deve mostrare il mapping della porta 8080.

3. Avvia l'app con una NUOVA build debug (termina prima eventuali sessioni
   flutter run già attive):
   flutter run --dart-define=USE_FIRESTORE_EMULATOR=true --dart-define=FIRESTORE_EMULATOR_HOST=127.0.0.1

   Con adb reverse, 127.0.0.1 è corretto anche sul telefono: la porta locale
   8080 del dispositivo viene inoltrata alla porta 8080 del PC.
   In alternativa, senza adb reverse, usa l'IP LAN del PC come host e consenti
   la porta 8080 nel firewall Windows.

4. Controlla il terminale di flutter run. Deve comparire:
   [Firebase] Firestore Emulator attivo su 127.0.0.1:8080

   Se il messaggio non compare, interrompi il test: l'app non è stata avviata
   con i dart-define corretti e potrebbe stare usando il database reale.

5. Apri http://127.0.0.1:4000 e seleziona Firestore > Requests.
   Accedi all'app con un account di test, completa la creazione del profilo
   mentre l'emulatore è attivo e poi completa un quiz per riprodurre il bug.
   La creazione del profilo e le scritture del quiz devono comparire qui.

NOTE IMPORTANTI
- L'emulatore Firestore parte vuoto: i documenti del database di produzione
  NON vengono copiati automaticamente. Per il test usa un account di prova
  e completa il profilo sull'emulatore prima di testare il quiz.
- Firebase Authentication resta collegato al progetto reale; solo Firestore
  viene reindirizzato all'emulatore.
- Le scritture Firestore di questa build debug vanno all'emulatore, non al
  database Firestore di produzione.
- La console emulator UI normalmente usa la porta 4000; Firestore usa 8080.
- Non condividere token, password o dati personali quando invii le tracce.
