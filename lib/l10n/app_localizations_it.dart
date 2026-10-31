// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Cesena Remembers 1945';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsHeaderTitle => 'Tour interattivo WWII';

  @override
  String get settingsHeaderSubtitle => 'Gestisci privacy, notifiche e lingua in un unico posto.';

  @override
  String get sectionCredits => 'Crediti';

  @override
  String get creditsTitle => 'Crediti e Riconoscimenti';

  @override
  String get creditsSubtitle => 'Scopri il team dietro Cesena Remembers';

  @override
  String get creditsPageTitle => 'Riconoscimenti';

  @override
  String get creditsAppName => 'Cesena Remembers';

  @override
  String get creditsAppDescription => 'Realizzato con passione per preservare la memoria storica della nostra città.';

  @override
  String get sectionTeam => 'Il Team';

  @override
  String get sectionThanks => 'Ringraziamenti';

  @override
  String get creditRoleDev => 'Sviluppo & Architettura';

  @override
  String get creditRoleGraphicsMarketing => 'Grafica e Marketing';

  @override
  String get creditRoleTeacher => 'Docente Referente';

  @override
  String get creditRoleClass => 'Supporto e Ideazione';

  @override
  String get creditSchoolSubtitle => 'Visita il sito web dell\'istituto';

  @override
  String get sectionAccount => 'Account';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutSubtitle => 'Esci dall\'account corrente';

  @override
  String get loggingOut => 'Uscita in corso...';

  @override
  String get deleteAccountTitle => 'Elimina account';

  @override
  String get deleteAccountSubtitle => 'Rimuovi profilo e dati associati';

  @override
  String get deletingAccount => 'Eliminazione in corso...';

  @override
  String get deleteAccountDialogTitle => 'Eliminare account?';

  @override
  String get deleteAccountDialogBody => 'Questa operazione rimuove account, progressi e dati associati in modo permanente.';

  @override
  String get deleteAccountSuccess => 'Account eliminato definitivamente.';

  @override
  String get deleteAccountFailure => 'Impossibile completare ora. Controlla il messaggio di errore.';

  @override
  String get sectionPreferences => 'Preferenze App';

  @override
  String get notificationsTitle => 'Notifiche';

  @override
  String get notificationsSubtitle => 'Ricevi avvisi su tappe e premi';

  @override
  String get darkModeTitle => 'Modalità Notte';

  @override
  String get darkModeSubtitle => 'Tema scuro per l\'intera app';

  @override
  String get sectionPrivacy => 'Privacy';

  @override
  String get gpsTitle => 'Posizione GPS';

  @override
  String get gpsSubtitle => 'Necessario per esplorare la mappa';

  @override
  String get privacyPolicyTitle => 'Informativa privacy';

  @override
  String get privacyPolicySubtitle => 'Leggi come vengono trattati i dati';

  @override
  String get gpsPermissionDenied => 'Permesso negato o GPS disattivato. Controlla le impostazioni del telefono.';

  @override
  String get sectionGeneral => 'Generale';

  @override
  String get languageTitle => 'Lingua';

  @override
  String get sectionInfo => 'Info';

  @override
  String get versionTitle => 'Versione';

  @override
  String get versionSubtitle => '1.0.0';

  @override
  String get versionSheetTitle => 'Versione app';

  @override
  String get versionSheetBody => 'Build number: 1.0.0';

  @override
  String get termsTitle => 'Termini di servizio';

  @override
  String get termsSubtitle => 'Regole d\'uso e responsabilità';

  @override
  String get contactsTitle => 'Contatti';

  @override
  String get contactsSubtitle => 'cesenaremembers@gmail.com';

  @override
  String get buttonClose => 'Chiudi';

  @override
  String get buttonCancel => 'Annulla';

  @override
  String get buttonDelete => 'Elimina';

  @override
  String get buttonOk => 'Perfetto';

  @override
  String get buttonRetry => 'Riprova';

  @override
  String get notificationOpenAction => 'APRI';

  @override
  String get notificationFallbackTitle => 'Notifica';

  @override
  String get bannedAccountError => 'Questo account è stato sospeso.';

  @override
  String get bannedOverlayTitle => 'Account sospeso';

  @override
  String get bannedOverlayMessage => 'Il tuo account è stato sospeso per violazione\ndei termini di servizio.\nContatta l\'assistenza per maggiori informazioni.\nEmail: cesenaremembers@gmail.com';

  @override
  String get navMap => 'Mappa';

  @override
  String get navProfile => 'Profilo';

  @override
  String get navCommunity => 'Community';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String errorLoadPreferences(String error) {
    return 'Errore nel caricamento preferenze: $error';
  }

  @override
  String get errorConnection => 'Errore di connessione. Modifica annullata.';

  @override
  String errorLogout(String error) {
    return 'Logout fallito.';
  }

  @override
  String get errorDeleteAccountPartial => 'Account non eliminato completamente. I dati app sono stati rimossi, ma la cancellazione auth è fallita. Verrai disconnesso per sicurezza.';

  @override
  String errorDeleteData(String error) {
    return 'Impossibile eliminare i dati: $error';
  }

  @override
  String get errorLoadProfile => 'Impossibile caricare il profilo.';

  @override
  String get errorOperationFailed => 'Operazione non riuscita. Stato ripristinato.';

  @override
  String get tourStopped => 'Tour interrotto.';

  @override
  String get errorSaveScore => 'Errore nel salvataggio del punteggio. Riprova tra poco.';

  @override
  String get errorLoadPoi => 'Errore nel caricamento dei punti di interesse.';

  @override
  String get errorSearch => 'Errore durante la ricerca.';

  @override
  String get errorAction => 'Errore durante l\'azione.';

  @override
  String get removeFriendship => 'Rimuovi amicizia';

  @override
  String get locationDisabled => 'Posizione disattivata';

  @override
  String get quizAnswerPerfect => 'Perfetto!';

  @override
  String get quizAnswerGood => 'Molto bravo!';

  @override
  String get toursCompleted => 'Tour Completati';

  @override
  String get tourLabel => 'Tour';

  @override
  String get tourConfirmStopTitle => 'Interrompere il tour?';

  @override
  String get tourConfirmStopBody => 'Il tour verrà terminato e perderai l\'ordine attuale delle tappe.';

  @override
  String get buttonStop => 'Interrompi';

  @override
  String get tourStartGpsRequired => 'Per iniziare il tour attiva GPS, permessi posizione e opzione nell\'app.';

  @override
  String get tourCompleted => '🎉 Tour completato! Ottimo lavoro.';

  @override
  String get tourStopButton => 'Interrompi tour';

  @override
  String get tourOrderButton => 'Ordina tappe';

  @override
  String get mapTestAnimation => 'Test animazione';

  @override
  String get mapStyleStandard => 'Standard';

  @override
  String get mapStyleSatellite => 'Satellite';

  @override
  String get profileTitle => 'Il mio profilo';

  @override
  String get sectionStatistics => 'Statistiche';

  @override
  String get sectionAchievements => 'Trofei';

  @override
  String get statTotalXp => 'XP Totali';

  @override
  String get statBestTour => 'Miglior tour (XP)';

  @override
  String get statVisitedSites => 'Siti Visitati';

  @override
  String get statBestTime => 'Miglior tempo';

  @override
  String get statAchievements => 'Trofei';

  @override
  String get profileFriends => 'Amici';

  @override
  String get profilePoints => 'Punti';

  @override
  String get profileNoRequests => 'Nessuna richiesta al momento.';

  @override
  String get profileYourFriends => 'I tuoi Amici';

  @override
  String get profileFriendRequests => 'Richieste d\'amicizia';

  @override
  String profileNameTooShort(int min, int max) {
    return 'Il nome deve avere $min-$max caratteri.';
  }

  @override
  String get profileNameOffensive => 'Il nome contiene termini non consentiti.\nInseriscine uno diverso.';

  @override
  String get avatarPickerTitle => 'Scegli il tuo Avatar';

  @override
  String get avatarPickerSubtitle => 'Personalizza il tuo profilo';

  @override
  String get poiTabInfo => 'Informazioni';

  @override
  String get poiTabQuiz => 'Quiz';

  @override
  String get poiSectionHistory => 'Storia';

  @override
  String get poiStartQuiz => 'Fai il quiz su questa tappa →';

  @override
  String get poiNoQuiz => 'Nessun quiz disponibile per questa tappa.';

  @override
  String get quizNextQuestion => 'Prossima domanda →';

  @override
  String get quizFinish => 'Termina quiz →';

  @override
  String get quizNextStop => 'Prossima tappa →';

  @override
  String get quizNotice => 'Avviso quiz';

  @override
  String quizCorrectAnswers(int score, int total) {
    return '$score / $total risposte corrette';
  }

  @override
  String quizTime(String time) {
    return 'Tempo: $time';
  }

  @override
  String quizQuestion(int current, int total) {
    return 'Domanda $current di $total';
  }

  @override
  String get tourStartButton => 'Inizia il tour';

  @override
  String get tourStopCardArrived => 'Sei arrivato! Tocca per aprire';

  @override
  String tourStopCardDistance(String distance, int index, int total) {
    return '$distance · tappa $index/$total';
  }

  @override
  String get tourPlanTitle => 'Ordine tappe';

  @override
  String get tourPlanSubtitle => 'Trascina dalla maniglia per riordinare il percorso.';

  @override
  String get tourPlanFirstStop => 'Prima tappa del tour';

  @override
  String tourPlanDistanceFromPrev(String distance) {
    return '$distance dalla precedente';
  }

  @override
  String get tourPlanCurrentLabel => 'Attuale';

  @override
  String get locationBannerMissingPermission => 'Permessi mancanti';

  @override
  String get locationBannerGpsOff => 'GPS Disattivato';

  @override
  String get locationBannerEnableLocation => 'Attiva la posizione per esplorare la mappa in tempo reale.';

  @override
  String get locationBannerReEnableLocation => 'Riattiva la posizione nelle impostazioni per mostrare la tua posizione sulla mappa.';

  @override
  String get locationBannerResolve => 'Risolvi';

  @override
  String get socialSearchHint => 'Cerca utente...';

  @override
  String get socialLeaderboardEmpty => 'Nessun punteggio disponibile nella classifica globale.';

  @override
  String get socialLeaderboard => 'Classifica globale';

  @override
  String get socialNoUserFound => 'Nessun utente trovato.';

  @override
  String get socialTypeMoreChars => 'Digita almeno 2 caratteri per cercare.';

  @override
  String get socialYou => 'Tu';

  @override
  String get socialDefaultUsername => 'utente';

  @override
  String socialFriendsOf(String name) {
    return 'Amici di $name';
  }

  @override
  String get socialMustBeFriend => 'Devi essere amico per vedere la sua lista amici.';

  @override
  String get socialRequestSent => 'Richiesta inviata';

  @override
  String get socialAccept => 'Accetta';

  @override
  String get socialReject => 'Rifiuta';

  @override
  String get socialAddFriend => 'Aggiungi agli amici';

  @override
  String get publicStatDetailed => 'Statistiche Dettagliate';

  @override
  String get publicStatAchievements => 'Traguardi';

  @override
  String get publicStatBestScore => 'Miglior Score';

  @override
  String get publicStatSites => 'Siti Visitati';

  @override
  String get publicStatQuiz => 'Quiz Superati';

  @override
  String get publicStatBestTime => 'Tempo Migliore';

  @override
  String get publicStatCorrectAnswers => 'Risposte Esatte';

  @override
  String get publicStatFriends => 'Amici';

  @override
  String get publicStatPoints => 'Punti';

  @override
  String get publicStatLevel => 'Livello';

  @override
  String get errorLoginFailed => 'Accesso non riuscito. Controlla la connessione e riprova.';

  @override
  String get errorOffline => 'Sei offline. Controlla la connessione Internet e riprova.';

  @override
  String get errorLoginGeneric => 'Accesso non riuscito. Riprova tra qualche secondo.';

  @override
  String get loginGoogleButton => 'ACCEDI CON GOOGLE';

  @override
  String get loginTermsNoticePrefix => 'Continuando accetti i ';

  @override
  String get loginTermsLink => 'Termini di Servizio';

  @override
  String get loginTermsAnd => ' e l\'';

  @override
  String get loginPrivacyLink => 'Informativa sulla Privacy';

  @override
  String get errorCommunication => 'Errore durante la comunicazione con il server.';

  @override
  String get errorNotLoggedIn => 'Utente non loggato.';

  @override
  String get errorLoadPrefs => 'Errore nel caricamento preferenze.';

  @override
  String get errorGpsDenied => 'Permesso negato o GPS disattivato. Controlla le impostazioni.';

  @override
  String get errorConnectionSettings => 'Errore di connessione. Modifica annullata.';

  @override
  String get errorDeleteAccount => 'Impossibile eliminare i dati.';

  @override
  String get errorDeleteAccountAuth => 'Account non eliminato completamente. I dati app sono stati rimossi, ma la cancellazione auth è fallita. Verrai disconnesso per sicurezza.';

  @override
  String get errorSyncProfile => 'Impossibile sincronizzare il profilo.';

  @override
  String get errorSaveProfile => 'Salvataggio profilo non riuscito.';

  @override
  String get errorLoadLeaderboard => 'Impossibile caricare la classifica.';

  @override
  String get settingsTourTitle => 'Tour interattivo WWII';

  @override
  String get settingsTourSubtitle => 'Gestisci privacy, notifiche e lingua in un unico posto.';

  @override
  String get settingsCredits => 'Crediti';

  @override
  String get settingsCreditsTitle => 'Crediti e Riconoscimenti';

  @override
  String get settingsCreditsSubtitle => 'Scopri il team dietro Cesena Remembers';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsLogoutInProgress => 'Uscita in corso...';

  @override
  String get settingsLogoutSubtitle => 'Esci dall\'account corrente';

  @override
  String get settingsDelete => 'Elimina account';

  @override
  String get settingsDeleteInProgress => 'Eliminazione in corso...';

  @override
  String get settingsDeleteSubtitle => 'Rimuovi profilo e dati associati';

  @override
  String get settingsAppPrefs => 'Preferenze App';

  @override
  String get settingsNotifications => 'Notifiche';

  @override
  String get settingsNotifSubtitle => 'Ricevi avvisi su tappe e premi';

  @override
  String get settingsDarkMode => 'Modalità Notte';

  @override
  String get settingsDarkModeSubtitle => 'Tema scuro per l\'intera app';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsGps => 'Posizione GPS';

  @override
  String get settingsGpsSubtitle => 'Necessario per esplorare la mappa';

  @override
  String get settingsPrivacyPolicy => 'Informativa privacy';

  @override
  String get settingsPrivacySubtitle => 'Leggi come vengono trattati i dati';

  @override
  String get settingsGeneral => 'Generale';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsInfo => 'Info';

  @override
  String get settingsVersion => 'Versione';

  @override
  String get settingsTerms => 'Termini di servizio';

  @override
  String get settingsTermsSubtitle => 'Regole d\'uso e responsabilità';

  @override
  String get settingsContacts => 'Contatti';

  @override
  String get settingsClose => 'Chiudi';

  @override
  String get settingsPerfect => 'Perfetto';

  @override
  String get settingsDeleteConfirmTitle => 'Eliminare account?';

  @override
  String get settingsDeleteConfirmBody => 'Questa operazione rimuove account, progressi e dati associati in modo permanente.';

  @override
  String get settingsCancel => 'Annulla';

  @override
  String get settingsDeleteConfirmBtn => 'Elimina';

  @override
  String get settingsDeleteSuccess => 'Account eliminato definitivamente.';

  @override
  String get settingsDeleteError => 'Impossibile completare ora. Controlla il messaggio di errore.';

  @override
  String get achievement_first_visit_title => 'Primo passo';

  @override
  String get achievement_first_visit_desc => 'Visita il tuo primo sito storico';

  @override
  String get achievement_first_quiz_title => 'Studente';

  @override
  String get achievement_first_quiz_desc => 'Completa il tuo primo quiz';

  @override
  String get achievement_first_tour_title => 'Pioniere';

  @override
  String get achievement_first_tour_desc => 'Finisci il tuo primo tour completo';

  @override
  String get achievement_quiz_15_title => 'Veterano';

  @override
  String get achievement_quiz_15_desc => 'Completa 15 quiz';

  @override
  String get achievement_perfect_tour_title => 'Infallibile';

  @override
  String get achievement_perfect_tour_desc => 'Rispondi correttamente a tutte le domande in un tour';

  @override
  String get achievement_xp_500_title => 'Collezionista';

  @override
  String get achievement_xp_500_desc => 'Raggiungi 500 XP totali';

  @override
  String get achievement_tour_under_1h_title => 'In marcia';

  @override
  String get achievement_tour_under_1h_desc => 'Completa un tour in meno di 1 ora';

  @override
  String get achievement_tour_under_30m_title => 'Fulmine';

  @override
  String get achievement_tour_under_30m_desc => 'Completa un tour in meno di 30 minuti';

  @override
  String get achievement_friend_1_title => 'Cittadino';

  @override
  String get achievement_friend_1_desc => 'Aggiungi il tuo primo amico';

  @override
  String get achievement_friend_5_title => 'Circolo storico';

  @override
  String get achievement_friend_5_desc => 'Raggiungi 5 amici';

  @override
  String get poi_santa_cristina_name => 'Chiesa di Santa Cristina';

  @override
  String get poi_santa_cristina_desc => 'La chiesa di Santa Cristina fu voluta da papa Pio VII Chiaramonti e progettata dall’architetto Giuseppe Valadier. I lavori iniziarono nel 1816 e si conclusero nel 1825; l’edificio è in stile neoclassico. Durante la Seconda guerra mondiale la cripta fu rafforzata e resa agibile come rifugio antiaereo, con una capienza fino a 200 persone.';

  @override
  String get poi_rocca_name => 'Rocca Malatestiana';

  @override
  String get poi_rocca_desc => 'La costruzione della Rocca Nuova, detta Rocca Malatestiana, fu avviata nel 1380 per iniziativa di Galeotto Malatesta e proseguita da Malatesta Novello; fu conclusa nei tardi anni Settanta del Quattrocento. Nel 1502 Cesare Borgia fece venire a Cesena Leonardo da Vinci per rilevare le difese delle città conquistate. Dopo la perdita della funzione militare, la Rocca fu trasformata in carcere e rimase tale fino al 1969. I rifugi antiaerei pubblici del 1944 si trovavano alle pendici del colle, lungo viale Mazzoni, non all’interno della fortezza.';

  @override
  String get poi_san_rocco_name => 'Chiesa di San Rocco';

  @override
  String get poi_san_rocco_desc => 'La parrocchia di San Rocco a Cesena risale al 1615. Nell’estate del 1944 la chiesa mise a disposizione i propri locali per dare riparo a chi fuggiva dai bombardamenti; un rifugio fu ricavato nel campanile. I bombardamenti del 1944 distrussero la chiesa insieme al borgo: oggi rimane soltanto il campanile ottocentesco.';

  @override
  String get poi_abbazia_monte_name => 'Abbazia di Santa Maria del Monte';

  @override
  String get poi_abbazia_monte_desc => 'L’abbazia benedettina di Santa Maria del Monte sorse agli inizi dell’XI secolo sul colle detto «il Monte», a sud-est di Cesena. Durante la Seconda guerra mondiale ospitò circa settecento sfollati, rifugiati negli scantinati e nella galleria. Tra il 16 e il 19 ottobre 1944 fu colpita ripetutamente e direttamente dai bombardamenti: la chiesa fu sventrata e una parte del monastero crollò. Non si registrarono vittime tra gli sfollati ospitati nell’abbazia.';

  @override
  String get poi_osservanza_name => 'Chiesa e Convento dell\'Osservanza';

  @override
  String get poi_osservanza_desc => 'La chiesa dell’Osservanza fu costruita tra il 1459 e il 1464 per volere di Malatesta Novello ed è legata ai frati Minori Osservanti. Durante la Seconda guerra mondiale vi furono ricavati due ricoveri antiaerei, nelle catacombe e presso il campanile, con una capienza complessiva di circa 200 persone. La chiesa fu colpita dai bombardamenti alleati del 16 e 19 ottobre 1944; durante quei bombardamenti morì padre Bosoni.';

  @override
  String get poi_palazzo_ridotto_name => 'Palazzo del Ridotto';

  @override
  String get poi_palazzo_ridotto_desc => 'Il Palazzo del Ridotto si trova in piazza Almerici e fu edificato tra il 1466 e il 1472 come sede dell’autorità comunale dei Conservatori. Durante la Seconda guerra mondiale sulla sua torre fu installata una sirena di allarme, parte di un sistema esteso a tutta la città e affiancato da campane di chiese in caso di mancanza di corrente. Dopo l’attentato del 18 gennaio 1944 alla sede del fascio in corso Umberto I, gli uffici del Partito Fascista Repubblicano furono trasferiti nel palazzo, usato anche come luogo di detenzione e tortura.';

  @override
  String get poi_stazione_name => 'Stazione Ferroviaria di Cesena';

  @override
  String get poi_stazione_desc => 'La prima stazione ferroviaria di Cesena fu attivata nel 1861. Nel 1919 fu approvato il progetto di un fabbricato più ampio e la prima pietra della nuova stazione fu posata nel 1925. Accanto si trovava la fabbrica alimentare Arrigoni e, sul lato opposto, la raffineria Montecatini. Per la vicinanza tra questi impianti, la zona fu bersaglio dei bombardamenti alleati dopo l’occupazione tedesca. Il 29 giugno 1944 un bombardamento colpì lo scalo, distrusse carichi di munizioni e incendiò la raffineria; seguirono altri raid tra luglio e settembre.';

  @override
  String get poi_arrigoni_name => 'Stabilimento Arrigoni';

  @override
  String get poi_arrigoni_desc => 'Lo stabilimento Arrigoni di Cesena sorgeva accanto alla stazione ferroviaria e divenne lo stabilimento di punta del gruppo per confetture, pomodori pelati e minestroni essiccati. Diede lavoro nel tempo a migliaia di cesenati e divenne una fucina dell’antifascismo locale. L’operaio Werther Ricchi vi lavorava già prima del 25 luglio 1943 e, dopo l’8 settembre, fece arrivare marmellata e altri prodotti ai partigiani dell’8ª brigata Garibaldi. Fu arrestato il 23 marzo 1944 e torturato.';

  @override
  String get poi_fantaguzzi_name => 'Palazzo Fantaguzzi';

  @override
  String get poi_fantaguzzi_desc => 'Palazzo Fantaguzzi si trova in corso Gastone Sozzi, già corso Umberto I, ed è sede della Banca Popolare di Cesena dal 1922. Nei primi mesi della Repubblica Sociale Italiana una parte dell’edificio ospitò anche gli uffici del fascio cittadino. Il 18 gennaio 1944 un commando del GAP fece esplodere una bomba nell’ingresso della sede del fascio: non ci furono vittime, ma l’edificio subì gravi danni. Poche settimane dopo la sede del fascio fu trasferita nel Palazzo del Ridotto.';

  @override
  String get poi_rifugi_antiaerei_name => 'Rifugi Antiaerei della Rocca';

  @override
  String get poi_rifugi_antiaerei_desc => 'Nel gennaio 1944 fu deciso di scavare una galleria nel colle della Rocca per creare un rifugio antiaereo pubblico. La galleria fu costruita ex novo nel 1944 dall’ingegnere capo del Comune, Mario Tellerini, e poteva accogliere 800 persone, di cui 290 sedute. Aveva due ingressi su viale Mazzoni protetti da un muro paraschegge; il camino di aerazione poteva servire anche da uscita di sicurezza.';

  @override
  String setupUsernameInvalid(int min, int max) {
    return 'Username non valido (usa $min-$max caratteri: a-z, 0-9, _ o .).';
  }

  @override
  String get setupUsernameOffensive => 'Username contiene termini non consentiti. Scegline uno diverso.';

  @override
  String get setupUsernameTaken => 'Username già in uso. Scegline un altro.';

  @override
  String setupFirestoreError(Object username) {
    return 'Configurazione Firestore non valida: servono permessi di lettura/scrittura su usernames/$username.';
  }

  @override
  String get setupPermissionDenied => 'Permessi Firestore insufficienti per completare il profilo. Controlla le regole del progetto.';

  @override
  String get setupGenericError => 'Impossibile salvare il profilo. Riprova tra qualche secondo.';

  @override
  String get setupTitle => 'Crea il tuo profilo';

  @override
  String get setupSubtitle => 'Scegli username univoco (non modificabile), nome in app e avatar.';

  @override
  String get setupNameLabel => 'Nome in app';

  @override
  String get setupUsernameLabel => 'Username';

  @override
  String get setupUsernameHint => 'es. cesena_explorer';

  @override
  String get setupAvatarLabel => 'Scegli avatar';

  @override
  String get setupSubmitButton => 'Conferma profilo';

  @override
  String get creditRoleDiplo => 'Rappresentanze Diplomatiche Tedesche in Italia';

  @override
  String get creditRoleDiploDesc => 'Sviluppato grazie al loro prezioso contributo';

  @override
  String get sectionSupport => 'Collaboratori e Supporto';

  @override
  String get quiz_fallback_name => 'Difficoltà standard (seed locale)';

  @override
  String get quiz_fallback_desc => 'Per un errore del server le domande non sono personalizzate e usano una difficoltà locale specifica.';

  @override
  String get quiz_santa_cristina_q1 => 'Chi progettò la chiesa di Santa Cristina?';

  @override
  String get quiz_santa_cristina_q1_o1 => 'L’architetto Giuseppe Valadier';

  @override
  String get quiz_santa_cristina_q1_o2 => 'Francesco Morandi detto il Terribilia';

  @override
  String get quiz_santa_cristina_q1_o3 => 'Leandro Marconi';

  @override
  String get quiz_santa_cristina_q2 => 'Quante persone poteva ospitare la cripta-rifugio?';

  @override
  String get quiz_santa_cristina_q2_o1 => 'Fino a 200 persone';

  @override
  String get quiz_santa_cristina_q2_o2 => 'Circa 700 persone';

  @override
  String get quiz_santa_cristina_q2_o3 => 'Fino a 800 persone';

  @override
  String get quiz_rocca_q1 => 'In quale anno iniziò la costruzione della Rocca Nuova?';

  @override
  String get quiz_rocca_q1_o1 => '1380';

  @override
  String get quiz_rocca_q1_o2 => '1464';

  @override
  String get quiz_rocca_q1_o3 => '1502';

  @override
  String get quiz_rocca_q2 => 'Chi fece venire Leonardo da Vinci a Cesena nel 1502?';

  @override
  String get quiz_rocca_q2_o1 => 'Malatesta Novello';

  @override
  String get quiz_rocca_q2_o2 => 'Cesare Borgia';

  @override
  String get quiz_rocca_q2_o3 => 'Federico Barbarossa';

  @override
  String get quiz_rocca_q3 => 'Fino a quale anno la Rocca fu utilizzata come carcere?';

  @override
  String get quiz_rocca_q3_o1 => '1944';

  @override
  String get quiz_rocca_q3_o2 => '1969';

  @override
  String get quiz_rocca_q3_o3 => '1974';

  @override
  String get quiz_san_rocco_q1 => 'A quale anno risale la parrocchia di San Rocco?';

  @override
  String get quiz_san_rocco_q1_o1 => '1615';

  @override
  String get quiz_san_rocco_q1_o2 => '1816';

  @override
  String get quiz_san_rocco_q1_o3 => '1944';

  @override
  String get quiz_san_rocco_q2 => 'Quale parte della chiesa storica rimane oggi?';

  @override
  String get quiz_san_rocco_q2_o1 => 'Il campanile ottocentesco';

  @override
  String get quiz_san_rocco_q2_o2 => 'La facciata principale';

  @override
  String get quiz_san_rocco_q2_o3 => 'La cripta';

  @override
  String get quiz_abbazia_monte_q1 => 'In quale secolo sorse l’abbazia di Santa Maria del Monte?';

  @override
  String get quiz_abbazia_monte_q1_o1 => 'All’inizio dell’XI secolo';

  @override
  String get quiz_abbazia_monte_q1_o2 => 'Nel XV secolo';

  @override
  String get quiz_abbazia_monte_q1_o3 => 'Nel XVIII secolo';

  @override
  String get quiz_abbazia_monte_q2 => 'Quanti sfollati circa furono ospitati nell’abbazia durante la guerra?';

  @override
  String get quiz_abbazia_monte_q2_o1 => 'Circa 200';

  @override
  String get quiz_abbazia_monte_q2_o2 => 'Circa 500';

  @override
  String get quiz_abbazia_monte_q2_o3 => 'Circa 700';

  @override
  String get quiz_osservanza_q1 => 'Tra quali anni fu costruita la chiesa dell’Osservanza?';

  @override
  String get quiz_osservanza_q1_o1 => '1459–1464';

  @override
  String get quiz_osservanza_q1_o2 => '1472–1502';

  @override
  String get quiz_osservanza_q1_o3 => '1816–1825';

  @override
  String get quiz_osservanza_q2 => 'Che cosa accadde alla chiesa nell’ottobre 1944?';

  @override
  String get quiz_osservanza_q2_o1 => 'Fu colpita dai bombardamenti e morì padre Bosoni';

  @override
  String get quiz_osservanza_q2_o2 => 'Rimase illesa durante tutti i bombardamenti';

  @override
  String get quiz_osservanza_q2_o3 => 'Fu trasformata in un ospedale alleato';

  @override
  String get quiz_palazzo_ridotto_q1 => 'Su quale piazza si affaccia il Palazzo del Ridotto?';

  @override
  String get quiz_palazzo_ridotto_q1_o1 => 'Piazza Almerici';

  @override
  String get quiz_palazzo_ridotto_q1_o2 => 'Piazza del Popolo';

  @override
  String get quiz_palazzo_ridotto_q1_o3 => 'Piazza del Duomo';

  @override
  String get quiz_palazzo_ridotto_q2 => 'Quale dispositivo di allarme fu installato sulla torre durante la guerra?';

  @override
  String get quiz_palazzo_ridotto_q2_o1 => 'Una sirena di allarme aereo';

  @override
  String get quiz_palazzo_ridotto_q2_o2 => 'Un radar di avvistamento';

  @override
  String get quiz_palazzo_ridotto_q2_o3 => 'Una radio militare';

  @override
  String get quiz_stazione_q1 => 'In quale anno fu attivata la prima stazione ferroviaria di Cesena?';

  @override
  String get quiz_stazione_q1_o1 => '1861';

  @override
  String get quiz_stazione_q1_o2 => '1919';

  @override
  String get quiz_stazione_q1_o3 => '1925';

  @override
  String get quiz_stazione_q2 => 'In quale data un bombardamento colpì lo scalo ferroviario di Cesena?';

  @override
  String get quiz_stazione_q2_o1 => '29 giugno 1944';

  @override
  String get quiz_stazione_q2_o2 => '25 luglio 1944';

  @override
  String get quiz_stazione_q2_o3 => '20 ottobre 1944';

  @override
  String get quiz_arrigoni_q1 => 'In quali settori lo stabilimento Arrigoni di Cesena era di punta?';

  @override
  String get quiz_arrigoni_q1_o1 => 'Confetture, pomodori pelati e minestroni essiccati';

  @override
  String get quiz_arrigoni_q1_o2 => 'Tessuti, filati e abbigliamento';

  @override
  String get quiz_arrigoni_q1_o3 => 'Meccanica, automobili e biciclette';

  @override
  String get quiz_arrigoni_q2 => 'Quale operaio antifascista lavorava allo stabilimento Arrigoni?';

  @override
  String get quiz_arrigoni_q2_o1 => 'Werther Ricchi';

  @override
  String get quiz_arrigoni_q2_o2 => 'Mario Tellerini';

  @override
  String get quiz_arrigoni_q2_o3 => 'Padre Bosoni';

  @override
  String get quiz_fantaguzzi_q1 => 'Da quale anno Palazzo Fantaguzzi è sede della Banca Popolare di Cesena?';

  @override
  String get quiz_fantaguzzi_q1_o1 => 'Dal 1922';

  @override
  String get quiz_fantaguzzi_q1_o2 => 'Dal 1944';

  @override
  String get quiz_fantaguzzi_q1_o3 => 'Dal 1970';

  @override
  String get quiz_fantaguzzi_q2 => 'In quale periodo una parte del palazzo ospitò gli uffici del fascio cittadino?';

  @override
  String get quiz_fantaguzzi_q2_o1 => 'Per tutto il Ventennio';

  @override
  String get quiz_fantaguzzi_q2_o2 => 'Nei primi mesi della Repubblica Sociale Italiana';

  @override
  String get quiz_fantaguzzi_q2_o3 => 'Dopo la liberazione del 1944';

  @override
  String get quiz_rifugi_antiaerei_q1 => 'Quando fu deciso di scavare la galleria antiaerea nel colle della Rocca?';

  @override
  String get quiz_rifugi_antiaerei_q1_o1 => 'Nel gennaio 1944';

  @override
  String get quiz_rifugi_antiaerei_q1_o2 => 'Nel giugno 1941';

  @override
  String get quiz_rifugi_antiaerei_q1_o3 => 'Nell’ottobre 1944';

  @override
  String get quiz_rifugi_antiaerei_q2 => 'Quante persone poteva accogliere il rifugio della Rocca?';

  @override
  String get quiz_rifugi_antiaerei_q2_o1 => '200 persone';

  @override
  String get quiz_rifugi_antiaerei_q2_o2 => '500 persone';

  @override
  String get quiz_rifugi_antiaerei_q2_o3 => '800 persone, 290 delle quali sedute';

  @override
  String tourCompletionXpGained(int xp) {
    return '+$xp XP ottenuti';
  }

  @override
  String get notificationNoNotifications => 'Nessuna notifica al momento.';

  @override
  String get notificationAchievementUnlocked => 'Obiettivo Sbloccato!';

  @override
  String get notificationFriendRequest => 'Richiesta di amicizia';

  @override
  String get notificationRedeemButton => 'RISCATTA';

  @override
  String get achievementUnlockButton => 'SBLOCCA';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get onboardingNext => 'Prosegui';

  @override
  String get onboardingStart => 'Inizia a esplorare';

  @override
  String get onboardingSlide0Tag => 'BENVENUTO';

  @override
  String get onboardingSlide0Title => 'Cesena\nRemembers';

  @override
  String get onboardingSlide0Desc => 'Esplora i luoghi che hanno scritto la storia di Cesena. Un viaggio tra memorie, quiz e persone.';

  @override
  String get onboardingSlide1Tag => '01 — TOUR';

  @override
  String get onboardingSlide1Title => 'Segui\nil percorso';

  @override
  String get onboardingSlide1Desc => 'Attiva un tour guidato e cammina tra i siti storici. Il GPS ti guida tappa dopo tappa.';

  @override
  String get onboardingSlide2Tag => '02 — QUIZ';

  @override
  String get onboardingSlide2Title => 'Metti\nalla prova';

  @override
  String get onboardingSlide2Desc => 'Rispondi alle domande di ogni luogo. Più sei preciso, più XP guadagni.';

  @override
  String get onboardingSlide3Tag => '03 — CLASSIFICA';

  @override
  String get onboardingSlide3Title => 'Scala\nla vetta';

  @override
  String get onboardingSlide3Desc => 'Scala la classifica globale e confronta i tuoi progressi con tutti gli esploratori.';

  @override
  String get onboardingSlide4Tag => '04 — ACHIEVEMENT';

  @override
  String get onboardingSlide4Title => 'Colleziona\ni badge';

  @override
  String get onboardingSlide4Desc => 'Ogni traguardo sblocca un riconoscimento esclusivo. Completa tour, supera quiz e conquista amici.';

  @override
  String get quizResultPerfectTitle => 'Perfetto!';

  @override
  String get quizResultPerfectBody => 'Nemmeno un errore. Sei un vero storico!';

  @override
  String get quizResultGreatTitle => 'Ottimo lavoro!';

  @override
  String get quizResultGreatBody => 'Conosci bene questo luogo.';

  @override
  String get quizResultGoodTitle => 'Buon risultato!';

  @override
  String get quizResultGoodBody => 'Hai colto i punti principali. Ancora un po\' e lo padroneggi.';

  @override
  String get quizResultFairTitle => 'Ci sei quasi';

  @override
  String get quizResultFairBody => 'Rileggi la scheda storica e rifatti alla prossima tappa.';

  @override
  String get quizResultPoorTitle => 'Non stavolta';

  @override
  String get quizResultPoorBody => 'Niente paura: la storia si impara un passo alla volta.';

  @override
  String tourXpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String speedBonusSteady(int percent) {
    return 'Buon ritmo! Bonus +$percent%';
  }

  @override
  String speedBonusFast(int percent) {
    return 'Passo svelto! Bonus +$percent%';
  }

  @override
  String speedBonusLightning(int percent) {
    return 'Velocissimo! Bonus +$percent%';
  }

  @override
  String get connectionErrorTitle => 'Nessuna connessione';

  @override
  String get connectionErrorBody => 'Al momento non riusciamo a raggiungere il server. Controlla la connessione e riprova. Alcune funzioni potrebbero essere limitate offline.';

  @override
  String get achievementUnlockedSnack => 'Hai sbloccato un nuovo obiettivo! Tocca per riscattarlo.';

  @override
  String get publicStatsPrivateTitle => 'Statistiche private';

  @override
  String get publicStatsPrivateBody => 'Diventa amico per vedere statistiche dettagliate, traguardi sbloccati e molto altro.';

  @override
  String get sectionMapLicenses => 'Licenze mappe';

  @override
  String get mapLicenseOsmTitle => 'OpenStreetMap';

  @override
  String get mapLicenseOsmSubtitle => '© Contributori OpenStreetMap — Licenza ODbL';

  @override
  String get mapLicenseCartoTitle => 'CARTO';

  @override
  String get mapLicenseCartoSubtitle => '© CARTO — Basato su dati OpenStreetMap';

  @override
  String get mapLicenseStadiaTitle => 'Stadia Maps / Stamen Design';

  @override
  String get mapLicenseStadiaSubtitle => '© Stadia Maps, © Stamen Design — Licenza CC BY 3.0';

  @override
  String get mapLicenseEsriTitle => 'Esri (Vista Satellite)';

  @override
  String get mapLicenseEsriSubtitle => 'Tiles © Esri, Maxar, Earthstar Geographics e la comunità GIS';
}
