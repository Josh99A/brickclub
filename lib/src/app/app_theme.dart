part of 'brickclub_app.dart';

class AppPalette {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.panel,
    required this.track,
    required this.border,
    required this.gold,
    required this.goldSoft,
    required this.primary,
    required this.secondary,
    required this.muted,
    required this.success,
    required this.warning,
  });

  final Color background;
  final Color surface;
  final Color panel;
  final Color track;
  final Color border;
  final Color gold;
  final Color goldSoft;
  final Color primary;
  final Color secondary;
  final Color muted;
  final Color success;
  final Color warning;

  static const dark = AppPalette(
    background: Color(0xFF0B0D0F),
    surface: Color(0xFF101316),
    panel: Color(0xFF15191D),
    track: Color(0xFF20252A),
    border: Color(0xFF2A3036),
    gold: Color(0xFFD8A94F),
    goldSoft: Color(0x1FD8A94F),
    primary: Color(0xFFF4F5F6),
    secondary: Color(0xFFB2B7BD),
    muted: Color(0xFF747B83),
    success: Color(0xFF51B96B),
    warning: Color(0xFFF59E0B),
  );

  static const light = AppPalette(
    background: Color(0xFFF7F4ED),
    surface: Color(0xFFFFFFFF),
    panel: Color(0xFFFFFCF6),
    track: Color(0xFFE8E0D2),
    border: Color(0xFFD6CAB7),
    gold: Color(0xFF9A6A12),
    goldSoft: Color(0x269A6A12),
    primary: Color(0xFF15110A),
    secondary: Color(0xFF504838),
    muted: Color(0xFF746A58),
    success: Color(0xFF257B40),
    warning: Color(0xFFB45309),
  );

  static AppPalette forBrightness(Brightness brightness) =>
      brightness == Brightness.light ? light : dark;
}

class AppColors extends InheritedWidget {
  const AppColors({super.key, required this.palette, required super.child});

  final AppPalette palette;

  /// Subscribes the calling widget to palette changes and returns the palette.
  static AppPalette of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppColors>()!.palette;

  @override
  bool updateShouldNotify(AppColors old) => palette != old.palette;

  // Static backing used by AppText and other build-time helpers.
  // Always up-to-date because the InheritedWidget provider updates _current
  // before notifying dependents (parent builds before children).
  static AppPalette _current = AppPalette.dark;
  static void _sync(AppPalette palette) => _current = palette;

  static Color get background => _current.background;
  static Color get surface => _current.surface;
  static Color get panel => _current.panel;
  static Color get track => _current.track;
  static Color get border => _current.border;
  static Color get gold => _current.gold;
  static Color get goldSoft => _current.goldSoft;
  static Color get primary => _current.primary;
  static Color get secondary => _current.secondary;
  static Color get muted => _current.muted;
  static Color get success => _current.success;
  static Color get warning => _current.warning;
}

abstract final class AppText {
  static TextStyle get status => TextStyle(
    color: AppColors.secondary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
  static TextStyle get authBrand => TextStyle(
    color: AppColors.primary,
    fontSize: 30,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get h1 => TextStyle(
    color: AppColors.primary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get h2 => TextStyle(
    color: AppColors.primary,
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get topTitle => TextStyle(
    color: AppColors.primary,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
  static TextStyle get detailAppBar => TextStyle(
    color: AppColors.primary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get bodyLarge => TextStyle(
    color: AppColors.secondary,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );
  static TextStyle get body => TextStyle(
    color: AppColors.secondary,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );
  static TextStyle get small => TextStyle(
    color: AppColors.secondary,
    fontSize: 11,
    height: 1.25,
    fontWeight: FontWeight.w500,
  );
  static TextStyle get tiny => TextStyle(color: AppColors.muted, fontSize: 10);
  static TextStyle get tinyLight =>
      TextStyle(color: AppColors.secondary, fontSize: 10);
  static TextStyle get disclosure =>
      TextStyle(color: AppColors.muted, fontSize: 12, height: 1.25);
  static TextStyle get fieldLabel => TextStyle(
    color: AppColors.secondary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static TextStyle get placeholder => TextStyle(
    color: AppColors.muted,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static TextStyle get eyebrow => TextStyle(
    color: AppColors.gold,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static TextStyle get goldBody => TextStyle(
    color: AppColors.gold,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get warning => TextStyle(
    color: AppColors.warning,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static TextStyle get hero => TextStyle(
    color: AppColors.primary,
    fontSize: 42,
    height: 1.05,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );
  static TextStyle get walletValue => TextStyle(
    color: AppColors.primary,
    fontSize: 35,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get portfolioValue => TextStyle(
    color: AppColors.primary,
    fontSize: 34,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get detailTitle => TextStyle(
    color: AppColors.primary,
    fontSize: 27,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get cardHeading => TextStyle(
    color: AppColors.primary,
    fontSize: 20,
    height: 1.15,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get cardHeadingSmall => TextStyle(
    color: AppColors.primary,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get investmentTitle => TextStyle(
    color: AppColors.primary,
    fontSize: 17,
    height: 1.15,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get goldMetric => TextStyle(
    color: AppColors.gold,
    fontSize: 34,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get goldMetricSmall => TextStyle(
    color: AppColors.gold,
    fontSize: 19,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get brandMark => TextStyle(
    color: AppColors.gold,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get headerIcon => TextStyle(
    color: AppColors.primary,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get headerInitials => TextStyle(
    color: AppColors.gold,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
