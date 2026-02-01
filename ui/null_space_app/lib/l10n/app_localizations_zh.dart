// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '空间笔记';

  @override
  String get notes => '笔记';

  @override
  String get search => '搜索';

  @override
  String get vault => '保险库';

  @override
  String get settings => '设置';

  @override
  String get createNote => '创建笔记';

  @override
  String get settingsTitle => '设置';

  @override
  String get appearance => '外观';

  @override
  String get security => '安全';

  @override
  String get editor => '编辑器';

  @override
  String get storage => '存储';

  @override
  String get about => '关于';

  @override
  String get theme => '主题';

  @override
  String get language => '语言';

  @override
  String get system => '系统默认';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get fontSize => '字体大小';

  @override
  String get lineSpacing => '行距';

  @override
  String get autoLockTimeout => '自动锁定超时';

  @override
  String get biometricUnlock => '生物识别解锁';

  @override
  String get oneMinute => '1分钟';

  @override
  String get fiveMinutes => '5分钟';

  @override
  String get fifteenMinutes => '15分钟';

  @override
  String get thirtyMinutes => '30分钟';

  @override
  String get never => '从不';

  @override
  String get defaultView => '默认视图';

  @override
  String get editMode => '编辑';

  @override
  String get previewMode => '预览';

  @override
  String get splitMode => '分屏';

  @override
  String get showLineNumbers => '显示行号';

  @override
  String get autoSave => '自动保存';

  @override
  String get storageLocation => '存储位置';

  @override
  String get cacheSize => '缓存大小';

  @override
  String get clearCache => '清除缓存';

  @override
  String get exportData => '导出数据';

  @override
  String get version => '版本';

  @override
  String get license => '许可证';

  @override
  String get resetSettings => '重置设置';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get create => '创建';

  @override
  String get import => '导入';

  @override
  String get export => '导出';

  @override
  String get unlock => '解锁';

  @override
  String get rename => '重命名';

  @override
  String get clear => '清除';

  @override
  String get ok => '确定';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get vaultScreen => '保险库';

  @override
  String get noVaults => '暂无保险库';

  @override
  String get createNewVaultPrompt => '创建一个新保险库以开始使用';

  @override
  String get createVault => '创建保险库';

  @override
  String get importVault => '导入保险库';

  @override
  String get renameVault => '重命名保险库';

  @override
  String get deleteVault => '删除保险库';

  @override
  String get deleteVaultMessage => '确定要删除此保险库吗？所有笔记将被永久删除。';

  @override
  String get createNewVault => '创建新保险库';

  @override
  String get vaultName => '保险库名称';

  @override
  String get vaultNameRequired => '保险库名称不能为空';

  @override
  String get description => '描述';

  @override
  String get password => '密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get passwordRequired => '密码不能为空';

  @override
  String get passwordMinLength => '密码至少需要8个字符';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get passwordStrengthWeak => '弱';

  @override
  String get passwordStrengthMedium => '中等';

  @override
  String get passwordStrengthStrong => '强';

  @override
  String get passwordStrengthVeryStrong => '非常强';

  @override
  String get unlockVault => '解锁保险库';

  @override
  String get unlockWithBiometrics => '使用生物识别解锁';

  @override
  String get incorrectPassword => '密码错误';

  @override
  String get failedToUnlock => '解锁失败';

  @override
  String get newNote => '新建笔记';

  @override
  String get editNote => '编辑笔记';

  @override
  String get title => '标题';

  @override
  String get content => '内容';

  @override
  String get tags => '标签';

  @override
  String get titleRequired => '请输入标题';

  @override
  String get contentRequired => '请输入内容';

  @override
  String get writeNoteHint => '使用 Markdown 编写笔记...';

  @override
  String get unsavedChanges => '未保存的更改';

  @override
  String get unsavedChangesMessage => '您有未保存的更改。是否要保存它们？';

  @override
  String get discard => '放弃';

  @override
  String get deleteNote => '删除笔记';

  @override
  String get deleteNoteMessage => '确定要删除此笔记吗？';

  @override
  String deleteNoteConfirmation(String title) {
    return '删除 \"$title\"？';
  }

  @override
  String get noteSaved => '笔记已保存';

  @override
  String get noteDeleted => '笔记已删除';

  @override
  String get searchNotes => '搜索笔记...';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get searchYourNotes => '搜索您的笔记';

  @override
  String get enterKeywords => '输入关键词查找笔记';

  @override
  String get noResultsFound => '未找到结果';

  @override
  String get tryDifferentKeywords => '尝试不同的关键词或检查拼写';

  @override
  String get noNotesYet => '暂无笔记';

  @override
  String get createFirstNote => '点击 + 创建您的第一条笔记';

  @override
  String get sortBy => '排序方式';

  @override
  String get recentlyUpdated => '最近更新';

  @override
  String get recentlyCreated => '最近创建';

  @override
  String get titleAZ => '标题A-Z';

  @override
  String get titleZA => '标题Z-A';

  @override
  String get filterByTags => '按标签筛选';

  @override
  String get untitledNote => '无标题笔记';

  @override
  String get updated => '更新于';

  @override
  String get deleteNoteTooltip => '删除笔记';

  @override
  String get vaultCreated => '保险库创建成功';

  @override
  String get vaultImported => '保险库导入成功';

  @override
  String get vaultRenamed => '保险库重命名成功';

  @override
  String get vaultDeleted => '保险库删除成功';

  @override
  String get error => '错误';

  @override
  String get genericError => '发生错误，请重试。';

  @override
  String get english => '英语';

  @override
  String get chineseSimplified => '简体中文';

  @override
  String get chineseTraditional => '繁体中文';

  @override
  String get japanese => '日语';

  @override
  String get korean => '韩语';

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
    return '$count分钟后锁定';
  }

  @override
  String lockAfterHours(int count) {
    return '$count小时后锁定';
  }

  @override
  String get neverLock => '从不自动锁定';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => '空間筆記';

  @override
  String get notes => '筆記';

  @override
  String get search => '搜尋';

  @override
  String get vault => '保險庫';

  @override
  String get settings => '設定';

  @override
  String get createNote => '建立筆記';

  @override
  String get settingsTitle => '設定';

  @override
  String get appearance => '外觀';

  @override
  String get security => '安全性';

  @override
  String get editor => '編輯器';

  @override
  String get storage => '儲存';

  @override
  String get about => '關於';

  @override
  String get theme => '主題';

  @override
  String get language => '語言';

  @override
  String get system => '系統預設';

  @override
  String get light => '淺色';

  @override
  String get dark => '深色';

  @override
  String get fontSize => '字型大小';

  @override
  String get lineSpacing => '行距';

  @override
  String get autoLockTimeout => '自動鎖定逾時';

  @override
  String get biometricUnlock => '生物辨識解鎖';

  @override
  String get oneMinute => '1分鐘';

  @override
  String get fiveMinutes => '5分鐘';

  @override
  String get fifteenMinutes => '15分鐘';

  @override
  String get thirtyMinutes => '30分鐘';

  @override
  String get never => '永不';

  @override
  String get defaultView => '預設檢視';

  @override
  String get editMode => '編輯';

  @override
  String get previewMode => '預覽';

  @override
  String get splitMode => '分割';

  @override
  String get showLineNumbers => '顯示行號';

  @override
  String get autoSave => '自動儲存';

  @override
  String get storageLocation => '儲存位置';

  @override
  String get cacheSize => '快取大小';

  @override
  String get clearCache => '清除快取';

  @override
  String get exportData => '匯出資料';

  @override
  String get version => '版本';

  @override
  String get license => '授權';

  @override
  String get resetSettings => '重設設定';

  @override
  String get cancel => '取消';

  @override
  String get save => '儲存';

  @override
  String get delete => '刪除';

  @override
  String get create => '建立';

  @override
  String get import => '匯入';

  @override
  String get export => '匯出';

  @override
  String get unlock => '解鎖';

  @override
  String get rename => '重新命名';

  @override
  String get clear => '清除';

  @override
  String get ok => '確定';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get vaultScreen => '保險庫';

  @override
  String get noVaults => '暫無保險庫';

  @override
  String get createNewVaultPrompt => '建立新保險庫以開始使用';

  @override
  String get createVault => '建立保險庫';

  @override
  String get importVault => '匯入保險庫';

  @override
  String get renameVault => '重新命名保險庫';

  @override
  String get deleteVault => '刪除保險庫';

  @override
  String get deleteVaultMessage => '確定要刪除此保險庫嗎？所有筆記將被永久刪除。';

  @override
  String get createNewVault => '建立新保險庫';

  @override
  String get vaultName => '保險庫名稱';

  @override
  String get vaultNameRequired => '保險庫名稱不能為空';

  @override
  String get description => '描述';

  @override
  String get password => '密碼';

  @override
  String get confirmPassword => '確認密碼';

  @override
  String get passwordRequired => '密碼不能為空';

  @override
  String get passwordMinLength => '密碼至少需要8個字元';

  @override
  String get passwordsDoNotMatch => '密碼不一致';

  @override
  String get passwordStrengthWeak => '弱';

  @override
  String get passwordStrengthMedium => '中等';

  @override
  String get passwordStrengthStrong => '強';

  @override
  String get passwordStrengthVeryStrong => '非常強';

  @override
  String get unlockVault => '解鎖保險庫';

  @override
  String get unlockWithBiometrics => '使用生物辨識解鎖';

  @override
  String get incorrectPassword => '密碼錯誤';

  @override
  String get failedToUnlock => '解鎖失敗';

  @override
  String get newNote => '新增筆記';

  @override
  String get editNote => '編輯筆記';

  @override
  String get title => '標題';

  @override
  String get content => '內容';

  @override
  String get tags => '標籤';

  @override
  String get titleRequired => '請輸入標題';

  @override
  String get contentRequired => '請輸入內容';

  @override
  String get writeNoteHint => '使用 Markdown 編寫筆記...';

  @override
  String get unsavedChanges => '未儲存的變更';

  @override
  String get unsavedChangesMessage => '您有未儲存的變更。是否要儲存它們？';

  @override
  String get discard => '放棄';

  @override
  String get deleteNote => '刪除筆記';

  @override
  String get deleteNoteMessage => '確定要刪除此筆記嗎？';

  @override
  String deleteNoteConfirmation(String title) {
    return '刪除 \"$title\"？';
  }

  @override
  String get noteSaved => '筆記已儲存';

  @override
  String get noteDeleted => '筆記已刪除';

  @override
  String get searchNotes => '搜尋筆記...';

  @override
  String get clearSearch => '清除搜尋';

  @override
  String get searchYourNotes => '搜尋您的筆記';

  @override
  String get enterKeywords => '輸入關鍵字以查找筆記';

  @override
  String get noResultsFound => '未找到結果';

  @override
  String get tryDifferentKeywords => '嘗試不同的關鍵字或檢查拼寫';

  @override
  String get noNotesYet => '暫無筆記';

  @override
  String get createFirstNote => '點擊 + 建立您的第一則筆記';

  @override
  String get sortBy => '排序方式';

  @override
  String get recentlyUpdated => '最近更新';

  @override
  String get recentlyCreated => '最近建立';

  @override
  String get titleAZ => '標題A-Z';

  @override
  String get titleZA => '標題Z-A';

  @override
  String get filterByTags => '按標籤篩選';

  @override
  String get untitledNote => '無標題筆記';

  @override
  String get updated => '更新於';

  @override
  String get deleteNoteTooltip => '刪除筆記';

  @override
  String get vaultCreated => '保險庫建立成功';

  @override
  String get vaultImported => '保險庫匯入成功';

  @override
  String get vaultRenamed => '保險庫重新命名成功';

  @override
  String get vaultDeleted => '保險庫刪除成功';

  @override
  String get error => '錯誤';

  @override
  String get genericError => '發生錯誤，請重試。';

  @override
  String get english => '英語';

  @override
  String get chineseSimplified => '簡體中文';

  @override
  String get chineseTraditional => '繁體中文';

  @override
  String get japanese => '日語';

  @override
  String get korean => '韓語';

  @override
  String lockAfterMinutes(int count) {
    return '$count分鐘後鎖定';
  }

  @override
  String lockAfterHours(int count) {
    return '$count小時後鎖定';
  }

  @override
  String get neverLock => '永不自動鎖定';
}
