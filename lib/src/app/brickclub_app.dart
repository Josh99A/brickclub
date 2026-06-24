import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
// intl also exports a `TextDirection` (LTR/RTL); hide it so `TextDirection`
// resolves to Flutter's (ltr/rtl), used for RTL-aware layout.
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../core/web/pwa_install.dart';
import '../features/admin/domain/admin_models.dart';
import '../features/admin/domain/admin_repository.dart';
import '../features/auth/domain/auth_credentials.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/investment/domain/investment_models.dart';
import '../features/investment/domain/investment_repository.dart';
import '../features/kyc/domain/kyc_models.dart';
import '../features/kyc/domain/kyc_repository.dart';
import '../features/referral/domain/referral_models.dart';
import '../features/referral/domain/referral_repository.dart';
import '../features/support/domain/support_models.dart';
import '../features/support/domain/support_repository.dart';

part 'splash_screen.dart';
part 'landing_page.dart';
part 'sign_in_screen.dart';
part 'admin_dashboard.dart';
part 'sign_up_screen.dart';
part 'member_shell.dart';
part 'kyc_screen.dart';
part 'home_screen.dart';
part 'invest_screen.dart';
part 'wallet_screen.dart';
part 'portfolio_screen.dart';
part 'profile_screen.dart';
part 'referral_screen.dart';
part 'support_screens.dart';
part 'filters_screen.dart';
part 'detail_screen.dart';
part 'payment_screen.dart';
part 'success_screen.dart';
part 'app_widgets.dart';
part 'app_theme.dart';
part 'phone_sign_in_sheet.dart';


final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

const _themeModePreferenceKey = 'brickclub.themeMode';
const _localePreferenceKey = 'brickclub.locale';

/// Exposes the active locale and a setter to the whole widget tree so any
/// screen (signed in or not) can offer a language switcher without threading
/// the controller through constructors.
class LocaleControllerScope extends InheritedWidget {
  const LocaleControllerScope({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
    required super.child,
  });

  final Locale? locale;
  final ValueChanged<Locale?> onLocaleChanged;

  static LocaleControllerScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LocaleControllerScope>();
    assert(scope != null, 'LocaleControllerScope was not found in the tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(LocaleControllerScope oldWidget) =>
      locale != oldWidget.locale;
}

class BrickClubApp extends StatefulWidget {
  const BrickClubApp({
    super.key,
    required this.authRepository,
    required this.adminRepository,
    required this.investmentRepository,
    required this.kycRepository,
    required this.referralRepository,
    required this.supportRepository,
    this.showLandingPage = kIsWeb,
    this.splashDuration = const Duration(seconds: 2),
  });

  final AuthRepository authRepository;
  final AdminRepository adminRepository;
  final InvestmentRepository investmentRepository;
  final KycRepository kycRepository;
  final ReferralRepository referralRepository;
  final SupportRepository supportRepository;
  final bool showLandingPage;
  final Duration splashDuration;

  @override
  State<BrickClubApp> createState() => _BrickClubAppState();
}

class _BrickClubAppState extends State<BrickClubApp> {
  final _themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  // null = follow the device language (Flutter resolves to a supported locale).
  final _localeNotifier = ValueNotifier<Locale?>(null);
  late final GoRouter _router;

  String get _authEntry => widget.showLandingPage ? '/landing' : '/signin';

  @override
  void initState() {
    super.initState();
    _themeModeNotifier.addListener(() => setState(() {}));
    _localeNotifier.addListener(() => setState(() {}));
    _loadThemeMode();
    _loadLocale();
    _router = _createRouter();
  }

  @override
  void dispose() {
    _themeModeNotifier.dispose();
    _localeNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    final storedMode = preferences.getString(_themeModePreferenceKey);
    final mode = switch (storedMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    if (mounted) {
      _themeModeNotifier.value = mode;
    }
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    _themeModeNotifier.value = mode;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModePreferenceKey, mode.name);
  }

  Future<void> _loadLocale() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_localePreferenceKey);
    if (stored == null || stored.isEmpty) return;
    final locale = Locale(stored);
    final isSupported = AppLocalizations.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
    if (mounted && isSupported) {
      _localeNotifier.value = locale;
    }
  }

  // Pass null to clear the override and follow the device language.
  Future<void> _setLocale(Locale? locale) async {
    _localeNotifier.value = locale;
    final preferences = await SharedPreferences.getInstance();
    if (locale == null) {
      await preferences.remove(_localePreferenceKey);
    } else {
      await preferences.setString(_localePreferenceKey, locale.languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BrickClub',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      themeMode: _themeModeNotifier.value,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      locale: _localeNotifier.value,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: _router,
      builder: (context, child) {
        final palette = AppPalette.forBrightness(Theme.of(context).brightness);
        AppColors._sync(palette);
        return LocaleControllerScope(
          locale: _localeNotifier.value,
          onLocaleChanged: _setLocale,
          child: AppColors(
            palette: palette,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  GoRouter _createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: widget.showLandingPage ? '/landing' : '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) =>
              _SplashGate(duration: widget.splashDuration),
        ),
        GoRoute(
          path: '/landing',
          builder: (context, state) => LandingPage(
            investmentRepository: widget.investmentRepository,
            onSignIn: () => context.go('/signin'),
            onSignUp: () => context.go('/signup'),
          ),
        ),
        GoRoute(
          path: '/signin',
          builder: (context, state) => SignInScreen(
            authRepository: widget.authRepository,
            onBack: () => context.go(_authEntry),
            onMemberSignedIn: () => context.go('/home'),
            onAdminSignedIn: () => context.go('/admin'),
            onCreateAccount: () => context.go('/signup'),
          ),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => SignUpScreen(
            authRepository: widget.authRepository,
            onBack: () => context.go(_authEntry),
            onSignIn: () => context.go('/signin'),
            onCreated: () => context.go('/home'),
          ),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => AdminDashboard(
            authRepository: widget.authRepository,
            adminRepository: widget.adminRepository,
            onSignOut: () async {
              await widget.authRepository.signOut();
              _router.go(_authEntry);
            },
          ),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => MemberShell(
            navigationShell: navigationShell,
            kycRepository: widget.kycRepository,
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => Builder(
                    builder: (context) {
                      AppColors.of(context);
                      final scope = MemberScope.of(context);
                      return HomeScreen(
                        kyc: scope.kyc,
                        investmentRepository: widget.investmentRepository,
                        onInvest: () => scope.goBranch(1),
                        onOpenPortfolio: () => scope.goBranch(3),
                        onStartKyc: () => _openKyc(context),
                        onOpenProfile: () => scope.goBranch(4),
                      );
                    },
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/invest',
                  builder: (context, state) => Builder(
                    builder: (context) {
                      AppColors.of(context);
                      final scope = MemberScope.of(context);
                      return InvestScreen(
                        kyc: scope.kyc,
                        investmentRepository: widget.investmentRepository,
                        onStartKyc: () => _openKyc(context),
                        onOpenProfile: () => scope.goBranch(4),
                      );
                    },
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/wallet',
                  builder: (context, state) => Builder(
                    builder: (context) {
                      AppColors.of(context);
                      final scope = MemberScope.of(context);
                      return WalletScreen(
                        kyc: scope.kyc,
                        investmentRepository: widget.investmentRepository,
                        onStartKyc: () => _openKyc(context),
                        onOpenProfile: () => scope.goBranch(4),
                      );
                    },
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/portfolio',
                  builder: (context, state) => Builder(
                    builder: (context) {
                      AppColors.of(context);
                      final scope = MemberScope.of(context);
                      return PortfolioScreen(
                        investmentRepository: widget.investmentRepository,
                        onOpenProfile: () => scope.goBranch(4),
                      );
                    },
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/more',
                  builder: (context, state) => Builder(
                    builder: (context) {
                      AppColors.of(context);
                      final scope = MemberScope.of(context);
                      return ValueListenableBuilder<ThemeMode>(
                        valueListenable: _themeModeNotifier,
                        builder: (context, themeMode, _) => ProfileScreen(
                          user: widget.authRepository.currentUserDetails(),
                          kyc: scope.kyc,
                          supportRepository: widget.supportRepository,
                          referralRepository: widget.referralRepository,
                          themeMode: themeMode,
                          onThemeModeChanged: _setThemeMode,
                          locale: _localeNotifier.value,
                          onLocaleChanged: _setLocale,
                          onStartKyc: () => _openKyc(context),
                          onSignOut: () async {
                            await widget.authRepository.signOut();
                            _router.go(_authEntry);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _openKyc(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => KycScreen(repository: widget.kycRepository),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final palette = AppPalette.forBrightness(brightness);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: palette.gold,
      brightness: brightness,
      primary: palette.gold,
      surface: palette.panel,
    );
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        hintStyle: TextStyle(color: palette.muted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.panel,
        contentTextStyle: TextStyle(color: palette.primary),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

}

/// Shows the splash screen, then advances to sign in once [duration] elapses.
class _SplashGate extends StatefulWidget {
  const _SplashGate({required this.duration});

  final Duration duration;

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.duration, () {
      if (mounted) {
        context.go('/signin');
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SplashScreen();
}

