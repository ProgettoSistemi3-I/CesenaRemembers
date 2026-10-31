// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cesena Remembers 1945';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsHeaderTitle => 'Interactive WWII Tour';

  @override
  String get settingsHeaderSubtitle => 'Manage privacy, notifications and language in one place.';

  @override
  String get sectionCredits => 'Credits';

  @override
  String get creditsTitle => 'Credits & Acknowledgements';

  @override
  String get creditsSubtitle => 'Discover the team behind Cesena Remembers';

  @override
  String get creditsPageTitle => 'Acknowledgements';

  @override
  String get creditsAppName => 'Cesena Remembers';

  @override
  String get creditsAppDescription => 'Made with passion to preserve the historical memory of our city.';

  @override
  String get sectionTeam => 'The Team';

  @override
  String get sectionThanks => 'Thanks';

  @override
  String get creditRoleDev => 'Development & Architecture';

  @override
  String get creditRoleGraphicsMarketing => 'Graphics & Marketing';

  @override
  String get creditRoleTeacher => 'Supervising Teacher';

  @override
  String get creditRoleClass => 'Support & Ideation';

  @override
  String get creditSchoolSubtitle => 'Visit the school website';

  @override
  String get sectionAccount => 'Account';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutSubtitle => 'Sign out of the current account';

  @override
  String get loggingOut => 'Signing out...';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountSubtitle => 'Remove profile and associated data';

  @override
  String get deletingAccount => 'Deleting...';

  @override
  String get deleteAccountDialogTitle => 'Delete account?';

  @override
  String get deleteAccountDialogBody => 'This action permanently removes the account, progress and all associated data.';

  @override
  String get deleteAccountSuccess => 'Account permanently deleted.';

  @override
  String get deleteAccountFailure => 'Could not complete now. Check the error message.';

  @override
  String get sectionPreferences => 'App Preferences';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle => 'Receive alerts on stops and rewards';

  @override
  String get darkModeTitle => 'Night Mode';

  @override
  String get darkModeSubtitle => 'Dark theme for the entire app';

  @override
  String get sectionPrivacy => 'Privacy';

  @override
  String get gpsTitle => 'GPS Location';

  @override
  String get gpsSubtitle => 'Required to explore the map';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get privacyPolicySubtitle => 'Read how your data is handled';

  @override
  String get gpsPermissionDenied => 'Permission denied or GPS disabled. Check your phone settings.';

  @override
  String get sectionGeneral => 'General';

  @override
  String get languageTitle => 'Language';

  @override
  String get sectionInfo => 'Info';

  @override
  String get versionTitle => 'Version';

  @override
  String get versionSubtitle => '1.0.0';

  @override
  String get versionSheetTitle => 'App version';

  @override
  String get versionSheetBody => 'Build number: 1.0.0';

  @override
  String get termsTitle => 'Terms of service';

  @override
  String get termsSubtitle => 'Usage rules and responsibilities';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsSubtitle => 'cesenaremembers@gmail.com';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonOk => 'Got it';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get notificationOpenAction => 'OPEN';

  @override
  String get notificationFallbackTitle => 'Notification';

  @override
  String get bannedAccountError => 'This account has been suspended.';

  @override
  String get bannedOverlayTitle => 'Suspended account';

  @override
  String get bannedOverlayMessage => 'Your account has been suspended for violating\nterms of service.\nContact support for more information.\nEmail: cesenaremembers@gmail.com';

  @override
  String get navMap => 'Map';

  @override
  String get navProfile => 'Profile';

  @override
  String get navCommunity => 'Community';

  @override
  String get navSettings => 'Settings';

  @override
  String errorLoadPreferences(String error) {
    return 'Error loading preferences: $error';
  }

  @override
  String get errorConnection => 'Connection error. Change cancelled.';

  @override
  String errorLogout(String error) {
    return 'Logout failed.';
  }

  @override
  String get errorDeleteAccountPartial => 'Account not fully deleted. App data was removed, but auth deletion failed. You will be signed out for safety.';

  @override
  String errorDeleteData(String error) {
    return 'Unable to delete data: $error';
  }

  @override
  String get errorLoadProfile => 'Failed to load profile.';

  @override
  String get errorOperationFailed => 'Operation failed. State restored.';

  @override
  String get tourStopped => 'Tour stopped.';

  @override
  String get errorSaveScore => 'Error saving score. Try again in a moment.';

  @override
  String get errorLoadPoi => 'Error loading points of interest.';

  @override
  String get errorSearch => 'Error during search.';

  @override
  String get errorAction => 'Error performing action.';

  @override
  String get removeFriendship => 'Remove friendship';

  @override
  String get locationDisabled => 'Location disabled';

  @override
  String get quizAnswerPerfect => 'Perfect!';

  @override
  String get quizAnswerGood => 'Well done!';

  @override
  String get toursCompleted => 'Tours Completed';

  @override
  String get tourLabel => 'Tour';

  @override
  String get tourConfirmStopTitle => 'Stop the tour?';

  @override
  String get tourConfirmStopBody => 'The tour will be ended and you will lose the current stop order.';

  @override
  String get buttonStop => 'Stop';

  @override
  String get tourStartGpsRequired => 'To start the tour, enable GPS, location permission and the in-app option.';

  @override
  String get tourCompleted => '🎉 Tour completed! Great job.';

  @override
  String get tourStopButton => 'Stop tour';

  @override
  String get tourOrderButton => 'Order stops';

  @override
  String get mapTestAnimation => 'Animation test';

  @override
  String get mapStyleStandard => 'Standard';

  @override
  String get mapStyleSatellite => 'Satellite';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get sectionStatistics => 'Statistics';

  @override
  String get sectionAchievements => 'Achievements';

  @override
  String get statTotalXp => 'Total XP';

  @override
  String get statBestTour => 'Best tour (XP)';

  @override
  String get statVisitedSites => 'Sites Visited';

  @override
  String get statBestTime => 'Best time';

  @override
  String get statAchievements => 'Achievements';

  @override
  String get profileFriends => 'Friends';

  @override
  String get profilePoints => 'Points';

  @override
  String get profileNoRequests => 'No requests at the moment.';

  @override
  String get profileYourFriends => 'Your Friends';

  @override
  String get profileFriendRequests => 'Friend Requests';

  @override
  String profileNameTooShort(int min, int max) {
    return 'Name must be $min-$max characters.';
  }

  @override
  String get profileNameOffensive => 'The name contains forbidden terms.\nPlease choose a different one.';

  @override
  String get avatarPickerTitle => 'Choose your Avatar';

  @override
  String get avatarPickerSubtitle => 'Customize your profile';

  @override
  String get poiTabInfo => 'Information';

  @override
  String get poiTabQuiz => 'Quiz';

  @override
  String get poiSectionHistory => 'History';

  @override
  String get poiStartQuiz => 'Take the quiz for this stop →';

  @override
  String get poiNoQuiz => 'No quiz available for this stop.';

  @override
  String get quizNextQuestion => 'Next question →';

  @override
  String get quizFinish => 'Finish quiz →';

  @override
  String get quizNextStop => 'Next stop →';

  @override
  String get quizNotice => 'Quiz notice';

  @override
  String quizCorrectAnswers(int score, int total) {
    return '$score / $total correct answers';
  }

  @override
  String quizTime(String time) {
    return 'Time: $time';
  }

  @override
  String quizQuestion(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get tourStartButton => 'Start tour';

  @override
  String get tourStopCardArrived => 'You arrived! Tap to open';

  @override
  String tourStopCardDistance(String distance, int index, int total) {
    return '$distance · stop $index/$total';
  }

  @override
  String get tourPlanTitle => 'Stop order';

  @override
  String get tourPlanSubtitle => 'Drag the handle to reorder the route.';

  @override
  String get tourPlanFirstStop => 'First stop of the tour';

  @override
  String tourPlanDistanceFromPrev(String distance) {
    return '$distance from previous';
  }

  @override
  String get tourPlanCurrentLabel => 'Current';

  @override
  String get locationBannerMissingPermission => 'Missing permissions';

  @override
  String get locationBannerGpsOff => 'GPS Disabled';

  @override
  String get locationBannerEnableLocation => 'Enable location to explore the map in real time.';

  @override
  String get locationBannerReEnableLocation => 'Re-enable location in settings to show your position on the map.';

  @override
  String get locationBannerResolve => 'Fix';

  @override
  String get socialSearchHint => 'Search user...';

  @override
  String get socialLeaderboardEmpty => 'Add friends to see your leaderboard.';

  @override
  String get socialLeaderboard => 'Friends leaderboard';

  @override
  String get socialNoUserFound => 'No user found.';

  @override
  String get socialTypeMoreChars => 'Type at least 2 characters to search.';

  @override
  String get socialYou => 'You';

  @override
  String get socialDefaultUsername => 'user';

  @override
  String socialFriendsOf(String name) {
    return 'Friends of $name';
  }

  @override
  String get socialMustBeFriend => 'You must be friends to view their friend list.';

  @override
  String get socialRequestSent => 'Request sent';

  @override
  String get socialAccept => 'Accept';

  @override
  String get socialReject => 'Decline';

  @override
  String get socialAddFriend => 'Add as friend';

  @override
  String get publicStatDetailed => 'Detailed Statistics';

  @override
  String get publicStatAchievements => 'Achievements';

  @override
  String get publicStatBestScore => 'Best Score';

  @override
  String get publicStatSites => 'Sites Visited';

  @override
  String get publicStatQuiz => 'Quizzes Passed';

  @override
  String get publicStatBestTime => 'Best Time';

  @override
  String get publicStatCorrectAnswers => 'Correct Answers';

  @override
  String get publicStatFriends => 'Friends';

  @override
  String get publicStatPoints => 'Points';

  @override
  String get publicStatLevel => 'Level';

  @override
  String get errorLoginFailed => 'Login failed. Check your connection and try again.';

  @override
  String get errorOffline => 'You are offline. Check your Internet connection and try again.';

  @override
  String get errorLoginGeneric => 'Login failed. Please try again in a few seconds.';

  @override
  String get loginGoogleButton => 'SIGN IN WITH GOOGLE';

  @override
  String get errorCommunication => 'Error communicating with the server.';

  @override
  String get errorNotLoggedIn => 'User not logged in.';

  @override
  String get errorLoadPrefs => 'Error loading preferences.';

  @override
  String get errorGpsDenied => 'Permission denied or GPS disabled. Check your settings.';

  @override
  String get errorConnectionSettings => 'Connection error. Changes reverted.';

  @override
  String get errorDeleteAccount => 'Failed to delete data.';

  @override
  String get errorDeleteAccountAuth => 'Account not fully deleted. App data removed, but auth deletion failed. Logging out for security.';

  @override
  String get errorSyncProfile => 'Failed to sync profile.';

  @override
  String get errorSaveProfile => 'Failed to save profile.';

  @override
  String get errorLoadLeaderboard => 'Failed to load leaderboard.';

  @override
  String get settingsTourTitle => 'WWII Interactive Tour';

  @override
  String get settingsTourSubtitle => 'Manage privacy, notifications, and language in one place.';

  @override
  String get settingsCredits => 'Credits';

  @override
  String get settingsCreditsTitle => 'Credits & Acknowledgements';

  @override
  String get settingsCreditsSubtitle => 'Discover the team behind Cesena Remembers';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsLogoutInProgress => 'Logging out...';

  @override
  String get settingsLogoutSubtitle => 'Sign out of current account';

  @override
  String get settingsDelete => 'Delete account';

  @override
  String get settingsDeleteInProgress => 'Deleting...';

  @override
  String get settingsDeleteSubtitle => 'Remove profile and associated data';

  @override
  String get settingsAppPrefs => 'App Preferences';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotifSubtitle => 'Receive alerts for stops and rewards';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsDarkModeSubtitle => 'Dark theme for the entire app';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsGps => 'GPS Location';

  @override
  String get settingsGpsSubtitle => 'Required to explore the map';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacySubtitle => 'Read how your data is handled';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsInfo => 'Info';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsTerms => 'Terms of Service';

  @override
  String get settingsTermsSubtitle => 'Usage rules and responsibilities';

  @override
  String get settingsContacts => 'Contacts';

  @override
  String get settingsClose => 'Close';

  @override
  String get settingsPerfect => 'Perfect';

  @override
  String get settingsDeleteConfirmTitle => 'Delete account?';

  @override
  String get settingsDeleteConfirmBody => 'This operation permanently removes your account, progress, and associated data.';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsDeleteConfirmBtn => 'Delete';

  @override
  String get settingsDeleteSuccess => 'Account permanently deleted.';

  @override
  String get settingsDeleteError => 'Unable to complete now. Check the error message.';

  @override
  String get achievement_first_visit_title => 'First Step';

  @override
  String get achievement_first_visit_desc => 'Visit your first historical site';

  @override
  String get achievement_first_quiz_title => 'Student';

  @override
  String get achievement_first_quiz_desc => 'Complete your first quiz';

  @override
  String get achievement_first_tour_title => 'Pioneer';

  @override
  String get achievement_first_tour_desc => 'Finish your first complete tour';

  @override
  String get achievement_quiz_15_title => 'Veteran';

  @override
  String get achievement_quiz_15_desc => 'Complete 15 quizzes';

  @override
  String get achievement_perfect_tour_title => 'Flawless';

  @override
  String get achievement_perfect_tour_desc => 'Answer all questions correctly in a tour';

  @override
  String get achievement_xp_500_title => 'Collector';

  @override
  String get achievement_xp_500_desc => 'Reach 500 total XP';

  @override
  String get achievement_tour_under_1h_title => 'On the March';

  @override
  String get achievement_tour_under_1h_desc => 'Complete a tour in under 1 hour';

  @override
  String get achievement_tour_under_30m_title => 'Lightning';

  @override
  String get achievement_tour_under_30m_desc => 'Complete a tour in under 30 minutes';

  @override
  String get achievement_friend_1_title => 'Citizen';

  @override
  String get achievement_friend_1_desc => 'Add your first friend';

  @override
  String get achievement_friend_5_title => 'Historical Circle';

  @override
  String get achievement_friend_5_desc => 'Reach 5 friends';

  @override
  String get poi_santa_cristina_name => 'Church of Santa Cristina';

  @override
  String get poi_santa_cristina_desc => 'The church of Santa Cristina was commissioned by Pope Pius VII Chiaramonti and designed by architect Giuseppe Valadier. Construction began in 1816 and ended in 1825; the building is Neoclassical. During the Second World War, the crypt was reinforced and made usable as an air-raid shelter, with capacity for up to 200 people.';

  @override
  String get poi_rocca_name => 'Malatestiana Fortress';

  @override
  String get poi_rocca_desc => 'Construction of the Rocca Nuova, also known as the Malatestiana Fortress, began in 1380 on the initiative of Galeotto Malatesta and continued under Malatesta Novello; it was completed in the late 1470s. In 1502 Cesare Borgia brought Leonardo da Vinci to Cesena to survey the defences of the conquered cities. After losing its military role, the fortress became a prison and remained one until 1969. The public air-raid shelters built in 1944 were at the foot of the hill along Viale Mazzoni, not inside the fortress.';

  @override
  String get poi_san_rocco_name => 'Church of San Rocco';

  @override
  String get poi_san_rocco_desc => 'The parish of San Rocco in Cesena dates back to 1615. In the summer of 1944, the church made its indoor rooms available to people fleeing the bombings, and a shelter was set up in the bell tower. The church was destroyed by the 1944 bombings together with the neighbourhood; only its nineteenth-century bell tower remains today.';

  @override
  String get poi_abbazia_monte_name => 'Abbey of Santa Maria del Monte';

  @override
  String get poi_abbazia_monte_desc => 'The Benedictine abbey of Santa Maria del Monte was founded at the beginning of the 11th century on the hill known as “il Monte”, south-east of Cesena. During the Second World War it sheltered about seven hundred displaced people in its cellars and tunnel. Between 16 and 19 October 1944 it was hit repeatedly and directly by bombing: the church was gutted and part of the monastery collapsed. None of the displaced people sheltering in the abbey were killed.';

  @override
  String get poi_osservanza_name => 'Church and Convent of the Osservanza';

  @override
  String get poi_osservanza_desc => 'The church of the Osservanza was built between 1459 and 1464 at the behest of Malatesta Novello and is linked to the Order of Friars Minor of the Observance. During the Second World War, two air-raid shelters were set up there, in the catacombs and near the bell tower, with a combined capacity of about 200 people. The church was hit by Allied bombing on 16 and 19 October 1944; Father Bosoni died during the raids.';

  @override
  String get poi_palazzo_ridotto_name => 'Palazzo del Ridotto';

  @override
  String get poi_palazzo_ridotto_desc => 'Palazzo del Ridotto stands in Piazza Almerici and was built between 1466 and 1472 as the seat of the municipal authority known as the Conservatori. During the Second World War, an alarm siren was installed on its tower as part of a city-wide warning system, backed up by church bells in the event of a power cut. After the 18 January 1944 attack on the Fascist headquarters in Corso Umberto I, the offices of the Republican Fascist Party moved to the palace, which was also used to detain and torture prisoners.';

  @override
  String get poi_stazione_name => 'Cesena Railway Station';

  @override
  String get poi_stazione_desc => 'Cesena’s first railway station opened in 1861. In 1919 a plan for a larger station building was approved, and the foundation stone of the new station was laid in 1925. The Arrigoni food factory stood next to it, while the Montecatini refinery stood on the opposite side. Because these facilities were close together, the area became a target of Allied bombing after the German occupation. On 29 June 1944 an air raid hit the railway yard, destroyed ammunition loads and set the refinery on fire; further raids followed between July and September.';

  @override
  String get poi_arrigoni_name => 'Arrigoni Factory';

  @override
  String get poi_arrigoni_desc => 'The Arrigoni factory in Cesena stood next to the railway station and became the group’s leading plant for jams, peeled tomatoes and dried minestrone. Over time it employed thousands of people from Cesena and became a centre of local anti-Fascism. Worker Werther Ricchi was employed there before 25 July 1943 and, after 8 September, sent jam and other Arrigoni products to the partisans of the 8th Garibaldi Brigade. He was arrested on 23 March 1944 and tortured.';

  @override
  String get poi_fantaguzzi_name => 'Palazzo Fantaguzzi';

  @override
  String get poi_fantaguzzi_desc => 'Palazzo Fantaguzzi stands in Corso Gastone Sozzi, formerly Corso Umberto I, and has housed the Banca Popolare di Cesena since 1922. During the first months of the Italian Social Republic, part of the building also housed the local Fascist offices. On 18 January 1944 a GAP commando detonated a bomb at the entrance to the Fascist headquarters: there were no casualties, but the building was badly damaged. A few weeks later the Fascist headquarters moved to Palazzo del Ridotto.';

  @override
  String get poi_rifugi_antiaerei_name => 'Air-Raid Shelters of the Fortress';

  @override
  String get poi_rifugi_antiaerei_desc => 'In January 1944, the decision was made to excavate a tunnel in the Rocca hill to create a public air-raid shelter. The tunnel was newly built in 1944 by the city’s chief engineer, Mario Tellerini, and could accommodate 800 people, 290 of them seated. It had two entrances on Viale Mazzoni protected by a blast wall; its ventilation shaft could also serve as an emergency exit.';

  @override
  String setupUsernameInvalid(int min, int max) {
    return 'Invalid username (use $min-$max characters: a-z, 0-9, _ or .).';
  }

  @override
  String get setupUsernameOffensive => 'Username contains prohibited terms. Please choose another.';

  @override
  String get setupUsernameTaken => 'Username is already taken. Please choose another.';

  @override
  String setupFirestoreError(Object username) {
    return 'Invalid Firestore configuration: read/write permissions required on usernames/$username.';
  }

  @override
  String get setupPermissionDenied => 'Insufficient Firestore permissions to complete the profile. Check project rules.';

  @override
  String get setupGenericError => 'Unable to save profile. Please try again in a few seconds.';

  @override
  String get setupTitle => 'Create your profile';

  @override
  String get setupSubtitle => 'Choose a unique username (cannot be changed), display name, and avatar.';

  @override
  String get setupNameLabel => 'Display Name';

  @override
  String get setupUsernameLabel => 'Username';

  @override
  String get setupUsernameHint => 'e.g., cesena_explorer';

  @override
  String get setupAvatarLabel => 'Choose avatar';

  @override
  String get setupSubmitButton => 'Confirm Profile';

  @override
  String get creditRoleDiplo => 'German Diplomatic Missions in Italy';

  @override
  String get creditRoleDiploDesc => 'Developed with their valuable contribution';

  @override
  String get sectionSupport => 'Collaborators and Support';

  @override
  String get quiz_fallback_name => 'Standard difficulty (local seed)';

  @override
  String get quiz_fallback_desc => 'Due to a server error, questions are not personalized and use a specific local difficulty.';

  @override
  String get quiz_santa_cristina_q1 => 'Who designed the church of Santa Cristina?';

  @override
  String get quiz_santa_cristina_q1_o1 => 'Architect Giuseppe Valadier';

  @override
  String get quiz_santa_cristina_q1_o2 => 'Francesco Morandi, known as il Terribilia';

  @override
  String get quiz_santa_cristina_q1_o3 => 'Leandro Marconi';

  @override
  String get quiz_santa_cristina_q2 => 'How many people could the crypt shelter?';

  @override
  String get quiz_santa_cristina_q2_o1 => 'Up to 200 people';

  @override
  String get quiz_santa_cristina_q2_o2 => 'About 700 people';

  @override
  String get quiz_santa_cristina_q2_o3 => 'Up to 800 people';

  @override
  String get quiz_rocca_q1 => 'In what year did construction of the Rocca Nuova begin?';

  @override
  String get quiz_rocca_q1_o1 => '1380';

  @override
  String get quiz_rocca_q1_o2 => '1464';

  @override
  String get quiz_rocca_q1_o3 => '1502';

  @override
  String get quiz_rocca_q2 => 'Who brought Leonardo da Vinci to Cesena in 1502?';

  @override
  String get quiz_rocca_q2_o1 => 'Malatesta Novello';

  @override
  String get quiz_rocca_q2_o2 => 'Cesare Borgia';

  @override
  String get quiz_rocca_q2_o3 => 'Frederick Barbarossa';

  @override
  String get quiz_rocca_q3 => 'Until what year was the fortress used as a prison?';

  @override
  String get quiz_rocca_q3_o1 => '1944';

  @override
  String get quiz_rocca_q3_o2 => '1969';

  @override
  String get quiz_rocca_q3_o3 => '1974';

  @override
  String get quiz_san_rocco_q1 => 'What year does the parish of San Rocco date back to?';

  @override
  String get quiz_san_rocco_q1_o1 => '1615';

  @override
  String get quiz_san_rocco_q1_o2 => '1816';

  @override
  String get quiz_san_rocco_q1_o3 => '1944';

  @override
  String get quiz_san_rocco_q2 => 'Which part of the historic church remains today?';

  @override
  String get quiz_san_rocco_q2_o1 => 'The nineteenth-century bell tower';

  @override
  String get quiz_san_rocco_q2_o2 => 'The main façade';

  @override
  String get quiz_san_rocco_q2_o3 => 'The crypt';

  @override
  String get quiz_abbazia_monte_q1 => 'In which century was the Abbey of Santa Maria del Monte founded?';

  @override
  String get quiz_abbazia_monte_q1_o1 => 'At the beginning of the 11th century';

  @override
  String get quiz_abbazia_monte_q1_o2 => 'In the 15th century';

  @override
  String get quiz_abbazia_monte_q1_o3 => 'In the 18th century';

  @override
  String get quiz_abbazia_monte_q2 => 'About how many displaced people did the abbey shelter during the war?';

  @override
  String get quiz_abbazia_monte_q2_o1 => 'About 200';

  @override
  String get quiz_abbazia_monte_q2_o2 => 'About 500';

  @override
  String get quiz_abbazia_monte_q2_o3 => 'About 700';

  @override
  String get quiz_osservanza_q1 => 'Between which years was the church of the Osservanza built?';

  @override
  String get quiz_osservanza_q1_o1 => '1459–1464';

  @override
  String get quiz_osservanza_q1_o2 => '1472–1502';

  @override
  String get quiz_osservanza_q1_o3 => '1816–1825';

  @override
  String get quiz_osservanza_q2 => 'What happened to the church in October 1944?';

  @override
  String get quiz_osservanza_q2_o1 => 'It was hit by bombing and Father Bosoni was killed';

  @override
  String get quiz_osservanza_q2_o2 => 'It remained unharmed throughout the air raids';

  @override
  String get quiz_osservanza_q2_o3 => 'It was turned into an Allied hospital';

  @override
  String get quiz_palazzo_ridotto_q1 => 'Which square does Palazzo del Ridotto face?';

  @override
  String get quiz_palazzo_ridotto_q1_o1 => 'Piazza Almerici';

  @override
  String get quiz_palazzo_ridotto_q1_o2 => 'Piazza del Popolo';

  @override
  String get quiz_palazzo_ridotto_q1_o3 => 'Piazza del Duomo';

  @override
  String get quiz_palazzo_ridotto_q2 => 'Which warning device was installed on the tower during the war?';

  @override
  String get quiz_palazzo_ridotto_q2_o1 => 'An air-raid siren';

  @override
  String get quiz_palazzo_ridotto_q2_o2 => 'A spotting radar';

  @override
  String get quiz_palazzo_ridotto_q2_o3 => 'A military radio';

  @override
  String get quiz_stazione_q1 => 'In what year did Cesena’s first railway station open?';

  @override
  String get quiz_stazione_q1_o1 => '1861';

  @override
  String get quiz_stazione_q1_o2 => '1919';

  @override
  String get quiz_stazione_q1_o3 => '1925';

  @override
  String get quiz_stazione_q2 => 'On what date did an air raid hit Cesena’s railway yard?';

  @override
  String get quiz_stazione_q2_o1 => '29 June 1944';

  @override
  String get quiz_stazione_q2_o2 => '25 July 1944';

  @override
  String get quiz_stazione_q2_o3 => '20 October 1944';

  @override
  String get quiz_arrigoni_q1 => 'In which sectors was the Cesena Arrigoni plant the group’s leading factory?';

  @override
  String get quiz_arrigoni_q1_o1 => 'Jams, peeled tomatoes and dried minestrone';

  @override
  String get quiz_arrigoni_q1_o2 => 'Textiles, yarn and clothing';

  @override
  String get quiz_arrigoni_q1_o3 => 'Engineering, cars and bicycles';

  @override
  String get quiz_arrigoni_q2 => 'Which anti-Fascist worker was employed at the Arrigoni factory?';

  @override
  String get quiz_arrigoni_q2_o1 => 'Werther Ricchi';

  @override
  String get quiz_arrigoni_q2_o2 => 'Mario Tellerini';

  @override
  String get quiz_arrigoni_q2_o3 => 'Father Bosoni';

  @override
  String get quiz_fantaguzzi_q1 => 'Since what year has Palazzo Fantaguzzi housed the Banca Popolare di Cesena?';

  @override
  String get quiz_fantaguzzi_q1_o1 => 'Since 1922';

  @override
  String get quiz_fantaguzzi_q1_o2 => 'Since 1944';

  @override
  String get quiz_fantaguzzi_q1_o3 => 'Since 1970';

  @override
  String get quiz_fantaguzzi_q2 => 'During which period did part of the palace house the local Fascist offices?';

  @override
  String get quiz_fantaguzzi_q2_o1 => 'Throughout the twenty-year Fascist period';

  @override
  String get quiz_fantaguzzi_q2_o2 => 'During the first months of the Italian Social Republic';

  @override
  String get quiz_fantaguzzi_q2_o3 => 'After the city’s liberation in 1944';

  @override
  String get quiz_rifugi_antiaerei_q1 => 'When was the decision made to excavate the air-raid tunnel in the Rocca hill?';

  @override
  String get quiz_rifugi_antiaerei_q1_o1 => 'January 1944';

  @override
  String get quiz_rifugi_antiaerei_q1_o2 => 'June 1941';

  @override
  String get quiz_rifugi_antiaerei_q1_o3 => 'October 1944';

  @override
  String get quiz_rifugi_antiaerei_q2 => 'How many people could the Rocca shelter accommodate?';

  @override
  String get quiz_rifugi_antiaerei_q2_o1 => '200 people';

  @override
  String get quiz_rifugi_antiaerei_q2_o2 => '500 people';

  @override
  String get quiz_rifugi_antiaerei_q2_o3 => '800 people, 290 of them seated';

  @override
  String tourCompletionXpGained(int xp) {
    return '+$xp XP earned';
  }

  @override
  String get notificationNoNotifications => 'No notifications at the moment.';

  @override
  String get notificationAchievementUnlocked => 'Achievement Unlocked!';

  @override
  String get notificationFriendRequest => 'Friend request';

  @override
  String get notificationRedeemButton => 'REDEEM';

  @override
  String get achievementUnlockButton => 'UNLOCK';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Continue';

  @override
  String get onboardingStart => 'Start exploring';

  @override
  String get onboardingSlide0Tag => 'WELCOME';

  @override
  String get onboardingSlide0Title => 'Cesena\nRemembers';

  @override
  String get onboardingSlide0Desc => 'Explore the places that shaped the history of Cesena. A journey through memories, quizzes and people.';

  @override
  String get onboardingSlide1Tag => '01 — TOUR';

  @override
  String get onboardingSlide1Title => 'Follow\nthe route';

  @override
  String get onboardingSlide1Desc => 'Start a guided tour and walk through historical sites. GPS guides you step by step.';

  @override
  String get onboardingSlide2Tag => '02 — QUIZ';

  @override
  String get onboardingSlide2Title => 'Put yourself\nto the test';

  @override
  String get onboardingSlide2Desc => 'Answer questions about each location. The more accurate you are, the more XP you earn.';

  @override
  String get onboardingSlide3Tag => '03 — LEADERBOARD';

  @override
  String get onboardingSlide3Title => 'Climb\nthe top';

  @override
  String get onboardingSlide3Desc => 'Compare your progress with your friends.';

  @override
  String get onboardingSlide4Tag => '04 — ACHIEVEMENTS';

  @override
  String get onboardingSlide4Title => 'Collect\nbadges';

  @override
  String get onboardingSlide4Desc => 'Every milestone unlocks an exclusive badge. Complete tours, ace quizzes and make friends.';

  @override
  String get quizResultPerfectTitle => 'Perfect!';

  @override
  String get quizResultPerfectBody => 'Not a single mistake. A true history buff!';

  @override
  String get quizResultGreatTitle => 'Great job!';

  @override
  String get quizResultGreatBody => 'You know this place well.';

  @override
  String get quizResultGoodTitle => 'Good result!';

  @override
  String get quizResultGoodBody => 'You got the main points. A little more and you\'ll master it.';

  @override
  String get quizResultFairTitle => 'Almost there';

  @override
  String get quizResultFairBody => 'Reread the history card and try again at the next stop.';

  @override
  String get quizResultPoorTitle => 'Not this time';

  @override
  String get quizResultPoorBody => 'Don\'t worry: history is learned one step at a time.';

  @override
  String tourXpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String speedBonusSteady(int percent) {
    return 'Steady pace! +$percent% bonus';
  }

  @override
  String speedBonusFast(int percent) {
    return 'Brisk pace! +$percent% bonus';
  }

  @override
  String speedBonusLightning(int percent) {
    return 'Lightning fast! +$percent% bonus';
  }

  @override
  String get connectionErrorTitle => 'No connection';

  @override
  String get connectionErrorBody => 'We can\'t reach the server right now. Check your connection and try again. Some features may be limited while offline.';

  @override
  String get achievementUnlockedSnack => 'You unlocked a new achievement! Tap to claim it.';

  @override
  String get publicStatsPrivateTitle => 'Private statistics';

  @override
  String get publicStatsPrivateBody => 'Become friends to see detailed stats, unlocked achievements and more.';

  @override
  String get sectionMapLicenses => 'Map licences';

  @override
  String get mapLicenseOsmTitle => 'OpenStreetMap';

  @override
  String get mapLicenseOsmSubtitle => '© OpenStreetMap contributors — ODbL licence';

  @override
  String get mapLicenseCartoTitle => 'CARTO';

  @override
  String get mapLicenseCartoSubtitle => '© CARTO — Based on OpenStreetMap data';

  @override
  String get mapLicenseStadiaTitle => 'Stadia Maps / Stamen Design';

  @override
  String get mapLicenseStadiaSubtitle => '© Stadia Maps, © Stamen Design — CC BY 3.0 licence';

  @override
  String get mapLicenseEsriTitle => 'Esri (Satellite view)';

  @override
  String get mapLicenseEsriSubtitle => 'Tiles © Esri, Maxar, Earthstar Geographics and the GIS User Community';
}
