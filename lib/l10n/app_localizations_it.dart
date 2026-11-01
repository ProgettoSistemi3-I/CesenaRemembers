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
  String get poi_santa_cristina_desc => 'Voluta dal papa cesenate Pio VII Chiaramonti e progettata dall’architetto Giuseppe Valadier, la chiesa fu costruita tra il 1816 e il 1825 in stile neoclassico. La pianta circolare, ispirata al Pantheon, è una delle caratteristiche più riconoscibili dell’edificio. Durante la Seconda guerra mondiale la cripta fu rinforzata e resa agibile come rifugio antiaereo per un massimo di 200 persone. Don Leo Bagnoli la ricordò come un ambiente solido e asciutto: qui i civili cercavano riparo durante gli allarmi e i bombardamenti che colpirono Cesena nel 1944.';

  @override
  String get poi_rocca_name => 'Rocca Malatestiana';

  @override
  String get poi_rocca_desc => 'La Rocca Nuova, detta Rocca Malatestiana, fu avviata nel 1380 da Galeotto Malatesta e proseguita da Malatesta Novello sul colle Garampo. Persa la funzione militare, divenne un carcere e mantenne questa destinazione fino al 1969. Durante l’occupazione nazifascista fu anche luogo di detenzione di antifascisti: nel 1944 la Resistenza organizzò due incursioni per liberare prigionieri politici. L’area dello Sferisterio, davanti all’ingresso della fortezza, fu teatro della fucilazione di otto antifascisti il 4 settembre 1944. Durante gli anni Quaranta anche i sotterranei della Rocca furono adibiti a rifugio. Il grande rifugio pubblico da 800 posti, spesso associato alla fortezza, era invece una galleria distinta scavata nel colle lungo viale Mazzoni.';

  @override
  String get poi_san_rocco_name => 'Chiesa di San Rocco';

  @override
  String get poi_san_rocco_desc => 'La parrocchia di San Rocco a Cesena risale al 1615. Nell’estate del 1944, mentre i bombardamenti alleati cercavano di ostacolare la ritirata delle truppe tedesche colpendo il Ponte Vecchio, anche il borgo di San Rocco fu investito dalle incursioni. La chiesa offrì riparo ai civili e il campanile fu adattato a rifugio antiaereo: la porta venne protetta con un paraschegge improvvisato, ottenuto riempiendo di sabbia un armadio. Sul campanile si trovavano anche una sirena e una campana, utile come allarme quando mancava la corrente. La chiesa fu distrutta nel 1944; oggi resta il campanile ottocentesco. La parrocchia venne poi ricostruita oltre il fiume Savio, nella zona del Campino.';

  @override
  String get poi_abbazia_monte_name => 'Abbazia di Santa Maria del Monte';

  @override
  String get poi_abbazia_monte_desc => 'L’abbazia benedettina di Santa Maria del Monte sorse agli inizi dell’XI secolo sul colle del Monte, a sud-est di Cesena. Durante la Seconda guerra mondiale i monaci realizzarono nei sotterranei una galleria accessibile tramite un pozzo e ampliata con grotte scavate nel tufo: qui trovarono riparo circa 700 sfollati in fuga dai bombardamenti e dai rastrellamenti. Nei sotterranei furono custoditi anche molti libri della Biblioteca Malatestiana, mentre i manoscritti più preziosi erano stati trasferiti nel modenese sin dall’inizio del conflitto. Don Odo Contestabile contribuì a proteggere famiglie ebree e nel 1943 accompagnò due famiglie verso il confine svizzero; dal 2019 è riconosciuto Giusto tra le Nazioni. Tra il 16 e il 19 ottobre 1944 l’abbazia fu colpita ripetutamente: la chiesa venne sventrata e una parte del monastero crollò. Non si registrarono vittime tra gli sfollati ospitati nel complesso.';

  @override
  String get poi_osservanza_name => 'Chiesa e Convento dell\'Osservanza';

  @override
  String get poi_osservanza_desc => 'La chiesa dell’Osservanza fu costruita tra il 1459 e il 1464 per volontà di Malatesta Novello e affidata ai frati Minori Osservanti; il progetto fu assegnato al maestro Maso della Val Lugano. Durante la Seconda guerra mondiale il complesso svolse anche una funzione di protezione civile: furono ricavati due ricoveri antiaerei, uno nelle catacombe e uno presso il campanile, con una capienza complessiva di circa 200 persone. Il luogo non rimase indenne dal passaggio del fronte: la chiesa fu colpita dai bombardamenti alleati del 16 e del 19 ottobre 1944. Durante quelle incursioni morì padre Bosoni, ricordato da una lapide nelle catacombe.';

  @override
  String get poi_palazzo_ridotto_name => 'Palazzo del Ridotto';

  @override
  String get poi_palazzo_ridotto_desc => 'Il Palazzo del Ridotto si affaccia su piazza Almerici e sorge su una preesistenza medievale. Le fonti non concordano sulla prima fase edilizia: Resistenza mAPPe indica un edificio del 1401–1403, ampliato tra il 1466 e il 1472; il catalogo regionale colloca invece l’edificazione del palazzo dei Conservatori tra il 1466 e il 1472 su una struttura precedente. Il nome è legato al ritrovo della nobiltà cesenate nel Settecento. Durante la Seconda guerra mondiale la torre ospitò una sirena collegata al sistema cittadino di allarme aereo; in caso di mancanza di corrente, il sistema ausiliario si affidava anche alle campane delle chiese. Dopo l’attentato partigiano del 18 gennaio 1944 alla sede fascista di Palazzo Fantaguzzi, gli uffici locali del Partito Fascista Repubblicano furono trasferiti qui. Il palazzo fu usato anche per detenere e torturare prigionieri. Una lapide, collocata nel 1995 sul lato verso piazza Almerici, ricorda gli ebrei cesenati uccisi nella Shoah.';

  @override
  String get poi_stazione_name => 'Stazione Ferroviaria di Cesena';

  @override
  String get poi_stazione_desc => 'La prima stazione ferroviaria di Cesena entrò in funzione nel 1861; il progetto per un fabbricato più ampio fu approvato nel 1919 e la prima pietra della nuova stazione venne posata nel 1925. Accanto allo scalo si trovava lo stabilimento alimentare Arrigoni, mentre sul lato opposto sorgeva la raffineria Montecatini, che lavorava lo zolfo delle miniere di Perticara e Formignano. Questa concentrazione di infrastrutture e impianti rese l’area un obiettivo strategico. Il primo bombardamento massiccio sulla città avvenne il 13 maggio 1944; il 29 giugno un raid colpì lo scalo ferroviario, distrusse carichi di munizioni e incendiò la raffineria. Seguirono altri attacchi in estate e all’inizio di settembre. Durante la Resistenza, stazione e linee ferroviarie furono inoltre bersaglio di azioni partigiane dirette a ostacolare i rifornimenti dell’esercito occupante.';

  @override
  String get poi_arrigoni_name => 'Stabilimento Arrigoni';

  @override
  String get poi_arrigoni_desc => 'Lo stabilimento Arrigoni sorgeva accanto alla stazione ferroviaria. Nel 1927 Giorgio Sanguinetti, che dirigeva l’Arrigoni di Trieste, acquistò il precedente Consorzio Industrie Agrarie (CIA) e ne ampliò gli impianti. Negli anni Trenta divenne la principale fabbrica alimentare della zona, arrivando a circa 5.000 addetti. A Cesena si distinse per la produzione di confetture, pomodori pelati e minestroni essiccati. La fabbrica fu anche un centro dell’antifascismo: numerosi operai si opposero al regime con scioperi, sabotaggi e propaganda libertaria, subendo persecuzioni. Tra loro c’era Werther Ricchi, che dopo l’8 settembre 1943 fece arrivare marmellata e altri prodotti ai partigiani dell’8ª Brigata Garibaldi. Fu arrestato il 23 marzo 1944 e torturato. Durante il passaggio del fronte, le maestranze contribuirono a salvare buona parte dei macchinari dello stabilimento.';

  @override
  String get poi_fantaguzzi_name => 'Palazzo Fantaguzzi';

  @override
  String get poi_fantaguzzi_desc => 'Palazzo Fantaguzzi si trova nell’attuale corso Gastone Sozzi, già corso Umberto I, e dal 1922 ospita la Banca Popolare di Cesena. Nei primi mesi della Repubblica Sociale Italiana una parte dell’edificio accolse anche gli uffici del fascio cittadino: le fonti non documentano invece un suo utilizzo come sede fascista per tutto il Ventennio. Per il valore simbolico di quel presidio, il comando del GAP cesenate organizzò un attentato. Il 18 gennaio 1944 quattro partigiani fecero esplodere una bomba nell’ingresso: non ci furono vittime, ma il palazzo riportò gravi danni. Alcune settimane dopo la sede del fascio fu trasferita al Palazzo del Ridotto. È importante distinguere i due luoghi: le fonti collocano al Ridotto, non a Palazzo Fantaguzzi, le successive detenzioni e torture di prigionieri.';

  @override
  String get poi_rifugi_antiaerei_name => 'Rifugi Antiaerei della Rocca';

  @override
  String get poi_rifugi_antiaerei_desc => 'Il rifugio di viale Mazzoni era una galleria pubblica scavata ex novo nel colle della Rocca nel 1944, su progetto dell’ingegnere capo del Comune Mario Tellerini. Poteva accogliere fino a 800 persone, con 290 posti a sedere. Aveva due ingressi protetti da strutture paraschegge e comprendeva un’infermeria, locali per i pompieri e per il responsabile del ricovero, latrine e impianti di illuminazione, acqua e telefono; quest’ultimo fu asportato dai tedeschi. Il camino di ventilazione terminava nel Parco della Rimembranza e poteva funzionare anche da uscita di sicurezza. Era stato ipotizzato un ampliamento per arrivare a 1.500 posti, ma il progetto non fu realizzato: il primo grande bombardamento su Cesena, il 13 maggio 1944, diede inizio a una lunga stagione di incursioni. La galleria era una struttura distinta dalla fortezza della Rocca.';

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
  String get quiz_fallback_name => 'Quiz di riserva';

  @override
  String get quiz_fallback_desc => 'Il quiz online non è al momento disponibile. Ecco tre domande di riserva dedicate a questo luogo.';





  @override
  String get quiz_santa_cristina_q1 => 'In quale parte della chiesa fu allestito il rifugio antiaereo?';

  @override
  String get quiz_santa_cristina_q1_o1 => 'Nella cripta';

  @override
  String get quiz_santa_cristina_q1_o2 => 'Nel campanile';

  @override
  String get quiz_santa_cristina_q1_o3 => 'Nel chiostro';

  @override
  String get quiz_santa_cristina_q2 => 'Quante persone poteva ospitare la cripta adibita a rifugio?';

  @override
  String get quiz_santa_cristina_q2_o1 => 'Fino a 200 persone';

  @override
  String get quiz_santa_cristina_q2_o2 => 'Circa 700 persone';

  @override
  String get quiz_santa_cristina_q2_o3 => 'Fino a 800 persone';

  @override
  String get quiz_rocca_q1 => 'Quale funzione mantenne la Rocca anche durante l’occupazione nazifascista?';

  @override
  String get quiz_rocca_q1_o1 => 'Carcere';

  @override
  String get quiz_rocca_q1_o2 => 'Rifugio antiaereo pubblico';

  @override
  String get quiz_rocca_q1_o3 => 'Ospedale da campo';

  @override
  String get quiz_rocca_q2 => 'Per quale motivo la Resistenza organizzò due incursioni alla Rocca nel 1944?';

  @override
  String get quiz_rocca_q2_o1 => 'Per liberare prigionieri politici';

  @override
  String get quiz_rocca_q2_o2 => 'Per trasferire i macchinari dell’Arrigoni';

  @override
  String get quiz_rocca_q2_o3 => 'Per proteggere i civili dai bombardamenti';

  @override
  String get quiz_rocca_q3 => 'Dove furono fucilati otto antifascisti il 4 settembre 1944?';

  @override
  String get quiz_rocca_q3_o1 => 'Nello Sferisterio, davanti all’ingresso della Rocca';

  @override
  String get quiz_rocca_q3_o2 => 'Nel cortile interno della fortezza';

  @override
  String get quiz_rocca_q3_o3 => 'Nella stazione ferroviaria';

  @override
  String get quiz_san_rocco_q1 => 'Quale parte della chiesa di San Rocco fu adattata a rifugio antiaereo?';

  @override
  String get quiz_san_rocco_q1_o1 => 'Il campanile';

  @override
  String get quiz_san_rocco_q1_o2 => 'La cripta';

  @override
  String get quiz_san_rocco_q1_o3 => 'La sacrestia';

  @override
  String get quiz_san_rocco_q2 => 'Quale obiettivo vicino al borgo fu colpito per ostacolare la ritirata tedesca?';

  @override
  String get quiz_san_rocco_q2_o1 => 'Il Ponte Vecchio';

  @override
  String get quiz_san_rocco_q2_o2 => 'Il Ponte Nuovo';

  @override
  String get quiz_san_rocco_q2_o3 => 'La stazione ferroviaria';

  @override
  String get quiz_abbazia_monte_q1 => 'Quante persone circa furono ospitate nei sotterranei e nella galleria dell’abbazia durante la guerra?';

  @override
  String get quiz_abbazia_monte_q1_o1 => 'Circa 700';

  @override
  String get quiz_abbazia_monte_q1_o2 => 'Circa 200';

  @override
  String get quiz_abbazia_monte_q1_o3 => 'Circa 800';

  @override
  String get quiz_abbazia_monte_q2 => 'Quali danni provocarono i bombardamenti dell’ottobre 1944 all’abbazia?';

  @override
  String get quiz_abbazia_monte_q2_o1 => 'La chiesa fu sventrata e una parte del monastero crollò';

  @override
  String get quiz_abbazia_monte_q2_o2 => 'Furono danneggiati soltanto i giardini';

  @override
  String get quiz_abbazia_monte_q2_o3 => 'L’intero colle venne evacuato senza danni agli edifici';

  @override
  String get quiz_osservanza_q1 => 'Dove si trovavano i due ricoveri antiaerei dell’Osservanza?';

  @override
  String get quiz_osservanza_q1_o1 => 'Nelle catacombe e presso il campanile';

  @override
  String get quiz_osservanza_q1_o2 => 'Nel chiostro e nella sacrestia';

  @override
  String get quiz_osservanza_q1_o3 => 'Sotto il refettorio e nel cortile';

  @override
  String get quiz_osservanza_q2 => 'Qual era la capienza complessiva dei due ricoveri dell’Osservanza?';

  @override
  String get quiz_osservanza_q2_o1 => 'Circa 200 persone';

  @override
  String get quiz_osservanza_q2_o2 => 'Circa 700 persone';

  @override
  String get quiz_osservanza_q2_o3 => 'Circa 800 persone';

  @override
  String get quiz_palazzo_ridotto_q1 => 'A che cosa serviva la sirena collocata sulla torre del Palazzo del Ridotto?';

  @override
  String get quiz_palazzo_ridotto_q1_o1 => 'A segnalare le incursioni aeree';

  @override
  String get quiz_palazzo_ridotto_q1_o2 => 'A regolare il traffico ferroviario';

  @override
  String get quiz_palazzo_ridotto_q1_o3 => 'A convocare le riunioni comunali';

  @override
  String get quiz_palazzo_ridotto_q2 => 'Quale sistema ausiliario poteva dare l’allarme quando mancava la corrente?';

  @override
  String get quiz_palazzo_ridotto_q2_o1 => 'Le campane delle chiese';

  @override
  String get quiz_palazzo_ridotto_q2_o2 => 'Le luci delle piazze';

  @override
  String get quiz_palazzo_ridotto_q2_o3 => 'I fischi dei treni';

  @override
  String get quiz_stazione_q1 => 'Perché l’area della stazione era considerata strategica durante l’occupazione?';

  @override
  String get quiz_stazione_q1_o1 => 'Per la vicinanza di Arrigoni e della raffineria Montecatini';

  @override
  String get quiz_stazione_q1_o2 => 'Per la presenza della Biblioteca Malatestiana';

  @override
  String get quiz_stazione_q1_o3 => 'Perché ospitava il rifugio della chiesa di Santa Cristina';

  @override
  String get quiz_stazione_q2 => 'Come cercò la Resistenza di ostacolare i rifornimenti all’esercito occupante?';

  @override
  String get quiz_stazione_q2_o1 => 'Colpendo la stazione e le linee ferroviarie';

  @override
  String get quiz_stazione_q2_o2 => 'Interrompendo le campane delle chiese';

  @override
  String get quiz_stazione_q2_o3 => 'Occupando il Palazzo del Ridotto';

  @override
  String get quiz_arrigoni_q1 => 'Quali prodotti caratterizzavano la produzione dello stabilimento cesenate?';

  @override
  String get quiz_arrigoni_q1_o1 => 'Confetture, pomodori pelati e minestroni essiccati';

  @override
  String get quiz_arrigoni_q1_o2 => 'Tessuti, filati e abbigliamento';

  @override
  String get quiz_arrigoni_q1_o3 => 'Automobili, biciclette e componenti meccanici';

  @override
  String get quiz_arrigoni_q2 => 'In che modo Werther Ricchi sostenne la Resistenza dopo l’8 settembre 1943?';

  @override
  String get quiz_arrigoni_q2_o1 => 'Facendo arrivare prodotti Arrigoni ai partigiani dell’8ª Brigata Garibaldi';

  @override
  String get quiz_arrigoni_q2_o2 => 'Fornendo carburante alla raffineria Montecatini';

  @override
  String get quiz_arrigoni_q2_o3 => 'Organizzando la costruzione della galleria antiaerea';

  @override
  String get quiz_fantaguzzi_q1 => 'Quale istituto aveva sede a Palazzo Fantaguzzi dal 1922?';

  @override
  String get quiz_fantaguzzi_q1_o1 => 'La Banca Popolare di Cesena';

  @override
  String get quiz_fantaguzzi_q1_o2 => 'La Biblioteca Malatestiana';

  @override
  String get quiz_fantaguzzi_q1_o3 => 'Il municipio';

  @override
  String get quiz_fantaguzzi_q2 => 'Che cosa accadde il 18 gennaio 1944 all’ingresso del palazzo?';

  @override
  String get quiz_fantaguzzi_q2_o1 => 'Il GAP fece esplodere una bomba, senza causare vittime';

  @override
  String get quiz_fantaguzzi_q2_o2 => 'Un bombardamento distrusse l’intero edificio';

  @override
  String get quiz_fantaguzzi_q2_o3 => 'Fu inaugurato un rifugio antiaereo';

  @override
  String get quiz_rifugi_antiaerei_q1 => 'Qual era la capienza complessiva della galleria scavata nel colle della Rocca?';

  @override
  String get quiz_rifugi_antiaerei_q1_o1 => 'Fino a 800 persone';

  @override
  String get quiz_rifugi_antiaerei_q1_o2 => 'Fino a 200 persone';

  @override
  String get quiz_rifugi_antiaerei_q1_o3 => 'Fino a 700 persone';

  @override
  String get quiz_rifugi_antiaerei_q2 => 'Quale elemento del rifugio poteva servire anche da uscita di sicurezza?';

  @override
  String get quiz_rifugi_antiaerei_q2_o1 => 'Il camino di ventilazione';

  @override
  String get quiz_rifugi_antiaerei_q2_o2 => 'Il muro paraschegge';

  @override
  String get quiz_rifugi_antiaerei_q2_o3 => 'Il locale dell’infermeria';

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
  @override
  String get quiz_santa_cristina_q3 => 'Come descrisse don Leo Bagnoli la cripta-rifugio?';

  @override
  String get quiz_santa_cristina_q3_o1 => 'Come un ambiente solido e asciutto';

  @override
  String get quiz_santa_cristina_q3_o2 => 'Come un ambiente instabile e umido';

  @override
  String get quiz_santa_cristina_q3_o3 => 'Come un locale privo di accessi';

  @override
  String get quiz_san_rocco_q3 => 'Quale elemento della chiesa originaria è rimasto dopo la distruzione del 1944?';

  @override
  String get quiz_san_rocco_q3_o1 => 'Il campanile ottocentesco';

  @override
  String get quiz_san_rocco_q3_o2 => 'La facciata principale';

  @override
  String get quiz_san_rocco_q3_o3 => 'La navata centrale';

  @override
  String get quiz_abbazia_monte_q3 => 'In che modo don Odo Contestabile aiutò due famiglie ebree nel 1943?';

  @override
  String get quiz_abbazia_monte_q3_o1 => 'Le accompagnò verso il confine con la Svizzera';

  @override
  String get quiz_abbazia_monte_q3_o2 => 'Le nascose nella galleria antiaerea della Rocca';

  @override
  String get quiz_abbazia_monte_q3_o3 => 'Le trasferì alla stazione ferroviaria';

  @override
  String get quiz_osservanza_q3 => 'Quale episodio è legato ai bombardamenti dell’ottobre 1944 sull’Osservanza?';

  @override
  String get quiz_osservanza_q3_o1 => 'La morte di padre Bosoni';

  @override
  String get quiz_osservanza_q3_o2 => 'Il trasferimento degli uffici fascisti';

  @override
  String get quiz_osservanza_q3_o3 => 'La distruzione della stazione ferroviaria';

  @override
  String get quiz_palazzo_ridotto_q3 => 'Perché gli uffici del Partito Fascista Repubblicano furono trasferiti al Ridotto?';

  @override
  String get quiz_palazzo_ridotto_q3_o1 => 'Dopo l’attentato alla sede di Palazzo Fantaguzzi';

  @override
  String get quiz_palazzo_ridotto_q3_o2 => 'Dopo il bombardamento dell’abbazia';

  @override
  String get quiz_palazzo_ridotto_q3_o3 => 'Perché la stazione venne chiusa';

  @override
  String get quiz_stazione_q3 => 'Che cosa accadde nell’attacco aereo del 29 giugno 1944 nell’area ferroviaria?';

  @override
  String get quiz_stazione_q3_o1 => 'Furono distrutti carichi di munizioni e incendiata la Montecatini';

  @override
  String get quiz_stazione_q3_o2 => 'Fu distrutto il campanile di San Rocco';

  @override
  String get quiz_stazione_q3_o3 => 'Fu colpita direttamente l’abbazia del Monte';

  @override
  String get quiz_arrigoni_q3 => 'Che cosa fecero gli operai Arrigoni durante il passaggio del fronte?';

  @override
  String get quiz_arrigoni_q3_o1 => 'Misero in salvo numerosi macchinari';

  @override
  String get quiz_arrigoni_q3_o2 => 'Trasferirono la stazione ferroviaria';

  @override
  String get quiz_arrigoni_q3_o3 => 'Costruirono un rifugio nel campanile di San Rocco';

  @override
  String get quiz_fantaguzzi_q3 => 'Dove fu trasferita la sede del fascio cittadino dopo l’attentato?';

  @override
  String get quiz_fantaguzzi_q3_o1 => 'Al Palazzo del Ridotto';

  @override
  String get quiz_fantaguzzi_q3_o2 => 'Alla Rocca Malatestiana';

  @override
  String get quiz_fantaguzzi_q3_o3 => 'Alla stazione ferroviaria';

  @override
  String get quiz_rifugi_antiaerei_q3 => 'Come erano protetti i due ingressi del rifugio su viale Mazzoni?';

  @override
  String get quiz_rifugi_antiaerei_q3_o1 => 'Con strutture paraschegge';

  @override
  String get quiz_rifugi_antiaerei_q3_o2 => 'Con campane d’allarme';

  @override
  String get quiz_rifugi_antiaerei_q3_o3 => 'Con porte di legno riempite d’acqua';
}
