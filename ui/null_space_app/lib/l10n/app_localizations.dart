import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Null Space'**
  String get appTitle;

  /// Notes tab label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Search tab label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Vault tab label
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get vault;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Create note button tooltip
  ///
  /// In en, this message translates to:
  /// **'Create Note'**
  String get createNote;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Appearance section header
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Security section header
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Editor section header
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get editor;

  /// Storage section header
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// About section header
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// System default option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Font size setting label
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// Line spacing setting label
  ///
  /// In en, this message translates to:
  /// **'Line Spacing'**
  String get lineSpacing;

  /// Auto-lock timeout setting label
  ///
  /// In en, this message translates to:
  /// **'Auto-lock Timeout'**
  String get autoLockTimeout;

  /// Biometric unlock setting label
  ///
  /// In en, this message translates to:
  /// **'Biometric Unlock'**
  String get biometricUnlock;

  /// 1 minute timeout option
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get oneMinute;

  /// 5 minutes timeout option
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get fiveMinutes;

  /// 15 minutes timeout option
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get fifteenMinutes;

  /// 30 minutes timeout option
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get thirtyMinutes;

  /// Never option
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// Default view setting label
  ///
  /// In en, this message translates to:
  /// **'Default View'**
  String get defaultView;

  /// Edit mode option
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editMode;

  /// Preview mode option
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewMode;

  /// Split mode option
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get splitMode;

  /// Show line numbers setting label
  ///
  /// In en, this message translates to:
  /// **'Show Line Numbers'**
  String get showLineNumbers;

  /// Auto-save setting label
  ///
  /// In en, this message translates to:
  /// **'Auto-save'**
  String get autoSave;

  /// Storage location setting label
  ///
  /// In en, this message translates to:
  /// **'Storage Location'**
  String get storageLocation;

  /// Cache size label
  ///
  /// In en, this message translates to:
  /// **'Cache Size'**
  String get cacheSize;

  /// Clear cache button
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// Export data button
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// License label
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// Reset settings button
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Create button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Import button
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// Export button
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Unlock button
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// Rename button
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// Clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Yes button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Vault screen title
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get vaultScreen;

  /// Empty vault list message
  ///
  /// In en, this message translates to:
  /// **'No Vaults'**
  String get noVaults;

  /// Prompt to create first vault
  ///
  /// In en, this message translates to:
  /// **'Create a new vault to get started'**
  String get createNewVaultPrompt;

  /// Create vault button
  ///
  /// In en, this message translates to:
  /// **'Create Vault'**
  String get createVault;

  /// Import vault button/dialog title
  ///
  /// In en, this message translates to:
  /// **'Import Vault'**
  String get importVault;

  /// Rename vault dialog title
  ///
  /// In en, this message translates to:
  /// **'Rename Vault'**
  String get renameVault;

  /// Delete vault confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete Vault'**
  String get deleteVault;

  /// Delete vault confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this vault? All notes will be permanently deleted.'**
  String get deleteVaultMessage;

  /// Create vault dialog title
  ///
  /// In en, this message translates to:
  /// **'Create New Vault'**
  String get createNewVault;

  /// Vault name field label
  ///
  /// In en, this message translates to:
  /// **'Vault Name'**
  String get vaultName;

  /// Vault name validation error
  ///
  /// In en, this message translates to:
  /// **'Vault name is required'**
  String get vaultNameRequired;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Password minimum length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// Password mismatch validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Weak password strength
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordStrengthWeak;

  /// Medium password strength
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get passwordStrengthMedium;

  /// Strong password strength
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// Very strong password strength
  ///
  /// In en, this message translates to:
  /// **'Very Strong'**
  String get passwordStrengthVeryStrong;

  /// Unlock vault dialog title
  ///
  /// In en, this message translates to:
  /// **'Unlock Vault'**
  String get unlockVault;

  /// Unlock with biometrics button
  ///
  /// In en, this message translates to:
  /// **'Unlock with Biometrics'**
  String get unlockWithBiometrics;

  /// Incorrect password error
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// Generic unlock failure error
  ///
  /// In en, this message translates to:
  /// **'Failed to unlock vault'**
  String get failedToUnlock;

  /// New note screen title
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// Edit note screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// Title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Content field label
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// Tags field label
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// Title validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get titleRequired;

  /// Content validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter some content'**
  String get contentRequired;

  /// Note content placeholder text
  ///
  /// In en, this message translates to:
  /// **'Write your note in Markdown...'**
  String get writeNoteHint;

  /// Unsaved changes dialog title
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// Unsaved changes dialog message
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to save them?'**
  String get unsavedChangesMessage;

  /// Discard button
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Delete note confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// Delete note confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get deleteNoteMessage;

  /// Delete note confirmation with title
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String deleteNoteConfirmation(String title);

  /// Note saved success message
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get noteSaved;

  /// Note deleted success message
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get noteDeleted;

  /// Search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search notes...'**
  String get searchNotes;

  /// Clear search button tooltip
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// Search empty state title
  ///
  /// In en, this message translates to:
  /// **'Search Your Notes'**
  String get searchYourNotes;

  /// Search empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter keywords to find notes'**
  String get enterKeywords;

  /// No search results title
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get noResultsFound;

  /// No search results subtitle
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or check your spelling'**
  String get tryDifferentKeywords;

  /// Empty notes list title
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotesYet;

  /// Empty notes list subtitle
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first note'**
  String get createFirstNote;

  /// Sort menu label
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// Sort by recently updated option
  ///
  /// In en, this message translates to:
  /// **'Recently Updated'**
  String get recentlyUpdated;

  /// Sort by recently created option
  ///
  /// In en, this message translates to:
  /// **'Recently Created'**
  String get recentlyCreated;

  /// Sort by title ascending option
  ///
  /// In en, this message translates to:
  /// **'Title A-Z'**
  String get titleAZ;

  /// Sort by title descending option
  ///
  /// In en, this message translates to:
  /// **'Title Z-A'**
  String get titleZA;

  /// Filter by tags button
  ///
  /// In en, this message translates to:
  /// **'Filter by tags'**
  String get filterByTags;

  /// Fallback title for notes without title
  ///
  /// In en, this message translates to:
  /// **'Untitled Note'**
  String get untitledNote;

  /// Updated prefix for date
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// Delete note button tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get deleteNoteTooltip;

  /// Vault created success message
  ///
  /// In en, this message translates to:
  /// **'Vault created successfully'**
  String get vaultCreated;

  /// Vault imported success message
  ///
  /// In en, this message translates to:
  /// **'Vault imported successfully'**
  String get vaultImported;

  /// Vault renamed success message
  ///
  /// In en, this message translates to:
  /// **'Vault renamed successfully'**
  String get vaultRenamed;

  /// Vault deleted success message
  ///
  /// In en, this message translates to:
  /// **'Vault deleted successfully'**
  String get vaultDeleted;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get genericError;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Chinese Simplified language name
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get chineseSimplified;

  /// Chinese Traditional language name
  ///
  /// In en, this message translates to:
  /// **'Chinese (Traditional)'**
  String get chineseTraditional;

  /// Japanese language name
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// Korean language name
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// 1 hour timeout option
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get oneHour;

  /// Biometric unlock subtitle
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face unlock'**
  String get useFingerprintOrFaceUnlock;

  /// Clear clipboard setting label
  ///
  /// In en, this message translates to:
  /// **'Clear Clipboard After Paste'**
  String get clearClipboardAfterPaste;

  /// Clear clipboard subtitle
  ///
  /// In en, this message translates to:
  /// **'Automatically clear clipboard for security'**
  String get automaticallyClearClipboardForSecurity;

  /// Default view mode setting label
  ///
  /// In en, this message translates to:
  /// **'Default View Mode'**
  String get defaultViewMode;

  /// Auto-save interval setting label
  ///
  /// In en, this message translates to:
  /// **'Auto-save Interval'**
  String get autoSaveInterval;

  /// 10 seconds interval option
  ///
  /// In en, this message translates to:
  /// **'10 seconds'**
  String get tenSeconds;

  /// 30 seconds interval option
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get thirtySeconds;

  /// 5 minutes interval option
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get fiveMinutesInterval;

  /// Manual only option
  ///
  /// In en, this message translates to:
  /// **'Manual only'**
  String get manualOnly;

  /// Spell check setting label
  ///
  /// In en, this message translates to:
  /// **'Spell Check'**
  String get spellCheck;

  /// Spell check subtitle
  ///
  /// In en, this message translates to:
  /// **'Check spelling while typing'**
  String get checkSpellingWhileTyping;

  /// Data directory setting label
  ///
  /// In en, this message translates to:
  /// **'Data Directory'**
  String get dataDirectory;

  /// Default data directory location
  ///
  /// In en, this message translates to:
  /// **'Default location'**
  String get defaultLocation;

  /// Clear search index setting label
  ///
  /// In en, this message translates to:
  /// **'Clear Search Index'**
  String get clearSearchIndex;

  /// Clear search index subtitle
  ///
  /// In en, this message translates to:
  /// **'Rebuild search index from scratch'**
  String get rebuildSearchIndexFromScratch;

  /// Export all data setting label
  ///
  /// In en, this message translates to:
  /// **'Export All Data'**
  String get exportAllData;

  /// Export all data subtitle
  ///
  /// In en, this message translates to:
  /// **'Export all vaults and notes'**
  String get exportAllVaultsAndNotes;

  /// Licenses label
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// Source code label
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get sourceCode;

  /// Reset to defaults label
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// Reset to defaults subtitle
  ///
  /// In en, this message translates to:
  /// **'Reset all settings to default values'**
  String get resetAllSettingsToDefaultValues;

  /// Reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Theme mode system option description
  ///
  /// In en, this message translates to:
  /// **'Follow system setting'**
  String get followSystemSetting;

  /// Theme mode light option description
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get lightTheme;

  /// Theme mode dark option description
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// Never auto-lock description
  ///
  /// In en, this message translates to:
  /// **'Never lock automatically'**
  String get neverLockAutomatically;

  /// Editor view mode edit option description
  ///
  /// In en, this message translates to:
  /// **'Edit only'**
  String get editOnly;

  /// Editor view mode preview option description
  ///
  /// In en, this message translates to:
  /// **'Preview only'**
  String get previewOnly;

  /// Editor view mode split option description
  ///
  /// In en, this message translates to:
  /// **'Side-by-side edit and preview'**
  String get sideBySideEditAndPreview;

  /// Auto-save manual only option description
  ///
  /// In en, this message translates to:
  /// **'Manual save only'**
  String get manualSaveOnly;

  /// Auto-save minutes description (singular)
  ///
  /// In en, this message translates to:
  /// **'Save every {minutes} minute'**
  String saveEveryMinute(int minutes);

  /// Auto-save minutes description (plural)
  ///
  /// In en, this message translates to:
  /// **'Save every {minutes} minutes'**
  String saveEveryMinutes(int minutes);

  /// Auto-save seconds description
  ///
  /// In en, this message translates to:
  /// **'Save every {seconds} seconds'**
  String saveEverySeconds(int seconds);

  /// Change data directory dialog title
  ///
  /// In en, this message translates to:
  /// **'Change Data Directory'**
  String get changeDataDirectory;

  /// Change data directory dialog message
  ///
  /// In en, this message translates to:
  /// **'This feature allows you to change where your vaults and notes are stored. Implementation coming soon.'**
  String get changeDataDirectoryMessage;

  /// Clear search index dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear Search Index'**
  String get clearSearchIndexTitle;

  /// Clear search index dialog message
  ///
  /// In en, this message translates to:
  /// **'This will clear the search index and rebuild it from scratch. This may take a few moments.'**
  String get clearSearchIndexMessage;

  /// Search index cleared success message
  ///
  /// In en, this message translates to:
  /// **'Search index cleared'**
  String get searchIndexCleared;

  /// Export all data dialog title
  ///
  /// In en, this message translates to:
  /// **'Export All Data'**
  String get exportAllDataTitle;

  /// Export all data dialog message
  ///
  /// In en, this message translates to:
  /// **'This will export all your vaults and notes to a ZIP file. You can then back up or transfer this file.'**
  String get exportAllDataMessage;

  /// Export feature coming soon message
  ///
  /// In en, this message translates to:
  /// **'Export feature coming soon'**
  String get exportFeatureComingSoon;

  /// Reset settings dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettingsTitle;

  /// Reset settings dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to their default values? This action cannot be undone.'**
  String get resetSettingsMessage;

  /// Settings reset to defaults success message
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsResetToDefaults;

  /// Could not launch URL error message
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunchUrl(String url);

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Auto-lock timeout in minutes
  ///
  /// In en, this message translates to:
  /// **'Lock after {count} minute(s)'**
  String lockAfterMinutes(int count);

  /// Auto-lock timeout in hours
  ///
  /// In en, this message translates to:
  /// **'Lock after {count} hour(s)'**
  String lockAfterHours(int count);

  /// Never auto-lock option
  ///
  /// In en, this message translates to:
  /// **'Never lock automatically'**
  String get neverLock;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
