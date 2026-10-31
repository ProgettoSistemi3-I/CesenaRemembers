import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cesena Remembers 1945'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive WWII Tour'**
  String get settingsHeaderTitle;

  /// No description provided for @settingsHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage privacy, notifications and language in one place.'**
  String get settingsHeaderSubtitle;

  /// No description provided for @sectionCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get sectionCredits;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits & Acknowledgements'**
  String get creditsTitle;

  /// No description provided for @creditsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover the team behind Cesena Remembers'**
  String get creditsSubtitle;

  /// No description provided for @creditsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Acknowledgements'**
  String get creditsPageTitle;

  /// No description provided for @creditsAppName.
  ///
  /// In en, this message translates to:
  /// **'Cesena Remembers'**
  String get creditsAppName;

  /// No description provided for @creditsAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Made with passion to preserve the historical memory of our city.'**
  String get creditsAppDescription;

  /// No description provided for @sectionTeam.
  ///
  /// In en, this message translates to:
  /// **'The Team'**
  String get sectionTeam;

  /// No description provided for @sectionThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks'**
  String get sectionThanks;

  /// No description provided for @creditRoleDev.
  ///
  /// In en, this message translates to:
  /// **'Development & Architecture'**
  String get creditRoleDev;

  /// No description provided for @creditRoleGraphicsMarketing.
  ///
  /// In en, this message translates to:
  /// **'Graphics & Marketing'**
  String get creditRoleGraphicsMarketing;

  /// No description provided for @creditRoleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Supervising Teacher'**
  String get creditRoleTeacher;

  /// No description provided for @creditRoleClass.
  ///
  /// In en, this message translates to:
  /// **'Support & Ideation'**
  String get creditRoleClass;

  /// No description provided for @creditSchoolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visit the school website'**
  String get creditSchoolSubtitle;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of the current account'**
  String get logoutSubtitle;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out...'**
  String get loggingOut;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove profile and associated data'**
  String get deleteAccountSubtitle;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deletingAccount;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This action permanently removes the account, progress and all associated data.'**
  String get deleteAccountDialogBody;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account permanently deleted.'**
  String get deleteAccountSuccess;

  /// No description provided for @deleteAccountFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not complete now. Check the error message.'**
  String get deleteAccountFailure;

  /// No description provided for @sectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get sectionPreferences;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts on stops and rewards'**
  String get notificationsSubtitle;

  /// No description provided for @darkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Night Mode'**
  String get darkModeTitle;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dark theme for the entire app'**
  String get darkModeSubtitle;

  /// No description provided for @sectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get sectionPrivacy;

  /// No description provided for @gpsTitle.
  ///
  /// In en, this message translates to:
  /// **'GPS Location'**
  String get gpsTitle;

  /// No description provided for @gpsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Required to explore the map'**
  String get gpsSubtitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read how your data is handled'**
  String get privacyPolicySubtitle;

  /// No description provided for @gpsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied or GPS disabled. Check your phone settings.'**
  String get gpsPermissionDenied;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @sectionInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get sectionInfo;

  /// No description provided for @versionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionTitle;

  /// No description provided for @versionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get versionSubtitle;

  /// No description provided for @versionSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get versionSheetTitle;

  /// No description provided for @versionSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Build number: 1.0.0'**
  String get versionSheetBody;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsTitle;

  /// No description provided for @termsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Usage rules and responsibilities'**
  String get termsSubtitle;

  /// No description provided for @contactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contactsTitle;

  /// No description provided for @contactsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'cesenaremembers@gmail.com'**
  String get contactsSubtitle;

  /// No description provided for @buttonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonOk.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get buttonOk;

  /// No description provided for @buttonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// No description provided for @notificationOpenAction.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get notificationOpenAction;

  /// No description provided for @notificationFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationFallbackTitle;

  /// No description provided for @bannedAccountError.
  ///
  /// In en, this message translates to:
  /// **'This account has been suspended.'**
  String get bannedAccountError;

  /// No description provided for @bannedOverlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspended account'**
  String get bannedOverlayTitle;

  /// No description provided for @bannedOverlayMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended for violating\nterms of service.\nContact support for more information.\nEmail: cesenaremembers@gmail.com'**
  String get bannedOverlayMessage;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @errorLoadPreferences.
  ///
  /// In en, this message translates to:
  /// **'Error loading preferences: {error}'**
  String errorLoadPreferences(String error);

  /// No description provided for @errorConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Change cancelled.'**
  String get errorConnection;

  /// No description provided for @errorLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout failed.'**
  String errorLogout(String error);

  /// No description provided for @errorDeleteAccountPartial.
  ///
  /// In en, this message translates to:
  /// **'Account not fully deleted. App data was removed, but auth deletion failed. You will be signed out for safety.'**
  String get errorDeleteAccountPartial;

  /// No description provided for @errorDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete data: {error}'**
  String errorDeleteData(String error);

  /// No description provided for @errorLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile.'**
  String get errorLoadProfile;

  /// No description provided for @errorOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed. State restored.'**
  String get errorOperationFailed;

  /// No description provided for @tourStopped.
  ///
  /// In en, this message translates to:
  /// **'Tour stopped.'**
  String get tourStopped;

  /// No description provided for @errorSaveScore.
  ///
  /// In en, this message translates to:
  /// **'Error saving score. Try again in a moment.'**
  String get errorSaveScore;

  /// No description provided for @errorLoadPoi.
  ///
  /// In en, this message translates to:
  /// **'Error loading points of interest.'**
  String get errorLoadPoi;

  /// No description provided for @errorSearch.
  ///
  /// In en, this message translates to:
  /// **'Error during search.'**
  String get errorSearch;

  /// No description provided for @errorAction.
  ///
  /// In en, this message translates to:
  /// **'Error performing action.'**
  String get errorAction;

  /// No description provided for @removeFriendship.
  ///
  /// In en, this message translates to:
  /// **'Remove friendship'**
  String get removeFriendship;

  /// No description provided for @locationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location disabled'**
  String get locationDisabled;

  /// No description provided for @quizAnswerPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect!'**
  String get quizAnswerPerfect;

  /// No description provided for @quizAnswerGood.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get quizAnswerGood;

  /// No description provided for @toursCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tours Completed'**
  String get toursCompleted;

  /// No description provided for @tourLabel.
  ///
  /// In en, this message translates to:
  /// **'Tour'**
  String get tourLabel;

  /// No description provided for @tourConfirmStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop the tour?'**
  String get tourConfirmStopTitle;

  /// No description provided for @tourConfirmStopBody.
  ///
  /// In en, this message translates to:
  /// **'The tour will be ended and you will lose the current stop order.'**
  String get tourConfirmStopBody;

  /// No description provided for @buttonStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get buttonStop;

  /// No description provided for @tourStartGpsRequired.
  ///
  /// In en, this message translates to:
  /// **'To start the tour, enable GPS, location permission and the in-app option.'**
  String get tourStartGpsRequired;

  /// No description provided for @tourCompleted.
  ///
  /// In en, this message translates to:
  /// **'🎉 Tour completed! Great job.'**
  String get tourCompleted;

  /// No description provided for @tourStopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop tour'**
  String get tourStopButton;

  /// No description provided for @tourOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Order stops'**
  String get tourOrderButton;

  /// No description provided for @mapTestAnimation.
  ///
  /// In en, this message translates to:
  /// **'Animation test'**
  String get mapTestAnimation;

  /// No description provided for @mapStyleStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get mapStyleStandard;

  /// No description provided for @mapStyleSatellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get mapStyleSatellite;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @sectionStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get sectionStatistics;

  /// No description provided for @sectionAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get sectionAchievements;

  /// No description provided for @statTotalXp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get statTotalXp;

  /// No description provided for @statBestTour.
  ///
  /// In en, this message translates to:
  /// **'Best tour (XP)'**
  String get statBestTour;

  /// No description provided for @statVisitedSites.
  ///
  /// In en, this message translates to:
  /// **'Sites Visited'**
  String get statVisitedSites;

  /// No description provided for @statBestTime.
  ///
  /// In en, this message translates to:
  /// **'Best time'**
  String get statBestTime;

  /// No description provided for @statAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get statAchievements;

  /// No description provided for @profileFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get profileFriends;

  /// No description provided for @profilePoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get profilePoints;

  /// No description provided for @profileNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests at the moment.'**
  String get profileNoRequests;

  /// No description provided for @profileYourFriends.
  ///
  /// In en, this message translates to:
  /// **'Your Friends'**
  String get profileYourFriends;

  /// No description provided for @profileFriendRequests.
  ///
  /// In en, this message translates to:
  /// **'Friend Requests'**
  String get profileFriendRequests;

  /// No description provided for @profileNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be {min}-{max} characters.'**
  String profileNameTooShort(int min, int max);

  /// No description provided for @profileNameOffensive.
  ///
  /// In en, this message translates to:
  /// **'The name contains forbidden terms.\nPlease choose a different one.'**
  String get profileNameOffensive;

  /// No description provided for @avatarPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your Avatar'**
  String get avatarPickerTitle;

  /// No description provided for @avatarPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your profile'**
  String get avatarPickerSubtitle;

  /// No description provided for @poiTabInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get poiTabInfo;

  /// No description provided for @poiTabQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get poiTabQuiz;

  /// No description provided for @poiSectionHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get poiSectionHistory;

  /// No description provided for @poiStartQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take the quiz for this stop →'**
  String get poiStartQuiz;

  /// No description provided for @poiNoQuiz.
  ///
  /// In en, this message translates to:
  /// **'No quiz available for this stop.'**
  String get poiNoQuiz;

  /// No description provided for @quizNextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next question →'**
  String get quizNextQuestion;

  /// No description provided for @quizFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish quiz →'**
  String get quizFinish;

  /// No description provided for @quizNextStop.
  ///
  /// In en, this message translates to:
  /// **'Next stop →'**
  String get quizNextStop;

  /// No description provided for @quizNotice.
  ///
  /// In en, this message translates to:
  /// **'Quiz notice'**
  String get quizNotice;

  /// No description provided for @quizCorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'{score} / {total} correct answers'**
  String quizCorrectAnswers(int score, int total);

  /// No description provided for @quizTime.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String quizTime(String time);

  /// No description provided for @quizQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizQuestion(int current, int total);

  /// No description provided for @tourStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start tour'**
  String get tourStartButton;

  /// No description provided for @tourStopCardArrived.
  ///
  /// In en, this message translates to:
  /// **'You arrived! Tap to open'**
  String get tourStopCardArrived;

  /// No description provided for @tourStopCardDistance.
  ///
  /// In en, this message translates to:
  /// **'{distance} · stop {index}/{total}'**
  String tourStopCardDistance(String distance, int index, int total);

  /// No description provided for @tourPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop order'**
  String get tourPlanTitle;

  /// No description provided for @tourPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag the handle to reorder the route.'**
  String get tourPlanSubtitle;

  /// No description provided for @tourPlanFirstStop.
  ///
  /// In en, this message translates to:
  /// **'First stop of the tour'**
  String get tourPlanFirstStop;

  /// No description provided for @tourPlanDistanceFromPrev.
  ///
  /// In en, this message translates to:
  /// **'{distance} from previous'**
  String tourPlanDistanceFromPrev(String distance);

  /// No description provided for @tourPlanCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get tourPlanCurrentLabel;

  /// No description provided for @locationBannerMissingPermission.
  ///
  /// In en, this message translates to:
  /// **'Missing permissions'**
  String get locationBannerMissingPermission;

  /// No description provided for @locationBannerGpsOff.
  ///
  /// In en, this message translates to:
  /// **'GPS Disabled'**
  String get locationBannerGpsOff;

  /// No description provided for @locationBannerEnableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable location to explore the map in real time.'**
  String get locationBannerEnableLocation;

  /// No description provided for @locationBannerReEnableLocation.
  ///
  /// In en, this message translates to:
  /// **'Re-enable location in settings to show your position on the map.'**
  String get locationBannerReEnableLocation;

  /// No description provided for @locationBannerResolve.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get locationBannerResolve;

  /// No description provided for @socialSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search user...'**
  String get socialSearchHint;

  /// No description provided for @socialLeaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add friends to see your leaderboard.'**
  String get socialLeaderboardEmpty;

  /// No description provided for @socialLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Friends leaderboard'**
  String get socialLeaderboard;

  /// No description provided for @socialNoUserFound.
  ///
  /// In en, this message translates to:
  /// **'No user found.'**
  String get socialNoUserFound;

  /// No description provided for @socialTypeMoreChars.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to search.'**
  String get socialTypeMoreChars;

  /// No description provided for @socialYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get socialYou;

  /// No description provided for @socialDefaultUsername.
  ///
  /// In en, this message translates to:
  /// **'user'**
  String get socialDefaultUsername;

  /// No description provided for @socialFriendsOf.
  ///
  /// In en, this message translates to:
  /// **'Friends of {name}'**
  String socialFriendsOf(String name);

  /// No description provided for @socialMustBeFriend.
  ///
  /// In en, this message translates to:
  /// **'You must be friends to view their friend list.'**
  String get socialMustBeFriend;

  /// No description provided for @socialRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get socialRequestSent;

  /// No description provided for @socialAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get socialAccept;

  /// No description provided for @socialReject.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get socialReject;

  /// No description provided for @socialAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Add as friend'**
  String get socialAddFriend;

  /// No description provided for @publicStatDetailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed Statistics'**
  String get publicStatDetailed;

  /// No description provided for @publicStatAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get publicStatAchievements;

  /// No description provided for @publicStatBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get publicStatBestScore;

  /// No description provided for @publicStatSites.
  ///
  /// In en, this message translates to:
  /// **'Sites Visited'**
  String get publicStatSites;

  /// No description provided for @publicStatQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quizzes Passed'**
  String get publicStatQuiz;

  /// No description provided for @publicStatBestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get publicStatBestTime;

  /// No description provided for @publicStatCorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct Answers'**
  String get publicStatCorrectAnswers;

  /// No description provided for @publicStatFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get publicStatFriends;

  /// No description provided for @publicStatPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get publicStatPoints;

  /// No description provided for @publicStatLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get publicStatLevel;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Check your connection and try again.'**
  String get errorLoginFailed;

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Check your Internet connection and try again.'**
  String get errorOffline;

  /// No description provided for @errorLoginGeneric.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again in a few seconds.'**
  String get errorLoginGeneric;

  /// No description provided for @loginGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN WITH GOOGLE'**
  String get loginGoogleButton;

  /// No description provided for @errorCommunication.
  ///
  /// In en, this message translates to:
  /// **'Error communicating with the server.'**
  String get errorCommunication;

  /// No description provided for @errorNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in.'**
  String get errorNotLoggedIn;

  /// No description provided for @errorLoadPrefs.
  ///
  /// In en, this message translates to:
  /// **'Error loading preferences.'**
  String get errorLoadPrefs;

  /// No description provided for @errorGpsDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied or GPS disabled. Check your settings.'**
  String get errorGpsDenied;

  /// No description provided for @errorConnectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Changes reverted.'**
  String get errorConnectionSettings;

  /// No description provided for @errorDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete data.'**
  String get errorDeleteAccount;

  /// No description provided for @errorDeleteAccountAuth.
  ///
  /// In en, this message translates to:
  /// **'Account not fully deleted. App data removed, but auth deletion failed. Logging out for security.'**
  String get errorDeleteAccountAuth;

  /// No description provided for @errorSyncProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to sync profile.'**
  String get errorSyncProfile;

  /// No description provided for @errorSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile.'**
  String get errorSaveProfile;

  /// No description provided for @errorLoadLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load leaderboard.'**
  String get errorLoadLeaderboard;

  /// No description provided for @settingsTourTitle.
  ///
  /// In en, this message translates to:
  /// **'WWII Interactive Tour'**
  String get settingsTourTitle;

  /// No description provided for @settingsTourSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage privacy, notifications, and language in one place.'**
  String get settingsTourSubtitle;

  /// No description provided for @settingsCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get settingsCredits;

  /// No description provided for @settingsCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits & Acknowledgements'**
  String get settingsCreditsTitle;

  /// No description provided for @settingsCreditsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover the team behind Cesena Remembers'**
  String get settingsCreditsSubtitle;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutInProgress.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get settingsLogoutInProgress;

  /// No description provided for @settingsLogoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of current account'**
  String get settingsLogoutSubtitle;

  /// No description provided for @settingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDelete;

  /// No description provided for @settingsDeleteInProgress.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get settingsDeleteInProgress;

  /// No description provided for @settingsDeleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove profile and associated data'**
  String get settingsDeleteSubtitle;

  /// No description provided for @settingsAppPrefs.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get settingsAppPrefs;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotifSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts for stops and rewards'**
  String get settingsNotifSubtitle;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dark theme for the entire app'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsGps.
  ///
  /// In en, this message translates to:
  /// **'GPS Location'**
  String get settingsGps;

  /// No description provided for @settingsGpsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Required to explore the map'**
  String get settingsGpsSubtitle;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read how your data is handled'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get settingsInfo;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTerms;

  /// No description provided for @settingsTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Usage rules and responsibilities'**
  String get settingsTermsSubtitle;

  /// No description provided for @settingsContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get settingsContacts;

  /// No description provided for @settingsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settingsClose;

  /// No description provided for @settingsPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get settingsPerfect;

  /// No description provided for @settingsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get settingsDeleteConfirmTitle;

  /// No description provided for @settingsDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This operation permanently removes your account, progress, and associated data.'**
  String get settingsDeleteConfirmBody;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsDeleteConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDeleteConfirmBtn;

  /// No description provided for @settingsDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account permanently deleted.'**
  String get settingsDeleteSuccess;

  /// No description provided for @settingsDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete now. Check the error message.'**
  String get settingsDeleteError;

  /// No description provided for @achievement_first_visit_title.
  ///
  /// In en, this message translates to:
  /// **'First Step'**
  String get achievement_first_visit_title;

  /// No description provided for @achievement_first_visit_desc.
  ///
  /// In en, this message translates to:
  /// **'Visit your first historical site'**
  String get achievement_first_visit_desc;

  /// No description provided for @achievement_first_quiz_title.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get achievement_first_quiz_title;

  /// No description provided for @achievement_first_quiz_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first quiz'**
  String get achievement_first_quiz_desc;

  /// No description provided for @achievement_first_tour_title.
  ///
  /// In en, this message translates to:
  /// **'Pioneer'**
  String get achievement_first_tour_title;

  /// No description provided for @achievement_first_tour_desc.
  ///
  /// In en, this message translates to:
  /// **'Finish your first complete tour'**
  String get achievement_first_tour_desc;

  /// No description provided for @achievement_quiz_15_title.
  ///
  /// In en, this message translates to:
  /// **'Veteran'**
  String get achievement_quiz_15_title;

  /// No description provided for @achievement_quiz_15_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 15 quizzes'**
  String get achievement_quiz_15_desc;

  /// No description provided for @achievement_perfect_tour_title.
  ///
  /// In en, this message translates to:
  /// **'Flawless'**
  String get achievement_perfect_tour_title;

  /// No description provided for @achievement_perfect_tour_desc.
  ///
  /// In en, this message translates to:
  /// **'Answer all questions correctly in a tour'**
  String get achievement_perfect_tour_desc;

  /// No description provided for @achievement_xp_500_title.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get achievement_xp_500_title;

  /// No description provided for @achievement_xp_500_desc.
  ///
  /// In en, this message translates to:
  /// **'Reach 500 total XP'**
  String get achievement_xp_500_desc;

  /// No description provided for @achievement_tour_under_1h_title.
  ///
  /// In en, this message translates to:
  /// **'On the March'**
  String get achievement_tour_under_1h_title;

  /// No description provided for @achievement_tour_under_1h_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete a tour in under 1 hour'**
  String get achievement_tour_under_1h_desc;

  /// No description provided for @achievement_tour_under_30m_title.
  ///
  /// In en, this message translates to:
  /// **'Lightning'**
  String get achievement_tour_under_30m_title;

  /// No description provided for @achievement_tour_under_30m_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete a tour in under 30 minutes'**
  String get achievement_tour_under_30m_desc;

  /// No description provided for @achievement_friend_1_title.
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get achievement_friend_1_title;

  /// No description provided for @achievement_friend_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Add your first friend'**
  String get achievement_friend_1_desc;

  /// No description provided for @achievement_friend_5_title.
  ///
  /// In en, this message translates to:
  /// **'Historical Circle'**
  String get achievement_friend_5_title;

  /// No description provided for @achievement_friend_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Reach 5 friends'**
  String get achievement_friend_5_desc;

  /// No description provided for @poi_santa_cristina_name.
  ///
  /// In en, this message translates to:
  /// **'Church of Santa Cristina'**
  String get poi_santa_cristina_name;

  /// No description provided for @poi_santa_cristina_desc.
  ///
  /// In en, this message translates to:
  /// **'The church of Santa Cristina was commissioned by Pope Pius VII Chiaramonti and designed by architect Giuseppe Valadier. Construction began in 1816 and ended in 1825; the building is Neoclassical. During the Second World War, the crypt was reinforced and made usable as an air-raid shelter, with capacity for up to 200 people.'**
  String get poi_santa_cristina_desc;

  /// No description provided for @poi_rocca_name.
  ///
  /// In en, this message translates to:
  /// **'Malatestiana Fortress'**
  String get poi_rocca_name;

  /// No description provided for @poi_rocca_desc.
  ///
  /// In en, this message translates to:
  /// **'Construction of the Rocca Nuova, also known as the Malatestiana Fortress, began in 1380 on the initiative of Galeotto Malatesta and continued under Malatesta Novello; it was completed in the late 1470s. In 1502 Cesare Borgia brought Leonardo da Vinci to Cesena to survey the defences of the conquered cities. After losing its military role, the fortress became a prison and remained one until 1969. The public air-raid shelters built in 1944 were at the foot of the hill along Viale Mazzoni, not inside the fortress.'**
  String get poi_rocca_desc;

  /// No description provided for @poi_san_rocco_name.
  ///
  /// In en, this message translates to:
  /// **'Church of San Rocco'**
  String get poi_san_rocco_name;

  /// No description provided for @poi_san_rocco_desc.
  ///
  /// In en, this message translates to:
  /// **'The parish of San Rocco in Cesena dates back to 1615. In the summer of 1944, the church made its indoor rooms available to people fleeing the bombings, and a shelter was set up in the bell tower. The church was destroyed by the 1944 bombings together with the neighbourhood; only its nineteenth-century bell tower remains today.'**
  String get poi_san_rocco_desc;

  /// No description provided for @poi_abbazia_monte_name.
  ///
  /// In en, this message translates to:
  /// **'Abbey of Santa Maria del Monte'**
  String get poi_abbazia_monte_name;

  /// No description provided for @poi_abbazia_monte_desc.
  ///
  /// In en, this message translates to:
  /// **'The Benedictine abbey of Santa Maria del Monte was founded at the beginning of the 11th century on the hill known as “il Monte”, south-east of Cesena. During the Second World War it sheltered about seven hundred displaced people in its cellars and tunnel. Between 16 and 19 October 1944 it was hit repeatedly and directly by bombing: the church was gutted and part of the monastery collapsed. None of the displaced people sheltering in the abbey were killed.'**
  String get poi_abbazia_monte_desc;

  /// No description provided for @poi_osservanza_name.
  ///
  /// In en, this message translates to:
  /// **'Church and Convent of the Osservanza'**
  String get poi_osservanza_name;

  /// No description provided for @poi_osservanza_desc.
  ///
  /// In en, this message translates to:
  /// **'The church of the Osservanza was built between 1459 and 1464 at the behest of Malatesta Novello and is linked to the Order of Friars Minor of the Observance. During the Second World War, two air-raid shelters were set up there, in the catacombs and near the bell tower, with a combined capacity of about 200 people. The church was hit by Allied bombing on 16 and 19 October 1944; Father Bosoni died during the raids.'**
  String get poi_osservanza_desc;

  /// No description provided for @poi_palazzo_ridotto_name.
  ///
  /// In en, this message translates to:
  /// **'Palazzo del Ridotto'**
  String get poi_palazzo_ridotto_name;

  /// No description provided for @poi_palazzo_ridotto_desc.
  ///
  /// In en, this message translates to:
  /// **'Palazzo del Ridotto stands in Piazza Almerici and was built between 1466 and 1472 as the seat of the municipal authority known as the Conservatori. During the Second World War, an alarm siren was installed on its tower as part of a city-wide warning system, backed up by church bells in the event of a power cut. After the 18 January 1944 attack on the Fascist headquarters in Corso Umberto I, the offices of the Republican Fascist Party moved to the palace, which was also used to detain and torture prisoners.'**
  String get poi_palazzo_ridotto_desc;

  /// No description provided for @poi_stazione_name.
  ///
  /// In en, this message translates to:
  /// **'Cesena Railway Station'**
  String get poi_stazione_name;

  /// No description provided for @poi_stazione_desc.
  ///
  /// In en, this message translates to:
  /// **'Cesena’s first railway station opened in 1861. In 1919 a plan for a larger station building was approved, and the foundation stone of the new station was laid in 1925. The Arrigoni food factory stood next to it, while the Montecatini refinery stood on the opposite side. Because these facilities were close together, the area became a target of Allied bombing after the German occupation. On 29 June 1944 an air raid hit the railway yard, destroyed ammunition loads and set the refinery on fire; further raids followed between July and September.'**
  String get poi_stazione_desc;

  /// No description provided for @poi_arrigoni_name.
  ///
  /// In en, this message translates to:
  /// **'Arrigoni Factory'**
  String get poi_arrigoni_name;

  /// No description provided for @poi_arrigoni_desc.
  ///
  /// In en, this message translates to:
  /// **'The Arrigoni factory in Cesena stood next to the railway station and became the group’s leading plant for jams, peeled tomatoes and dried minestrone. Over time it employed thousands of people from Cesena and became a centre of local anti-Fascism. Worker Werther Ricchi was employed there before 25 July 1943 and, after 8 September, sent jam and other Arrigoni products to the partisans of the 8th Garibaldi Brigade. He was arrested on 23 March 1944 and tortured.'**
  String get poi_arrigoni_desc;

  /// No description provided for @poi_fantaguzzi_name.
  ///
  /// In en, this message translates to:
  /// **'Palazzo Fantaguzzi'**
  String get poi_fantaguzzi_name;

  /// No description provided for @poi_fantaguzzi_desc.
  ///
  /// In en, this message translates to:
  /// **'Palazzo Fantaguzzi stands in Corso Gastone Sozzi, formerly Corso Umberto I, and has housed the Banca Popolare di Cesena since 1922. During the first months of the Italian Social Republic, part of the building also housed the local Fascist offices. On 18 January 1944 a GAP commando detonated a bomb at the entrance to the Fascist headquarters: there were no casualties, but the building was badly damaged. A few weeks later the Fascist headquarters moved to Palazzo del Ridotto.'**
  String get poi_fantaguzzi_desc;

  /// No description provided for @poi_rifugi_antiaerei_name.
  ///
  /// In en, this message translates to:
  /// **'Air-Raid Shelters of the Fortress'**
  String get poi_rifugi_antiaerei_name;

  /// No description provided for @poi_rifugi_antiaerei_desc.
  ///
  /// In en, this message translates to:
  /// **'In January 1944, the decision was made to excavate a tunnel in the Rocca hill to create a public air-raid shelter. The tunnel was newly built in 1944 by the city’s chief engineer, Mario Tellerini, and could accommodate 800 people, 290 of them seated. It had two entrances on Viale Mazzoni protected by a blast wall; its ventilation shaft could also serve as an emergency exit.'**
  String get poi_rifugi_antiaerei_desc;

  /// No description provided for @setupUsernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid username (use {min}-{max} characters: a-z, 0-9, _ or .).'**
  String setupUsernameInvalid(int min, int max);

  /// No description provided for @setupUsernameOffensive.
  ///
  /// In en, this message translates to:
  /// **'Username contains prohibited terms. Please choose another.'**
  String get setupUsernameOffensive;

  /// No description provided for @setupUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken. Please choose another.'**
  String get setupUsernameTaken;

  /// No description provided for @setupFirestoreError.
  ///
  /// In en, this message translates to:
  /// **'Invalid Firestore configuration: read/write permissions required on usernames/{username}.'**
  String setupFirestoreError(Object username);

  /// No description provided for @setupPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Firestore permissions to complete the profile. Check project rules.'**
  String get setupPermissionDenied;

  /// No description provided for @setupGenericError.
  ///
  /// In en, this message translates to:
  /// **'Unable to save profile. Please try again in a few seconds.'**
  String get setupGenericError;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your profile'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a unique username (cannot be changed), display name, and avatar.'**
  String get setupSubtitle;

  /// No description provided for @setupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get setupNameLabel;

  /// No description provided for @setupUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get setupUsernameLabel;

  /// No description provided for @setupUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., cesena_explorer'**
  String get setupUsernameHint;

  /// No description provided for @setupAvatarLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose avatar'**
  String get setupAvatarLabel;

  /// No description provided for @setupSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Profile'**
  String get setupSubmitButton;

  /// No description provided for @creditRoleDiplo.
  ///
  /// In en, this message translates to:
  /// **'German Diplomatic Missions in Italy'**
  String get creditRoleDiplo;

  /// No description provided for @creditRoleDiploDesc.
  ///
  /// In en, this message translates to:
  /// **'Developed with their valuable contribution'**
  String get creditRoleDiploDesc;

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Collaborators and Support'**
  String get sectionSupport;

  /// No description provided for @quiz_fallback_name.
  ///
  /// In en, this message translates to:
  /// **'Standard difficulty (local seed)'**
  String get quiz_fallback_name;

  /// No description provided for @quiz_fallback_desc.
  ///
  /// In en, this message translates to:
  /// **'Due to a server error, questions are not personalized and use a specific local difficulty.'**
  String get quiz_fallback_desc;

  /// No description provided for @quiz_santa_cristina_q1.
  ///
  /// In en, this message translates to:
  /// **'Who designed the church of Santa Cristina?'**
  String get quiz_santa_cristina_q1;

  /// No description provided for @quiz_santa_cristina_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'Architect Giuseppe Valadier'**
  String get quiz_santa_cristina_q1_o1;

  /// No description provided for @quiz_santa_cristina_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'Francesco Morandi, known as il Terribilia'**
  String get quiz_santa_cristina_q1_o2;

  /// No description provided for @quiz_santa_cristina_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'Leandro Marconi'**
  String get quiz_santa_cristina_q1_o3;

  /// No description provided for @quiz_santa_cristina_q2.
  ///
  /// In en, this message translates to:
  /// **'How many people could the crypt shelter?'**
  String get quiz_santa_cristina_q2;

  /// No description provided for @quiz_santa_cristina_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'Up to 200 people'**
  String get quiz_santa_cristina_q2_o1;

  /// No description provided for @quiz_santa_cristina_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'About 700 people'**
  String get quiz_santa_cristina_q2_o2;

  /// No description provided for @quiz_santa_cristina_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'Up to 800 people'**
  String get quiz_santa_cristina_q2_o3;

  /// No description provided for @quiz_rocca_q1.
  ///
  /// In en, this message translates to:
  /// **'In what year did construction of the Rocca Nuova begin?'**
  String get quiz_rocca_q1;

  /// No description provided for @quiz_rocca_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'1380'**
  String get quiz_rocca_q1_o1;

  /// No description provided for @quiz_rocca_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'1464'**
  String get quiz_rocca_q1_o2;

  /// No description provided for @quiz_rocca_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'1502'**
  String get quiz_rocca_q1_o3;

  /// No description provided for @quiz_rocca_q2.
  ///
  /// In en, this message translates to:
  /// **'Who brought Leonardo da Vinci to Cesena in 1502?'**
  String get quiz_rocca_q2;

  /// No description provided for @quiz_rocca_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'Malatesta Novello'**
  String get quiz_rocca_q2_o1;

  /// No description provided for @quiz_rocca_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'Cesare Borgia'**
  String get quiz_rocca_q2_o2;

  /// No description provided for @quiz_rocca_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'Frederick Barbarossa'**
  String get quiz_rocca_q2_o3;

  /// No description provided for @quiz_rocca_q3.
  ///
  /// In en, this message translates to:
  /// **'Until what year was the fortress used as a prison?'**
  String get quiz_rocca_q3;

  /// No description provided for @quiz_rocca_q3_o1.
  ///
  /// In en, this message translates to:
  /// **'1944'**
  String get quiz_rocca_q3_o1;

  /// No description provided for @quiz_rocca_q3_o2.
  ///
  /// In en, this message translates to:
  /// **'1969'**
  String get quiz_rocca_q3_o2;

  /// No description provided for @quiz_rocca_q3_o3.
  ///
  /// In en, this message translates to:
  /// **'1974'**
  String get quiz_rocca_q3_o3;

  /// No description provided for @quiz_san_rocco_q1.
  ///
  /// In en, this message translates to:
  /// **'What year does the parish of San Rocco date back to?'**
  String get quiz_san_rocco_q1;

  /// No description provided for @quiz_san_rocco_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'1615'**
  String get quiz_san_rocco_q1_o1;

  /// No description provided for @quiz_san_rocco_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'1816'**
  String get quiz_san_rocco_q1_o2;

  /// No description provided for @quiz_san_rocco_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'1944'**
  String get quiz_san_rocco_q1_o3;

  /// No description provided for @quiz_san_rocco_q2.
  ///
  /// In en, this message translates to:
  /// **'Which part of the historic church remains today?'**
  String get quiz_san_rocco_q2;

  /// No description provided for @quiz_san_rocco_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'The nineteenth-century bell tower'**
  String get quiz_san_rocco_q2_o1;

  /// No description provided for @quiz_san_rocco_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'The main façade'**
  String get quiz_san_rocco_q2_o2;

  /// No description provided for @quiz_san_rocco_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'The crypt'**
  String get quiz_san_rocco_q2_o3;

  /// No description provided for @quiz_abbazia_monte_q1.
  ///
  /// In en, this message translates to:
  /// **'In which century was the Abbey of Santa Maria del Monte founded?'**
  String get quiz_abbazia_monte_q1;

  /// No description provided for @quiz_abbazia_monte_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'At the beginning of the 11th century'**
  String get quiz_abbazia_monte_q1_o1;

  /// No description provided for @quiz_abbazia_monte_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'In the 15th century'**
  String get quiz_abbazia_monte_q1_o2;

  /// No description provided for @quiz_abbazia_monte_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'In the 18th century'**
  String get quiz_abbazia_monte_q1_o3;

  /// No description provided for @quiz_abbazia_monte_q2.
  ///
  /// In en, this message translates to:
  /// **'About how many displaced people did the abbey shelter during the war?'**
  String get quiz_abbazia_monte_q2;

  /// No description provided for @quiz_abbazia_monte_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'About 200'**
  String get quiz_abbazia_monte_q2_o1;

  /// No description provided for @quiz_abbazia_monte_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'About 500'**
  String get quiz_abbazia_monte_q2_o2;

  /// No description provided for @quiz_abbazia_monte_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'About 700'**
  String get quiz_abbazia_monte_q2_o3;

  /// No description provided for @quiz_osservanza_q1.
  ///
  /// In en, this message translates to:
  /// **'Between which years was the church of the Osservanza built?'**
  String get quiz_osservanza_q1;

  /// No description provided for @quiz_osservanza_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'1459–1464'**
  String get quiz_osservanza_q1_o1;

  /// No description provided for @quiz_osservanza_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'1472–1502'**
  String get quiz_osservanza_q1_o2;

  /// No description provided for @quiz_osservanza_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'1816–1825'**
  String get quiz_osservanza_q1_o3;

  /// No description provided for @quiz_osservanza_q2.
  ///
  /// In en, this message translates to:
  /// **'What happened to the church in October 1944?'**
  String get quiz_osservanza_q2;

  /// No description provided for @quiz_osservanza_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'It was hit by bombing and Father Bosoni was killed'**
  String get quiz_osservanza_q2_o1;

  /// No description provided for @quiz_osservanza_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'It remained unharmed throughout the air raids'**
  String get quiz_osservanza_q2_o2;

  /// No description provided for @quiz_osservanza_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'It was turned into an Allied hospital'**
  String get quiz_osservanza_q2_o3;

  /// No description provided for @quiz_palazzo_ridotto_q1.
  ///
  /// In en, this message translates to:
  /// **'Which square does Palazzo del Ridotto face?'**
  String get quiz_palazzo_ridotto_q1;

  /// No description provided for @quiz_palazzo_ridotto_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'Piazza Almerici'**
  String get quiz_palazzo_ridotto_q1_o1;

  /// No description provided for @quiz_palazzo_ridotto_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'Piazza del Popolo'**
  String get quiz_palazzo_ridotto_q1_o2;

  /// No description provided for @quiz_palazzo_ridotto_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'Piazza del Duomo'**
  String get quiz_palazzo_ridotto_q1_o3;

  /// No description provided for @quiz_palazzo_ridotto_q2.
  ///
  /// In en, this message translates to:
  /// **'Which warning device was installed on the tower during the war?'**
  String get quiz_palazzo_ridotto_q2;

  /// No description provided for @quiz_palazzo_ridotto_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'An air-raid siren'**
  String get quiz_palazzo_ridotto_q2_o1;

  /// No description provided for @quiz_palazzo_ridotto_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'A spotting radar'**
  String get quiz_palazzo_ridotto_q2_o2;

  /// No description provided for @quiz_palazzo_ridotto_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'A military radio'**
  String get quiz_palazzo_ridotto_q2_o3;

  /// No description provided for @quiz_stazione_q1.
  ///
  /// In en, this message translates to:
  /// **'In what year did Cesena’s first railway station open?'**
  String get quiz_stazione_q1;

  /// No description provided for @quiz_stazione_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'1861'**
  String get quiz_stazione_q1_o1;

  /// No description provided for @quiz_stazione_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'1919'**
  String get quiz_stazione_q1_o2;

  /// No description provided for @quiz_stazione_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'1925'**
  String get quiz_stazione_q1_o3;

  /// No description provided for @quiz_stazione_q2.
  ///
  /// In en, this message translates to:
  /// **'On what date did an air raid hit Cesena’s railway yard?'**
  String get quiz_stazione_q2;

  /// No description provided for @quiz_stazione_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'29 June 1944'**
  String get quiz_stazione_q2_o1;

  /// No description provided for @quiz_stazione_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'25 July 1944'**
  String get quiz_stazione_q2_o2;

  /// No description provided for @quiz_stazione_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'20 October 1944'**
  String get quiz_stazione_q2_o3;

  /// No description provided for @quiz_arrigoni_q1.
  ///
  /// In en, this message translates to:
  /// **'In which sectors was the Cesena Arrigoni plant the group’s leading factory?'**
  String get quiz_arrigoni_q1;

  /// No description provided for @quiz_arrigoni_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'Jams, peeled tomatoes and dried minestrone'**
  String get quiz_arrigoni_q1_o1;

  /// No description provided for @quiz_arrigoni_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'Textiles, yarn and clothing'**
  String get quiz_arrigoni_q1_o2;

  /// No description provided for @quiz_arrigoni_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'Engineering, cars and bicycles'**
  String get quiz_arrigoni_q1_o3;

  /// No description provided for @quiz_arrigoni_q2.
  ///
  /// In en, this message translates to:
  /// **'Which anti-Fascist worker was employed at the Arrigoni factory?'**
  String get quiz_arrigoni_q2;

  /// No description provided for @quiz_arrigoni_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'Werther Ricchi'**
  String get quiz_arrigoni_q2_o1;

  /// No description provided for @quiz_arrigoni_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'Mario Tellerini'**
  String get quiz_arrigoni_q2_o2;

  /// No description provided for @quiz_arrigoni_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'Father Bosoni'**
  String get quiz_arrigoni_q2_o3;

  /// No description provided for @quiz_fantaguzzi_q1.
  ///
  /// In en, this message translates to:
  /// **'Since what year has Palazzo Fantaguzzi housed the Banca Popolare di Cesena?'**
  String get quiz_fantaguzzi_q1;

  /// No description provided for @quiz_fantaguzzi_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'Since 1922'**
  String get quiz_fantaguzzi_q1_o1;

  /// No description provided for @quiz_fantaguzzi_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'Since 1944'**
  String get quiz_fantaguzzi_q1_o2;

  /// No description provided for @quiz_fantaguzzi_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'Since 1970'**
  String get quiz_fantaguzzi_q1_o3;

  /// No description provided for @quiz_fantaguzzi_q2.
  ///
  /// In en, this message translates to:
  /// **'During which period did part of the palace house the local Fascist offices?'**
  String get quiz_fantaguzzi_q2;

  /// No description provided for @quiz_fantaguzzi_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'Throughout the twenty-year Fascist period'**
  String get quiz_fantaguzzi_q2_o1;

  /// No description provided for @quiz_fantaguzzi_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'During the first months of the Italian Social Republic'**
  String get quiz_fantaguzzi_q2_o2;

  /// No description provided for @quiz_fantaguzzi_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'After the city’s liberation in 1944'**
  String get quiz_fantaguzzi_q2_o3;

  /// No description provided for @quiz_rifugi_antiaerei_q1.
  ///
  /// In en, this message translates to:
  /// **'When was the decision made to excavate the air-raid tunnel in the Rocca hill?'**
  String get quiz_rifugi_antiaerei_q1;

  /// No description provided for @quiz_rifugi_antiaerei_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'January 1944'**
  String get quiz_rifugi_antiaerei_q1_o1;

  /// No description provided for @quiz_rifugi_antiaerei_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'June 1941'**
  String get quiz_rifugi_antiaerei_q1_o2;

  /// No description provided for @quiz_rifugi_antiaerei_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'October 1944'**
  String get quiz_rifugi_antiaerei_q1_o3;

  /// No description provided for @quiz_rifugi_antiaerei_q2.
  ///
  /// In en, this message translates to:
  /// **'How many people could the Rocca shelter accommodate?'**
  String get quiz_rifugi_antiaerei_q2;

  /// No description provided for @quiz_rifugi_antiaerei_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'200 people'**
  String get quiz_rifugi_antiaerei_q2_o1;

  /// No description provided for @quiz_rifugi_antiaerei_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'500 people'**
  String get quiz_rifugi_antiaerei_q2_o2;

  /// No description provided for @quiz_rifugi_antiaerei_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'800 people, 290 of them seated'**
  String get quiz_rifugi_antiaerei_q2_o3;

  /// XP gained badge shown in the tour completion animation
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP earned'**
  String tourCompletionXpGained(int xp);

  /// No description provided for @notificationNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications at the moment.'**
  String get notificationNoNotifications;

  /// No description provided for @notificationAchievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get notificationAchievementUnlocked;

  /// No description provided for @notificationFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'Friend request'**
  String get notificationFriendRequest;

  /// No description provided for @notificationRedeemButton.
  ///
  /// In en, this message translates to:
  /// **'REDEEM'**
  String get notificationRedeemButton;

  /// No description provided for @achievementUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'UNLOCK'**
  String get achievementUnlockButton;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start exploring'**
  String get onboardingStart;

  /// No description provided for @onboardingSlide0Tag.
  ///
  /// In en, this message translates to:
  /// **'WELCOME'**
  String get onboardingSlide0Tag;

  /// No description provided for @onboardingSlide0Title.
  ///
  /// In en, this message translates to:
  /// **'Cesena\nRemembers'**
  String get onboardingSlide0Title;

  /// No description provided for @onboardingSlide0Desc.
  ///
  /// In en, this message translates to:
  /// **'Explore the places that shaped the history of Cesena. A journey through memories, quizzes and people.'**
  String get onboardingSlide0Desc;

  /// No description provided for @onboardingSlide1Tag.
  ///
  /// In en, this message translates to:
  /// **'01 — TOUR'**
  String get onboardingSlide1Tag;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Follow\nthe route'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Desc.
  ///
  /// In en, this message translates to:
  /// **'Start a guided tour and walk through historical sites. GPS guides you step by step.'**
  String get onboardingSlide1Desc;

  /// No description provided for @onboardingSlide2Tag.
  ///
  /// In en, this message translates to:
  /// **'02 — QUIZ'**
  String get onboardingSlide2Tag;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Put yourself\nto the test'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Desc.
  ///
  /// In en, this message translates to:
  /// **'Answer questions about each location. The more accurate you are, the more XP you earn.'**
  String get onboardingSlide2Desc;

  /// No description provided for @onboardingSlide3Tag.
  ///
  /// In en, this message translates to:
  /// **'03 — LEADERBOARD'**
  String get onboardingSlide3Tag;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Climb\nthe top'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Desc.
  ///
  /// In en, this message translates to:
  /// **'Compare your progress with your friends.'**
  String get onboardingSlide3Desc;

  /// No description provided for @onboardingSlide4Tag.
  ///
  /// In en, this message translates to:
  /// **'04 — ACHIEVEMENTS'**
  String get onboardingSlide4Tag;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In en, this message translates to:
  /// **'Collect\nbadges'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingSlide4Desc.
  ///
  /// In en, this message translates to:
  /// **'Every milestone unlocks an exclusive badge. Complete tours, ace quizzes and make friends.'**
  String get onboardingSlide4Desc;

  /// No description provided for @quizResultPerfectTitle.
  ///
  /// In en, this message translates to:
  /// **'Perfect!'**
  String get quizResultPerfectTitle;

  /// No description provided for @quizResultPerfectBody.
  ///
  /// In en, this message translates to:
  /// **'Not a single mistake. A true history buff!'**
  String get quizResultPerfectBody;

  /// No description provided for @quizResultGreatTitle.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get quizResultGreatTitle;

  /// No description provided for @quizResultGreatBody.
  ///
  /// In en, this message translates to:
  /// **'You know this place well.'**
  String get quizResultGreatBody;

  /// No description provided for @quizResultGoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Good result!'**
  String get quizResultGoodTitle;

  /// No description provided for @quizResultGoodBody.
  ///
  /// In en, this message translates to:
  /// **'You got the main points. A little more and you\'ll master it.'**
  String get quizResultGoodBody;

  /// No description provided for @quizResultFairTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get quizResultFairTitle;

  /// No description provided for @quizResultFairBody.
  ///
  /// In en, this message translates to:
  /// **'Reread the history card and try again at the next stop.'**
  String get quizResultFairBody;

  /// No description provided for @quizResultPoorTitle.
  ///
  /// In en, this message translates to:
  /// **'Not this time'**
  String get quizResultPoorTitle;

  /// No description provided for @quizResultPoorBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry: history is learned one step at a time.'**
  String get quizResultPoorBody;

  /// No description provided for @tourXpEarned.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String tourXpEarned(int xp);

  /// No description provided for @speedBonusSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady pace! +{percent}% bonus'**
  String speedBonusSteady(int percent);

  /// No description provided for @speedBonusFast.
  ///
  /// In en, this message translates to:
  /// **'Brisk pace! +{percent}% bonus'**
  String speedBonusFast(int percent);

  /// No description provided for @speedBonusLightning.
  ///
  /// In en, this message translates to:
  /// **'Lightning fast! +{percent}% bonus'**
  String speedBonusLightning(int percent);

  /// No description provided for @connectionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get connectionErrorTitle;

  /// No description provided for @connectionErrorBody.
  ///
  /// In en, this message translates to:
  /// **'We can\'t reach the server right now. Check your connection and try again. Some features may be limited while offline.'**
  String get connectionErrorBody;

  /// No description provided for @achievementUnlockedSnack.
  ///
  /// In en, this message translates to:
  /// **'You unlocked a new achievement! Tap to claim it.'**
  String get achievementUnlockedSnack;

  /// No description provided for @publicStatsPrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Private statistics'**
  String get publicStatsPrivateTitle;

  /// No description provided for @publicStatsPrivateBody.
  ///
  /// In en, this message translates to:
  /// **'Become friends to see detailed stats, unlocked achievements and more.'**
  String get publicStatsPrivateBody;

  /// No description provided for @sectionMapLicenses.
  ///
  /// In en, this message translates to:
  /// **'Map licences'**
  String get sectionMapLicenses;

  /// No description provided for @mapLicenseOsmTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenStreetMap'**
  String get mapLicenseOsmTitle;

  /// No description provided for @mapLicenseOsmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'© OpenStreetMap contributors — ODbL licence'**
  String get mapLicenseOsmSubtitle;

  /// No description provided for @mapLicenseCartoTitle.
  ///
  /// In en, this message translates to:
  /// **'CARTO'**
  String get mapLicenseCartoTitle;

  /// No description provided for @mapLicenseCartoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'© CARTO — Based on OpenStreetMap data'**
  String get mapLicenseCartoSubtitle;

  /// No description provided for @mapLicenseStadiaTitle.
  ///
  /// In en, this message translates to:
  /// **'Stadia Maps / Stamen Design'**
  String get mapLicenseStadiaTitle;

  /// No description provided for @mapLicenseStadiaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'© Stadia Maps, © Stamen Design — CC BY 3.0 licence'**
  String get mapLicenseStadiaSubtitle;

  /// No description provided for @mapLicenseEsriTitle.
  ///
  /// In en, this message translates to:
  /// **'Esri (Satellite view)'**
  String get mapLicenseEsriTitle;

  /// No description provided for @mapLicenseEsriSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tiles © Esri, Maxar, Earthstar Geographics and the GIS User Community'**
  String get mapLicenseEsriSubtitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'it': return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
