// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Null Space';

  @override
  String get notes => '노트';

  @override
  String get search => '검색';

  @override
  String get vault => '보관함';

  @override
  String get settings => '설정';

  @override
  String get createNote => '노트 만들기';

  @override
  String get settingsTitle => '설정';

  @override
  String get appearance => '외관';

  @override
  String get security => '보안';

  @override
  String get editor => '편집기';

  @override
  String get storage => '저장소';

  @override
  String get about => '정보';

  @override
  String get theme => '테마';

  @override
  String get language => '언어';

  @override
  String get system => '시스템 기본값';

  @override
  String get light => '라이트';

  @override
  String get dark => '다크';

  @override
  String get fontSize => '글꼴 크기';

  @override
  String get lineSpacing => '줄 간격';

  @override
  String get autoLockTimeout => '자동 잠금 시간';

  @override
  String get biometricUnlock => '생체 인증 잠금 해제';

  @override
  String get oneMinute => '1분';

  @override
  String get fiveMinutes => '5분';

  @override
  String get fifteenMinutes => '15분';

  @override
  String get thirtyMinutes => '30분';

  @override
  String get never => '사용 안 함';

  @override
  String get defaultView => '기본 보기';

  @override
  String get editMode => '편집';

  @override
  String get previewMode => '미리보기';

  @override
  String get splitMode => '분할';

  @override
  String get showLineNumbers => '줄 번호 표시';

  @override
  String get autoSave => '자동 저장';

  @override
  String get storageLocation => '저장 위치';

  @override
  String get cacheSize => '캐시 크기';

  @override
  String get clearCache => '캐시 지우기';

  @override
  String get exportData => '데이터 내보내기';

  @override
  String get version => '버전';

  @override
  String get license => '라이선스';

  @override
  String get resetSettings => '설정 초기화';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get create => '만들기';

  @override
  String get import => '가져오기';

  @override
  String get export => '내보내기';

  @override
  String get unlock => '잠금 해제';

  @override
  String get rename => '이름 바꾸기';

  @override
  String get clear => '지우기';

  @override
  String get ok => '확인';

  @override
  String get yes => '예';

  @override
  String get no => '아니오';

  @override
  String get vaultScreen => '보관함';

  @override
  String get noVaults => '보관함 없음';

  @override
  String get createNewVaultPrompt => '새 보관함을 만들어 시작하세요';

  @override
  String get createVault => '보관함 만들기';

  @override
  String get importVault => '보관함 가져오기';

  @override
  String get renameVault => '보관함 이름 바꾸기';

  @override
  String get deleteVault => '보관함 삭제';

  @override
  String get deleteVaultMessage => '이 보관함을 삭제하시겠습니까? 모든 노트가 영구적으로 삭제됩니다.';

  @override
  String get createNewVault => '새 보관함 만들기';

  @override
  String get vaultName => '보관함 이름';

  @override
  String get vaultNameRequired => '보관함 이름을 입력하세요';

  @override
  String get description => '설명';

  @override
  String get password => '비밀번호';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get passwordRequired => '비밀번호를 입력하세요';

  @override
  String get passwordMinLength => '비밀번호는 최소 8자 이상이어야 합니다';

  @override
  String get passwordsDoNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get passwordStrengthWeak => '약함';

  @override
  String get passwordStrengthMedium => '보통';

  @override
  String get passwordStrengthStrong => '강함';

  @override
  String get passwordStrengthVeryStrong => '매우 강함';

  @override
  String get unlockVault => '보관함 잠금 해제';

  @override
  String get unlockWithBiometrics => '생체 인증으로 잠금 해제';

  @override
  String get incorrectPassword => '잘못된 비밀번호';

  @override
  String get failedToUnlock => '잠금 해제 실패';

  @override
  String get newNote => '새 노트';

  @override
  String get editNote => '노트 편집';

  @override
  String get title => '제목';

  @override
  String get content => '내용';

  @override
  String get tags => '태그';

  @override
  String get titleRequired => '제목을 입력하세요';

  @override
  String get contentRequired => '내용을 입력하세요';

  @override
  String get writeNoteHint => 'Markdown으로 노트 작성...';

  @override
  String get unsavedChanges => '저장되지 않은 변경사항';

  @override
  String get unsavedChangesMessage => '저장되지 않은 변경사항이 있습니다. 저장하시겠습니까?';

  @override
  String get discard => '취소';

  @override
  String get deleteNote => '노트 삭제';

  @override
  String get deleteNoteMessage => '이 노트를 삭제하시겠습니까?';

  @override
  String deleteNoteConfirmation(String title) {
    return '\"$title\" 삭제?';
  }

  @override
  String get noteSaved => '노트가 저장되었습니다';

  @override
  String get noteDeleted => '노트가 삭제되었습니다';

  @override
  String get searchNotes => '노트 검색...';

  @override
  String get clearSearch => '검색 지우기';

  @override
  String get searchYourNotes => '노트 검색';

  @override
  String get enterKeywords => '키워드를 입력하여 노트를 찾으세요';

  @override
  String get noResultsFound => '결과를 찾을 수 없음';

  @override
  String get tryDifferentKeywords => '다른 키워드를 시도하거나 철자를 확인하세요';

  @override
  String get noNotesYet => '노트가 아직 없습니다';

  @override
  String get createFirstNote => '+ 를 눌러 첫 번째 노트를 만드세요';

  @override
  String get sortBy => '정렬 기준';

  @override
  String get recentlyUpdated => '최근 업데이트';

  @override
  String get recentlyCreated => '최근 생성';

  @override
  String get titleAZ => '제목 가나다순';

  @override
  String get titleZA => '제목 역순';

  @override
  String get filterByTags => '태그로 필터';

  @override
  String get untitledNote => '제목 없는 노트';

  @override
  String get updated => '업데이트됨';

  @override
  String get deleteNoteTooltip => '노트 삭제';

  @override
  String get vaultCreated => '보관함이 생성되었습니다';

  @override
  String get vaultImported => '보관함을 가져왔습니다';

  @override
  String get vaultRenamed => '보관함 이름이 변경되었습니다';

  @override
  String get vaultDeleted => '보관함이 삭제되었습니다';

  @override
  String get error => '오류';

  @override
  String get genericError => '오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get english => '영어';

  @override
  String get chineseSimplified => '중국어 간체';

  @override
  String get chineseTraditional => '중국어 번체';

  @override
  String get japanese => '일본어';

  @override
  String get korean => '한국어';

  @override
  String get oneHour => '1 hour';

  @override
  String get useFingerprintOrFaceUnlock => 'Use fingerprint or face unlock';

  @override
  String get clearClipboardAfterPaste => 'Clear Clipboard After Paste';

  @override
  String get automaticallyClearClipboardForSecurity =>
      'Automatically clear clipboard for security';

  @override
  String get defaultViewMode => 'Default View Mode';

  @override
  String get autoSaveInterval => 'Auto-save Interval';

  @override
  String get tenSeconds => '10 seconds';

  @override
  String get thirtySeconds => '30 seconds';

  @override
  String get fiveMinutesInterval => '5 minutes';

  @override
  String get manualOnly => 'Manual only';

  @override
  String get spellCheck => 'Spell Check';

  @override
  String get checkSpellingWhileTyping => 'Check spelling while typing';

  @override
  String get dataDirectory => 'Data Directory';

  @override
  String get defaultLocation => 'Default location';

  @override
  String get clearSearchIndex => 'Clear Search Index';

  @override
  String get rebuildSearchIndexFromScratch =>
      'Rebuild search index from scratch';

  @override
  String get exportAllData => 'Export All Data';

  @override
  String get exportAllVaultsAndNotes => 'Export all vaults and notes';

  @override
  String get licenses => 'Licenses';

  @override
  String get sourceCode => 'Source Code';

  @override
  String get resetToDefaults => 'Reset to Defaults';

  @override
  String get resetAllSettingsToDefaultValues =>
      'Reset all settings to default values';

  @override
  String get reset => 'Reset';

  @override
  String get followSystemSetting => 'Follow system setting';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get neverLockAutomatically => 'Never lock automatically';

  @override
  String get editOnly => 'Edit only';

  @override
  String get previewOnly => 'Preview only';

  @override
  String get sideBySideEditAndPreview => 'Side-by-side edit and preview';

  @override
  String get manualSaveOnly => 'Manual save only';

  @override
  String saveEveryMinute(int minutes) {
    return 'Save every $minutes minute';
  }

  @override
  String saveEveryMinutes(int minutes) {
    return 'Save every $minutes minutes';
  }

  @override
  String saveEverySeconds(int seconds) {
    return 'Save every $seconds seconds';
  }

  @override
  String get changeDataDirectory => 'Change Data Directory';

  @override
  String get changeDataDirectoryMessage =>
      'This feature allows you to change where your vaults and notes are stored. Implementation coming soon.';

  @override
  String get clearSearchIndexTitle => 'Clear Search Index';

  @override
  String get clearSearchIndexMessage =>
      'This will clear the search index and rebuild it from scratch. This may take a few moments.';

  @override
  String get searchIndexCleared => 'Search index cleared';

  @override
  String get exportAllDataTitle => 'Export All Data';

  @override
  String get exportAllDataMessage =>
      'This will export all your vaults and notes to a ZIP file. You can then back up or transfer this file.';

  @override
  String get exportFeatureComingSoon => 'Export feature coming soon';

  @override
  String get resetSettingsTitle => 'Reset Settings';

  @override
  String get resetSettingsMessage =>
      'Are you sure you want to reset all settings to their default values? This action cannot be undone.';

  @override
  String get settingsResetToDefaults => 'Settings reset to defaults';

  @override
  String couldNotLaunchUrl(String url) {
    return 'Could not launch $url';
  }

  @override
  String get loading => 'Loading...';

  @override
  String lockAfterMinutes(int count) {
    return '$count분 후 잠금';
  }

  @override
  String lockAfterHours(int count) {
    return '$count시간 후 잠금';
  }

  @override
  String get neverLock => '자동 잠금 안 함';
}
