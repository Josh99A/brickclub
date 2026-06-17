import 'package:file_picker/file_picker.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
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
    return MaterialApp(
      title: 'BrickClub',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      builder: (context, child) {
        AppColors.useBrightness(Theme.of(context).brightness);
        return child ?? const SizedBox.shrink();
      },
      home: AppGate(
        authRepository: widget.authRepository,
        adminRepository: widget.adminRepository,
        investmentRepository: widget.investmentRepository,
        kycRepository: widget.kycRepository,
        supportRepository: widget.supportRepository,
        showLandingPage: widget.showLandingPage,
        splashDuration: widget.splashDuration,
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
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

class AppGate extends StatefulWidget {
  const AppGate({
    super.key,
    required this.authRepository,
    required this.adminRepository,
    required this.investmentRepository,
    required this.kycRepository,
    required this.supportRepository,
    required this.showLandingPage,
    required this.splashDuration,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final AuthRepository authRepository;
  final AdminRepository adminRepository;
  final InvestmentRepository investmentRepository;
  final KycRepository kycRepository;
  final SupportRepository supportRepository;
  final bool showLandingPage;
  final Duration splashDuration;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  late AppDestination destination;

  @override
  void initState() {
    super.initState();
    destination = widget.showLandingPage
        ? AppDestination.landing
        : AppDestination.splash;
    if (!widget.showLandingPage) {
      Future<void>.delayed(widget.splashDuration, () {
        if (mounted && destination == AppDestination.splash) {
          setState(() => destination = AppDestination.signIn);
        }
      });
    }
  }

  AppDestination get authEntryDestination =>
      widget.showLandingPage ? AppDestination.landing : AppDestination.signIn;

  @override
  Widget build(BuildContext context) {
    return switch (destination) {
      AppDestination.splash => const SplashScreen(),
      AppDestination.landing => LandingPage(
        onSignIn: () => setState(() => destination = AppDestination.signIn),
        onSignUp: () => setState(() => destination = AppDestination.signUp),
      ),
      AppDestination.signIn => SignInScreen(
        authRepository: widget.authRepository,
        onBack: () => setState(() => destination = authEntryDestination),
        onMemberSignedIn: () =>
            setState(() => destination = AppDestination.member),
        onAdminSignedIn: () =>
            setState(() => destination = AppDestination.admin),
        onCreateAccount: () =>
            setState(() => destination = AppDestination.signUp),
      ),
      AppDestination.signUp => SignUpScreen(
        authRepository: widget.authRepository,
        onBack: () => setState(
          () => destination = widget.showLandingPage
              ? AppDestination.landing
              : AppDestination.signIn,
        ),
        onSignIn: () => setState(() => destination = AppDestination.signIn),
        onCreated: () => setState(() => destination = AppDestination.member),
      ),
      AppDestination.member => BrickClubShell(
        authRepository: widget.authRepository,
        investmentRepository: widget.investmentRepository,
        kycRepository: widget.kycRepository,
        supportRepository: widget.supportRepository,
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
      AppDestination.admin => AdminDashboard(
        authRepository: widget.authRepository,
        adminRepository: widget.adminRepository,
        onSignOut: () async {
          await widget.authRepository.signOut();
          setState(() => destination = authEntryDestination);
        },
      ),
    };
  }
}

enum AppDestination { splash, landing, signIn, signUp, member, admin }

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.surface, AppColors.background],
            ),
          ),
          child: Center(
            child: Container(
              width: 248,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
              decoration: BoxDecoration(
                color: AppColors.panel,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .18),
                    blurRadius: 36,
                    offset: const Offset(0, 22),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BrandLockup(height: 128),
                  SizedBox(height: 12),
                  Text(
                    'Property-backed ownership',
                    textAlign: TextAlign.center,
                    style: AppText.bodyLarge,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: 96,
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: AppColors.track,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SelectionArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _LandingHeader(onSignIn: onSignIn, onSignUp: onSignUp),
              _HeroSection(onInstall: () => _showInstallMessage(context)),
              const _TrustStrip(),
              const _HowItWorksSection(),
              const _FeatureSection(),
              const _TestimonialsSection(),
              _FinalCta(
                onInstall: () => _showInstallMessage(context),
                onSignIn: onSignIn,
                onSignUp: onSignUp,
              ),
              _LandingFooter(onSignIn: onSignIn, onSignUp: onSignUp),
            ],
          ),
        ),
      ),
    );
  }

  void _showInstallMessage(BuildContext context) {
    showMessage(context, 'App Store and Google Play links are coming soon');
  }
}

class _LandingHeader extends StatelessWidget {
  const _LandingHeader({required this.onSignIn, required this.onSignUp});

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              return Row(
                children: [
                  const _BrandLockup(),
                  const Spacer(),
                  if (!compact) ...[
                    for (final item in [
                      ('Features', 'features'),
                      ('How it works', 'how-it-works'),
                      ('Testimonials', 'testimonials'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 28),
                        child: Text(
                          item.$1,
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                  TextButton(
                    key: const ValueKey('landing-sign-in'),
                    onPressed: onSignIn,
                    child: Text('Sign in'),
                  ),
                  SizedBox(width: 10),
                  _WebButton(
                    label: compact ? 'Join' : 'Create account',
                    onPressed: onSignUp,
                    filled: true,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup({this.height = 54});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/brickclub_logo.png',
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'The Brick Club',
    );
  }
}

class _BrickMark extends StatelessWidget {
  const _BrickMark();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/brickclub_mark.png',
      width: 32,
      height: 32,
      fit: BoxFit.contain,
      semanticLabel: 'The Brick Club mark',
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onInstall});

  final VoidCallback onInstall;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(.75, -.15),
          radius: 1.2,
          colors: [Color(0xFF171B1F), AppColors.background],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 70, 28, 74),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 850;
                final copy = _HeroCopy(onInstall: onInstall);
                const visual = _HeroVisual();
                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      copy,
                      SizedBox(height: 54),
                      Center(child: visual),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(flex: 10, child: copy),
                    SizedBox(width: 60),
                    const Expanded(flex: 9, child: visual),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onInstall});

  final VoidCallback onInstall;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Own more than\na dream.',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 68,
            height: .98,
            fontWeight: FontWeight.w800,
            letterSpacing: -3.1,
          ),
        ),
        SizedBox(height: 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Build real ownership through verified property-backed '
            'BrickShares, with transparent performance and trusted crypto '
            'settlement from one secure app.',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 18,
              height: 1.55,
            ),
          ),
        ),
        SizedBox(height: 34),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _WebButton(
              key: const ValueKey('install-app'),
              label: 'Install the app',
              icon: Icons.download_rounded,
              onPressed: onInstall,
              filled: true,
            ),
            _WebButton(
              label: 'Explore BrickShares',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => showMessage(
                context,
                'Sign in to explore verified BrickShares',
              ),
            ),
          ],
        ),
        SizedBox(height: 34),
        const Wrap(
          spacing: 28,
          runSpacing: 12,
          children: [
            _ProofPoint(Icons.verified_user_outlined, 'Verified assets'),
            _ProofPoint(Icons.wallet_outlined, 'Trusted settlement'),
            _ProofPoint(Icons.insights_outlined, 'Clear performance'),
          ],
        ),
      ],
    );
  }
}

class _ProofPoint extends StatelessWidget {
  const _ProofPoint(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.gold, size: 18),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 520,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 0,
            top: 45,
            child: Container(
              width: 410,
              height: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                image: const DecorationImage(
                  image: AssetImage('assets/images/kololo_heights_v2.png'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 0,
            child: Container(
              width: 272,
              height: 480,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(38),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xA6000000),
                    blurRadius: 42,
                    offset: Offset(0, 24),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: const _PhonePreview(),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 30,
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target annual return', style: AppText.small),
                  SizedBox(height: 6),
                  Text('12.4%', style: AppText.goldMetric),
                  SizedBox(height: 10),
                  ProgressLine(value: .74, height: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhonePreview extends StatelessWidget {
  const _PhonePreview();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'BrickClub',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.secondary,
                    size: 15,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            Text('Portfolio value', style: AppText.small),
            SizedBox(height: 4),
            Text(
              'UGX 18.6M',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 27,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/kololo_heights_v2.png',
                height: 116,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Kololo Heights\nIncome Fund',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                height: 1.12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Minimum', style: AppText.tinyLight),
                Text('Target return', style: AppText.tinyLight),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('UGX 250K', style: AppText.goldBody),
                Text('12.4%', style: AppText.cardHeadingSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      color: AppColors.gold,
      child: const Wrap(
        alignment: WrapAlignment.center,
        spacing: 58,
        runSpacing: 18,
        children: [
          _DarkProof('PROPERTY DUE DILIGENCE'),
          _DarkProof('KYC VERIFIED MEMBERS'),
          _DarkProof('USDT SETTLEMENT'),
          _DarkProof('CLEAR OWNERSHIP RECORDS'),
        ],
      ),
    );
  }
}

class _DarkProof extends StatelessWidget {
  const _DarkProof(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.background,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    return const _LandingSection(
      title: 'From signup to ownership.',
      subtitle:
          'A clear path designed for investors who want confidence at every step.',
      child: LayoutBuilder(builder: _buildSteps),
    );
  }

  static Widget _buildSteps(BuildContext context, BoxConstraints constraints) {
    const steps = [
      _Step(
        '01',
        'Create and verify',
        'Open your account, complete KYC, and connect a verified wallet.',
      ),
      _Step(
        '02',
        'Choose BrickShares',
        'Review verified assets, target returns, risks, and ownership terms.',
      ),
      _Step(
        '03',
        'Fund and track',
        'Settle securely with supported crypto and monitor your portfolio.',
      ),
    ];
    if (constraints.maxWidth < 760) {
      return Column(
        children: [
          for (final step in steps)
            Padding(padding: const EdgeInsets.only(bottom: 22), child: step),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final step in steps) Expanded(child: step)],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.title, this.body);

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 34),
          Text(
            title,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 96),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final details = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Built for clarity,\nnot speculation.',
                      style: _LandingSection.headingStyle,
                    ),
                    SizedBox(height: 22),
                    Text(
                      'Every opportunity brings the important information '
                      'forward: ownership structure, asset verification, '
                      'target returns, risks, funding network, and settlement '
                      'status.',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 17,
                        height: 1.55,
                      ),
                    ),
                    SizedBox(height: 34),
                    for (final feature in const [
                      (
                        Icons.fact_check_outlined,
                        'Verified asset documentation',
                      ),
                      (
                        Icons.currency_bitcoin_rounded,
                        'Transparent crypto quotes and network fees',
                      ),
                      (
                        Icons.lock_outline_rounded,
                        'Confirmation before every financial action',
                      ),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _FeatureRow(feature.$1, feature.$2),
                      ),
                  ],
                );
                const visual = _AssetReviewPanel();
                if (constraints.maxWidth < 820) {
                  return Column(
                    children: [details, SizedBox(height: 50), visual],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: details),
                    SizedBox(width: 74),
                    const Expanded(child: visual),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.goldSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.gold, size: 20),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _AssetReviewPanel extends StatelessWidget {
  const _AssetReviewPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.panel,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/images/kololo_heights_v2.png',
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kololo Heights', style: AppText.cardHeading),
              Text('VERIFIED', style: AppText.eyebrow),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Income-producing residential property',
            style: AppText.bodyLarge,
          ),
          SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Metric('12.4%', 'Target return', gold: true),
              Metric('UGX 250K', 'Minimum'),
              Metric('62%', 'Funded'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TestimonialsSection extends StatelessWidget {
  const _TestimonialsSection();

  @override
  Widget build(BuildContext context) {
    return const _LandingSection(
      title: 'Built on investor confidence.',
      subtitle: 'What early BrickClub members value most about the experience.',
      child: LayoutBuilder(builder: _buildTestimonials),
    );
  }

  static Widget _buildTestimonials(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    const items = [
      _Testimonial(
        'BrickClub makes the important details easy to understand. I know '
            'what I own, how it is performing, and what happens before I fund.',
        'Sarah N.',
        'Entrepreneur, Kampala',
      ),
      _Testimonial(
        'The verification and confirmation flow gave me confidence. It feels '
            'like a serious investment platform, not another crypto shortcut.',
        'Daniel K.',
        'Product lead, Nairobi',
      ),
      _Testimonial(
        'I can start at a practical amount and still get access to assets I '
            'would normally only watch from the outside.',
        'Amina M.',
        'Consultant, Dar es Salaam',
      ),
    ];
    if (constraints.maxWidth < 820) {
      return Column(
        children: [
          for (final item in items)
            Padding(padding: const EdgeInsets.only(bottom: 18), child: item),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final item in items) Expanded(child: item)],
    );
  }
}

class _Testimonial extends StatelessWidget {
  const _Testimonial(this.quote, this.name, this.role);

  final String quote;
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 18),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, color: AppColors.gold),
          SizedBox(height: 20),
          Text(
            quote,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 28),
          Text(
            name,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(role, style: AppText.small),
        ],
      ),
    );
  }
}

class _LandingSection extends StatelessWidget {
  const _LandingSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  static TextStyle get headingStyle => TextStyle(
    color: AppColors.primary,
    fontSize: 43,
    height: 1.08,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: headingStyle),
                SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 17,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 54),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FinalCta extends StatelessWidget {
  const _FinalCta({
    required this.onInstall,
    required this.onSignIn,
    required this.onSignUp,
  });

  final VoidCallback onInstall;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.gold,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 82),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Text(
                'Your next asset can start here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 48,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                ),
              ),
              SizedBox(height: 18),
              Text(
                'Install BrickClub, create your account, and explore verified '
                'BrickShares built for long-term ownership.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 17,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 32),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  _WebButton(
                    label: 'Install the app',
                    icon: Icons.download_rounded,
                    onPressed: onInstall,
                    dark: true,
                  ),
                  _WebButton(
                    label: 'Sign up',
                    onPressed: onSignUp,
                    darkOutline: true,
                  ),
                  TextButton(
                    onPressed: onSignIn,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.background,
                    ),
                    child: Text('Sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingFooter extends StatelessWidget {
  const _LandingFooter({required this.onSignIn, required this.onSignUp});

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Row(
            children: [
              const _BrandLockup(),
              const Spacer(),
              TextButton(onPressed: onSignIn, child: Text('Sign in')),
              TextButton(onPressed: onSignUp, child: Text('Sign up')),
              SizedBox(width: 10),
              Text('© 2026 BrickClub', style: AppText.small),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebButton extends StatelessWidget {
  const _WebButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = false,
    this.dark = false,
    this.darkOutline = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool filled;
  final bool dark;
  final bool darkOutline;

  @override
  Widget build(BuildContext context) {
    final foreground = dark || darkOutline
        ? AppColors.background
        : filled
        ? AppColors.background
        : AppColors.primary;
    final background = dark
        ? AppColors.background
        : filled
        ? AppColors.gold
        : Colors.transparent;
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          side: BorderSide(
            color: darkOutline
                ? AppColors.background
                : filled || dark
                ? background
                : AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
    required this.authRepository,
    required this.onBack,
    required this.onMemberSignedIn,
    required this.onAdminSignedIn,
    required this.onCreateAccount,
  });

  final AuthRepository authRepository;
  final VoidCallback onBack;
  final VoidCallback onMemberSignedIn;
  final VoidCallback onAdminSignedIn;
  final VoidCallback onCreateAccount;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool adminAccess = false;
  bool signingIn = false;
  bool signingInWithGoogle = false;
  String? authMessage;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (MediaQuery.sizeOf(context).width >= 900)
            const Expanded(child: _SignInStory()),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: widget.onBack,
                              icon: Icon(Icons.arrow_back_rounded),
                            ),
                          ),
                          SizedBox(height: 18),
                          const _BrandLockup(height: 72),
                          SizedBox(height: 30),
                          Text(
                            adminAccess ? 'Admin sign in' : 'Welcome back',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.2,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            adminAccess
                                ? 'Access user, asset, and crypto payment operations.'
                                : 'Continue to your BrickShares portfolio.',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 24),
                          const FieldLabel('Email'),
                          SizedBox(height: 8),
                          AppTextField(
                            key: const ValueKey('email-field'),
                            controller: emailController,
                            hintText: 'you@example.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 18),
                          const FieldLabel('Password'),
                          SizedBox(height: 8),
                          AppTextField(
                            key: const ValueKey('password-field'),
                            controller: passwordController,
                            hintText: 'Enter your password',
                            obscureText: true,
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _sendPasswordReset,
                              child: Text('Forgot password?'),
                            ),
                          ),
                          SizedBox(height: 10),
                          if (authMessage != null) ...[
                            _AuthMessageBanner(message: authMessage!),
                            SizedBox(height: 14),
                          ],
                          PrimaryButton(
                            key: const ValueKey('sign-in'),
                            label: signingIn
                                ? 'Signing in...'
                                : adminAccess
                                ? 'Open admin dashboard'
                                : 'Sign in securely',
                            onPressed: signingIn ? null : _signIn,
                          ),
                          SizedBox(height: 12),
                          GoogleAuthButton(
                            key: const ValueKey('google-sign-in'),
                            label: signingInWithGoogle
                                ? 'Connecting...'
                                : adminAccess
                                ? 'Continue as admin with Google'
                                : 'Continue with Google',
                            onPressed: signingIn || signingInWithGoogle
                                ? null
                                : _signInWithGoogle,
                          ),
                          SizedBox(height: 24),
                          Center(
                            child: TextButton.icon(
                              key: const ValueKey('admin-access'),
                              onPressed: () {
                                setState(() {
                                  adminAccess = !adminAccess;
                                  authMessage = null;
                                  emailController.clear();
                                  passwordController.clear();
                                });
                              },
                              icon: Icon(
                                adminAccess
                                    ? Icons.person_outline_rounded
                                    : Icons.admin_panel_settings_outlined,
                              ),
                              label: Text(
                                adminAccess
                                    ? 'Use member sign in'
                                    : 'Sign in as an admin',
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              key: const ValueKey('create-account-link'),
                              onPressed: widget.onCreateAccount,
                              child: Text('Create a BrickClub account'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      authMessage = null;
      signingInWithGoogle = true;
    });
    try {
      await widget.authRepository.signInWithGoogle();

      if (!mounted) {
        return;
      }

      if (adminAccess) {
        final isAdmin = await widget.authRepository.currentUserIsAdmin();
        if (!mounted) {
          return;
        }

        if (!isAdmin) {
          _showAuthMessage('This Google account does not have admin access.');
          return;
        }

        widget.onAdminSignedIn();
        return;
      }

      widget.onMemberSignedIn();
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => signingInWithGoogle = false);
      }
    }
  }

  Future<void> _signIn() async {
    setState(() {
      authMessage = null;
      signingIn = true;
    });
    try {
      await widget.authRepository.signIn(
        SignInCredentials(
          email: emailController.text,
          password: passwordController.text,
        ),
      );

      if (!mounted) {
        return;
      }

      if (adminAccess) {
        final isAdmin = await widget.authRepository.currentUserIsAdmin();
        if (!mounted) {
          return;
        }

        if (!isAdmin) {
          _showAuthMessage('This account does not have admin access.');
          return;
        }

        widget.onAdminSignedIn();
        return;
      }

      widget.onMemberSignedIn();
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => signingIn = false);
      }
    }
  }

  Future<void> _sendPasswordReset() async {
    setState(() => authMessage = null);
    try {
      await widget.authRepository.sendPasswordResetEmail(emailController.text);
      if (mounted) {
        showMessage(context, 'Password reset instructions sent');
      }
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(error));
      }
    }
  }

  void _showAuthMessage(String message) {
    setState(() => authMessage = message);
    showMessage(context, message);
  }
}

class _AuthMessageBanner extends StatelessWidget {
  const _AuthMessageBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const ValueKey('auth-message'),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: .5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignInStory extends StatelessWidget {
  const _SignInStory();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/kololo_heights_v2.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Color(0x7A0B0D0F), BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Ownership, made\nmore accessible.',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 54,
                height: 1.02,
                fontWeight: FontWeight.w800,
                letterSpacing: -2,
              ),
            ),
            SizedBox(height: 22),
            SizedBox(
              width: 500,
              child: Text(
                'Review verified opportunities, settle with confidence, '
                'and keep every asset in view.',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
    required this.authRepository,
    required this.adminRepository,
    required this.onSignOut,
  });

  final AuthRepository authRepository;
  final AdminRepository adminRepository;
  final VoidCallback onSignOut;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;
  late Future<AdminDashboardData> dashboardFuture;

  static const sections = [
    ('Overview', Icons.grid_view_rounded),
    ('Users', Icons.people_alt_outlined),
    ('Assets', Icons.apartment_outlined),
    ('Crypto payments', Icons.currency_bitcoin_rounded),
    ('Support', Icons.support_agent_rounded),
    ('Reports', Icons.bar_chart_rounded),
    ('Settings', Icons.settings_outlined),
  ];

  @override
  void initState() {
    super.initState();
    dashboardFuture = widget.adminRepository.loadDashboard();
  }

  void reloadDashboard() {
    setState(() {
      dashboardFuture = widget.adminRepository.loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: wide ? null : Drawer(child: _sidebarContent()),
      body: Row(
        children: [
          if (wide) SizedBox(width: 252, child: _sidebarContent()),
          Expanded(
            child: ColoredBox(
              color: AppColors.surface,
              child: Column(
                children: [
                  _AdminTopBar(
                    title: sections[selectedIndex].$1,
                    showMenu: !wide,
                    user: widget.authRepository.currentUserDetails(),
                  ),
                  Expanded(
                    child: FutureBuilder<AdminDashboardData>(
                      future: dashboardFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.gold,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return _AdminErrorState(
                            message: _adminErrorMessage(snapshot.error!),
                            onRetry: reloadDashboard,
                          );
                        }

                        final data = snapshot.data!;
                        return SingleChildScrollView(
                          padding: EdgeInsets.all(wide ? 30 : 18),
                          child: _AdminSection(
                            index: selectedIndex,
                            data: data,
                            repository: widget.adminRepository,
                            onChanged: reloadDashboard,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarContent() {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _BrandLockup(),
                ),
              ),
              SizedBox(height: 46),
              for (var index = 0; index < sections.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _AdminNavItem(
                    key: ValueKey('admin-${sections[index].$1.toLowerCase()}'),
                    label: sections[index].$1,
                    icon: sections[index].$2,
                    selected: selectedIndex == index,
                    onTap: () {
                      setState(() => selectedIndex = index);
                      if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              const Spacer(),
              Divider(color: AppColors.border),
              SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                leading: CircleAvatar(
                  backgroundColor: AppColors.panel,
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
                title: Text(
                  widget.authRepository.currentUserDetails()?.primaryLabel ??
                      'Signed-in admin',
                  style: AppText.fieldLabel,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  widget.authRepository.currentUserDetails()?.email ??
                      'Admin access',
                  style: AppText.tinyLight,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _AdminNavItem(
                label: 'Sign out',
                icon: Icons.logout_rounded,
                selected: false,
                onTap: widget.onSignOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.goldSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.gold : AppColors.muted,
              ),
              SizedBox(width: 13),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.secondary,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar({
    required this.title,
    required this.showMenu,
    required this.user,
  });

  final String title;
  final bool showMenu;
  final SignedInUserDetails? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (showMenu) ...[
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(Icons.menu_rounded),
              ),
            ),
            SizedBox(width: 8),
          ],
          Text(
            title == 'Overview' ? 'Admin overview' : title,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (MediaQuery.sizeOf(context).width >= 720)
            SizedBox(
              width: 250,
              height: 42,
              child: TextField(
                style: AppText.fieldLabel,
                decoration: InputDecoration(
                  hintText: 'Search operations',
                  hintStyle: AppText.small,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.muted,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.panel,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gold),
                  ),
                ),
              ),
            ),
          SizedBox(width: 12),
          IconButton(
            onPressed: () => showMessage(context, 'No new notifications'),
            icon: Icon(Icons.notifications_none_rounded),
          ),
          if (MediaQuery.sizeOf(context).width >= 900) ...[
            SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                user?.primaryLabel ?? 'Signed-in admin',
                style: AppText.fieldLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          SizedBox(width: 8),
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.panel,
            child: Icon(
              Icons.admin_panel_settings_outlined,
              color: AppColors.gold,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSection extends StatelessWidget {
  const _AdminSection({
    required this.index,
    required this.data,
    required this.repository,
    required this.onChanged,
  });

  final int index;
  final AdminDashboardData data;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return switch (index) {
      0 => _OverviewPanel(data: data),
      1 => _UsersPanel(
        users: data.users,
        repository: repository,
        onChanged: onChanged,
      ),
      2 => _AssetsPanel(
        assets: data.assets,
        repository: repository,
        onChanged: onChanged,
      ),
      3 => _PaymentsPanel(
        options: data.cryptoPaymentOptions,
        depositRequests: data.depositRequests,
        repository: repository,
        onChanged: onChanged,
      ),
      4 => _SupportPanel(
        tickets: data.supportTickets,
        repository: repository,
        onChanged: onChanged,
      ),
      5 => _ReportsPanel(data: data),
      _ => _SettingsPanel(
        policy: data.withdrawalPolicy,
        repository: repository,
        onChanged: onChanged,
      ),
    };
  }
}

class _OverviewPanel extends StatelessWidget {
  const _OverviewPanel({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    final activeUsers = data.users.where((user) => !user.disabled).length;
    final liveAssets = data.assets
        .where((asset) => asset.publishedStatus.toLowerCase() == 'live')
        .length;
    final enabledPaymentOptions = data.cryptoPaymentOptions
        .where((option) => option.enabled)
        .length;
    final pendingAssets = data.assets
        .where((asset) => asset.reviewStatus.toLowerCase() != 'verified')
        .length;
    final pendingDeposits = data.depositRequests
        .where((request) => request.status == 'proof_submitted')
        .length;
    final pendingSupport = data.supportTickets
        .where((ticket) => ticket.status == 'waiting_for_admin')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monitor member activity, verified assets, and settlement flow.',
          style: TextStyle(color: AppColors.secondary, fontSize: 14),
        ),
        SizedBox(height: 26),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _AdminMetricCard(
              'Total users',
              '${data.users.length}',
              '$activeUsers active',
              Icons.people_alt_outlined,
            ),
            _AdminMetricCard(
              'Live assets',
              '$liveAssets',
              '${data.assets.length} total',
              Icons.apartment_outlined,
            ),
            _AdminMetricCard(
              'Payment options',
              '$enabledPaymentOptions',
              'enabled networks',
              Icons.currency_bitcoin_rounded,
            ),
            _AdminMetricCard(
              'Pending reviews',
              '${pendingAssets + pendingDeposits + pendingSupport}',
              '$pendingDeposits deposits',
              Icons.pending_actions_outlined,
              warning: true,
            ),
            _AdminMetricCard(
              'Support tickets',
              '${data.supportTickets.length}',
              '$pendingSupport need reply',
              Icons.support_agent_rounded,
              warning: pendingSupport > 0,
            ),
          ],
        ),
        SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final chart = _UserGrowthChart(data: data);
            final reviews = _PendingReviews(data: data);
            if (constraints.maxWidth < 850) {
              return Column(children: [chart, SizedBox(height: 18), reviews]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: chart),
                SizedBox(width: 18),
                Expanded(flex: 2, child: reviews),
              ],
            );
          },
        ),
        SizedBox(height: 20),
        _AdminPanel(
          title: 'Recent crypto payments',
          action: 'View all',
          child: _PaymentOptionTable(
            options: data.cryptoPaymentOptions,
            compact: true,
          ),
        ),
        SizedBox(height: 20),
        _AdminPanel(
          title: 'Recent users',
          action: 'Manage users',
          child: _UserTable(users: data.users, compact: true),
        ),
      ],
    );
  }
}

class _AdminErrorState extends StatelessWidget {
  const _AdminErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Panel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              color: AppColors.gold,
              size: 34,
            ),
            SizedBox(height: 14),
            Text('Admin data unavailable', style: AppText.h2),
            SizedBox(height: 8),
            Text(
              message,
              style: AppText.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18),
            SecondaryButton(label: 'Retry', onPressed: onRetry, compact: true),
          ],
        ),
      ),
    );
  }
}

class _AdminMetricCard extends StatelessWidget {
  const _AdminMetricCard(
    this.label,
    this.value,
    this.change,
    this.icon, {
    this.warning = false,
  });

  final String label;
  final String value;
  final String change;
  final IconData icon;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 226,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.small,
                ),
              ),
              SizedBox(width: 8),
              Icon(icon, size: 20, color: AppColors.gold),
            ],
          ),
          SizedBox(height: 18),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          Text(
            change,
            style: TextStyle(
              color: warning ? AppColors.warning : const Color(0xFF45C486),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPanel extends StatelessWidget {
  const _AdminPanel({required this.title, required this.child, this.action});

  final String title;
  final String? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.panel,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (action != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(action!, style: AppText.eyebrow),
                ),
            ],
          ),
          SizedBox(height: 22),
          child,
        ],
      ),
    );
  }
}

class _UserGrowthChart extends StatelessWidget {
  const _UserGrowthChart({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    final activeUsers = data.users.where((user) => !user.disabled).length;
    final admins = data.users.where((user) => user.admin).length;
    final verifiedEmails = data.users
        .where((user) => user.emailVerified)
        .length;
    final disabledUsers = data.users.where((user) => user.disabled).length;
    return _AdminPanel(
      title: 'User mix',
      action: '${data.users.length} total',
      child: SizedBox(
        height: 220,
        child: _BarChart(
          values: [
            data.users.length.toDouble(),
            activeUsers.toDouble(),
            verifiedEmails.toDouble(),
            admins.toDouble(),
            disabledUsers.toDouble(),
          ],
          labels: const ['All', 'Active', 'Email', 'Admin', 'Off'],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a > b ? a : b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var index = 0; index < values.length; index++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: maxValue <= 0
                            ? 0
                            : values[index] / maxValue,
                        child: Container(
                          decoration: BoxDecoration(
                            color: index == values.length - 1
                                ? AppColors.gold
                                : AppColors.track,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(labels[index], style: AppText.tinyLight),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PendingReviews extends StatelessWidget {
  const _PendingReviews({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    final pendingAssets = data.assets
        .where((asset) => asset.reviewStatus.toLowerCase() != 'verified')
        .toList();
    final pendingDeposits = data.depositRequests
        .where((request) => request.status == 'proof_submitted')
        .toList();
    final pendingSupport = data.supportTickets
        .where((ticket) => ticket.status == 'waiting_for_admin')
        .toList();
    final rows = <Widget>[
      for (final asset in pendingAssets.take(2))
        _ReviewRow(asset.title, asset.reviewStatus, 'Asset'),
      for (final request in pendingDeposits.take(2))
        _ReviewRow(request.opportunityTitle, 'Deposit proof', 'Payment'),
      for (final ticket in pendingSupport.take(2))
        _ReviewRow(ticket.subject, ticket.requesterLabel, 'Support'),
    ];

    return _AdminPanel(
      title: 'Pending asset reviews',
      action: '${rows.length} shown',
      child: rows.isEmpty
          ? Text('No pending operational reviews.', style: AppText.body)
          : Column(children: rows),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.title, this.status, this.time);
  final String title;
  final String status;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.apartment_outlined,
              color: AppColors.gold,
              size: 19,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.fieldLabel),
                SizedBox(height: 3),
                Text(status, style: AppText.tinyLight),
              ],
            ),
          ),
          Text(time, style: AppText.tiny),
        ],
      ),
    );
  }
}

class _UsersPanel extends StatelessWidget {
  const _UsersPanel({
    required this.users,
    required this.repository,
    required this.onChanged,
  });

  final List<AdminUser> users;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      description: 'Review verification, account status, and member activity.',
      actionLabel: 'Add user',
      onAction: () => _showUserDialog(
        context,
        repository: repository,
        onChanged: onChanged,
      ),
      child: _AdminPanel(
        title: 'Users',
        child: _UserTable(
          users: users,
          onEdit: (user) => _showUserDialog(
            context,
            repository: repository,
            user: user,
            onChanged: onChanged,
          ),
          onDelete: (user) => _runAdminAction(
            context,
            action: () => repository.deleteUser(user.uid),
            onChanged: onChanged,
          ),
          onToggleAdmin: (user, admin) => _runAdminAction(
            context,
            action: () => repository.setUserAdmin(uid: user.uid, admin: admin),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _AssetsPanel extends StatelessWidget {
  const _AssetsPanel({
    required this.assets,
    required this.repository,
    required this.onChanged,
  });

  final List<AdminAsset> assets;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      description:
          'Manage listings, due diligence, funding progress, and publication.',
      actionLabel: 'Add asset',
      onAction: () => _showAssetDialog(
        context,
        repository: repository,
        onChanged: onChanged,
      ),
      child: _AdminPanel(
        title: 'Asset inventory',
        child: _AssetTable(
          assets: assets,
          onEdit: (asset) => _showAssetDialog(
            context,
            repository: repository,
            asset: asset,
            onChanged: onChanged,
          ),
          onDelete: (asset) => _runAdminAction(
            context,
            action: () => repository.deleteAsset(asset.id),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _PaymentsPanel extends StatelessWidget {
  const _PaymentsPanel({
    required this.options,
    required this.depositRequests,
    required this.repository,
    required this.onChanged,
  });

  final List<CryptoPaymentOption> options;
  final List<AdminDepositRequest> depositRequests;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      description:
          'Manage the crypto networks and wallet addresses offered in the app.',
      actionLabel: 'Add option',
      onAction: () => _showPaymentOptionDialog(
        context,
        repository: repository,
        onChanged: onChanged,
      ),
      child: _AdminPanel(
        title: 'Crypto payment options',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PaymentOptionTable(
              options: options,
              onEdit: (option) => _showPaymentOptionDialog(
                context,
                repository: repository,
                option: option,
                onChanged: onChanged,
              ),
              onDelete: (option) => _runAdminAction(
                context,
                action: () => repository.deleteCryptoPaymentOption(option.id),
                onChanged: onChanged,
              ),
            ),
            SizedBox(height: 24),
            Text('Deposit proof review', style: AppText.cardHeadingSmall),
            SizedBox(height: 12),
            _DepositRequestTable(
              requests: depositRequests,
              onVerify: (request) => _runAdminAction(
                context,
                action: () => repository.verifyDepositRequest(request.id),
                onChanged: onChanged,
              ),
              onReject: (request) => _showRejectDepositDialog(
                context,
                repository: repository,
                request: request,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositRequestTable extends StatelessWidget {
  const _DepositRequestTable({
    required this.requests,
    required this.onVerify,
    required this.onReject,
  });

  final List<AdminDepositRequest> requests;
  final ValueChanged<AdminDepositRequest> onVerify;
  final ValueChanged<AdminDepositRequest> onReject;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Panel(
        child: Text('No submitted deposit proofs yet.', style: AppText.body),
      );
    }

    return _ResponsiveDataTable(
      columns: const ['Asset', 'Amount', 'Coin', 'Hash', 'Status'],
      rows: [
        for (final request in requests)
          _AdminTableRow(
            values: [
              request.opportunityTitle,
              request.amountUgx.toStringAsFixed(0),
              '${request.paymentAsset} ${request.paymentNetwork}',
              _shortHash(request.transactionHash),
              request.status,
            ],
            source: request,
          ),
      ],
      statusColumns: const {4},
      trailingBuilder: (row) {
        final request = row.source as AdminDepositRequest;
        final submitted = request.status == 'proof_submitted';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Open proof',
              onPressed: request.proofUrl.isEmpty
                  ? null
                  : () => showMessage(context, request.proofUrl),
              icon: Icon(Icons.receipt_long_outlined, size: 18),
            ),
            IconButton(
              tooltip: 'Verify',
              onPressed: submitted ? () => onVerify(request) : null,
              icon: Icon(Icons.verified_outlined, size: 18),
            ),
            IconButton(
              tooltip: 'Reject',
              onPressed: submitted ? () => onReject(request) : null,
              icon: Icon(Icons.close_rounded, size: 18),
            ),
          ],
        );
      },
    );
  }
}

class _SupportPanel extends StatelessWidget {
  const _SupportPanel({
    required this.tickets,
    required this.repository,
    required this.onChanged,
  });

  final List<AdminSupportTicket> tickets;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      description: 'Review member support requests and reply from operations.',
      child: _AdminPanel(
        title: 'Support conversations',
        child: _SupportTicketTable(
          tickets: tickets,
          onReply: (ticket) => _showSupportReplyDialog(
            context,
            repository: repository,
            ticket: ticket,
            onChanged: onChanged,
          ),
          onClose: (ticket) => _runAdminAction(
            context,
            action: () => repository.closeSupportTicket(ticket.id),
            onChanged: onChanged,
            successMessage: 'Support request closed',
          ),
        ),
      ),
    );
  }
}

class _SupportTicketTable extends StatelessWidget {
  const _SupportTicketTable({
    required this.tickets,
    required this.onReply,
    required this.onClose,
  });

  final List<AdminSupportTicket> tickets;
  final ValueChanged<AdminSupportTicket> onReply;
  final ValueChanged<AdminSupportTicket> onClose;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return Panel(child: Text('No support tickets yet.', style: AppText.body));
    }

    return _ResponsiveDataTable(
      columns: const ['Member', 'Subject', 'Status', 'Messages'],
      rows: [
        for (final ticket in tickets)
          _AdminTableRow(
            values: [
              ticket.requesterLabel,
              ticket.subject,
              ticket.statusLabel,
              '${ticket.messageCount}',
            ],
            source: ticket,
          ),
      ],
      statusColumns: const {2},
      trailingBuilder: (row) {
        final ticket = row.source as AdminSupportTicket;
        final closed = ticket.status == 'closed';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Reply',
              onPressed: closed ? null : () => onReply(ticket),
              icon: Icon(Icons.reply_rounded, size: 18),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: closed ? null : () => onClose(ticket),
              icon: Icon(Icons.task_alt_rounded, size: 18),
            ),
          ],
        );
      },
    );
  }
}

class _ReportsPanel extends StatelessWidget {
  const _ReportsPanel({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    final verifiedAssets = data.assets
        .where((asset) => asset.reviewStatus.toLowerCase() == 'verified')
        .length;
    final liveAssets = data.assets
        .where((asset) => asset.publishedStatus.toLowerCase() == 'live')
        .length;
    final submittedDeposits = data.depositRequests
        .where((request) => request.status == 'proof_submitted')
        .length;
    final verifiedDeposits = data.depositRequests
        .where((request) => request.status == 'deposit_verified')
        .length;
    final rejectedDeposits = data.depositRequests
        .where((request) => request.status == 'deposit_rejected')
        .length;
    final openSupport = data.supportTickets
        .where((ticket) => ticket.status != 'closed')
        .length;

    return _SectionPage(
      description:
          'Operational reporting for member growth, assets, and settlement.',
      child: _AdminPanel(
        title: 'Operations report',
        child: SizedBox(
          height: 320,
          child: _BarChart(
            values: [
              data.users.length.toDouble(),
              verifiedAssets.toDouble(),
              liveAssets.toDouble(),
              submittedDeposits.toDouble(),
              verifiedDeposits.toDouble(),
              rejectedDeposits.toDouble(),
              openSupport.toDouble(),
            ],
            labels: const [
              'Users',
              'Verified',
              'Live',
              'Proofs',
              'Paid',
              'Rejected',
              'Support',
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.policy,
    required this.repository,
    required this.onChanged,
  });

  final WithdrawalPolicy policy;
  final AdminRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      description:
          'Configure approval rules, payment networks, and administrator access.',
      actionLabel: 'Edit withdrawals',
      onAction: () => _showWithdrawalPolicyDialog(
        context,
        repository: repository,
        policy: policy,
        onChanged: onChanged,
      ),
      child: _AdminPanel(
        title: 'Withdrawal requirements',
        child: Column(
          children: [
            _SettingRow(
              'Withdrawals',
              policy.enabled ? 'Enabled' : 'Disabled',
              switchValue: policy.enabled,
            ),
            _SettingRow(
              'Minimum amount',
              'UGX ${policy.minimumAmountUgx.toStringAsFixed(0)}',
            ),
            _SettingRow(
              'Fees',
              'UGX ${policy.flatFeeUgx.toStringAsFixed(0)} + ${policy.percentageFee.toStringAsFixed(2)}%',
            ),
            _SettingRow(
              'Destination wallet',
              policy.requiresDestinationWalletVerification
                  ? 'Verification required'
                  : 'Address format only',
              switchValue: policy.requiresDestinationWalletVerification,
            ),
            _SettingRow(
              'Approvals',
              '${policy.requiredApprovals} admin approval${policy.requiredApprovals == 1 ? '' : 's'}',
            ),
            _SettingRow('Processing time', policy.processingTime),
            _SettingRow('Notes', policy.notes),
          ],
        ),
      ),
    );
  }
}

class _SectionPage extends StatelessWidget {
  const _SectionPage({
    required this.description,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String description;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(description, style: AppText.bodyLarge),
        SizedBox(height: 24),
        Row(
          children: [
            const Spacer(),
            if (actionLabel != null)
              SecondaryButton(
                label: actionLabel!,
                onPressed: onAction,
                compact: true,
              ),
          ],
        ),
        SizedBox(height: 20),
        child,
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow(this.title, this.value, {this.switchValue});
  final String title;
  final String value;
  final bool? switchValue;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppText.fieldLabel),
      subtitle: Text(value, style: AppText.small),
      trailing: switchValue == null
          ? null
          : Switch(
              value: switchValue!,
              onChanged: null,
              activeThumbColor: AppColors.gold,
            ),
    );
  }
}

class _UserTable extends StatelessWidget {
  const _UserTable({
    required this.users,
    this.compact = false,
    this.onEdit,
    this.onDelete,
    this.onToggleAdmin,
  });

  final List<AdminUser> users;
  final bool compact;
  final ValueChanged<AdminUser>? onEdit;
  final ValueChanged<AdminUser>? onDelete;
  final void Function(AdminUser user, bool admin)? onToggleAdmin;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveDataTable(
      columns: const ['Member', 'Email', 'Role', 'Account'],
      rows: [
        for (final user in users.take(compact ? 4 : users.length))
          _AdminTableRow(
            values: [
              user.displayName?.isNotEmpty == true ? user.displayName! : '-',
              user.email,
              user.admin ? 'Admin' : 'Member',
              user.disabled ? 'Disabled' : 'Active',
            ],
            source: user,
          ),
      ],
      statusColumns: const {2, 3},
      onEdit: onEdit == null ? null : (row) => onEdit!(row.source as AdminUser),
      onDelete: onDelete == null
          ? null
          : (row) => onDelete!(row.source as AdminUser),
      trailingBuilder: compact || onToggleAdmin == null
          ? null
          : (row) {
              final user = row.source as AdminUser;
              return Switch(
                value: user.admin,
                onChanged: (value) => onToggleAdmin!(user, value),
                activeThumbColor: AppColors.gold,
              );
            },
    );
  }
}

class _AssetTable extends StatelessWidget {
  const _AssetTable({required this.assets, this.onEdit, this.onDelete});

  final List<AdminAsset> assets;
  final ValueChanged<AdminAsset>? onEdit;
  final ValueChanged<AdminAsset>? onDelete;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveDataTable(
      columns: const ['Asset', 'Type', 'Funded', 'Review', 'Published'],
      rows: [
        for (final asset in assets)
          _AdminTableRow(
            values: [
              asset.title,
              asset.type,
              '${asset.fundedPercent.toStringAsFixed(0)}%',
              asset.reviewStatus,
              asset.publishedStatus,
            ],
            source: asset,
          ),
      ],
      statusColumns: const {3, 4},
      onEdit: onEdit == null
          ? null
          : (row) => onEdit!(row.source as AdminAsset),
      onDelete: onDelete == null
          ? null
          : (row) => onDelete!(row.source as AdminAsset),
    );
  }
}

class _PaymentOptionTable extends StatelessWidget {
  const _PaymentOptionTable({
    required this.options,
    this.compact = false,
    this.onEdit,
    this.onDelete,
  });

  final List<CryptoPaymentOption> options;
  final bool compact;
  final ValueChanged<CryptoPaymentOption>? onEdit;
  final ValueChanged<CryptoPaymentOption>? onDelete;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveDataTable(
      columns: const ['Network', 'Asset', 'Wallet', 'QR', 'Minimum', 'Status'],
      rows: [
        for (final option in options.take(compact ? 4 : options.length))
          _AdminTableRow(
            values: [
              option.network,
              option.assetSymbol,
              option.walletAddress,
              option.qrCodeUrl.isEmpty ? 'Missing' : 'Uploaded',
              option.minimumAmount.toStringAsFixed(2),
              option.enabled ? 'Active' : 'Disabled',
            ],
            source: option,
          ),
      ],
      statusColumns: const {3, 5},
      onEdit: onEdit == null
          ? null
          : (row) => onEdit!(row.source as CryptoPaymentOption),
      onDelete: onDelete == null
          ? null
          : (row) => onDelete!(row.source as CryptoPaymentOption),
    );
  }
}

class _AdminTableRow {
  const _AdminTableRow({required this.values, this.source});

  final List<String> values;
  final Object? source;
}

class _ResponsiveDataTable extends StatelessWidget {
  const _ResponsiveDataTable({
    required this.columns,
    required this.rows,
    this.statusColumns = const {},
    this.onEdit,
    this.onDelete,
    this.trailingBuilder,
  });

  final List<String> columns;
  final List<_AdminTableRow> rows;
  final Set<int> statusColumns;
  final ValueChanged<_AdminTableRow>? onEdit;
  final ValueChanged<_AdminTableRow>? onDelete;
  final Widget Function(_AdminTableRow row)? trailingBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680) {
          return Column(
            children: [
              for (final row in rows)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      for (var index = 0; index < columns.length; index++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 92,
                                child: Text(
                                  columns[index],
                                  style: AppText.tiny,
                                ),
                              ),
                              Expanded(
                                child: statusColumns.contains(index)
                                    ? Align(
                                        alignment: Alignment.centerLeft,
                                        child: _StatusChip(row.values[index]),
                                      )
                                    : Text(
                                        row.values[index],
                                        style: AppText.fieldLabel,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      if (onEdit != null ||
                          onDelete != null ||
                          trailingBuilder != null)
                        _RowActions(
                          onEdit: onEdit == null ? null : () => onEdit!(row),
                          onDelete: onDelete == null
                              ? null
                              : () => onDelete!(row),
                          trailing: trailingBuilder?.call(row),
                        ),
                    ],
                  ),
                ),
            ],
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingTextStyle: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            dataTextStyle: AppText.fieldLabel,
            headingRowHeight: 42,
            dataRowMinHeight: 52,
            dataRowMaxHeight: 56,
            horizontalMargin: 8,
            columnSpacing: 34,
            dividerThickness: .5,
            border: TableBorder(
              horizontalInside: BorderSide(color: AppColors.border),
            ),
            columns: [
              for (final column in columns) DataColumn(label: Text(column)),
              if (onEdit != null || onDelete != null || trailingBuilder != null)
                const DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (final row in rows)
                DataRow(
                  cells: [
                    for (var index = 0; index < row.values.length; index++)
                      DataCell(
                        statusColumns.contains(index)
                            ? _StatusChip(row.values[index])
                            : Text(row.values[index]),
                      ),
                    if (onEdit != null ||
                        onDelete != null ||
                        trailingBuilder != null)
                      DataCell(
                        _RowActions(
                          onEdit: onEdit == null ? null : () => onEdit!(row),
                          onDelete: onDelete == null
                              ? null
                              : () => onDelete!(row),
                          trailing: trailingBuilder?.call(row),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions({this.onEdit, this.onDelete, this.trailing});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?trailing,
        if (onEdit != null)
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 18),
          ),
        if (onDelete != null)
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, size: 18),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final positive = {
      'Verified',
      'Active',
      'Live',
      'Confirmed',
      'Uploaded',
      'deposit_verified',
    }.contains(label);
    final warning = {
      'Review',
      'Pending',
      'Draft',
      'proof_submitted',
    }.contains(label);
    final color = positive
        ? const Color(0xFF45C486)
        : warning
        ? AppColors.warning
        : const Color(0xFFE36D6D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<void> _showUserDialog(
  BuildContext context, {
  required AdminRepository repository,
  required VoidCallback onChanged,
  AdminUser? user,
}) async {
  final email = TextEditingController(text: user?.email ?? '');
  final name = TextEditingController(text: user?.displayName ?? '');
  final password = TextEditingController();
  var disabled = user?.disabled ?? false;
  var admin = user?.admin ?? false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: AppColors.panel,
          title: Text(user == null ? 'Create user' : 'Edit user'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: name,
                  hintText: 'Full name',
                  initialValue: null,
                ),
                SizedBox(height: 10),
                AppTextField(
                  controller: email,
                  hintText: 'member@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),
                AppTextField(
                  controller: password,
                  hintText: user == null
                      ? 'Temporary password'
                      : 'Leave blank to keep password',
                  obscureText: true,
                  initialValue: null,
                ),
                SwitchListTile(
                  value: admin,
                  onChanged: (value) => setState(() => admin = value),
                  title: Text('Admin access'),
                  activeThumbColor: AppColors.gold,
                ),
                SwitchListTile(
                  value: disabled,
                  onChanged: (value) => setState(() => disabled = value),
                  title: Text('Disabled'),
                  activeThumbColor: AppColors.gold,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await _runAdminAction(
                  context,
                  action: () => user == null
                      ? repository.createUser(
                          email: email.text,
                          password: password.text,
                          displayName: name.text,
                          disabled: disabled,
                          admin: admin,
                        )
                      : repository.updateUser(
                          uid: user.uid,
                          email: email.text,
                          password: password.text,
                          displayName: name.text,
                          disabled: disabled,
                          admin: admin,
                        ),
                  onChanged: onChanged,
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    ),
  );

  email.dispose();
  name.dispose();
  password.dispose();
}

Future<void> _showAssetDialog(
  BuildContext context, {
  required AdminRepository repository,
  required VoidCallback onChanged,
  AdminAsset? asset,
}) async {
  final value = asset ?? AdminAsset.empty();
  final title = TextEditingController(text: value.title);
  final location = TextEditingController(text: value.location);
  final type = TextEditingController(text: value.type);
  final fundedPercent = TextEditingController(
    text: value.fundedPercent.toStringAsFixed(0),
  );
  final reviewStatus = TextEditingController(text: value.reviewStatus);
  final publishedStatus = TextEditingController(text: value.publishedStatus);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: Text(asset == null ? 'Create asset' : 'Edit asset'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: title, hintText: 'Asset title'),
            SizedBox(height: 10),
            AppTextField(controller: location, hintText: 'Location'),
            SizedBox(height: 10),
            AppTextField(controller: type, hintText: 'Asset type'),
            SizedBox(height: 10),
            AppTextField(
              controller: fundedPercent,
              hintText: 'Funded percent',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            AppTextField(controller: reviewStatus, hintText: 'Review status'),
            SizedBox(height: 10),
            AppTextField(
              controller: publishedStatus,
              hintText: 'Published status',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final payload = AdminAsset(
              id: value.id,
              title: title.text,
              location: location.text,
              type: type.text,
              fundedPercent: double.tryParse(fundedPercent.text) ?? 0,
              reviewStatus: reviewStatus.text,
              publishedStatus: publishedStatus.text,
            );

            await _runAdminAction(
              context,
              action: () => asset == null
                  ? repository.createAsset(payload)
                  : repository.updateAsset(payload),
              onChanged: onChanged,
            );
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
          },
          child: Text('Save'),
        ),
      ],
    ),
  );

  title.dispose();
  location.dispose();
  type.dispose();
  fundedPercent.dispose();
  reviewStatus.dispose();
  publishedStatus.dispose();
}

Future<void> _showPaymentOptionDialog(
  BuildContext context, {
  required AdminRepository repository,
  required VoidCallback onChanged,
  CryptoPaymentOption? option,
}) async {
  final value = option ?? CryptoPaymentOption.empty();
  final network = TextEditingController(text: value.network);
  final assetSymbol = TextEditingController(text: value.assetSymbol);
  final walletAddress = TextEditingController(text: value.walletAddress);
  var qrCodeUrl = value.qrCodeUrl;
  final minimumAmount = TextEditingController(
    text: value.minimumAmount.toStringAsFixed(2),
  );
  var enabled = value.enabled;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: AppColors.panel,
          title: Text(option == null ? 'Create payment option' : 'Edit option'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(controller: network, hintText: 'Network'),
                SizedBox(height: 10),
                AppTextField(controller: assetSymbol, hintText: 'Asset symbol'),
                SizedBox(height: 10),
                AppTextField(
                  controller: walletAddress,
                  hintText: 'Settlement wallet address',
                ),
                SizedBox(height: 10),
                _PickerTile(
                  icon: Icons.qr_code_2_rounded,
                  title: qrCodeUrl.isEmpty
                      ? 'Upload payment QR code'
                      : 'QR code uploaded',
                  onTap: () async {
                    final uploaded = await _pickAdminQrCode(repository);
                    if (uploaded != null) {
                      setState(() => qrCodeUrl = uploaded);
                    }
                  },
                ),
                SizedBox(height: 10),
                AppTextField(
                  controller: minimumAmount,
                  hintText: 'Minimum amount',
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  value: enabled,
                  onChanged: (value) => setState(() => enabled = value),
                  title: Text('Enabled'),
                  activeThumbColor: AppColors.gold,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final payload = CryptoPaymentOption(
                  id: value.id,
                  network: network.text,
                  assetSymbol: assetSymbol.text,
                  walletAddress: walletAddress.text,
                  qrCodeUrl: qrCodeUrl,
                  enabled: enabled,
                  minimumAmount: double.tryParse(minimumAmount.text) ?? 0,
                );

                await _runAdminAction(
                  context,
                  action: () => option == null
                      ? repository.createCryptoPaymentOption(payload)
                      : repository.updateCryptoPaymentOption(payload),
                  onChanged: onChanged,
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    ),
  );

  network.dispose();
  assetSymbol.dispose();
  walletAddress.dispose();
  minimumAmount.dispose();
}

Future<String?> _pickAdminQrCode(AdminRepository repository) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    withData: true,
  );
  final file = result?.files.single;
  if (file?.bytes == null) return null;

  return repository.uploadCryptoPaymentQrCode(
    AdminUploadFile(
      name: file!.name,
      bytes: file.bytes!,
      contentType: _contentTypeForName(file.name),
    ),
  );
}

Future<void> _showRejectDepositDialog(
  BuildContext context, {
  required AdminRepository repository,
  required AdminDepositRequest request,
  required VoidCallback onChanged,
}) async {
  final reason = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: Text('Reject deposit proof'),
      content: SizedBox(
        width: 420,
        child: AppTextField(
          controller: reason,
          hintText: 'Reason shown to the member',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await _runAdminAction(
              context,
              action: () => repository.rejectDepositRequest(
                id: request.id,
                reason: reason.text,
              ),
              onChanged: onChanged,
            );
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: Text('Reject'),
        ),
      ],
    ),
  );
  reason.dispose();
}

Future<void> _showWithdrawalPolicyDialog(
  BuildContext context, {
  required AdminRepository repository,
  required WithdrawalPolicy policy,
  required VoidCallback onChanged,
}) async {
  final minimum = TextEditingController(
    text: policy.minimumAmountUgx.toStringAsFixed(0),
  );
  final flatFee = TextEditingController(
    text: policy.flatFeeUgx.toStringAsFixed(0),
  );
  final percentageFee = TextEditingController(
    text: policy.percentageFee.toStringAsFixed(2),
  );
  final approvals = TextEditingController(
    text: policy.requiredApprovals.toString(),
  );
  final processingTime = TextEditingController(text: policy.processingTime);
  final notes = TextEditingController(text: policy.notes);
  var enabled = policy.enabled;
  var requiresWalletVerification = policy.requiresDestinationWalletVerification;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: AppColors.panel,
          title: Text('Withdrawal requirements'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    value: enabled,
                    onChanged: (value) => setState(() => enabled = value),
                    title: Text('Withdrawals enabled'),
                    activeThumbColor: AppColors.gold,
                  ),
                  SwitchListTile(
                    value: requiresWalletVerification,
                    onChanged: (value) =>
                        setState(() => requiresWalletVerification = value),
                    title: Text('Require wallet verification'),
                    activeThumbColor: AppColors.gold,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: minimum,
                    hintText: 'Minimum amount in UGX',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: flatFee,
                    hintText: 'Flat fee in UGX',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: percentageFee,
                    hintText: 'Percentage fee',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: approvals,
                    hintText: 'Required admin approvals',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  AppTextField(
                    controller: processingTime,
                    hintText: 'Processing time',
                  ),
                  SizedBox(height: 10),
                  AppTextField(controller: notes, hintText: 'Member notes'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final payload = WithdrawalPolicy(
                  minimumAmountUgx: double.tryParse(minimum.text) ?? 0,
                  flatFeeUgx: double.tryParse(flatFee.text) ?? 0,
                  percentageFee: double.tryParse(percentageFee.text) ?? 0,
                  requiresDestinationWalletVerification:
                      requiresWalletVerification,
                  requiredApprovals: int.tryParse(approvals.text) ?? 1,
                  processingTime: processingTime.text,
                  enabled: enabled,
                  notes: notes.text,
                );

                await _runAdminAction(
                  context,
                  action: () => repository.updateWithdrawalPolicy(payload),
                  onChanged: onChanged,
                  successMessage: 'Withdrawal requirements updated',
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    ),
  );

  minimum.dispose();
  flatFee.dispose();
  percentageFee.dispose();
  approvals.dispose();
  processingTime.dispose();
  notes.dispose();
}

Future<void> _showSupportReplyDialog(
  BuildContext context, {
  required AdminRepository repository,
  required AdminSupportTicket ticket,
  required VoidCallback onChanged,
}) async {
  final reply = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: Text('Reply to ${ticket.requesterLabel}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.subject, style: AppText.fieldLabel),
            if (ticket.latestMessage.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(ticket.latestMessage, style: AppText.body),
            ],
            SizedBox(height: 16),
            TextField(
              controller: reply,
              minLines: 4,
              maxLines: 6,
              style: TextStyle(color: AppColors.primary),
              decoration: InputDecoration(
                hintText: 'Type your reply',
                hintStyle: AppText.placeholder,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final message = reply.text.trim();
            if (message.isEmpty) {
              showMessage(context, 'Enter a reply');
              return;
            }
            await _runAdminAction(
              context,
              action: () => repository.replyToSupportTicket(
                id: ticket.id,
                message: message,
              ),
              onChanged: onChanged,
              successMessage: 'Support reply sent',
            );
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: Text('Send reply'),
        ),
      ],
    ),
  );
  reply.dispose();
}

Future<void> _runAdminAction(
  BuildContext context, {
  required Future<void> Function() action,
  required VoidCallback onChanged,
  String successMessage = 'Admin change saved',
}) async {
  try {
    await action();
    onChanged();
    if (context.mounted) {
      showMessage(context, successMessage);
    }
  } catch (error) {
    if (context.mounted) {
      showMessage(context, _adminErrorMessage(error));
    }
  }
}

String _adminErrorMessage(Object error) {
  if (error is FirebaseFunctionsException) {
    return switch (error.code) {
      'unauthenticated' => 'Sign in again to continue.',
      'permission-denied' =>
        'Your account does not have permission to make this change.',
      'invalid-argument' =>
        'Check the details and try again. Some required information is missing or invalid.',
      'not-found' => 'We could not find that record. Refresh and try again.',
      'already-exists' => 'A record with those details already exists.',
      'unavailable' =>
        'Admin services are temporarily unavailable. Please try again shortly.',
      'deadline-exceeded' =>
        'The request took too long. Please check your connection and try again.',
      'resource-exhausted' =>
        'Too many requests right now. Please wait a moment and try again.',
      'failed-precondition' => _friendlyFirebaseMessage(
        error.message,
        fallback: 'This action is not available right now.',
      ),
      _ => 'We could not complete that admin action. Please try again.',
    };
  }

  return _friendlyUnexpectedMessage(error);
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    required this.authRepository,
    required this.onBack,
    required this.onSignIn,
    required this.onCreated,
  });

  final AuthRepository authRepository;
  final VoidCallback onBack;
  final VoidCallback onSignIn;
  final VoidCallback onCreated;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool accepted = false;
  bool creatingAccount = false;
  bool signingUpWithGoogle = false;
  String? authMessage;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          color: AppColors.background,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: Icon(Icons.chevron_left, size: 34),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  const _BrandLockup(height: 112),
                  SizedBox(height: 10),
                  Text(
                    'Create your BrickShares account. Wallet verification '
                    'and KYC come next.',
                    style: AppText.bodyLarge,
                  ),
                  SizedBox(height: 26),
                  Panel(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create account', style: AppText.h2),
                        Text(
                          'Use your legal names exactly as they appear on your ID.',
                          style: AppText.body,
                        ),
                        SizedBox(height: 18),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stackNames = constraints.maxWidth < 350;
                            final firstName = _SignUpField(
                              label: 'First name',
                              child: AppTextField(
                                controller: firstNameController,
                                hintText: 'Legal first name',
                                compact: true,
                                prefixIcon: Icons.badge_outlined,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.givenName],
                              ),
                            );
                            final lastName = _SignUpField(
                              label: 'Last name',
                              child: AppTextField(
                                controller: lastNameController,
                                hintText: 'Legal last name',
                                compact: true,
                                prefixIcon: Icons.badge_outlined,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.familyName],
                              ),
                            );

                            if (stackNames) {
                              return Column(
                                children: [
                                  firstName,
                                  SizedBox(height: 14),
                                  lastName,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: firstName),
                                SizedBox(width: 12),
                                Expanded(child: lastName),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 14),
                        _SignUpField(
                          label: 'Email',
                          child: AppTextField(
                            controller: emailController,
                            hintText: 'you@example.com',
                            keyboardType: TextInputType.emailAddress,
                            compact: true,
                            prefixIcon: Icons.alternate_email_rounded,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                          ),
                        ),
                        SizedBox(height: 14),
                        _SignUpField(
                          label: 'Password',
                          child: AppTextField(
                            controller: passwordController,
                            hintText: 'Create a password',
                            obscureText: true,
                            compact: true,
                            prefixIcon: Icons.lock_outline_rounded,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                          ),
                        ),
                        SizedBox(height: 14),
                        _SignUpField(
                          label: 'Confirm password',
                          child: AppTextField(
                            controller: confirmPasswordController,
                            hintText: 'Confirm your password',
                            obscureText: true,
                            compact: true,
                            prefixIcon: Icons.lock_reset_rounded,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: accepted,
                              onChanged: (value) => setState(() {
                                accepted = value ?? false;
                                authMessage = null;
                              }),
                              side: BorderSide(color: AppColors.border),
                              activeColor: AppColors.gold,
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  'I agree to terms, risk disclosures, and '
                                  'settlement confirmation notices.',
                                  style: AppText.small,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  if (authMessage != null) ...[
                    _AuthMessageBanner(message: authMessage!),
                    SizedBox(height: 10),
                  ],
                  PrimaryButton(
                    key: const ValueKey('create-account-submit'),
                    label: creatingAccount
                        ? 'Creating account...'
                        : 'Create account',
                    onPressed: accepted && !creatingAccount
                        ? _createAccount
                        : null,
                  ),
                  SizedBox(height: 10),
                  GoogleAuthButton(
                    key: const ValueKey('google-sign-up'),
                    label: signingUpWithGoogle
                        ? 'Connecting...'
                        : 'Sign up with Google',
                    onPressed: creatingAccount || signingUpWithGoogle
                        ? null
                        : _signUpWithGoogle,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Financial actions require KYC and verified wallet setup '
                    'after account creation.',
                    textAlign: TextAlign.center,
                    style: AppText.disclosure,
                  ),
                  SizedBox(height: 10),
                  SecondaryButton(
                    key: const ValueKey('account-login-button'),
                    label: 'Already have an account? Sign in',
                    onPressed: widget.onSignIn,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      authMessage = null;
      signingUpWithGoogle = true;
    });
    try {
      await widget.authRepository.signInWithGoogle();

      if (mounted) {
        widget.onCreated();
      }
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => signingUpWithGoogle = false);
      }
    }
  }

  Future<void> _createAccount() async {
    setState(() {
      authMessage = null;
      creatingAccount = true;
    });
    try {
      await widget.authRepository.createAccount(
        SignUpCredentials(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          password: passwordController.text,
          confirmPassword: confirmPasswordController.text,
        ),
      );

      if (mounted) {
        widget.onCreated();
      }
    } catch (error) {
      if (mounted) {
        _showAuthMessage(_authErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => creatingAccount = false);
      }
    }
  }

  void _showAuthMessage(String message) {
    setState(() => authMessage = message);
    showMessage(context, message);
  }
}

class _SignUpField extends StatelessWidget {
  const _SignUpField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [FieldLabel(label), SizedBox(height: 7), child],
    );
  }
}

class BrickClubShell extends StatefulWidget {
  const BrickClubShell({
    super.key,
    required this.authRepository,
    required this.investmentRepository,
    required this.kycRepository,
    required this.supportRepository,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final AuthRepository authRepository;
  final InvestmentRepository investmentRepository;
  final KycRepository kycRepository;
  final SupportRepository supportRepository;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<BrickClubShell> createState() => _BrickClubShellState();
}

class _BrickClubShellState extends State<BrickClubShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<KycProfile>(
      stream: widget.kycRepository.watchProfile(),
      builder: (context, snapshot) {
        final kyc =
            snapshot.data ??
            const KycProfile(
              status: KycStatus.notStarted,
              emailVerified: false,
              phoneVerified: false,
            );
        final pages = [
          HomeScreen(
            kyc: kyc,
            investmentRepository: widget.investmentRepository,
            onInvest: () => setState(() => index = 1),
            onStartKyc: () => _openKyc(context),
            onOpenProfile: _openProfile,
          ),
          InvestScreen(
            kyc: kyc,
            investmentRepository: widget.investmentRepository,
            onStartKyc: () => _openKyc(context),
            onOpenProfile: _openProfile,
          ),
          WalletScreen(
            kyc: kyc,
            investmentRepository: widget.investmentRepository,
            onStartKyc: () => _openKyc(context),
            onOpenProfile: _openProfile,
          ),
          PortfolioScreen(
            investmentRepository: widget.investmentRepository,
            onOpenProfile: _openProfile,
          ),
          ProfileScreen(
            user: widget.authRepository.currentUserDetails(),
            kyc: kyc,
            supportRepository: widget.supportRepository,
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
            onStartKyc: () => _openKyc(context),
          ),
        ];
        return PhoneFrame(
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: IndexedStack(index: index, children: pages),
            bottomNavigationBar: AppBottomNav(
              index: index,
              onChanged: (value) => setState(() => index = value),
            ),
          ),
        );
      },
    );
  }

  void _openKyc(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KycScreen(repository: widget.kycRepository),
      ),
    );
  }

  void _openProfile() {
    setState(() => index = 4);
  }
}

void requireApprovedKyc(
  BuildContext context,
  KycProfile kyc,
  VoidCallback onApproved,
  VoidCallback onStartKyc,
) {
  if (kyc.canPerformFinancialActions) {
    onApproved();
    return;
  }

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.panel,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: AppColors.gold),
          SizedBox(height: 16),
          Text('Complete KYC first', style: AppText.h2),
          SizedBox(height: 8),
          Text(
            'Status: ${kyc.label}. Purchases, withdrawals, wallet changes, '
            'and crypto settlement unlock after approval.',
            style: AppText.bodyLarge,
          ),
          SizedBox(height: 20),
          PrimaryButton(
            key: const ValueKey('start-kyc-gate'),
            label: kyc.status == KycStatus.submitted
                ? 'View KYC status'
                : 'Complete KYC',
            onPressed: () {
              Navigator.pop(sheetContext);
              onStartKyc();
            },
          ),
        ],
      ),
    ),
  );
}

class KycStatusCard extends StatelessWidget {
  const KycStatusCard({
    super.key,
    required this.kyc,
    required this.onStartKyc,
    this.compact = false,
    this.showAction = true,
  });

  final KycProfile kyc;
  final VoidCallback onStartKyc;
  final bool compact;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    final isApproved = kyc.status == KycStatus.approved;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isApproved
                    ? Icons.verified_rounded
                    : Icons.verified_user_outlined,
                color: isApproved ? AppColors.success : AppColors.gold,
                size: 30,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KYC ${kyc.label}', style: AppText.cardHeadingSmall),
                    SizedBox(height: 4),
                    Text(_statusCopy(kyc), style: AppText.body),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          ProgressLine(value: kyc.completionRatio.clamp(0, 1), height: 6),
          if (!compact) ...[
            SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _KycChip('Email', kyc.emailVerified),
                _KycChip('Phone', kyc.phoneVerified),
                _KycChip('Identity', kyc.status == KycStatus.approved),
              ],
            ),
          ],
          if (showAction) ...[
            SizedBox(height: 16),
            PrimaryButton(
              key: const ValueKey('kyc-status-cta'),
              label: isApproved ? 'View KYC details' : 'Complete KYC',
              height: 44,
              onPressed: onStartKyc,
            ),
          ],
        ],
      ),
    );
  }

  String _statusCopy(KycProfile kyc) {
    return switch (kyc.status) {
      KycStatus.approved => 'Financial actions are unlocked.',
      KycStatus.submitted => 'Your documents are under review.',
      KycStatus.rejected =>
        kyc.rejectionReason ?? 'Review the request and resubmit.',
      _ => 'Required before purchases and wallet changes.',
    };
  }
}

class _KycChip extends StatelessWidget {
  const _KycChip(this.label, this.complete);

  final String label;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return ChoicePill(
      label: '$label ${complete ? 'OK' : 'Needed'}',
      selected: complete,
    );
  }
}

class KycScreen extends StatefulWidget {
  const KycScreen({super.key, required this.repository});

  final KycRepository repository;

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final phoneCodeController = TextEditingController();
  final imagePicker = ImagePicker();
  DateTime? dateOfBirth;
  KycDocumentFile? governmentId;
  KycDocumentFile? selfie;
  KycDocumentFile? addressProof;
  bool sendingEmail = false;
  bool sendingPhone = false;
  bool submitting = false;
  String? kycMessage;

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    phoneCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, 'Verify identity'),
        body: StreamBuilder<KycProfile>(
          stream: widget.repository.watchProfile(),
          builder: (context, snapshot) {
            final kyc =
                snapshot.data ??
                const KycProfile(
                  status: KycStatus.notStarted,
                  emailVerified: false,
                  phoneVerified: false,
                );
            _hydrateOnce(kyc);
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KycStatusCard(
                      kyc: kyc,
                      onStartKyc: () {},
                      compact: true,
                      showAction: false,
                    ),
                    if (kycMessage != null) ...[
                      SizedBox(height: 14),
                      _KycMessageBanner(message: kycMessage!),
                    ],
                    SizedBox(height: 18),
                    const FieldLabel('Full legal name'),
                    SizedBox(height: 8),
                    AppTextField(
                      controller: fullNameController,
                      hintText: 'Name exactly as shown on your ID',
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Date of birth'),
                    SizedBox(height: 8),
                    _PickerTile(
                      key: const ValueKey('kyc-dob'),
                      icon: Icons.calendar_month_outlined,
                      title: dateOfBirth == null
                          ? 'Select date'
                          : DateFormat.yMMMd().format(dateOfBirth!),
                      onTap: _pickDateOfBirth,
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Government ID or passport'),
                    SizedBox(height: 8),
                    _PickerTile(
                      key: const ValueKey('kyc-government-id'),
                      icon: Icons.badge_outlined,
                      title: governmentId?.name ?? 'Upload ID document',
                      onTap: () => _pickFile((file) => governmentId = file),
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Selfie / face verification'),
                    SizedBox(height: 8),
                    _PickerTile(
                      key: const ValueKey('kyc-selfie'),
                      icon: Icons.face_retouching_natural_outlined,
                      title: selfie?.name ?? 'Capture selfie',
                      onTap: _pickSelfie,
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Physical address proof'),
                    SizedBox(height: 8),
                    _PickerTile(
                      key: const ValueKey('kyc-address-proof'),
                      icon: Icons.home_work_outlined,
                      title:
                          addressProof?.name ?? 'Upload utility bill or lease',
                      onTap: () => _pickFile((file) => addressProof = file),
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Phone verification'),
                    SizedBox(height: 8),
                    AppTextField(
                      key: const ValueKey('kyc-phone'),
                      controller: phoneController,
                      hintText: '+256774224734',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_iphone_rounded,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                    ),
                    SizedBox(height: 10),
                    SecondaryButton(
                      key: const ValueKey('send-phone-code'),
                      label: sendingPhone ? 'Sending...' : 'Send code',
                      onPressed: sendingPhone ? null : _sendPhoneCode,
                    ),
                    SizedBox(height: 10),
                    AppTextField(
                      key: const ValueKey('kyc-phone-code'),
                      controller: phoneCodeController,
                      hintText: 'Verification code',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.sms_outlined,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Email verification'),
                    SizedBox(height: 8),
                    _VerificationRow(
                      label: kyc.emailVerified
                          ? 'Email verified'
                          : 'Email not verified',
                      verified: kyc.emailVerified,
                      action: sendingEmail ? 'Sending...' : 'Send email',
                      onAction: sendingEmail || kyc.emailVerified
                          ? null
                          : _sendEmailVerification,
                    ),
                    SizedBox(height: 26),
                    PrimaryButton(
                      key: const ValueKey('submit-kyc'),
                      label: submitting ? 'Submitting...' : 'Submit for review',
                      onPressed: submitting ? null : _submit,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Phone codes appear in the Firebase Auth emulator. Development emails appear in Mailpit.',
                      style: AppText.disclosure,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  var hydrated = false;

  void _hydrateOnce(KycProfile kyc) {
    if (hydrated) return;
    fullNameController.text = kyc.fullLegalName ?? fullNameController.text;
    phoneController.text = kyc.phoneNumber ?? phoneController.text;
    dateOfBirth = kyc.dateOfBirth;
    hydrated = true;
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.gold,
            surface: AppColors.panel,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => dateOfBirth = picked);
    }
  }

  Future<void> _pickFile(ValueChanged<KycDocumentFile> onPicked) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = result?.files.single;
    if (file?.bytes == null) return;
    setState(() {
      onPicked(
        KycDocumentFile(
          name: file!.name,
          bytes: file.bytes!,
          contentType: _contentTypeFor(file.name),
        ),
      );
    });
  }

  Future<void> _pickSelfie() async {
    final source = kIsWeb ? ImageSource.gallery : ImageSource.camera;
    final image = await imagePicker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 84,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      selfie = KycDocumentFile(
        name: image.name,
        bytes: bytes,
        contentType: image.mimeType ?? _contentTypeFor(image.name),
      );
    });
  }

  Future<void> _sendEmailVerification() async {
    setState(() {
      kycMessage = null;
      sendingEmail = true;
    });
    try {
      await widget.repository.sendEmailVerification();
      if (mounted) showMessage(context, 'Verification email sent');
    } catch (error) {
      if (mounted) _showKycMessage(_kycErrorMessage(error));
    } finally {
      if (mounted) setState(() => sendingEmail = false);
    }
  }

  Future<void> _sendPhoneCode() async {
    if (phoneController.text.trim().isEmpty) {
      _showKycMessage('Enter your phone number first');
      return;
    }
    setState(() {
      kycMessage = null;
      sendingPhone = true;
    });
    try {
      await widget.repository.sendPhoneVerificationCode(phoneController.text);
      if (mounted) {
        showMessage(context, 'Code sent. Check the Firebase Auth emulator.');
      }
    } catch (error) {
      if (mounted) _showKycMessage(_kycErrorMessage(error));
    } finally {
      if (mounted) setState(() => sendingPhone = false);
    }
  }

  Future<void> _submit() async {
    final missing = _missingFields();
    if (missing != null) {
      _showKycMessage(missing);
      return;
    }

    setState(() {
      kycMessage = null;
      submitting = true;
    });
    try {
      await widget.repository.submit(
        KycSubmission(
          fullLegalName: fullNameController.text,
          dateOfBirth: dateOfBirth!,
          phoneNumber: phoneController.text,
          phoneVerificationCode: phoneCodeController.text,
          governmentId: governmentId!,
          selfie: selfie!,
          addressProof: addressProof!,
        ),
      );
      if (mounted) {
        showMessage(context, 'KYC submitted for automatic checks');
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) _showKycMessage(_kycErrorMessage(error));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  String? _missingFields() {
    if (fullNameController.text.trim().isEmpty) return 'Enter your legal name';
    if (dateOfBirth == null) return 'Select your date of birth';
    if (governmentId == null) return 'Upload your ID or passport';
    if (selfie == null) return 'Capture a selfie';
    if (addressProof == null) return 'Upload address proof';
    if (phoneController.text.trim().isEmpty) return 'Enter your phone number';
    if (!_isE164PhoneNumber(phoneController.text.trim())) {
      return 'Enter your phone number in international format, e.g. +256774224734.';
    }
    if (phoneCodeController.text.trim().isEmpty) {
      return 'Enter the phone verification code';
    }
    return null;
  }

  void _showKycMessage(String message) {
    final displayMessage = message.trim().isEmpty
        ? 'We could not update your KYC details. Please try again.'
        : message.trim();
    setState(() => kycMessage = displayMessage);
    showMessage(context, displayMessage);
  }

  bool _isE164PhoneNumber(String phoneNumber) {
    return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phoneNumber);
  }

  String _contentTypeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }
}

class _KycMessageBanner extends StatelessWidget {
  const _KycMessageBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const ValueKey('kyc-message'),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: .55)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.warning,
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text(title, style: AppText.fieldLabel)),
            Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  const _VerificationRow({
    required this.label,
    required this.verified,
    required this.action,
    required this.onAction,
  });

  final String label;
  final bool verified;
  final String action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            verified ? Icons.check_circle_rounded : Icons.mail_outline_rounded,
            color: verified ? AppColors.success : AppColors.gold,
          ),
          SizedBox(width: 12),
          Expanded(child: Text(label, style: AppText.fieldLabel)),
          SizedBox(
            width: 104,
            child: SecondaryButton(
              label: action,
              onPressed: onAction,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}

String _kycErrorMessage(Object error) {
  if (error is KycValidationException) {
    return error.message;
  }
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-phone-number' =>
        'Enter your phone number in international format, e.g. +256774224734.',
      'invalid-verification-code' => 'Enter the SMS code from the emulator.',
      'credential-already-in-use' =>
        'That phone number is already linked to another account.',
      'too-many-requests' => 'Too many verification attempts. Try again later.',
      _ =>
        error.message?.trim().isNotEmpty == true
            ? error.message!
            : 'Phone verification failed. Please try again.',
    };
  }
  if (error is FirebaseException) {
    return switch (error.code) {
      'unauthenticated' => 'Sign in again to continue with KYC.',
      'permission-denied' =>
        'You do not have permission to update this KYC profile.',
      'unavailable' =>
        'KYC services are temporarily unavailable. Please try again shortly.',
      'deadline-exceeded' =>
        'The request took too long. Please check your connection and try again.',
      'storage/unauthorized' =>
        'You do not have permission to upload this document.',
      'storage/canceled' => 'Document upload was cancelled.',
      'storage/retry-limit-exceeded' =>
        'The upload took too long. Please check your connection and try again.',
      'storage/quota-exceeded' =>
        'Document uploads are temporarily unavailable. Please try again later.',
      _ => 'We could not update your KYC details. Please try again.',
    };
  }
  return _friendlyUnexpectedMessage(error);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.kyc,
    required this.investmentRepository,
    required this.onInvest,
    required this.onStartKyc,
    required this.onOpenProfile,
  });

  final KycProfile kyc;
  final InvestmentRepository investmentRepository;
  final VoidCallback onInvest;
  final VoidCallback onStartKyc;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'BrickClub',
      onProfileTap: onOpenProfile,
      children: [
        KycStatusCard(kyc: kyc, onStartKyc: onStartKyc, compact: true),
        FutureBuilder<MemberDashboardData>(
          future: investmentRepository.loadMemberDashboard(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _DashboardLoadingPanel();
            }
            if (snapshot.hasError) {
              return const _DashboardErrorPanel();
            }
            return _PortfolioOverview(
              data: snapshot.data ?? MemberDashboardData.empty(),
            );
          },
        ),
        SectionHeading(
          title: 'Featured opportunity',
          action: 'View all',
          onAction: onInvest,
        ),
        FutureBuilder<List<InvestmentOpportunity>>(
          future: investmentRepository.listOpportunities(),
          builder: (context, snapshot) {
            final opportunities = snapshot.data ?? const [];
            if (snapshot.connectionState != ConnectionState.done) {
              return Panel(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              );
            }
            if (opportunities.isEmpty) {
              return Panel(
                child: Column(
                  children: [
                    Icon(
                      Icons.apartment_rounded,
                      color: AppColors.gold,
                      size: 34,
                    ),
                    SizedBox(height: 10),
                    Text('No live BrickShares yet', style: AppText.h2),
                    SizedBox(height: 6),
                    Text(
                      'Published, verified assets will appear here.',
                      textAlign: TextAlign.center,
                      style: AppText.body,
                    ),
                    SizedBox(height: 16),
                    SecondaryButton(label: 'View invest', onPressed: onInvest),
                  ],
                ),
              );
            }

            final opportunity = opportunities.first;
            return InvestmentCard(
              compact: true,
              category: opportunity.assetClass,
              title: opportunity.displayTitle,
              location: opportunity.location,
              minimum: opportunity.minimumText,
              returnText: opportunity.returnText,
              onTap: () => openDetail(
                context,
                kyc,
                opportunity,
                investmentRepository,
                onStartKyc,
              ),
            );
          },
        ),
        const SectionHeading(title: 'Your holdings', action: 'View all'),
        FutureBuilder<MemberDashboardData>(
          future: investmentRepository.loadMemberDashboard(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _DashboardLoadingPanel();
            }
            if (snapshot.hasError) {
              return const _DashboardErrorPanel();
            }
            return _HoldingsPanel(
              holdings: (snapshot.data ?? MemberDashboardData.empty()).holdings,
            );
          },
        ),
        const SectionHeading(title: 'Recent activity', action: 'View all'),
        FutureBuilder<MemberDashboardData>(
          future: investmentRepository.loadMemberDashboard(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _DashboardLoadingPanel();
            }
            if (snapshot.hasError) {
              return const _DashboardErrorPanel();
            }
            return _ActivityPanel(
              activity: (snapshot.data ?? MemberDashboardData.empty()).activity,
            );
          },
        ),
      ],
    );
  }
}

class _PortfolioOverview extends StatelessWidget {
  const _PortfolioOverview({required this.data});

  final MemberDashboardData data;

  @override
  Widget build(BuildContext context) {
    final chartValues = data.chartValues.isEmpty
        ? const <double>[0, 0, 0, 0, 0, 0]
        : data.chartValues;
    final chartLabels = data.chartLabels.isEmpty
        ? const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
        : data.chartLabels;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Portfolio value', style: AppText.bodyLarge),
        SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Text(data.portfolioValueText, style: AppText.hero)),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(data.yearReturnText, style: AppText.goldBody),
            ),
          ],
        ),
        SizedBox(height: 18),
        SizedBox(
          height: 96,
          width: double.infinity,
          child: CustomPaint(painter: _PortfolioChartPainter(chartValues)),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final label in chartLabels.take(6))
              Text(label, style: AppText.tiny),
          ],
        ),
      ],
    );
  }
}

class _PortfolioChartPainter extends CustomPainter {
  const _PortfolioChartPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxValue = values.fold<double>(0, (max, value) {
      return value > max ? value : max;
    });
    if (values.length < 2 || maxValue <= 0) return;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final normalized = values[i] / maxValue;
      final y = size.height - (normalized * size.height * .78);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.gold
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _PortfolioChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

class _HoldingsPanel extends StatelessWidget {
  const _HoldingsPanel({required this.holdings});

  final List<MemberHolding> holdings;

  @override
  Widget build(BuildContext context) {
    if (holdings.isEmpty) {
      return const _EmptyFinancePanel(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No holdings yet',
        message: 'Verified deposits will appear here as BrickShares.',
      );
    }

    return Panel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (final entry in holdings.take(4).indexed) ...[
            if (entry.$1 > 0) Divider(height: 1, color: AppColors.border),
            _HoldingRow(
              title: entry.$2.title,
              subtitle: entry.$2.sharesText,
              value: entry.$2.valueText,
              change: entry.$2.returnText,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({required this.activity});

  final List<MemberActivity> activity;

  @override
  Widget build(BuildContext context) {
    if (activity.isEmpty) {
      return const _EmptyFinancePanel(
        icon: Icons.history_rounded,
        title: 'No activity yet',
        message: 'Deposit requests and settlement updates will appear here.',
      );
    }

    return Panel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (final entry in activity.take(4).indexed) ...[
            if (entry.$1 > 0) Divider(height: 1, color: AppColors.border),
            _ActivityRow(
              icon: _activityIcon(entry.$2.status),
              title: entry.$2.title,
              subtitle: entry.$2.subtitle,
              value: entry.$2.value,
            ),
          ],
        ],
      ),
    );
  }

  IconData _activityIcon(String status) {
    return switch (status) {
      'deposit_verified' => Icons.verified_user_outlined,
      'proof_submitted' => Icons.receipt_long_outlined,
      'deposit_rejected' => Icons.error_outline_rounded,
      _ => Icons.south_west_rounded,
    };
  }
}

class _DashboardLoadingPanel extends StatelessWidget {
  const _DashboardLoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
    );
  }
}

class _DashboardErrorPanel extends StatelessWidget {
  const _DashboardErrorPanel();

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        children: [
          Text('Unable to load account data', style: AppText.h2),
          SizedBox(height: 8),
          Text(
            'Check the backend connection and try again.',
            textAlign: TextAlign.center,
            style: AppText.body,
          ),
        ],
      ),
    );
  }
}

class _EmptyFinancePanel extends StatelessWidget {
  const _EmptyFinancePanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold, size: 32),
          SizedBox(height: 10),
          Text(title, style: AppText.h2),
          SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: AppText.body),
        ],
      ),
    );
  }
}

class _HoldingRow extends StatelessWidget {
  const _HoldingRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.change,
  });

  final String title;
  final String subtitle;
  final String value;
  final String change;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const _AssetIcon(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.fieldLabel),
                SizedBox(height: 3),
                Text(subtitle, style: AppText.tiny),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: AppText.fieldLabel),
              SizedBox(height: 3),
              Text(
                change,
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.track,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.gold, size: 19),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.fieldLabel),
                SizedBox(height: 3),
                Text(subtitle, style: AppText.tiny),
              ],
            ),
          ),
          Text(value, style: AppText.goldBody),
        ],
      ),
    );
  }
}

class _AssetIcon extends StatelessWidget {
  const _AssetIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.apartment_rounded, color: AppColors.gold, size: 18),
    );
  }
}

class BrickShareFilters {
  const BrickShareFilters({
    this.asset = 'All',
    this.risk = 'All',
    this.payment = 'All',
  });

  final String asset;
  final String risk;
  final String payment;

  bool matches(InvestmentOpportunity opportunity) {
    return (asset == 'All' || opportunity.assetClass == asset) &&
        (risk == 'All' || opportunity.riskLevel == risk) &&
        (payment == 'All' || opportunity.paymentMethods.contains(payment));
  }
}

class InvestScreen extends StatefulWidget {
  const InvestScreen({
    super.key,
    required this.kyc,
    required this.investmentRepository,
    required this.onStartKyc,
    required this.onOpenProfile,
  });

  final KycProfile kyc;
  final InvestmentRepository investmentRepository;
  final VoidCallback onStartKyc;
  final VoidCallback onOpenProfile;

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> {
  BrickShareFilters filters = const BrickShareFilters();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InvestmentOpportunity>>(
      future: widget.investmentRepository.listOpportunities(),
      builder: (context, snapshot) {
        final allOpportunities = snapshot.data ?? const [];
        final opportunities = allOpportunities
            .where(filters.matches)
            .toList(growable: false);
        final featuredReturn = opportunities.isEmpty
            ? '0.0%'
            : opportunities.first.returnText;

        return AppPage(
          title: 'Invest',
          subtitle: 'Explore verified multi-asset BrickShares',
          onProfileTap: widget.onOpenProfile,
          children: [
            SizedBox(
              height: 36,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoicePill(
                      label: 'Available ${opportunities.length}',
                      selected: true,
                    ),
                    SizedBox(width: 8),
                    ChoicePill(label: filters.asset),
                    SizedBox(width: 8),
                    ChoicePill(label: filters.risk),
                    SizedBox(width: 8),
                    ChoicePill(label: filters.payment),
                  ],
                ),
              ),
            ),
            Panel(
              radius: 20,
              child: Row(
                children: [
                  Text(featuredReturn, style: AppText.goldMetric),
                  SizedBox(width: 22),
                  Expanded(
                    child: Text(
                      'Filtered income\nBrickShares',
                      style: AppText.cardHeadingSmall,
                    ),
                  ),
                ],
              ),
            ),
            SectionHeading(
              title: snapshot.connectionState == ConnectionState.done
                  ? '${opportunities.length} opportunities'
                  : 'Loading opportunities',
              action: 'Filters',
              actionButton: true,
              onAction: allOpportunities.isEmpty
                  ? null
                  : () => _openFilters(allOpportunities),
            ),
            if (snapshot.connectionState != ConnectionState.done)
              Panel(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              )
            else if (opportunities.isEmpty)
              Panel(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      color: AppColors.gold,
                      size: 34,
                    ),
                    SizedBox(height: 10),
                    Text('No BrickShares match', style: AppText.h2),
                    SizedBox(height: 6),
                    Text(
                      allOpportunities.isEmpty
                          ? 'Admin-published verified assets will appear here.'
                          : 'Try a different asset class, risk level, or payment method.',
                      textAlign: TextAlign.center,
                      style: AppText.body,
                    ),
                    SizedBox(height: 16),
                    SecondaryButton(
                      label: 'Reset filters',
                      onPressed: () =>
                          setState(() => filters = const BrickShareFilters()),
                    ),
                  ],
                ),
              )
            else
              for (final opportunity in opportunities)
                InvestmentCard(
                  category: opportunity.assetClass,
                  title: opportunity.displayTitle,
                  location: opportunity.location,
                  minimum: opportunity.minimumText,
                  returnText: opportunity.returnText,
                  onTap: () => openDetail(
                    context,
                    widget.kyc,
                    opportunity,
                    widget.investmentRepository,
                    widget.onStartKyc,
                  ),
                ),
          ],
        );
      },
    );
  }

  Future<void> _openFilters(List<InvestmentOpportunity> opportunities) async {
    final updated = await Navigator.push<BrickShareFilters>(
      context,
      MaterialPageRoute(
        builder: (_) => FiltersScreen(
          initialFilters: filters,
          opportunities: opportunities,
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() => filters = updated);
    }
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({
    super.key,
    required this.kyc,
    required this.investmentRepository,
    required this.onStartKyc,
    required this.onOpenProfile,
  });

  final KycProfile kyc;
  final InvestmentRepository investmentRepository;
  final VoidCallback onStartKyc;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Wallet',
      onProfileTap: onOpenProfile,
      children: [
        FutureBuilder<MemberDashboardData>(
          future: investmentRepository.loadMemberDashboard(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _DashboardLoadingPanel();
            }
            if (snapshot.hasError) {
              return const _DashboardErrorPanel();
            }
            final data = snapshot.data ?? MemberDashboardData.empty();
            return Container(
              height: 170,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.panel, AppColors.surface],
                ),
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Verified wallet balance', style: AppText.bodyLarge),
                  SizedBox(height: 10),
                  Text(data.walletBalanceText, style: AppText.walletValue),
                  SizedBox(height: 8),
                  Text(data.cryptoRailsText, style: AppText.eyebrow),
                ],
              ),
            );
          },
        ),
        KycStatusCard(kyc: kyc, onStartKyc: onStartKyc, compact: true),
        SizedBox(height: 28),
        Panel(
          child: Column(
            children: [
              Text(
                'Crypto funding readiness',
                style: AppText.cardHeading,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Add a verified wallet before sending funds. Network, fees, '
                'quote expiry, and settlement status are shown before confirmation.',
                textAlign: TextAlign.center,
                style: AppText.body,
              ),
              SizedBox(height: 20),
              PrimaryButton(
                label: 'Add verified wallet',
                height: 46,
                onPressed: () => requireApprovedKyc(
                  context,
                  kyc,
                  () => showMessage(context, 'Wallet verification started'),
                  onStartKyc,
                ),
              ),
            ],
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settlement confirmation required',
                style: AppText.cardHeadingSmall,
              ),
              SizedBox(height: 10),
              Text(
                'Purchases, withdrawals, and wallet changes require final confirmation.',
                style: AppText.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({
    super.key,
    required this.investmentRepository,
    required this.onOpenProfile,
  });

  final InvestmentRepository investmentRepository;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Portfolio',
      onProfileTap: onOpenProfile,
      children: [
        FutureBuilder<MemberDashboardData>(
          future: investmentRepository.loadMemberDashboard(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _DashboardLoadingPanel();
            }
            if (snapshot.hasError) {
              return const _DashboardErrorPanel();
            }
            final data = snapshot.data ?? MemberDashboardData.empty();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Panel(
                  radius: 22,
                  padding: const EdgeInsets.all(18),
                  child: SizedBox(
                    height: 112,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total BrickShares allocation',
                          style: AppText.body,
                        ),
                        SizedBox(height: 10),
                        Text(
                          data.portfolioValueText,
                          style: AppText.portfolioValue,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text('Allocation', style: AppText.h2),
                if (data.allocation.isEmpty)
                  const _EmptyFinancePanel(
                    icon: Icons.pie_chart_outline_rounded,
                    title: 'No allocation yet',
                    message: 'Your asset mix appears after deposits verify.',
                  )
                else
                  for (final entry in data.allocation.indexed)
                    AllocationRow(
                      entry.$2.label,
                      entry.$2.percent,
                      _allocationColor(entry.$1),
                    ),
                SizedBox(height: 14),
                Text('Recent activity', style: AppText.h2),
                _ActivityPanel(activity: data.activity),
              ],
            );
          },
        ),
      ],
    );
  }

  Color _allocationColor(int index) {
    final colors = [
      AppColors.gold,
      Color(0xFF38BDF8),
      Color(0xFF22C55E),
      Color(0xFFF59E0B),
      Color(0xFFA78BFA),
    ];
    return colors[index % colors.length];
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.kyc,
    required this.supportRepository,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onStartKyc,
  });

  final SignedInUserDetails? user;
  final KycProfile kyc;
  final SupportRepository supportRepository;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback onStartKyc;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Profile',
      simpleHeader: true,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          color: AppColors.panel,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.track,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.gold,
                  size: 28,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_profileName, style: AppText.h2),
                    Text(
                      _profileSubtitle,
                      style: AppText.body,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18),
        KycStatusCard(kyc: kyc, onStartKyc: onStartKyc),
        ProfileRow(
          key: const ValueKey('profile-settings'),
          title: 'Settings',
          subtitle: '${_themeModeLabel(themeMode)} theme',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ThemeSettingsScreen(
                themeMode: themeMode,
                onThemeModeChanged: onThemeModeChanged,
              ),
            ),
          ),
        ),
        for (final item in [
          ('Security & privacy', 'Verified wallet and biometrics'),
          ('Documents', 'Statements, risk disclosures'),
        ])
          ProfileRow(
            title: item.$1,
            subtitle: item.$2,
            onTap: () => showMessage(context, '${item.$1} opened'),
          ),
        ProfileRow(
          key: const ValueKey('profile-support'),
          title: 'Support',
          subtitle: 'Message the BrickClub team',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SupportScreen(repository: supportRepository),
            ),
          ),
        ),
      ],
    );
  }

  String get _profileName {
    final signedInName = user?.displayName?.trim();
    if (signedInName != null && signedInName.isNotEmpty) return signedInName;

    final legalName = kyc.fullLegalName?.trim();
    if (legalName != null && legalName.isNotEmpty) return legalName;

    return user?.primaryLabel ?? 'BrickClub member';
  }

  String get _profileSubtitle {
    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) return email;

    return 'Your account and BrickShares details';
  }
}

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, 'Theme'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Text('Appearance', style: AppText.h2),
            SizedBox(height: 8),
            Text(
              'Choose how BrickClub looks on this device.',
              style: AppText.bodyLarge,
            ),
            SizedBox(height: 18),
            Panel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final mode in ThemeMode.values)
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        key: ValueKey('theme-${mode.name}'),
                        title: Text(_themeModeLabel(mode), style: AppText.h2),
                        subtitle: Text(
                          _themeModeDescription(mode),
                          style: AppText.body,
                        ),
                        trailing: Icon(
                          themeMode == mode
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: themeMode == mode
                              ? AppColors.gold
                              : AppColors.muted,
                        ),
                        onTap: () => onThemeModeChanged(mode),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'System default',
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
};

String _themeModeDescription(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'Follow this device automatically.',
  ThemeMode.light => 'Use a bright interface with dark text.',
  ThemeMode.dark => 'Use the classic dark BrickClub interface.',
};

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key, required this.repository});

  final SupportRepository repository;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, 'Support'),
        body: StreamBuilder<List<SupportTicket>>(
          stream: repository.watchMyTickets(),
          builder: (context, snapshot) {
            final tickets = snapshot.data ?? const <SupportTicket>[];
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
              children: [
                PrimaryButton(
                  key: const ValueKey('new-support-ticket'),
                  label: 'New support request',
                  onPressed: () => _showCreateTicket(context),
                ),
                SizedBox(height: 18),
                if (snapshot.connectionState == ConnectionState.waiting)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  )
                else if (tickets.isEmpty)
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No support requests yet', style: AppText.h2),
                        SizedBox(height: 8),
                        Text(
                          'Start a conversation with the BrickClub team when you need account, KYC, wallet, or investment help.',
                          style: AppText.body,
                        ),
                      ],
                    ),
                  )
                else
                  for (final ticket in tickets)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SupportTicketTile(
                        ticket: ticket,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SupportThreadScreen(
                              repository: repository,
                              ticket: ticket,
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCreateTicket(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SupportComposerSheet(
        title: 'New support request',
        subjectEnabled: true,
        submitLabel: 'Send request',
        onSubmit: (subject, message) async {
          await repository.createTicket(subject: subject, message: message);
        },
      ),
    );
  }
}

class SupportThreadScreen extends StatelessWidget {
  const SupportThreadScreen({
    super.key,
    required this.repository,
    required this.ticket,
  });

  final SupportRepository repository;
  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, ticket.subject),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(ticket.status.label, style: AppText.goldBody),
                ),
                Text('${ticket.messages.length} messages', style: AppText.tiny),
              ],
            ),
            SizedBox(height: 16),
            for (final message in ticket.messages)
              _SupportMessageBubble(message: message),
            SizedBox(height: 16),
            PrimaryButton(
              key: const ValueKey('reply-support-ticket'),
              label: ticket.isClosed ? 'Request closed' : 'Reply',
              onPressed: ticket.isClosed ? null : () => _showReply(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReply(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SupportComposerSheet(
        title: 'Reply to support',
        subjectEnabled: false,
        submitLabel: 'Send reply',
        onSubmit: (_, message) async {
          await repository.replyToTicket(ticketId: ticket.id, message: message);
        },
      ),
    );
  }
}

class _SupportTicketTile extends StatelessWidget {
  const _SupportTicketTile({required this.ticket, required this.onTap});

  final SupportTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(ticket.subject, style: AppText.h2)),
                  Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                ],
              ),
              SizedBox(height: 8),
              Text(
                ticket.latestMessage?.body ?? 'No messages yet',
                style: AppText.body,
              ),
              SizedBox(height: 12),
              ChoicePill(label: ticket.status.label, selected: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportMessageBubble extends StatelessWidget {
  const _SupportMessageBubble({required this.message});

  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final alignment = message.isAdmin
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;
    final color = message.isAdmin ? AppColors.panel : AppColors.goldSoft;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            message.isAdmin ? 'BrickClub support' : 'You',
            style: AppText.tinyLight,
          ),
          SizedBox(height: 5),
          Container(
            constraints: const BoxConstraints(maxWidth: 290),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(message.body, style: AppText.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _SupportComposerSheet extends StatefulWidget {
  const _SupportComposerSheet({
    required this.title,
    required this.subjectEnabled,
    required this.submitLabel,
    required this.onSubmit,
  });

  final String title;
  final bool subjectEnabled;
  final String submitLabel;
  final Future<void> Function(String subject, String message) onSubmit;

  @override
  State<_SupportComposerSheet> createState() => _SupportComposerSheetState();
}

class _SupportComposerSheetState extends State<_SupportComposerSheet> {
  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  bool submitting = false;

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        22,
        22,
        MediaQuery.viewInsetsOf(context).bottom + 26,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: AppText.h2),
          if (widget.subjectEnabled) ...[
            SizedBox(height: 16),
            const FieldLabel('Subject'),
            SizedBox(height: 8),
            AppTextField(
              key: const ValueKey('support-subject'),
              controller: subjectController,
              hintText: 'What do you need help with?',
              prefixIcon: Icons.support_agent_rounded,
            ),
          ],
          SizedBox(height: 16),
          const FieldLabel('Message'),
          SizedBox(height: 8),
          TextField(
            key: const ValueKey('support-message'),
            controller: messageController,
            minLines: 4,
            maxLines: 6,
            style: TextStyle(fontSize: 14, color: AppColors.primary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              hintText: 'Type your message',
              hintStyle: AppText.placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.gold, width: 1.3),
              ),
            ),
          ),
          SizedBox(height: 18),
          PrimaryButton(
            key: const ValueKey('send-support-message'),
            label: submitting ? 'Sending...' : widget.submitLabel,
            onPressed: submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final subject = subjectController.text.trim();
    final message = messageController.text.trim();
    if (widget.subjectEnabled && subject.isEmpty) {
      showMessage(context, 'Enter a subject');
      return;
    }
    if (message.isEmpty) {
      showMessage(context, 'Enter a message');
      return;
    }

    setState(() => submitting = true);
    try {
      await widget.onSubmit(subject, message);
      if (mounted) {
        Navigator.pop(context);
        showMessage(context, 'Message sent');
      }
    } catch (error) {
      if (mounted) showMessage(context, _friendlyUnexpectedMessage(error));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }
}

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({
    super.key,
    required this.initialFilters,
    required this.opportunities,
  });

  final BrickShareFilters initialFilters;
  final List<InvestmentOpportunity> opportunities;

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late String asset;
  late String risk;
  late String payment;

  @override
  void initState() {
    super.initState();
    asset = widget.initialFilters.asset;
    risk = widget.initialFilters.risk;
    payment = widget.initialFilters.payment;
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, 'Filters'),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Panel(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Asset class', style: AppText.h2),
                            SizedBox(height: 16),
                            FilterChoices(
                              values: _assetOptions,
                              selected: asset,
                              onChanged: (value) =>
                                  setState(() => asset = value),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Panel(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Risk level', style: AppText.h2),
                            SizedBox(height: 16),
                            FilterChoices(
                              values: _riskOptions,
                              selected: risk,
                              onChanged: (value) =>
                                  setState(() => risk = value),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Panel(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Payment method', style: AppText.h2),
                            SizedBox(height: 16),
                            FilterChoices(
                              values: _paymentOptions,
                              selected: payment,
                              onChanged: (value) =>
                                  setState(() => payment = value),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      key: const ValueKey('reset-filters'),
                      label: 'Reset',
                      onPressed: () => setState(() {
                        asset = const BrickShareFilters().asset;
                        risk = const BrickShareFilters().risk;
                        payment = const BrickShareFilters().payment;
                      }),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      key: const ValueKey('show-brickshares'),
                      label: 'Show $_matchingCount',
                      height: 46,
                      onPressed: () => Navigator.pop(
                        context,
                        BrickShareFilters(
                          asset: asset,
                          risk: risk,
                          payment: payment,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int get _matchingCount {
    final selected = BrickShareFilters(
      asset: asset,
      risk: risk,
      payment: payment,
    );
    return widget.opportunities.where(selected.matches).length;
  }

  List<String> get _assetOptions => _uniqueOptions(
    widget.opportunities.map((opportunity) => opportunity.assetClass),
  );

  List<String> get _riskOptions => _uniqueOptions(
    widget.opportunities.map((opportunity) => opportunity.riskLevel),
  );

  List<String> get _paymentOptions => _uniqueOptions(
    widget.opportunities.expand((opportunity) => opportunity.paymentMethods),
  );

  List<String> _uniqueOptions(Iterable<String> values) {
    final unique =
        values
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All', ...unique];
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.kyc,
    required this.opportunity,
    required this.investmentRepository,
    required this.onStartKyc,
  });

  final KycProfile kyc;
  final InvestmentOpportunity opportunity;
  final InvestmentRepository investmentRepository;
  final VoidCallback onStartKyc;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, 'BrickShares'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/kololo_heights_v2.png',
                      height: 206,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Positioned(
                    top: 16,
                    left: 14,
                    child: ChoicePill(label: 'Verified docs', selected: true),
                  ),
                ],
              ),
              SizedBox(height: 26),
              Text(opportunity.displayTitle, style: AppText.detailTitle),
              Text(
                '${opportunity.assetClass} BrickShares | ${opportunity.location}',
                style: AppText.body,
              ),
              SizedBox(height: 20),
              Panel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Metric(
                            opportunity.returnText,
                            'Target return',
                            gold: true,
                          ),
                        ),
                        Expanded(
                          child: Metric(opportunity.minimumText, 'Minimum'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Metric('36 mo', 'Liquidity')),
                        Expanded(
                          child: Metric(opportunity.riskLevel, 'Risk level'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Panel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Funding status',
                            style: AppText.cardHeadingSmall,
                          ),
                        ),
                        Text(
                          '${opportunity.fundedPercent.toStringAsFixed(0)}% funded',
                          style: AppText.goldBody,
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    ProgressLine(value: opportunity.fundedPercent / 100),
                    SizedBox(height: 12),
                    Text(
                      'Supported payment options and quote expiry are shown before settlement confirmation.',
                      style: AppText.small,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              PrimaryButton(
                key: const ValueKey('invest-with-crypto'),
                label: 'Invest with crypto funding',
                onPressed: () => requireApprovedKyc(
                  context,
                  kyc,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        kyc: kyc,
                        opportunity: opportunity,
                        investmentRepository: investmentRepository,
                      ),
                    ),
                  ),
                  onStartKyc,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.kyc,
    required this.opportunity,
    required this.investmentRepository,
  });

  final KycProfile kyc;
  final InvestmentOpportunity opportunity;
  final InvestmentRepository investmentRepository;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool submitting = false;
  PurchaseOrder? order;
  DepositProofFile? proof;
  late String selectedPaymentAsset;
  late final TextEditingController amountController;
  late final TextEditingController transactionHashController;

  @override
  void initState() {
    super.initState();
    selectedPaymentAsset = _cryptoPaymentMethods.contains('USDT')
        ? 'USDT'
        : _cryptoPaymentMethods.firstOrNull ?? 'USDT';
    amountController = TextEditingController(
      text: widget.opportunity.minimumInvestment.toStringAsFixed(0),
    );
    transactionHashController = TextEditingController();
  }

  @override
  void dispose() {
    amountController.dispose();
    transactionHashController.dispose();
    super.dispose();
  }

  List<String> get _cryptoPaymentMethods {
    final methods =
        widget.opportunity.paymentMethods
            .where((method) => method.toUpperCase() != 'UGX WALLET')
            .map((method) => method.trim().toUpperCase())
            .where((method) => method.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return methods.isEmpty ? const ['USDT'] : methods;
  }

  double get _enteredAmount {
    final normalized = amountController.text.replaceAll(',', '').trim();
    return double.tryParse(normalized) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethods = _cryptoPaymentMethods;
    final amount = order?.amountUgx ?? _enteredAmount;
    final belowMinimum =
        order == null && amount < widget.opportunity.minimumInvestment;
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, 'Confirm funding'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              _FundingHero(
                title: widget.opportunity.displayTitle,
                location: widget.opportunity.location,
                amountText: _formatUgxCompact(amount),
                rail: selectedPaymentAsset,
              ),
              SizedBox(height: 18),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Crypto funding setup',
                            style: AppText.cardHeading,
                          ),
                        ),
                        _StatusChip(order == null ? 'Draft' : 'Active'),
                      ],
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Payment rail'),
                    SizedBox(height: 10),
                    FilterChoices(
                      values: paymentMethods,
                      selected: selectedPaymentAsset,
                      onChanged: order == null
                          ? (value) => setState(() {
                              selectedPaymentAsset = value;
                            })
                          : (_) {},
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Investment amount'),
                    SizedBox(height: 8),
                    AppTextField(
                      controller: amountController,
                      hintText: 'Amount in UGX',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.payments_outlined,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 8),
                    Text(
                      belowMinimum
                          ? 'Minimum for this opportunity is ${widget.opportunity.minimumText}.'
                          : 'Demo amount can be adjusted before creating the deposit request.',
                      style: belowMinimum ? AppText.warning : AppText.small,
                    ),
                    SizedBox(height: 18),
                    QuoteRow(
                      'Payment asset',
                      order?.paymentAsset ?? selectedPaymentAsset,
                    ),
                    QuoteRow('Amount', _formatUgxCompact(amount)),
                    QuoteRow(
                      'Network',
                      order == null
                          ? 'Selected after request'
                          : order!.paymentNetwork,
                    ),
                    QuoteRow(
                      'Quote',
                      order == null ? 'Created by backend' : order!.quoteText,
                    ),
                    QuoteRow(
                      'Network fee',
                      order == null
                          ? 'Calculated by backend'
                          : order!.networkFeeText,
                    ),
                    const QuoteRow(
                      'Settlement',
                      'Pending confirmation',
                      warning: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              _FundingSteps(order: order, proofReady: proof != null),
              if (order != null) ...[
                SizedBox(height: 18),
                _DepositInstructions(
                  order: order!,
                  proofName: proof?.name,
                  transactionHashController: transactionHashController,
                  onPickProof: _pickProof,
                ),
              ],
              SizedBox(height: 18),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirmable financial action',
                      style: AppText.cardHeadingSmall,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'You are authorizing a crypto-funded BrickShares '
                      'purchase. Settlement may take network confirmations.',
                      style: AppText.body,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 36),
              PrimaryButton(
                key: const ValueKey('confirm-purchase'),
                label: submitting
                    ? 'Submitting...'
                    : order == null
                    ? 'Create deposit request'
                    : 'Submit proof for review',
                onPressed:
                    widget.kyc.canPerformFinancialActions &&
                        !submitting &&
                        !belowMinimum
                    ? () => order == null
                          ? _createDepositRequest(selectedPaymentAsset, amount)
                          : _submitProof()
                    : null,
              ),
              SizedBox(height: 14),
              SecondaryButton(
                label: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createDepositRequest(
    String paymentAsset,
    double amountUgx,
  ) async {
    if (amountUgx < widget.opportunity.minimumInvestment) {
      showMessage(context, 'Increase the amount to the opportunity minimum.');
      return;
    }
    setState(() => submitting = true);
    try {
      final createdOrder = await widget.investmentRepository
          .createPurchaseOrder(
            PurchaseRequest(
              opportunityId: widget.opportunity.id,
              amountUgx: amountUgx,
              paymentAsset: paymentAsset,
            ),
          );

      if (mounted) {
        setState(() => order = createdOrder);
        showMessage(context, 'Deposit request created');
      }
    } catch (error) {
      if (mounted) {
        showMessage(context, _friendlyUnexpectedMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }

  Future<void> _pickProof() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = result?.files.single;
    if (file?.bytes == null) return;
    setState(() {
      proof = DepositProofFile(
        name: file!.name,
        bytes: file.bytes!,
        contentType: _contentTypeForName(file.name),
      );
    });
  }

  Future<void> _submitProof() async {
    final currentOrder = order;
    final currentProof = proof;
    if (currentOrder == null) return;
    if (transactionHashController.text.trim().isEmpty) {
      showMessage(context, 'Enter the transaction hash');
      return;
    }
    if (currentProof == null) {
      showMessage(context, 'Upload proof of payment');
      return;
    }

    setState(() => submitting = true);
    try {
      final updatedOrder = await widget.investmentRepository.submitDepositProof(
        orderId: currentOrder.id,
        transactionHash: transactionHashController.text,
        proof: currentProof,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SuccessScreen(order: updatedOrder)),
        );
      }
    } catch (error) {
      if (mounted) {
        showMessage(context, _friendlyUnexpectedMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }
}

class _DepositInstructions extends StatelessWidget {
  const _DepositInstructions({
    required this.order,
    required this.proofName,
    required this.transactionHashController,
    required this.onPickProof,
  });

  final PurchaseOrder order;
  final String? proofName;
  final TextEditingController transactionHashController;
  final VoidCallback onPickProof;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deposit instructions', style: AppText.cardHeading),
          SizedBox(height: 14),
          if (order.paymentQrCodeUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                order.paymentQrCodeUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 14),
          ],
          _CopyableQuoteRow('Wallet address', order.paymentWalletAddress),
          QuoteRow('Network', order.paymentNetwork),
          SizedBox(height: 14),
          const FieldLabel('Transaction hash'),
          SizedBox(height: 8),
          AppTextField(
            key: const ValueKey('transaction-hash'),
            controller: transactionHashController,
            hintText: 'Paste blockchain transaction hash',
            prefixIcon: Icons.tag_rounded,
          ),
          SizedBox(height: 14),
          _PickerTile(
            key: const ValueKey('payment-proof'),
            icon: Icons.upload_file_rounded,
            title: proofName ?? 'Upload proof of payment',
            onTap: onPickProof,
          ),
        ],
      ),
    );
  }
}

class _FundingHero extends StatelessWidget {
  const _FundingHero({
    required this.title,
    required this.location,
    required this.amountText,
    required this.rail,
  });

  final String title;
  final String location;
  final String amountText;
  final String rail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF087F7A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF20BBAE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.currency_bitcoin_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(rail, style: AppText.cardHeadingSmall),
              const Spacer(),
              Icon(Icons.north_east_rounded, color: AppColors.primary),
            ],
          ),
          SizedBox(height: 26),
          Text(amountText, style: AppText.walletValue),
          SizedBox(height: 6),
          Text(title, style: AppText.cardHeadingSmall),
          Text(location, style: AppText.bodyLarge),
        ],
      ),
    );
  }
}

class _FundingSteps extends StatelessWidget {
  const _FundingSteps({required this.order, required this.proofReady});

  final PurchaseOrder? order;
  final bool proofReady;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: _FundingStep(
              icon: Icons.tune_rounded,
              label: 'Quote',
              active: true,
              done: order != null,
            ),
          ),
          const _StepDivider(),
          Expanded(
            child: _FundingStep(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Send',
              active: order != null,
              done: proofReady,
            ),
          ),
          const _StepDivider(),
          Expanded(
            child: _FundingStep(
              icon: Icons.verified_outlined,
              label: 'Review',
              active: proofReady,
              done: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _FundingStep extends StatelessWidget {
  const _FundingStep({
    required this.icon,
    required this.label,
    required this.active,
    required this.done,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? AppColors.success
        : active
        ? AppColors.gold
        : AppColors.muted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .14),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: .45)),
          ),
          child: Icon(icon, color: color, size: 19),
        ),
        SizedBox(height: 7),
        Text(label, style: AppText.tinyLight, maxLines: 1),
      ],
    );
  }
}

class _StepDivider extends StatelessWidget {
  const _StepDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 1,
      margin: const EdgeInsets.only(bottom: 22),
      color: AppColors.border,
    );
  }
}

class _CopyableQuoteRow extends StatelessWidget {
  const _CopyableQuoteRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.body)),
          Flexible(
            child: Text(
              _shortHash(value),
              textAlign: TextAlign.right,
              style: AppText.fieldLabel,
            ),
          ),
          IconButton(
            tooltip: 'Copy',
            visualDensity: VisualDensity.compact,
            onPressed: value.trim().isEmpty
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: value));
                    if (context.mounted) {
                      showMessage(context, 'Wallet address copied');
                    }
                  },
            icon: Icon(Icons.copy_rounded, size: 16),
          ),
        ],
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.order});

  final PurchaseOrder order;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
            child: Column(
              children: [
                Container(
                  width: 128,
                  height: 128,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.track,
                    border: Border.all(color: AppColors.gold),
                    shape: BoxShape.circle,
                  ),
                  child: Text('OK', style: AppText.goldMetricSmall),
                ),
                SizedBox(height: 44),
                Text('Proof submitted', style: AppText.h1),
                SizedBox(height: 12),
                Text(
                  'Your proof of payment is awaiting admin verification. '
                  'We will notify you after review.',
                  textAlign: TextAlign.center,
                  style: AppText.bodyLarge,
                ),
                SizedBox(height: 38),
                Panel(
                  child: SizedBox(
                    height: 84,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Settlement status',
                            style: AppText.bodyLarge,
                          ),
                        ),
                        Text(order.status, style: AppText.warning),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 62),
                PrimaryButton(
                  key: const ValueKey('view-portfolio'),
                  label: 'View portfolio',
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.simpleHeader = false,
    this.onProfileTap,
  });

  final String title;
  final String? subtitle;
  final bool simpleHeader;
  final VoidCallback? onProfileTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (simpleHeader)
                    Center(child: Text(title, style: AppText.topTitle))
                  else
                    AppHeader(title: title, onProfileTap: onProfileTap),
                  if (subtitle != null) ...[
                    SizedBox(height: 4),
                    Text(subtitle!, style: AppText.body),
                  ],
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            sliver: SliverList.separated(
              itemCount: children.length,
              itemBuilder: (_, index) => children[index],
              separatorBuilder: (_, _) => SizedBox(height: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.title, this.onProfileTap});

  final String title;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const _BrickMark(),
          SizedBox(width: 10),
          Expanded(child: Text(title, style: AppText.topTitle)),
          HeaderCircle(
            onTap: () => showMessage(context, 'No new notifications'),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.secondary,
              size: 18,
            ),
          ),
          SizedBox(width: 9),
          HeaderCircle(
            key: const ValueKey('profile-header-button'),
            onTap:
                onProfileTap ??
                () => showMessage(context, 'Profile is in More'),
            child: Icon(
              Icons.person_outline_rounded,
              color: AppColors.gold,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static final items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.trending_up_rounded, Icons.trending_up_rounded, 'Invest'),
    (
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet_rounded,
      'Wallet',
    ),
    (Icons.pie_chart_outline_rounded, Icons.pie_chart_rounded, 'Portfolio'),
    (Icons.menu_rounded, Icons.menu_rounded, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _BottomNavItem(
                    key: ValueKey('nav-${items[i].$3.toLowerCase()}'),
                    icon: items[i].$1,
                    selectedIcon: items[i].$2,
                    label: items[i].$3,
                    selected: i == index,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 42,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.goldSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                selected ? selectedIcon : icon,
                color: selected ? AppColors.gold : AppColors.muted,
                size: 21,
              ),
            ),
            SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                color: selected ? AppColors.gold : AppColors.muted,
                fontSize: 10,
                height: 1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class InvestmentCard extends StatelessWidget {
  const InvestmentCard({
    super.key,
    required this.onTap,
    this.compact = false,
    this.category = 'Real Estate',
    this.title = 'Kololo Heights\nIncome Fund',
    this.location = 'Kampala Central',
    this.minimum = 'UGX 250K',
    this.returnText = '11.8%',
  });

  final VoidCallback onTap;
  final bool compact;
  final String category;
  final String title;
  final String location;
  final String minimum;
  final String returnText;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 176.0 : 188.0;
    return Material(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: const ValueKey('investment-card'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SizedBox(
                width: compact ? 134 : 128,
                height: height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/kololo_heights_v2.png',
                        width: compact ? 134 : 128,
                        height: height,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: ChoicePill(label: category, selected: true),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 18, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: AppText.investmentTitle),
                      SizedBox(height: 4),
                      Text(location, style: AppText.small),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              minimum,
                              style: AppText.goldBody,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(returnText, style: AppText.cardHeadingSmall),
                        ],
                      ),
                      if (!compact) ...[
                        SizedBox(height: 16),
                        const ProgressLine(value: .62, height: 6),
                        SizedBox(height: 7),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Crypto funding', style: AppText.tiny),
                            Text('62%', style: AppText.tinyLight),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 18,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.panel,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.actionButton = false,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final bool actionButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: AppText.h2)),
        if (action != null)
          actionButton
              ? SecondaryButton(
                  label: action!,
                  onPressed: onAction,
                  compact: true,
                )
              : TextButton(
                  onPressed: onAction,
                  child: Text(action!, style: AppText.body),
                ),
      ],
    );
  }
}

class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : AppColors.panel,
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.background : AppColors.secondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class FilterChoices extends StatelessWidget {
  const FilterChoices({
    super.key,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final value in values)
          ChoicePill(
            label: value,
            selected: selected == value,
            onTap: () => onChanged(value),
          ),
      ],
    );
  }
}

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.border),
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        icon: const GoogleIcon(),
        label: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .16;
    final rect = Offset.zero & size;

    void drawArc(Color color, double start, double sweep) {
      canvas.drawArc(
        rect.deflate(stroke / 2),
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }

    drawArc(const Color(0xFF4285F4), -0.08, 1.32);
    drawArc(const Color(0xFF34A853), 1.18, 1.34);
    drawArc(const Color(0xFFFBBC05), 2.43, 1.06);
    drawArc(const Color(0xFFEA4335), 3.43, 1.54);

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final centerY = size.height * .52;
    canvas.drawLine(
      Offset(size.width * .52, centerY),
      Offset(size.width * .94, centerY),
      bluePaint,
    );
    canvas.drawLine(
      Offset(size.width * .94, centerY),
      Offset(size.width * .94, size.height * .65),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          disabledBackgroundColor: AppColors.muted,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 95 : double.infinity,
      height: compact ? 38 : 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.border),
          backgroundColor: AppColors.panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.initialValue,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.compact = false,
    this.keyboardType,
    this.prefixIcon,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
  });

  final String? initialValue;
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final bool compact;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool obscured;

  @override
  void initState() {
    super.initState();
    obscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      obscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.compact ? 44 : 50,
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.controller == null ? widget.initialValue : null,
        obscureText: obscured,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints,
        onChanged: widget.onChanged,
        style: TextStyle(fontSize: 14, color: AppColors.primary),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.prefixIcon == null ? 16 : 12,
          ),
          filled: true,
          fillColor: AppColors.surface,
          hintText: widget.hintText,
          hintStyle: AppText.placeholder,
          prefixIcon: widget.prefixIcon == null
              ? null
              : Icon(widget.prefixIcon, color: AppColors.muted, size: 19),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 42,
            minHeight: 42,
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  tooltip: obscured ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => obscured = !obscured),
                  icon: Icon(
                    obscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.muted,
                    size: 20,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.compact ? 12 : 14),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.compact ? 12 : 14),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.compact ? 12 : 14),
            borderSide: BorderSide(color: AppColors.gold, width: 1.3),
          ),
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Text(label, style: AppText.fieldLabel);
}

class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 58,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.panel,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: AppText.cardHeadingSmall),
              Text(subtitle, style: AppText.tinyLight),
            ],
          ),
        ),
      ),
    );
  }
}

class AllocationRow extends StatelessWidget {
  const AllocationRow(this.label, this.value, this.color, {super.key});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 128, child: Text(label, style: AppText.fieldLabel)),
          Expanded(
            child: ProgressLine(value: value, color: color, height: 7),
          ),
        ],
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
  });

  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? AppColors.gold;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value,
          color: lineColor,
          backgroundColor: AppColors.track,
        ),
      ),
    );
  }
}

class Metric extends StatelessWidget {
  const Metric(this.value, this.label, {super.key, this.gold = false});

  final String value;
  final String label;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: gold ? AppColors.gold : AppColors.primary,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: AppText.small),
      ],
    );
  }
}

class QuoteRow extends StatelessWidget {
  const QuoteRow(this.label, this.value, {super.key, this.warning = false});

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.body)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: warning ? AppText.warning : AppText.fieldLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderPill extends StatelessWidget {
  const HeaderPill(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 31,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.panel,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: AppText.headerInitials),
    );
  }
}

class HeaderCircle extends StatelessWidget {
  const HeaderCircle({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.panel,
          border: Border.all(color: AppColors.border),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}

class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 393),
          child: Material(color: AppColors.background, child: child),
        ),
      ),
    );
  }
}

PreferredSizeWidget detailAppBar(BuildContext context, String title) {
  return AppBar(
    toolbarHeight: 76,
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.primary,
    centerTitle: true,
    leading: IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Icon(Icons.chevron_left, size: 32),
    ),
    title: Text(title, style: AppText.detailAppBar),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: AppColors.border),
    ),
  );
}

void openDetail(
  BuildContext context,
  KycProfile kyc,
  InvestmentOpportunity opportunity,
  InvestmentRepository investmentRepository,
  VoidCallback onStartKyc,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DetailScreen(
        kyc: kyc,
        opportunity: opportunity,
        investmentRepository: investmentRepository,
        onStartKyc: onStartKyc,
      ),
    ),
  );
}

String _shortHash(String hash) {
  final trimmed = hash.trim();
  if (trimmed.length <= 14) return trimmed.isEmpty ? '-' : trimmed;
  return '${trimmed.substring(0, 8)}...${trimmed.substring(trimmed.length - 6)}';
}

String _formatUgxCompact(double value) {
  if (value <= 0) return 'UGX 0';
  return 'UGX ${NumberFormat.compact().format(value)}';
}

String _contentTypeForName(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.png')) return 'image/png';
  return 'image/jpeg';
}

void showMessage(BuildContext context, String message) {
  final displayMessage = message.trim();
  if (displayMessage.isEmpty) {
    return;
  }
  final messenger =
      rootScaffoldMessengerKey.currentState ?? ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 22),
        elevation: 10,
        backgroundColor: AppColors.panel,
        showCloseIcon: true,
        closeIconColor: AppColors.secondary,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.border),
        ),
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayMessage,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

String _authErrorMessage(Object error) {
  if (error is AuthValidationException) {
    return error.message;
  }
  if (error is AuthOperationTimeoutException) {
    return error.message;
  }
  if (error is FirebaseAuthException) {
    final message = error.message?.toLowerCase() ?? '';
    if (message.contains('cleartext') || message.contains('10.0.2.2')) {
      return 'The app could not reach the Firebase Auth emulator. Rebuild the debug app and make sure the Firebase emulators are running.';
    }

    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'missing-email' => 'Enter your email address.',
      'missing-password' => 'Enter your password.',
      'user-not-found' => 'No account exists for that email.',
      'wrong-password' ||
      'invalid-credential' => 'Email or password is incorrect.',
      'email-already-in-use' => 'An account already exists for that email.',
      'weak-password' => 'Use a stronger password with at least 6 characters.',
      'operation-not-allowed' =>
        'Email sign in is not enabled yet. Contact support.',
      'user-disabled' =>
        'This account has been disabled. Contact support for help.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment before trying again.',
      'network-request-failed' =>
        'We could not connect. Check your internet and try again.',
      'requires-recent-login' => 'Sign in again before making this change.',
      'expired-action-code' =>
        'This link has expired. Request a new one and try again.',
      'invalid-action-code' =>
        'This link is no longer valid. Request a new one and try again.',
      'internal-error' =>
        'We could not complete that account request. Please try again.',
      _ => 'We could not complete that account request. Please try again.',
    };
  }

  if (error is FirebaseFunctionsException) {
    return switch (error.code) {
      'invalid-argument' => 'Enter a valid email address.',
      'unavailable' =>
        'Password reset email is temporarily unavailable. Please try again shortly.',
      'failed-precondition' => _friendlyFirebaseMessage(
        error.message,
        fallback: 'Password reset is not available right now.',
      ),
      _ => 'We could not send the reset email. Please try again.',
    };
  }

  return _friendlyUnexpectedMessage(error);
}

String _friendlyFirebaseMessage(String? message, {required String fallback}) {
  final normalized = message?.trim();
  if (normalized == null || normalized.isEmpty) return fallback;

  return switch (normalized) {
    'Authentication is required.' => 'Sign in again to continue.',
    'Admin access is required.' =>
      'Your account does not have permission to do that.',
    'Development email is only available in the Functions emulator.' =>
      'Email sending is not available in this environment.',
    'User has no email address.' =>
      'Add an email address to your account first.',
    _ => fallback,
  };
}

String _friendlyUnexpectedMessage(Object error) {
  final text = error.toString().toLowerCase();
  if (text.contains('network') ||
      text.contains('socket') ||
      text.contains('host lookup') ||
      text.contains('unavailable')) {
    return 'We could not connect. Check your internet and try again.';
  }

  if (text.contains('permission-denied') ||
      text.contains('permission denied')) {
    return 'You do not have permission to do that.';
  }

  return 'Something went wrong. Please try again.';
}

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

abstract final class AppColors {
  static AppPalette _current = AppPalette.dark;

  static void useBrightness(Brightness brightness) {
    _current = AppPalette.forBrightness(brightness);
  }

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
