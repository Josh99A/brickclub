// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => '语言';

  @override
  String get languageScreenTitle => '语言';

  @override
  String get languageHeading => '显示语言';

  @override
  String get languageDescription => '选择 BrickClub 在此设备上使用的语言。';

  @override
  String get languageSystemDefault => '系统默认';
}
