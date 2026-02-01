// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Null Space';

  @override
  String get notes => 'ノート';

  @override
  String get search => '検索';

  @override
  String get vault => 'Vault';

  @override
  String get settings => '設定';

  @override
  String get createNote => 'ノートを作成';

  @override
  String get settingsTitle => '設定';

  @override
  String get appearance => '外観';

  @override
  String get security => 'セキュリティ';

  @override
  String get editor => 'エディター';

  @override
  String get storage => 'ストレージ';

  @override
  String get about => 'について';

  @override
  String get theme => 'テーマ';

  @override
  String get language => '言語';

  @override
  String get system => 'システムデフォルト';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get fontSize => 'フォントサイズ';

  @override
  String get lineSpacing => '行間';

  @override
  String get autoLockTimeout => '自動ロックタイムアウト';

  @override
  String get biometricUnlock => '生体認証でロック解除';

  @override
  String get oneMinute => '1分';

  @override
  String get fiveMinutes => '5分';

  @override
  String get fifteenMinutes => '15分';

  @override
  String get thirtyMinutes => '30分';

  @override
  String get never => 'なし';

  @override
  String get defaultView => 'デフォルトビュー';

  @override
  String get editMode => '編集';

  @override
  String get previewMode => 'プレビュー';

  @override
  String get splitMode => '分割';

  @override
  String get showLineNumbers => '行番号を表示';

  @override
  String get autoSave => '自動保存';

  @override
  String get storageLocation => '保存場所';

  @override
  String get cacheSize => 'キャッシュサイズ';

  @override
  String get clearCache => 'キャッシュをクリア';

  @override
  String get exportData => 'データをエクスポート';

  @override
  String get version => 'バージョン';

  @override
  String get license => 'ライセンス';

  @override
  String get resetSettings => '設定をリセット';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get create => '作成';

  @override
  String get import => 'インポート';

  @override
  String get export => 'エクスポート';

  @override
  String get unlock => 'ロック解除';

  @override
  String get rename => '名前を変更';

  @override
  String get clear => 'クリア';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get vaultScreen => 'Vault';

  @override
  String get noVaults => 'Vaultがありません';

  @override
  String get createNewVaultPrompt => '新しいVaultを作成して始めましょう';

  @override
  String get createVault => 'Vaultを作成';

  @override
  String get importVault => 'Vaultをインポート';

  @override
  String get renameVault => 'Vaultの名前を変更';

  @override
  String get deleteVault => 'Vaultを削除';

  @override
  String get deleteVaultMessage => 'このVaultを削除してもよろしいですか？すべてのノートが完全に削除されます。';

  @override
  String get createNewVault => '新しいVaultを作成';

  @override
  String get vaultName => 'Vault名';

  @override
  String get vaultNameRequired => 'Vault名を入力してください';

  @override
  String get description => '説明';

  @override
  String get password => 'パスワード';

  @override
  String get confirmPassword => 'パスワードの確認';

  @override
  String get passwordRequired => 'パスワードを入力してください';

  @override
  String get passwordMinLength => 'パスワードは8文字以上にしてください';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get passwordStrengthWeak => '弱い';

  @override
  String get passwordStrengthMedium => '普通';

  @override
  String get passwordStrengthStrong => '強い';

  @override
  String get passwordStrengthVeryStrong => '非常に強い';

  @override
  String get unlockVault => 'Vaultのロック解除';

  @override
  String get unlockWithBiometrics => '生体認証でロック解除';

  @override
  String get incorrectPassword => 'パスワードが正しくありません';

  @override
  String get failedToUnlock => 'ロック解除に失敗しました';

  @override
  String get newNote => '新しいノート';

  @override
  String get editNote => 'ノートを編集';

  @override
  String get title => 'タイトル';

  @override
  String get content => '内容';

  @override
  String get tags => 'タグ';

  @override
  String get titleRequired => 'タイトルを入力してください';

  @override
  String get contentRequired => '内容を入力してください';

  @override
  String get writeNoteHint => 'Markdownでノートを書く...';

  @override
  String get unsavedChanges => '未保存の変更';

  @override
  String get unsavedChangesMessage => '保存されていない変更があります。保存しますか？';

  @override
  String get discard => '破棄';

  @override
  String get deleteNote => 'ノートを削除';

  @override
  String get deleteNoteMessage => 'このノートを削除してもよろしいですか？';

  @override
  String deleteNoteConfirmation(String title) {
    return '\"$title\"を削除？';
  }

  @override
  String get noteSaved => 'ノートを保存しました';

  @override
  String get noteDeleted => 'ノートを削除しました';

  @override
  String get searchNotes => 'ノートを検索...';

  @override
  String get clearSearch => '検索をクリア';

  @override
  String get searchYourNotes => 'ノートを検索';

  @override
  String get enterKeywords => 'キーワードを入力してノートを検索';

  @override
  String get noResultsFound => '結果が見つかりません';

  @override
  String get tryDifferentKeywords => '別のキーワードを試すか、スペルを確認してください';

  @override
  String get noNotesYet => 'ノートがまだありません';

  @override
  String get createFirstNote => '+ をタップして最初のノートを作成';

  @override
  String get sortBy => '並べ替え';

  @override
  String get recentlyUpdated => '最近更新された';

  @override
  String get recentlyCreated => '最近作成された';

  @override
  String get titleAZ => 'タイトルA-Z';

  @override
  String get titleZA => 'タイトルZ-A';

  @override
  String get filterByTags => 'タグでフィルター';

  @override
  String get untitledNote => 'タイトルなし';

  @override
  String get updated => '更新日時';

  @override
  String get deleteNoteTooltip => 'ノートを削除';

  @override
  String get vaultCreated => 'Vaultを作成しました';

  @override
  String get vaultImported => 'Vaultをインポートしました';

  @override
  String get vaultRenamed => 'Vaultの名前を変更しました';

  @override
  String get vaultDeleted => 'Vaultを削除しました';

  @override
  String get error => 'エラー';

  @override
  String get genericError => 'エラーが発生しました。もう一度お試しください。';

  @override
  String get english => '英語';

  @override
  String get chineseSimplified => '簡体字中国語';

  @override
  String get chineseTraditional => '繁体字中国語';

  @override
  String get japanese => '日本語';

  @override
  String get korean => '韓国語';

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
    return '$count分後にロック';
  }

  @override
  String lockAfterHours(int count) {
    return '$count時間後にロック';
  }

  @override
  String get neverLock => '自動ロックしない';
}
