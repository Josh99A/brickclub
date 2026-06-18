import 'package:file_picker/file_picker.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/admin/domain/admin_models.dart';
import '../features/admin/domain/admin_repository.dart';
import '../features/auth/domain/auth_credentials.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/investment/domain/investment_models.dart';
import '../features/investment/domain/investment_repository.dart';
import '../features/kyc/domain/kyc_models.dart';
import '../features/kyc/domain/kyc_repository.dart';
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
part 'support_screens.dart';
part 'filters_screen.dart';
part 'detail_screen.dart';
part 'payment_screen.dart';
part 'success_screen.dart';
part 'app_widgets.dart';
part 'app_theme.dart';


final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

const _themeModePreferenceKey = 'brickclub.themeMode';

class BrickClubApp extends StatefulWidget {
  const BrickClubApp({
    super.key,
    required this.authRepository,
    required this.adminRepository,
    required this.investmentRepository,
    required this.kycRepository,
    required this.supportRepository,
    this.showLandingPage = kIsWeb,
    this.splashDuration = const Duration(seconds: 2),
  });

  final AuthRepository authRepository;
  final AdminRepository adminRepository;
  final InvestmentRepository investmentRepository;
  final KycRepository kycRepository;
  final SupportRepository supportRepository;
  final bool showLandingPage;
  final Duration splashDuration;

  @override
  State<BrickClubApp> createState() => _BrickClubAppState();
}

class _BrickClubAppState extends State<BrickClubApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late final GoRouter _router;

  String get _authEntry => widget.showLandingPage ? '/landing' : '/signin';

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _router = _createRouter();
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
      setState(() => _themeMode = mode);
    }
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModePreferenceKey, mode.name);
  }

  @override
  Widget build(BuildContext context) {
    AppColors.useBrightness(_effectiveBrightness(context));
    return MaterialApp.router(
      title: 'BrickClub',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      routerConfig: _router,
      builder: (context, child) {
        AppColors.useBrightness(Theme.of(context).brightness);
        return child ?? const SizedBox.shrink();
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
                      final scope = MemberScope.of(context);
                      return HomeScreen(
                        kyc: scope.kyc,
                        investmentRepository: widget.investmentRepository,
                        onInvest: () => scope.goBranch(1),
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
                      final scope = MemberScope.of(context);
                      return ProfileScreen(
                        user: widget.authRepository.currentUserDetails(),
                        kyc: scope.kyc,
                        supportRepository: widget.supportRepository,
                        themeMode: _themeMode,
                        onThemeModeChanged: _setThemeMode,
                        onStartKyc: () => _openKyc(context),
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

  Brightness _effectiveBrightness(BuildContext context) {
    return switch (_themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system =>
        MediaQuery.maybePlatformBrightnessOf(context) ??
            View.of(context).platformDispatcher.platformBrightness,
    };
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

