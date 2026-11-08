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
  /// **'Enable to consent to push notifications for friend requests and new friendships.'**
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
  /// **'—'**
  String get versionSubtitle;

  /// No description provided for @versionSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get versionSheetTitle;

  /// No description provided for @versionSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Version metadata read from the installed app'**
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
  /// **'No scores available on the global leaderboard yet.'**
  String get socialLeaderboardEmpty;

  /// No description provided for @socialLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Global leaderboard'**
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

  /// No description provided for @loginTermsNoticePrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get loginTermsNoticePrefix;

  /// No description provided for @loginTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get loginTermsLink;

  /// No description provided for @loginTermsAnd.
  ///
  /// In en, this message translates to:
  /// **' and acknowledge that I have read the '**
  String get loginTermsAnd;

  /// No description provided for @loginPrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get loginPrivacyLink;

  /// No description provided for @loginAgeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'I confirm that I am at least 14 years old.'**
  String get loginAgeConfirmation;

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
  /// **'Enable to consent to push notifications for friend requests and new friendships.'**
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
  /// **'Commissioned by Pope Pius VII Chiaramonti, who was born in Cesena, and designed by architect Giuseppe Valadier, the church was built between 1816 and 1825 in the Neoclassical style. Its circular plan, inspired by the Pantheon, is one of the building’s most distinctive features. During the Second World War, the crypt was reinforced and made safe for use as an air-raid shelter with room for up to 200 people. Father Leo Bagnoli remembered it as a solid, dry space where civilians sought refuge during air-raid warnings and the bombings that struck Cesena in 1944.'**
  String get poi_santa_cristina_desc;

  /// No description provided for @poi_rocca_name.
  ///
  /// In en, this message translates to:
  /// **'Malatestiana Fortress'**
  String get poi_rocca_name;

  /// No description provided for @poi_rocca_desc.
  ///
  /// In en, this message translates to:
  /// **'Construction of the Rocca Nuova, or Malatestiana Fortress, began in 1380 under Galeotto Malatesta and continued under Malatesta Novello on Garampo hill. After losing its military function, the fortress became a prison and remained one until 1969. During the Nazi-Fascist occupation it continued to house the city\'s district prison; in 1944 the Resistance carried out two raids to free political prisoners. The nearby Sferisterio, in front of the fortress entrance, was the site where eight anti-Fascists were executed on 4 September 1944. During the 1940s, the fortress’s underground spaces were also used as a shelter. The separate public shelter for 800 people often associated with the Rocca was a tunnel excavated into the hill along Viale Mazzoni.'**
  String get poi_rocca_desc;

  /// No description provided for @poi_san_rocco_name.
  ///
  /// In en, this message translates to:
  /// **'Church of San Rocco'**
  String get poi_san_rocco_name;

  /// No description provided for @poi_san_rocco_desc.
  ///
  /// In en, this message translates to:
  /// **'The parish of San Rocco in Cesena dates back to 1615. In the summer of 1944, Allied bombing aimed at disrupting the German retreat by attacking the Ponte Vecchio also struck the San Rocco district. The church opened its rooms to civilians seeking shelter, and its bell tower was adapted as an air-raid refuge. A makeshift blast shield was built by filling a wardrobe with sand and placing it in front of the door. The tower also carried a siren and a bell, which could warn residents when the electricity failed. The church was destroyed in 1944; the only surviving part of the original building is its nineteenth-century bell tower. The parish was later rebuilt across the River Savio, in the Campino area.'**
  String get poi_san_rocco_desc;

  /// No description provided for @poi_abbazia_monte_name.
  ///
  /// In en, this message translates to:
  /// **'Abbey of Santa Maria del Monte'**
  String get poi_abbazia_monte_name;

  /// No description provided for @poi_abbazia_monte_desc.
  ///
  /// In en, this message translates to:
  /// **'The Benedictine Abbey of Santa Maria del Monte was founded at the beginning of the 11th century on the hill known as il Monte, south-east of Cesena. During the Second World War, the monks built an underground gallery accessible through a well and enlarged with chambers carved into the tuff. It sheltered about 700 displaced people fleeing air raids and roundups. Many books from the Malatestiana Library were also kept underground, while its most valuable manuscripts had been moved to the Modena area at the beginning of the conflict. The monk Odo Contestabile helped protect Jewish families and, in 1943, escorted two families towards the Swiss border; he was recognised as Righteous Among the Nations in 2019. Between 16 and 19 October 1944, repeated bombing struck the abbey: the church was gutted and part of the monastery collapsed. None of the displaced people sheltering in the complex were killed.'**
  String get poi_abbazia_monte_desc;

  /// No description provided for @poi_osservanza_name.
  ///
  /// In en, this message translates to:
  /// **'Church and Convent of the Osservanza'**
  String get poi_osservanza_name;

  /// No description provided for @poi_osservanza_desc.
  ///
  /// In en, this message translates to:
  /// **'The church of the Osservanza was built between 1459 and 1464 at the behest of Malatesta Novello and was associated with the Order of Friars Minor of the Observance. Its design was entrusted to master builder Maso della Val Lugano. During the Second World War, the complex also served as a place of civilian protection: two air-raid shelters were set up, one in the catacombs and one near the bell tower, with a combined capacity of about 200 people. The church did not escape the fighting around the Gothic Line: it was hit by Allied raids on 16 and 19 October 1944. Father Bosoni died during those raids and is remembered by a plaque in the catacombs.'**
  String get poi_osservanza_desc;

  /// No description provided for @poi_palazzo_ridotto_name.
  ///
  /// In en, this message translates to:
  /// **'Palazzo del Ridotto'**
  String get poi_palazzo_ridotto_name;

  /// No description provided for @poi_palazzo_ridotto_desc.
  ///
  /// In en, this message translates to:
  /// **'Palazzo del Ridotto faces Piazza Almerici and stands on an earlier medieval structure. Sources differ on its first building phase: Resistenza mAPPe describes a building from 1401–1403, enlarged between 1466 and 1472, while the regional catalogue dates the construction of the Conservatori palace to 1466–1472 on an earlier structure. Its name is linked to the meeting place of Cesena’s nobility in the 18th century. During the Second World War, an air-raid siren was installed on its tower as part of the city-wide warning system; church bells also provided a backup when the electricity failed. After the partisan attack of 18 January 1944 on the Fascist headquarters at Palazzo Fantaguzzi, the local offices of the Republican Fascist Party moved here. The palace was also used to detain and torture prisoners. A plaque placed in 1995 on the side facing Piazza Almerici commemorates the Jews of Cesena murdered in the Holocaust.'**
  String get poi_palazzo_ridotto_desc;

  /// No description provided for @poi_stazione_name.
  ///
  /// In en, this message translates to:
  /// **'Cesena Railway Station'**
  String get poi_stazione_name;

  /// No description provided for @poi_stazione_desc.
  ///
  /// In en, this message translates to:
  /// **'Cesena’s first railway station opened in 1861. A plan for a larger station building was approved in 1919, and its foundation stone was laid in 1925. The Arrigoni food factory stood beside the railway yard, while the Montecatini refinery, which processed sulphur from the Perticara and Formignano mines, stood on the opposite side. This concentration of transport and industrial facilities made the area a strategic target. The first heavy air raid on the city took place on 13 May 1944; on 29 June a raid hit the railway yard, destroyed ammunition loads and set the refinery on fire. Further attacks followed in July, August and early September. During the Resistance, the station and railway lines were also targeted by partisan actions intended to disrupt supplies to the occupying army.'**
  String get poi_stazione_desc;

  /// No description provided for @poi_arrigoni_name.
  ///
  /// In en, this message translates to:
  /// **'Arrigoni Factory'**
  String get poi_arrigoni_name;

  /// No description provided for @poi_arrigoni_desc.
  ///
  /// In en, this message translates to:
  /// **'The Arrigoni factory stood next to Cesena railway station. In 1927, Giorgio Sanguinetti, who managed the Arrigoni company in Trieste, acquired the former Consorzio Industrie Agrarie (CIA) and expanded its facilities. By the 1930s it had become the area’s leading food factory, employing about 5,000 people. The Cesena plant was known for jams, peeled tomatoes and dried minestrone. It was also a centre of local anti-Fascism: many workers opposed the regime through strikes, acts of sabotage and libertarian propaganda, and faced persecution. One of them was Werther Ricchi, who sent jam and other products to the partisans of the 8th Garibaldi Brigade after 8 September 1943. He was arrested on 23 March 1944 and tortured. As the front moved through the area, the workforce helped save a large part of the factory’s machinery.'**
  String get poi_arrigoni_desc;

  /// No description provided for @poi_fantaguzzi_name.
  ///
  /// In en, this message translates to:
  /// **'Palazzo Fantaguzzi'**
  String get poi_fantaguzzi_name;

  /// No description provided for @poi_fantaguzzi_desc.
  ///
  /// In en, this message translates to:
  /// **'Palazzo Fantaguzzi stands on today’s Corso Gastone Sozzi, formerly Corso Umberto I, and has housed the Banca Popolare di Cesena since 1922. During the first months of the Italian Social Republic, part of the building also housed the local Fascist offices; the sources do not show that it served as the Fascist headquarters throughout the entire dictatorship. Because of the symbolic importance of that presence, the Cesena GAP planned an attack. On 18 January 1944, four partisans set off a bomb at the entrance. There were no casualties, but the building was seriously damaged. A few weeks later, the local Fascist headquarters moved to Palazzo del Ridotto. The distinction matters: the sources place the later detention and torture of prisoners at the Ridotto, not at Palazzo Fantaguzzi.'**
  String get poi_fantaguzzi_desc;

  /// No description provided for @poi_rifugi_antiaerei_name.
  ///
  /// In en, this message translates to:
  /// **'Air-Raid Shelters of the Fortress'**
  String get poi_rifugi_antiaerei_name;

  /// No description provided for @poi_rifugi_antiaerei_desc.
  ///
  /// In en, this message translates to:
  /// **'The Viale Mazzoni shelter was a public tunnel excavated into the Rocca hill in 1944, designed by Mario Tellerini, the municipal chief engineer. It could accommodate up to 800 people, with 290 seats. It had two entrances protected by blast walls and included an infirmary, rooms for firefighters and the shelter supervisor, toilets, lighting, water and a telephone; the Germans later removed the telephone. The ventilation shaft ended in the Parco della Rimembranza and could also be used as an emergency exit. An extension to increase capacity to 1,500 people was considered, but the project was never built. The first major air raid on Cesena took place on 13 May 1944, marking the beginning of a prolonged period of raids. The gallery was separate from the Malatestiana Fortress itself.'**
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
  /// **'Backup quiz'**
  String get quiz_fallback_name;

  /// No description provided for @quiz_fallback_desc.
  ///
  /// In en, this message translates to:
  /// **'The online quiz is temporarily unavailable. Here are three backup questions about this place.'**
  String get quiz_fallback_desc;

  /// No description provided for @quiz_santa_cristina_q1.
  ///
  /// In en, this message translates to:
  /// **'Which part of the church was adapted as an air-raid shelter?'**
  String get quiz_santa_cristina_q1;

  /// No description provided for @quiz_santa_cristina_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'The crypt'**
  String get quiz_santa_cristina_q1_o1;

  /// No description provided for @quiz_santa_cristina_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'The bell tower'**
  String get quiz_santa_cristina_q1_o2;

  /// No description provided for @quiz_santa_cristina_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'The cloister'**
  String get quiz_santa_cristina_q1_o3;

  /// No description provided for @quiz_santa_cristina_q2.
  ///
  /// In en, this message translates to:
  /// **'How many people could the crypt shelter accommodate?'**
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
  /// **'Which function did the fortress retain during the Nazi-Fascist occupation?'**
  String get quiz_rocca_q1;

  /// No description provided for @quiz_rocca_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'A prison'**
  String get quiz_rocca_q1_o1;

  /// No description provided for @quiz_rocca_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'A public air-raid shelter'**
  String get quiz_rocca_q1_o2;

  /// No description provided for @quiz_rocca_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'A field hospital'**
  String get quiz_rocca_q1_o3;

  /// No description provided for @quiz_rocca_q2.
  ///
  /// In en, this message translates to:
  /// **'Why did the Resistance carry out two raids on the fortress in 1944?'**
  String get quiz_rocca_q2;

  /// No description provided for @quiz_rocca_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'To free political prisoners'**
  String get quiz_rocca_q2_o1;

  /// No description provided for @quiz_rocca_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'To move the Arrigoni machinery'**
  String get quiz_rocca_q2_o2;

  /// No description provided for @quiz_rocca_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'To protect civilians from air raids'**
  String get quiz_rocca_q2_o3;

  /// No description provided for @quiz_rocca_q3.
  ///
  /// In en, this message translates to:
  /// **'Where were eight anti-Fascists executed on 4 September 1944?'**
  String get quiz_rocca_q3;

  /// No description provided for @quiz_rocca_q3_o1.
  ///
  /// In en, this message translates to:
  /// **'At the Sferisterio, in front of the fortress entrance'**
  String get quiz_rocca_q3_o1;

  /// No description provided for @quiz_rocca_q3_o2.
  ///
  /// In en, this message translates to:
  /// **'In the fortress courtyard'**
  String get quiz_rocca_q3_o2;

  /// No description provided for @quiz_rocca_q3_o3.
  ///
  /// In en, this message translates to:
  /// **'At the railway station'**
  String get quiz_rocca_q3_o3;

  /// No description provided for @quiz_san_rocco_q1.
  ///
  /// In en, this message translates to:
  /// **'Which part of the church of San Rocco was adapted as an air-raid shelter?'**
  String get quiz_san_rocco_q1;

  /// No description provided for @quiz_san_rocco_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'The bell tower'**
  String get quiz_san_rocco_q1_o1;

  /// No description provided for @quiz_san_rocco_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'The crypt'**
  String get quiz_san_rocco_q1_o2;

  /// No description provided for @quiz_san_rocco_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'The sacristy'**
  String get quiz_san_rocco_q1_o3;

  /// No description provided for @quiz_san_rocco_q2.
  ///
  /// In en, this message translates to:
  /// **'Which nearby target was attacked in an effort to hinder the German retreat?'**
  String get quiz_san_rocco_q2;

  /// No description provided for @quiz_san_rocco_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'The Ponte Vecchio'**
  String get quiz_san_rocco_q2_o1;

  /// No description provided for @quiz_san_rocco_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'The Ponte Nuovo'**
  String get quiz_san_rocco_q2_o2;

  /// No description provided for @quiz_san_rocco_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'The railway station'**
  String get quiz_san_rocco_q2_o3;

  /// No description provided for @quiz_abbazia_monte_q1.
  ///
  /// In en, this message translates to:
  /// **'About how many people took shelter in the abbey’s underground spaces during the war?'**
  String get quiz_abbazia_monte_q1;

  /// No description provided for @quiz_abbazia_monte_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'About 700'**
  String get quiz_abbazia_monte_q1_o1;

  /// No description provided for @quiz_abbazia_monte_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'About 200'**
  String get quiz_abbazia_monte_q1_o2;

  /// No description provided for @quiz_abbazia_monte_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'About 800'**
  String get quiz_abbazia_monte_q1_o3;

  /// No description provided for @quiz_abbazia_monte_q2.
  ///
  /// In en, this message translates to:
  /// **'What damage did the October 1944 bombing cause to the abbey?'**
  String get quiz_abbazia_monte_q2;

  /// No description provided for @quiz_abbazia_monte_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'The church was gutted and part of the monastery collapsed'**
  String get quiz_abbazia_monte_q2_o1;

  /// No description provided for @quiz_abbazia_monte_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'Only the gardens were damaged'**
  String get quiz_abbazia_monte_q2_o2;

  /// No description provided for @quiz_abbazia_monte_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'The whole hill was evacuated but the buildings were unharmed'**
  String get quiz_abbazia_monte_q2_o3;

  /// No description provided for @quiz_osservanza_q1.
  ///
  /// In en, this message translates to:
  /// **'Where were the two air-raid shelters at the Osservanza located?'**
  String get quiz_osservanza_q1;

  /// No description provided for @quiz_osservanza_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'In the catacombs and near the bell tower'**
  String get quiz_osservanza_q1_o1;

  /// No description provided for @quiz_osservanza_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'In the cloister and the sacristy'**
  String get quiz_osservanza_q1_o2;

  /// No description provided for @quiz_osservanza_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'Under the refectory and in the courtyard'**
  String get quiz_osservanza_q1_o3;

  /// No description provided for @quiz_osservanza_q2.
  ///
  /// In en, this message translates to:
  /// **'What was the combined capacity of the two Osservanza shelters?'**
  String get quiz_osservanza_q2;

  /// No description provided for @quiz_osservanza_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'About 200 people'**
  String get quiz_osservanza_q2_o1;

  /// No description provided for @quiz_osservanza_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'About 700 people'**
  String get quiz_osservanza_q2_o2;

  /// No description provided for @quiz_osservanza_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'About 800 people'**
  String get quiz_osservanza_q2_o3;

  /// No description provided for @quiz_palazzo_ridotto_q1.
  ///
  /// In en, this message translates to:
  /// **'What was the purpose of the siren installed on the tower of Palazzo del Ridotto?'**
  String get quiz_palazzo_ridotto_q1;

  /// No description provided for @quiz_palazzo_ridotto_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'To warn people of air raids'**
  String get quiz_palazzo_ridotto_q1_o1;

  /// No description provided for @quiz_palazzo_ridotto_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'To regulate railway traffic'**
  String get quiz_palazzo_ridotto_q1_o2;

  /// No description provided for @quiz_palazzo_ridotto_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'To call municipal meetings'**
  String get quiz_palazzo_ridotto_q1_o3;

  /// No description provided for @quiz_palazzo_ridotto_q2.
  ///
  /// In en, this message translates to:
  /// **'Which backup system could sound an alarm when the electricity failed?'**
  String get quiz_palazzo_ridotto_q2;

  /// No description provided for @quiz_palazzo_ridotto_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'Church bells'**
  String get quiz_palazzo_ridotto_q2_o1;

  /// No description provided for @quiz_palazzo_ridotto_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'Square lighting'**
  String get quiz_palazzo_ridotto_q2_o2;

  /// No description provided for @quiz_palazzo_ridotto_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'Train whistles'**
  String get quiz_palazzo_ridotto_q2_o3;

  /// No description provided for @quiz_stazione_q1.
  ///
  /// In en, this message translates to:
  /// **'Why was the railway station area considered strategic during the occupation?'**
  String get quiz_stazione_q1;

  /// No description provided for @quiz_stazione_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'Because Arrigoni and the Montecatini refinery were nearby'**
  String get quiz_stazione_q1_o1;

  /// No description provided for @quiz_stazione_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'Because the Malatestiana Library was located there'**
  String get quiz_stazione_q1_o2;

  /// No description provided for @quiz_stazione_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'Because it housed the shelter of Santa Cristina church'**
  String get quiz_stazione_q1_o3;

  /// No description provided for @quiz_stazione_q2.
  ///
  /// In en, this message translates to:
  /// **'How did the Resistance try to disrupt supplies to the occupying army?'**
  String get quiz_stazione_q2;

  /// No description provided for @quiz_stazione_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'By targeting the station and railway lines'**
  String get quiz_stazione_q2_o1;

  /// No description provided for @quiz_stazione_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'By silencing the church bells'**
  String get quiz_stazione_q2_o2;

  /// No description provided for @quiz_stazione_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'By occupying Palazzo del Ridotto'**
  String get quiz_stazione_q2_o3;

  /// No description provided for @quiz_arrigoni_q1.
  ///
  /// In en, this message translates to:
  /// **'Which products were characteristic of the Cesena plant?'**
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
  /// **'Cars, bicycles and mechanical parts'**
  String get quiz_arrigoni_q1_o3;

  /// No description provided for @quiz_arrigoni_q2.
  ///
  /// In en, this message translates to:
  /// **'How did Werther Ricchi support the Resistance after 8 September 1943?'**
  String get quiz_arrigoni_q2;

  /// No description provided for @quiz_arrigoni_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'By getting Arrigoni products to the partisans of the 8th Garibaldi Brigade'**
  String get quiz_arrigoni_q2_o1;

  /// No description provided for @quiz_arrigoni_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'By supplying fuel to the Montecatini refinery'**
  String get quiz_arrigoni_q2_o2;

  /// No description provided for @quiz_arrigoni_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'By organising construction of the air-raid tunnel'**
  String get quiz_arrigoni_q2_o3;

  /// No description provided for @quiz_fantaguzzi_q1.
  ///
  /// In en, this message translates to:
  /// **'Which institution had its headquarters at Palazzo Fantaguzzi from 1922?'**
  String get quiz_fantaguzzi_q1;

  /// No description provided for @quiz_fantaguzzi_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'The Banca Popolare di Cesena'**
  String get quiz_fantaguzzi_q1_o1;

  /// No description provided for @quiz_fantaguzzi_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'The Malatestiana Library'**
  String get quiz_fantaguzzi_q1_o2;

  /// No description provided for @quiz_fantaguzzi_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'The town hall'**
  String get quiz_fantaguzzi_q1_o3;

  /// No description provided for @quiz_fantaguzzi_q2.
  ///
  /// In en, this message translates to:
  /// **'What happened at the palace entrance on 18 January 1944?'**
  String get quiz_fantaguzzi_q2;

  /// No description provided for @quiz_fantaguzzi_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'The GAP set off a bomb; there were no casualties'**
  String get quiz_fantaguzzi_q2_o1;

  /// No description provided for @quiz_fantaguzzi_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'An air raid destroyed the entire building'**
  String get quiz_fantaguzzi_q2_o2;

  /// No description provided for @quiz_fantaguzzi_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'An air-raid shelter was inaugurated'**
  String get quiz_fantaguzzi_q2_o3;

  /// No description provided for @quiz_rifugi_antiaerei_q1.
  ///
  /// In en, this message translates to:
  /// **'How many people could the public tunnel in the Rocca hill shelter?'**
  String get quiz_rifugi_antiaerei_q1;

  /// No description provided for @quiz_rifugi_antiaerei_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'Up to 800 people'**
  String get quiz_rifugi_antiaerei_q1_o1;

  /// No description provided for @quiz_rifugi_antiaerei_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'Up to 200 people'**
  String get quiz_rifugi_antiaerei_q1_o2;

  /// No description provided for @quiz_rifugi_antiaerei_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'Up to 700 people'**
  String get quiz_rifugi_antiaerei_q1_o3;

  /// No description provided for @quiz_rifugi_antiaerei_q2.
  ///
  /// In en, this message translates to:
  /// **'Which part of the shelter could also serve as an emergency exit?'**
  String get quiz_rifugi_antiaerei_q2;

  /// No description provided for @quiz_rifugi_antiaerei_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'The ventilation shaft'**
  String get quiz_rifugi_antiaerei_q2_o1;

  /// No description provided for @quiz_rifugi_antiaerei_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'The blast wall'**
  String get quiz_rifugi_antiaerei_q2_o2;

  /// No description provided for @quiz_rifugi_antiaerei_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'The infirmary'**
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
  /// **'Climb the global leaderboard and compare your progress with all explorers.'**
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
  /// **'Stadia Maps — Alidade Smooth Dark'**
  String get mapLicenseStadiaTitle;

  /// No description provided for @mapLicenseStadiaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'© Stadia Maps © OpenMapTiles © OpenStreetMap contributors'**
  String get mapLicenseStadiaSubtitle;

  /// No description provided for @quiz_santa_cristina_q3.
  ///
  /// In en, this message translates to:
  /// **'How did Father Leo Bagnoli describe the shelter in the crypt?'**
  String get quiz_santa_cristina_q3;

  /// No description provided for @quiz_santa_cristina_q3_o1.
  ///
  /// In en, this message translates to:
  /// **'As a solid and dry space'**
  String get quiz_santa_cristina_q3_o1;

  /// No description provided for @quiz_santa_cristina_q3_o2.
  ///
  /// In en, this message translates to:
  /// **'As an unstable and damp space'**
  String get quiz_santa_cristina_q3_o2;

  /// No description provided for @quiz_santa_cristina_q3_o3.
  ///
  /// In en, this message translates to:
  /// **'As a room with no access'**
  String get quiz_santa_cristina_q3_o3;

  /// No description provided for @quiz_san_rocco_q3.
  ///
  /// In en, this message translates to:
  /// **'Which part of the original church survived its destruction in 1944?'**
  String get quiz_san_rocco_q3;

  /// No description provided for @quiz_san_rocco_q3_o1.
  ///
  /// In en, this message translates to:
  /// **'The nineteenth-century bell tower'**
  String get quiz_san_rocco_q3_o1;

  /// No description provided for @quiz_san_rocco_q3_o2.
  ///
  /// In en, this message translates to:
  /// **'The main façade'**
  String get quiz_san_rocco_q3_o2;

  /// No description provided for @quiz_san_rocco_q3_o3.
  ///
  /// In en, this message translates to:
  /// **'The central nave'**
  String get quiz_san_rocco_q3_o3;

  /// No description provided for @quiz_abbazia_monte_q3.
  ///
  /// In en, this message translates to:
  /// **'How did the monk Odo Contestabile help two Jewish families in 1943?'**
  String get quiz_abbazia_monte_q3;

  /// No description provided for @quiz_abbazia_monte_q3_o1.
  ///
  /// In en, this message translates to:
  /// **'He escorted them towards the Swiss border'**
  String get quiz_abbazia_monte_q3_o1;

  /// No description provided for @quiz_abbazia_monte_q3_o2.
  ///
  /// In en, this message translates to:
  /// **'He hid them in the Rocca air-raid tunnel'**
  String get quiz_abbazia_monte_q3_o2;

  /// No description provided for @quiz_abbazia_monte_q3_o3.
  ///
  /// In en, this message translates to:
  /// **'He moved them to the railway station'**
  String get quiz_abbazia_monte_q3_o3;

  /// No description provided for @quiz_osservanza_q3.
  ///
  /// In en, this message translates to:
  /// **'Which event is associated with the October 1944 bombing of the Osservanza?'**
  String get quiz_osservanza_q3;

  /// No description provided for @quiz_osservanza_q3_o1.
  ///
  /// In en, this message translates to:
  /// **'The death of Father Bosoni'**
  String get quiz_osservanza_q3_o1;

  /// No description provided for @quiz_osservanza_q3_o2.
  ///
  /// In en, this message translates to:
  /// **'The transfer of the Fascist offices'**
  String get quiz_osservanza_q3_o2;

  /// No description provided for @quiz_osservanza_q3_o3.
  ///
  /// In en, this message translates to:
  /// **'The destruction of the railway station'**
  String get quiz_osservanza_q3_o3;

  /// No description provided for @quiz_palazzo_ridotto_q3.
  ///
  /// In en, this message translates to:
  /// **'Why were the local offices of the Republican Fascist Party moved to the Ridotto?'**
  String get quiz_palazzo_ridotto_q3;

  /// No description provided for @quiz_palazzo_ridotto_q3_o1.
  ///
  /// In en, this message translates to:
  /// **'After the attack on the headquarters at Palazzo Fantaguzzi'**
  String get quiz_palazzo_ridotto_q3_o1;

  /// No description provided for @quiz_palazzo_ridotto_q3_o2.
  ///
  /// In en, this message translates to:
  /// **'After the bombing of the abbey'**
  String get quiz_palazzo_ridotto_q3_o2;

  /// No description provided for @quiz_palazzo_ridotto_q3_o3.
  ///
  /// In en, this message translates to:
  /// **'Because the railway station was closed'**
  String get quiz_palazzo_ridotto_q3_o3;

  /// No description provided for @quiz_stazione_q3.
  ///
  /// In en, this message translates to:
  /// **'What happened during the air raid on the railway area on 29 June 1944?'**
  String get quiz_stazione_q3;

  /// No description provided for @quiz_stazione_q3_o1.
  ///
  /// In en, this message translates to:
  /// **'Ammunition loads were destroyed and Montecatini was set on fire'**
  String get quiz_stazione_q3_o1;

  /// No description provided for @quiz_stazione_q3_o2.
  ///
  /// In en, this message translates to:
  /// **'The bell tower of San Rocco was destroyed'**
  String get quiz_stazione_q3_o2;

  /// No description provided for @quiz_stazione_q3_o3.
  ///
  /// In en, this message translates to:
  /// **'The Abbey of Santa Maria del Monte was hit directly'**
  String get quiz_stazione_q3_o3;

  /// No description provided for @quiz_arrigoni_q3.
  ///
  /// In en, this message translates to:
  /// **'What did Arrigoni workers do as the front moved through the area?'**
  String get quiz_arrigoni_q3;

  /// No description provided for @quiz_arrigoni_q3_o1.
  ///
  /// In en, this message translates to:
  /// **'They saved a large amount of the factory’s machinery'**
  String get quiz_arrigoni_q3_o1;

  /// No description provided for @quiz_arrigoni_q3_o2.
  ///
  /// In en, this message translates to:
  /// **'They moved the railway station'**
  String get quiz_arrigoni_q3_o2;

  /// No description provided for @quiz_arrigoni_q3_o3.
  ///
  /// In en, this message translates to:
  /// **'They built a shelter in San Rocco’s bell tower'**
  String get quiz_arrigoni_q3_o3;

  /// No description provided for @quiz_fantaguzzi_q3.
  ///
  /// In en, this message translates to:
  /// **'Where were the local Fascist headquarters moved after the attack?'**
  String get quiz_fantaguzzi_q3;

  /// No description provided for @quiz_fantaguzzi_q3_o1.
  ///
  /// In en, this message translates to:
  /// **'To Palazzo del Ridotto'**
  String get quiz_fantaguzzi_q3_o1;

  /// No description provided for @quiz_fantaguzzi_q3_o2.
  ///
  /// In en, this message translates to:
  /// **'To the Malatestiana Fortress'**
  String get quiz_fantaguzzi_q3_o2;

  /// No description provided for @quiz_fantaguzzi_q3_o3.
  ///
  /// In en, this message translates to:
  /// **'To the railway station'**
  String get quiz_fantaguzzi_q3_o3;

  /// No description provided for @quiz_rifugi_antiaerei_q3.
  ///
  /// In en, this message translates to:
  /// **'How were the two shelter entrances on Viale Mazzoni protected?'**
  String get quiz_rifugi_antiaerei_q3;

  /// No description provided for @quiz_rifugi_antiaerei_q3_o1.
  ///
  /// In en, this message translates to:
  /// **'With blast-protection structures'**
  String get quiz_rifugi_antiaerei_q3_o1;

  /// No description provided for @quiz_rifugi_antiaerei_q3_o2.
  ///
  /// In en, this message translates to:
  /// **'With warning bells'**
  String get quiz_rifugi_antiaerei_q3_o2;

  /// No description provided for @quiz_rifugi_antiaerei_q3_o3.
  ///
  /// In en, this message translates to:
  /// **'With wooden doors filled with water'**
  String get quiz_rifugi_antiaerei_q3_o3;

  /// No description provided for @consentNotificationsTag.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get consentNotificationsTag;

  /// No description provided for @consentNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay up to date'**
  String get consentNotificationsTitle;

  /// No description provided for @consentNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Get an alert when someone sends you a friend request or you unlock a new achievement.'**
  String get consentNotificationsBody;

  /// No description provided for @consentNotificationsNote.
  ///
  /// In en, this message translates to:
  /// **'Notifications are optional and can be turned off at any time in Settings.'**
  String get consentNotificationsNote;

  /// No description provided for @consentNotificationsAccept.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get consentNotificationsAccept;

  /// No description provided for @consentNotificationsDecline.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get consentNotificationsDecline;

  /// No description provided for @consentLocationTag.
  ///
  /// In en, this message translates to:
  /// **'LOCATION'**
  String get consentLocationTag;

  /// No description provided for @consentLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Cesena, one stop at a time'**
  String get consentLocationTitle;

  /// No description provided for @consentLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Your location lets us show where you are on the map and guide you along the tours.'**
  String get consentLocationBody;

  /// No description provided for @consentLocationNote.
  ///
  /// In en, this message translates to:
  /// **'Android will ask for permission only after you choose to enable it. You can still use the app without GPS.'**
  String get consentLocationNote;

  /// No description provided for @consentLocationAccept.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get consentLocationAccept;

  /// No description provided for @consentLocationDecline.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get consentLocationDecline;

  /// No description provided for @consentDiagnosticsTag.
  ///
  /// In en, this message translates to:
  /// **'OPTIONAL DIAGNOSTICS'**
  String get consentDiagnosticsTag;

  /// No description provided for @consentDiagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Help us improve the app'**
  String get consentDiagnosticsTitle;

  /// No description provided for @consentDiagnosticsBody.
  ///
  /// In en, this message translates to:
  /// **'When an error occurs, you can send Firebase Crashlytics a technical report containing a stack trace, app version, device information and a technical installation identifier. This helps us find and fix problems.'**
  String get consentDiagnosticsBody;

  /// No description provided for @consentDiagnosticsNote.
  ///
  /// In en, this message translates to:
  /// **'This is optional: the app works normally without it. You can withdraw consent at any time in Settings.'**
  String get consentDiagnosticsNote;

  /// No description provided for @consentDiagnosticsAccept.
  ///
  /// In en, this message translates to:
  /// **'Share technical reports'**
  String get consentDiagnosticsAccept;

  /// No description provided for @consentDiagnosticsDecline.
  ///
  /// In en, this message translates to:
  /// **'No, thanks'**
  String get consentDiagnosticsDecline;

  /// No description provided for @consentSaveError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your choice. Check your connection and try again.'**
  String get consentSaveError;

  /// No description provided for @settingsDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Technical reports'**
  String get settingsDiagnostics;

  /// No description provided for @settingsDiagnosticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow technical error reports to be sent through Firebase Crashlytics.'**
  String get settingsDiagnosticsSubtitle;

  /// No description provided for @mapLicenseSatelliteTitle.
  ///
  /// In en, this message translates to:
  /// **'Stadia Maps — Alidade Satellite'**
  String get mapLicenseSatelliteTitle;

  /// No description provided for @mapLicenseSatelliteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'© CNES, Distribution Airbus DS, © Airbus DS, © PlanetObserver (Contains Copernicus Data)'**
  String get mapLicenseSatelliteSubtitle;

  /// No description provided for @mapLicenseDirectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mapbox Directions API'**
  String get mapLicenseDirectionsTitle;

  /// No description provided for @mapLicenseDirectionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Service used to calculate walking routes.'**
  String get mapLicenseDirectionsSubtitle;

  /// No description provided for @mapLicenseDirectionsAttribution.
  ///
  /// In en, this message translates to:
  /// **'Route powered by Mapbox'**
  String get mapLicenseDirectionsAttribution;
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
