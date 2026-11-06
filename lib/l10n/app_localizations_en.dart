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
  String get notificationsSubtitle => 'Enable to consent to push notifications for friend requests and new friendships.';

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
  String get versionSubtitle => '—';

  @override
  String get versionSheetTitle => 'App version';

  @override
  String get versionSheetBody => 'Version metadata read from the installed app';

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
  String get socialLeaderboardEmpty => 'No scores available on the global leaderboard yet.';

  @override
  String get socialLeaderboard => 'Global leaderboard';

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
  String get loginTermsNoticePrefix => 'I accept the ';

  @override
  String get loginTermsLink => 'Terms of Service';

  @override
  String get loginTermsAnd => ' and acknowledge that I have read the ';

  @override
  String get loginPrivacyLink => 'Privacy Policy';

  @override
  String get loginAgeConfirmation => 'I confirm that I am at least 14 years old.';

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
  String get settingsNotifSubtitle => 'Enable to consent to push notifications for friend requests and new friendships.';

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
  String get poi_santa_cristina_desc => 'Commissioned by Pope Pius VII Chiaramonti, who was born in Cesena, and designed by architect Giuseppe Valadier, the church was built between 1816 and 1825 in the Neoclassical style. Its circular plan, inspired by the Pantheon, is one of the building’s most distinctive features. During the Second World War, the crypt was reinforced and made safe for use as an air-raid shelter with room for up to 200 people. Father Leo Bagnoli remembered it as a solid, dry space where civilians sought refuge during air-raid warnings and the bombings that struck Cesena in 1944.';

  @override
  String get poi_rocca_name => 'Malatestiana Fortress';

  @override
  String get poi_rocca_desc => 'Construction of the Rocca Nuova, or Malatestiana Fortress, began in 1380 under Galeotto Malatesta and continued under Malatesta Novello on Garampo hill. After losing its military function, the fortress became a prison and remained one until 1969. During the Nazi-Fascist occupation it continued to house the city\'s district prison; in 1944 the Resistance carried out two raids to free political prisoners. The nearby Sferisterio, in front of the fortress entrance, was the site where eight anti-Fascists were executed on 4 September 1944. During the 1940s, the fortress’s underground spaces were also used as a shelter. The separate public shelter for 800 people often associated with the Rocca was a tunnel excavated into the hill along Viale Mazzoni.';

  @override
  String get poi_san_rocco_name => 'Church of San Rocco';

  @override
  String get poi_san_rocco_desc => 'The parish of San Rocco in Cesena dates back to 1615. In the summer of 1944, Allied bombing aimed at disrupting the German retreat by attacking the Ponte Vecchio also struck the San Rocco district. The church opened its rooms to civilians seeking shelter, and its bell tower was adapted as an air-raid refuge. A makeshift blast shield was built by filling a wardrobe with sand and placing it in front of the door. The tower also carried a siren and a bell, which could warn residents when the electricity failed. The church was destroyed in 1944; the only surviving part of the original building is its nineteenth-century bell tower. The parish was later rebuilt across the River Savio, in the Campino area.';

  @override
  String get poi_abbazia_monte_name => 'Abbey of Santa Maria del Monte';

  @override
  String get poi_abbazia_monte_desc => 'The Benedictine Abbey of Santa Maria del Monte was founded at the beginning of the 11th century on the hill known as il Monte, south-east of Cesena. During the Second World War, the monks built an underground gallery accessible through a well and enlarged with chambers carved into the tuff. It sheltered about 700 displaced people fleeing air raids and roundups. Many books from the Malatestiana Library were also kept underground, while its most valuable manuscripts had been moved to the Modena area at the beginning of the conflict. The monk Odo Contestabile helped protect Jewish families and, in 1943, escorted two families towards the Swiss border; he was recognised as Righteous Among the Nations in 2019. Between 16 and 19 October 1944, repeated bombing struck the abbey: the church was gutted and part of the monastery collapsed. None of the displaced people sheltering in the complex were killed.';

  @override
  String get poi_osservanza_name => 'Church and Convent of the Osservanza';

  @override
  String get poi_osservanza_desc => 'The church of the Osservanza was built between 1459 and 1464 at the behest of Malatesta Novello and was associated with the Order of Friars Minor of the Observance. Its design was entrusted to master builder Maso della Val Lugano. During the Second World War, the complex also served as a place of civilian protection: two air-raid shelters were set up, one in the catacombs and one near the bell tower, with a combined capacity of about 200 people. The church did not escape the fighting around the Gothic Line: it was hit by Allied raids on 16 and 19 October 1944. Father Bosoni died during those raids and is remembered by a plaque in the catacombs.';

  @override
  String get poi_palazzo_ridotto_name => 'Palazzo del Ridotto';

  @override
  String get poi_palazzo_ridotto_desc => 'Palazzo del Ridotto faces Piazza Almerici and stands on an earlier medieval structure. Sources differ on its first building phase: Resistenza mAPPe describes a building from 1401–1403, enlarged between 1466 and 1472, while the regional catalogue dates the construction of the Conservatori palace to 1466–1472 on an earlier structure. Its name is linked to the meeting place of Cesena’s nobility in the 18th century. During the Second World War, an air-raid siren was installed on its tower as part of the city-wide warning system; church bells also provided a backup when the electricity failed. After the partisan attack of 18 January 1944 on the Fascist headquarters at Palazzo Fantaguzzi, the local offices of the Republican Fascist Party moved here. The palace was also used to detain and torture prisoners. A plaque placed in 1995 on the side facing Piazza Almerici commemorates the Jews of Cesena murdered in the Holocaust.';

  @override
  String get poi_stazione_name => 'Cesena Railway Station';

  @override
  String get poi_stazione_desc => 'Cesena’s first railway station opened in 1861. A plan for a larger station building was approved in 1919, and its foundation stone was laid in 1925. The Arrigoni food factory stood beside the railway yard, while the Montecatini refinery, which processed sulphur from the Perticara and Formignano mines, stood on the opposite side. This concentration of transport and industrial facilities made the area a strategic target. The first heavy air raid on the city took place on 13 May 1944; on 29 June a raid hit the railway yard, destroyed ammunition loads and set the refinery on fire. Further attacks followed in July, August and early September. During the Resistance, the station and railway lines were also targeted by partisan actions intended to disrupt supplies to the occupying army.';

  @override
  String get poi_arrigoni_name => 'Arrigoni Factory';

  @override
  String get poi_arrigoni_desc => 'The Arrigoni factory stood next to Cesena railway station. In 1927, Giorgio Sanguinetti, who managed the Arrigoni company in Trieste, acquired the former Consorzio Industrie Agrarie (CIA) and expanded its facilities. By the 1930s it had become the area’s leading food factory, employing about 5,000 people. The Cesena plant was known for jams, peeled tomatoes and dried minestrone. It was also a centre of local anti-Fascism: many workers opposed the regime through strikes, acts of sabotage and libertarian propaganda, and faced persecution. One of them was Werther Ricchi, who sent jam and other products to the partisans of the 8th Garibaldi Brigade after 8 September 1943. He was arrested on 23 March 1944 and tortured. As the front moved through the area, the workforce helped save a large part of the factory’s machinery.';

  @override
  String get poi_fantaguzzi_name => 'Palazzo Fantaguzzi';

  @override
  String get poi_fantaguzzi_desc => 'Palazzo Fantaguzzi stands on today’s Corso Gastone Sozzi, formerly Corso Umberto I, and has housed the Banca Popolare di Cesena since 1922. During the first months of the Italian Social Republic, part of the building also housed the local Fascist offices; the sources do not show that it served as the Fascist headquarters throughout the entire dictatorship. Because of the symbolic importance of that presence, the Cesena GAP planned an attack. On 18 January 1944, four partisans set off a bomb at the entrance. There were no casualties, but the building was seriously damaged. A few weeks later, the local Fascist headquarters moved to Palazzo del Ridotto. The distinction matters: the sources place the later detention and torture of prisoners at the Ridotto, not at Palazzo Fantaguzzi.';

  @override
  String get poi_rifugi_antiaerei_name => 'Air-Raid Shelters of the Fortress';

  @override
  String get poi_rifugi_antiaerei_desc => 'The Viale Mazzoni shelter was a public tunnel excavated into the Rocca hill in 1944, designed by Mario Tellerini, the municipal chief engineer. It could accommodate up to 800 people, with 290 seats. It had two entrances protected by blast walls and included an infirmary, rooms for firefighters and the shelter supervisor, toilets, lighting, water and a telephone; the Germans later removed the telephone. The ventilation shaft ended in the Parco della Rimembranza and could also be used as an emergency exit. An extension to increase capacity to 1,500 people was considered but never built: the first major air raid on Cesena, on 13 May 1944, began a long period of bombing. The gallery was separate from the Malatestiana Fortress itself.';

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
  String get quiz_fallback_name => 'Backup quiz';

  @override
  String get quiz_fallback_desc => 'The online quiz is temporarily unavailable. Here are three backup questions about this place.';

  @override
  String get quiz_santa_cristina_q1 => 'Which part of the church was adapted as an air-raid shelter?';

  @override
  String get quiz_santa_cristina_q1_o1 => 'The crypt';

  @override
  String get quiz_santa_cristina_q1_o2 => 'The bell tower';

  @override
  String get quiz_santa_cristina_q1_o3 => 'The cloister';

  @override
  String get quiz_santa_cristina_q2 => 'How many people could the crypt shelter accommodate?';

  @override
  String get quiz_santa_cristina_q2_o1 => 'Up to 200 people';

  @override
  String get quiz_santa_cristina_q2_o2 => 'About 700 people';

  @override
  String get quiz_santa_cristina_q2_o3 => 'Up to 800 people';

  @override
  String get quiz_rocca_q1 => 'Which function did the fortress retain during the Nazi-Fascist occupation?';

  @override
  String get quiz_rocca_q1_o1 => 'A prison';

  @override
  String get quiz_rocca_q1_o2 => 'A public air-raid shelter';

  @override
  String get quiz_rocca_q1_o3 => 'A field hospital';

  @override
  String get quiz_rocca_q2 => 'Why did the Resistance carry out two raids on the fortress in 1944?';

  @override
  String get quiz_rocca_q2_o1 => 'To free political prisoners';

  @override
  String get quiz_rocca_q2_o2 => 'To move the Arrigoni machinery';

  @override
  String get quiz_rocca_q2_o3 => 'To protect civilians from air raids';

  @override
  String get quiz_rocca_q3 => 'Where were eight anti-Fascists executed on 4 September 1944?';

  @override
  String get quiz_rocca_q3_o1 => 'At the Sferisterio, in front of the fortress entrance';

  @override
  String get quiz_rocca_q3_o2 => 'In the fortress courtyard';

  @override
  String get quiz_rocca_q3_o3 => 'At the railway station';

  @override
  String get quiz_san_rocco_q1 => 'Which part of the church of San Rocco was adapted as an air-raid shelter?';

  @override
  String get quiz_san_rocco_q1_o1 => 'The bell tower';

  @override
  String get quiz_san_rocco_q1_o2 => 'The crypt';

  @override
  String get quiz_san_rocco_q1_o3 => 'The sacristy';

  @override
  String get quiz_san_rocco_q2 => 'Which nearby target was attacked in an effort to hinder the German retreat?';

  @override
  String get quiz_san_rocco_q2_o1 => 'The Ponte Vecchio';

  @override
  String get quiz_san_rocco_q2_o2 => 'The Ponte Nuovo';

  @override
  String get quiz_san_rocco_q2_o3 => 'The railway station';

  @override
  String get quiz_abbazia_monte_q1 => 'About how many people took shelter in the abbey’s underground spaces during the war?';

  @override
  String get quiz_abbazia_monte_q1_o1 => 'About 700';

  @override
  String get quiz_abbazia_monte_q1_o2 => 'About 200';

  @override
  String get quiz_abbazia_monte_q1_o3 => 'About 800';

  @override
  String get quiz_abbazia_monte_q2 => 'What damage did the October 1944 bombing cause to the abbey?';

  @override
  String get quiz_abbazia_monte_q2_o1 => 'The church was gutted and part of the monastery collapsed';

  @override
  String get quiz_abbazia_monte_q2_o2 => 'Only the gardens were damaged';

  @override
  String get quiz_abbazia_monte_q2_o3 => 'The whole hill was evacuated but the buildings were unharmed';

  @override
  String get quiz_osservanza_q1 => 'Where were the two air-raid shelters at the Osservanza located?';

  @override
  String get quiz_osservanza_q1_o1 => 'In the catacombs and near the bell tower';

  @override
  String get quiz_osservanza_q1_o2 => 'In the cloister and the sacristy';

  @override
  String get quiz_osservanza_q1_o3 => 'Under the refectory and in the courtyard';

  @override
  String get quiz_osservanza_q2 => 'What was the combined capacity of the two Osservanza shelters?';

  @override
  String get quiz_osservanza_q2_o1 => 'About 200 people';

  @override
  String get quiz_osservanza_q2_o2 => 'About 700 people';

  @override
  String get quiz_osservanza_q2_o3 => 'About 800 people';

  @override
  String get quiz_palazzo_ridotto_q1 => 'What was the purpose of the siren installed on the tower of Palazzo del Ridotto?';

  @override
  String get quiz_palazzo_ridotto_q1_o1 => 'To warn people of air raids';

  @override
  String get quiz_palazzo_ridotto_q1_o2 => 'To regulate railway traffic';

  @override
  String get quiz_palazzo_ridotto_q1_o3 => 'To call municipal meetings';

  @override
  String get quiz_palazzo_ridotto_q2 => 'Which backup system could sound an alarm when the electricity failed?';

  @override
  String get quiz_palazzo_ridotto_q2_o1 => 'Church bells';

  @override
  String get quiz_palazzo_ridotto_q2_o2 => 'Square lighting';

  @override
  String get quiz_palazzo_ridotto_q2_o3 => 'Train whistles';

  @override
  String get quiz_stazione_q1 => 'Why was the railway station area considered strategic during the occupation?';

  @override
  String get quiz_stazione_q1_o1 => 'Because Arrigoni and the Montecatini refinery were nearby';

  @override
  String get quiz_stazione_q1_o2 => 'Because the Malatestiana Library was located there';

  @override
  String get quiz_stazione_q1_o3 => 'Because it housed the shelter of Santa Cristina church';

  @override
  String get quiz_stazione_q2 => 'How did the Resistance try to disrupt supplies to the occupying army?';

  @override
  String get quiz_stazione_q2_o1 => 'By targeting the station and railway lines';

  @override
  String get quiz_stazione_q2_o2 => 'By silencing the church bells';

  @override
  String get quiz_stazione_q2_o3 => 'By occupying Palazzo del Ridotto';

  @override
  String get quiz_arrigoni_q1 => 'Which products were characteristic of the Cesena plant?';

  @override
  String get quiz_arrigoni_q1_o1 => 'Jams, peeled tomatoes and dried minestrone';

  @override
  String get quiz_arrigoni_q1_o2 => 'Textiles, yarn and clothing';

  @override
  String get quiz_arrigoni_q1_o3 => 'Cars, bicycles and mechanical parts';

  @override
  String get quiz_arrigoni_q2 => 'How did Werther Ricchi support the Resistance after 8 September 1943?';

  @override
  String get quiz_arrigoni_q2_o1 => 'By getting Arrigoni products to the partisans of the 8th Garibaldi Brigade';

  @override
  String get quiz_arrigoni_q2_o2 => 'By supplying fuel to the Montecatini refinery';

  @override
  String get quiz_arrigoni_q2_o3 => 'By organising construction of the air-raid tunnel';

  @override
  String get quiz_fantaguzzi_q1 => 'Which institution had its headquarters at Palazzo Fantaguzzi from 1922?';

  @override
  String get quiz_fantaguzzi_q1_o1 => 'The Banca Popolare di Cesena';

  @override
  String get quiz_fantaguzzi_q1_o2 => 'The Malatestiana Library';

  @override
  String get quiz_fantaguzzi_q1_o3 => 'The town hall';

  @override
  String get quiz_fantaguzzi_q2 => 'What happened at the palace entrance on 18 January 1944?';

  @override
  String get quiz_fantaguzzi_q2_o1 => 'The GAP set off a bomb; there were no casualties';

  @override
  String get quiz_fantaguzzi_q2_o2 => 'An air raid destroyed the entire building';

  @override
  String get quiz_fantaguzzi_q2_o3 => 'An air-raid shelter was inaugurated';

  @override
  String get quiz_rifugi_antiaerei_q1 => 'How many people could the public tunnel in the Rocca hill shelter?';

  @override
  String get quiz_rifugi_antiaerei_q1_o1 => 'Up to 800 people';

  @override
  String get quiz_rifugi_antiaerei_q1_o2 => 'Up to 200 people';

  @override
  String get quiz_rifugi_antiaerei_q1_o3 => 'Up to 700 people';

  @override
  String get quiz_rifugi_antiaerei_q2 => 'Which part of the shelter could also serve as an emergency exit?';

  @override
  String get quiz_rifugi_antiaerei_q2_o1 => 'The ventilation shaft';

  @override
  String get quiz_rifugi_antiaerei_q2_o2 => 'The blast wall';

  @override
  String get quiz_rifugi_antiaerei_q2_o3 => 'The infirmary';

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
  String get onboardingSlide3Desc => 'Climb the global leaderboard and compare your progress with all explorers.';

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

  @override
  String get quiz_santa_cristina_q3 => 'How did Father Leo Bagnoli describe the shelter in the crypt?';

  @override
  String get quiz_santa_cristina_q3_o1 => 'As a solid and dry space';

  @override
  String get quiz_santa_cristina_q3_o2 => 'As an unstable and damp space';

  @override
  String get quiz_santa_cristina_q3_o3 => 'As a room with no access';

  @override
  String get quiz_san_rocco_q3 => 'Which part of the original church survived its destruction in 1944?';

  @override
  String get quiz_san_rocco_q3_o1 => 'The nineteenth-century bell tower';

  @override
  String get quiz_san_rocco_q3_o2 => 'The main façade';

  @override
  String get quiz_san_rocco_q3_o3 => 'The central nave';

  @override
  String get quiz_abbazia_monte_q3 => 'How did the monk Odo Contestabile help two Jewish families in 1943?';

  @override
  String get quiz_abbazia_monte_q3_o1 => 'He escorted them towards the Swiss border';

  @override
  String get quiz_abbazia_monte_q3_o2 => 'He hid them in the Rocca air-raid tunnel';

  @override
  String get quiz_abbazia_monte_q3_o3 => 'He moved them to the railway station';

  @override
  String get quiz_osservanza_q3 => 'Which event is associated with the October 1944 bombing of the Osservanza?';

  @override
  String get quiz_osservanza_q3_o1 => 'The death of Father Bosoni';

  @override
  String get quiz_osservanza_q3_o2 => 'The transfer of the Fascist offices';

  @override
  String get quiz_osservanza_q3_o3 => 'The destruction of the railway station';

  @override
  String get quiz_palazzo_ridotto_q3 => 'Why were the local offices of the Republican Fascist Party moved to the Ridotto?';

  @override
  String get quiz_palazzo_ridotto_q3_o1 => 'After the attack on the headquarters at Palazzo Fantaguzzi';

  @override
  String get quiz_palazzo_ridotto_q3_o2 => 'After the bombing of the abbey';

  @override
  String get quiz_palazzo_ridotto_q3_o3 => 'Because the railway station was closed';

  @override
  String get quiz_stazione_q3 => 'What happened during the air raid on the railway area on 29 June 1944?';

  @override
  String get quiz_stazione_q3_o1 => 'Ammunition loads were destroyed and Montecatini was set on fire';

  @override
  String get quiz_stazione_q3_o2 => 'The bell tower of San Rocco was destroyed';

  @override
  String get quiz_stazione_q3_o3 => 'The Abbey of Santa Maria del Monte was hit directly';

  @override
  String get quiz_arrigoni_q3 => 'What did Arrigoni workers do as the front moved through the area?';

  @override
  String get quiz_arrigoni_q3_o1 => 'They saved a large amount of the factory’s machinery';

  @override
  String get quiz_arrigoni_q3_o2 => 'They moved the railway station';

  @override
  String get quiz_arrigoni_q3_o3 => 'They built a shelter in San Rocco’s bell tower';

  @override
  String get quiz_fantaguzzi_q3 => 'Where were the local Fascist headquarters moved after the attack?';

  @override
  String get quiz_fantaguzzi_q3_o1 => 'To Palazzo del Ridotto';

  @override
  String get quiz_fantaguzzi_q3_o2 => 'To the Malatestiana Fortress';

  @override
  String get quiz_fantaguzzi_q3_o3 => 'To the railway station';

  @override
  String get quiz_rifugi_antiaerei_q3 => 'How were the two shelter entrances on Viale Mazzoni protected?';

  @override
  String get quiz_rifugi_antiaerei_q3_o1 => 'With blast-protection structures';

  @override
  String get quiz_rifugi_antiaerei_q3_o2 => 'With warning bells';

  @override
  String get quiz_rifugi_antiaerei_q3_o3 => 'With wooden doors filled with water';

  @override
  String get consentNotificationsTag => 'NOTIFICATIONS';

  @override
  String get consentNotificationsTitle => 'Stay up to date';

  @override
  String get consentNotificationsBody => 'Get an alert when someone sends you a friend request or you unlock a new achievement.';

  @override
  String get consentNotificationsNote => 'Notifications are optional and can be turned off at any time in Settings.';

  @override
  String get consentNotificationsAccept => 'Enable notifications';

  @override
  String get consentNotificationsDecline => 'Not now';

  @override
  String get consentLocationTag => 'LOCATION';

  @override
  String get consentLocationTitle => 'Discover Cesena, one stop at a time';

  @override
  String get consentLocationBody => 'Your location lets us show where you are on the map and guide you along the tours.';

  @override
  String get consentLocationNote => 'Android will ask for permission only after you choose to enable it. You can still use the app without GPS.';

  @override
  String get consentLocationAccept => 'Enable location';

  @override
  String get consentLocationDecline => 'Not now';

  @override
  String get consentDiagnosticsTag => 'OPTIONAL DIAGNOSTICS';

  @override
  String get consentDiagnosticsTitle => 'Help us improve the app';

  @override
  String get consentDiagnosticsBody => 'When an error occurs, you can send Firebase Crashlytics a technical report containing a stack trace, app version, device information and a technical installation identifier. This helps us find and fix problems.';

  @override
  String get consentDiagnosticsNote => 'This is optional: the app works normally without it. You can withdraw consent at any time in Settings.';

  @override
  String get consentDiagnosticsAccept => 'Share technical reports';

  @override
  String get consentDiagnosticsDecline => 'No, thanks';

  @override
  String get consentSaveError => 'We couldn\'t save your choice. Check your connection and try again.';

  @override
  String get settingsDiagnostics => 'Technical reports';

  @override
  String get settingsDiagnosticsSubtitle => 'Allow technical error reports to be sent through Firebase Crashlytics.';
}
