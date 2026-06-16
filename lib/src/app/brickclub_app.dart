import 'package:file_picker/file_picker.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../features/admin/domain/admin_models.dart';
import '../features/admin/domain/admin_repository.dart';
import '../features/auth/domain/auth_credentials.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/investment/domain/investment_models.dart';
import '../features/investment/domain/investment_repository.dart';
import '../features/kyc/domain/kyc_models.dart';
import '../features/kyc/domain/kyc_repository.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class BrickClubApp extends StatelessWidget {
  const BrickClubApp({
    super.key,
    required this.authRepository,
    required this.adminRepository,
    required this.investmentRepository,
    required this.kycRepository,
    this.showLandingPage = kIsWeb,
    this.splashDuration = const Duration(seconds: 2),
  });

  final AuthRepository authRepository;
  final AdminRepository adminRepository;
  final InvestmentRepository investmentRepository;
  final KycRepository kycRepository;
  final bool showLandingPage;
  final Duration splashDuration;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrickClub',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          surface: AppColors.panel,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: AppGate(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: kycRepository,
        showLandingPage: showLandingPage,
        splashDuration: splashDuration,
      ),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({
    super.key,
    required this.authRepository,
    required this.adminRepository,
    required this.investmentRepository,
    required this.kycRepository,
    required this.showLandingPage,
    required this.splashDuration,
  });

  final AuthRepository authRepository;
  final AdminRepository adminRepository;
  final InvestmentRepository investmentRepository;
  final KycRepository kycRepository;
  final bool showLandingPage;
  final Duration splashDuration;

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
    return const PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BrandLockup(height: 160),
              SizedBox(height: 8),
              Text('Property-backed ownership', style: AppText.bodyLarge),
            ],
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
      decoration: const BoxDecoration(
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
                    for (final item in const [
                      ('Features', 'features'),
                      ('How it works', 'how-it-works'),
                      ('Testimonials', 'testimonials'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 28),
                        child: Text(
                          item.$1,
                          style: const TextStyle(
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
                    child: const Text('Sign in'),
                  ),
                  const SizedBox(width: 10),
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
      decoration: const BoxDecoration(
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
                      const SizedBox(height: 54),
                      const Center(child: visual),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(flex: 10, child: copy),
                    const SizedBox(width: 60),
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
        const Text(
          'Own more than\na dream.',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 68,
            height: .98,
            fontWeight: FontWeight.w800,
            letterSpacing: -3.1,
          ),
        ),
        const SizedBox(height: 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: const Text(
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
        const SizedBox(height: 34),
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
        const SizedBox(height: 34),
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
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
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
              child: const Column(
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
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
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
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.secondary,
                    size: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Portfolio value', style: AppText.small),
            const SizedBox(height: 4),
            const Text(
              'UGX 18.6M',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 27,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/kololo_heights_v2.png',
                height: 116,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kololo Heights\nIncome Fund',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                height: 1.12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Minimum', style: AppText.tinyLight),
                Text('Target return', style: AppText.tinyLight),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
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
      style: const TextStyle(
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
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 34),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
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
                    const Text(
                      'Built for clarity,\nnot speculation.',
                      style: _LandingSection.headingStyle,
                    ),
                    const SizedBox(height: 22),
                    const Text(
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
                    const SizedBox(height: 34),
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
                    children: [details, const SizedBox(height: 50), visual],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: details),
                    const SizedBox(width: 74),
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
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
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
          const SizedBox(height: 22),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kololo Heights', style: AppText.cardHeading),
              Text('VERIFIED', style: AppText.eyebrow),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Income-producing residential property',
            style: AppText.bodyLarge,
          ),
          const SizedBox(height: 22),
          const Row(
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
          const Icon(Icons.format_quote_rounded, color: AppColors.gold),
          const SizedBox(height: 20),
          Text(
            quote,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
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

  static const headingStyle = TextStyle(
    color: AppColors.primary,
    fontSize: 43,
    height: 1.08,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.6,
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
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 17,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 54),
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
              const Text(
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
              const SizedBox(height: 18),
              const Text(
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
              const SizedBox(height: 32),
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
                    child: const Text('Sign in'),
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
              TextButton(onPressed: onSignIn, child: const Text('Sign in')),
              TextButton(onPressed: onSignUp, child: const Text('Sign up')),
              const SizedBox(width: 10),
              const Text('© 2026 BrickClub', style: AppText.small),
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
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const _BrandLockup(height: 72),
                          const SizedBox(height: 30),
                          Text(
                            adminAccess ? 'Admin sign in' : 'Welcome back',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            adminAccess
                                ? 'Access user, asset, and crypto payment operations.'
                                : 'Continue to your BrickShares portfolio.',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const FieldLabel('Email'),
                          const SizedBox(height: 8),
                          AppTextField(
                            key: const ValueKey('email-field'),
                            controller: emailController,
                            hintText: 'you@example.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 18),
                          const FieldLabel('Password'),
                          const SizedBox(height: 8),
                          AppTextField(
                            key: const ValueKey('password-field'),
                            controller: passwordController,
                            hintText: 'Enter your password',
                            obscureText: true,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _sendPasswordReset,
                              child: const Text('Forgot password?'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (authMessage != null) ...[
                            _AuthMessageBanner(message: authMessage!),
                            const SizedBox(height: 14),
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
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 24),
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
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              key: const ValueKey('create-account-link'),
                              onPressed: widget.onCreateAccount,
                              child: const Text('Create a BrickClub account'),
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
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.gold,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/kololo_heights_v2.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Color(0x7A0B0D0F), BlendMode.darken),
        ),
      ),
      child: const Padding(
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
                          return const Center(
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _BrandLockup(),
                ),
              ),
              const SizedBox(height: 46),
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
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                leading: const CircleAvatar(
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
              const SizedBox(width: 13),
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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (showMenu) ...[
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title == 'Overview' ? 'Admin overview' : title,
            style: const TextStyle(
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
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.muted,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.panel,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.gold),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => showMessage(context, 'No new notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          if (MediaQuery.sizeOf(context).width >= 900) ...[
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                user?.primaryLabel ?? 'Signed-in admin',
                style: AppText.fieldLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(width: 8),
          const CircleAvatar(
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
        repository: repository,
        onChanged: onChanged,
      ),
      4 => const _ReportsPanel(),
      _ => const _SettingsPanel(),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monitor member activity, verified assets, and settlement flow.',
          style: TextStyle(color: AppColors.secondary, fontSize: 14),
        ),
        const SizedBox(height: 26),
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
              '$pendingAssets',
              'Needs action',
              Icons.pending_actions_outlined,
              warning: true,
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            const chart = _UserGrowthChart();
            const reviews = _PendingReviews();
            if (constraints.maxWidth < 850) {
              return const Column(
                children: [chart, SizedBox(height: 18), reviews],
              );
            }
            return const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: chart),
                SizedBox(width: 18),
                Expanded(flex: 2, child: reviews),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        _AdminPanel(
          title: 'Recent crypto payments',
          action: 'View all',
          child: _PaymentOptionTable(
            options: data.cryptoPaymentOptions,
            compact: true,
          ),
        ),
        const SizedBox(height: 20),
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
            const Icon(
              Icons.admin_panel_settings_outlined,
              color: AppColors.gold,
              size: 34,
            ),
            const SizedBox(height: 14),
            Text('Admin data unavailable', style: AppText.h2),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppText.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
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
              const SizedBox(width: 8),
              Icon(icon, size: 20, color: AppColors.gold),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
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
                  style: const TextStyle(
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
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }
}

class _UserGrowthChart extends StatelessWidget {
  const _UserGrowthChart();

  @override
  Widget build(BuildContext context) {
    return const _AdminPanel(
      title: 'User growth',
      action: 'Last 6 months',
      child: SizedBox(
        height: 220,
        child: _BarChart(
          values: [64, 92, 118, 105, 148, 176],
          labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
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
    final maxValue = values.reduce((a, b) => a > b ? a : b);
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
                        heightFactor: values[index] / maxValue,
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
                  const SizedBox(height: 10),
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
  const _PendingReviews();

  @override
  Widget build(BuildContext context) {
    return const _AdminPanel(
      title: 'Pending asset reviews',
      action: '17 pending',
      child: Column(
        children: [
          _ReviewRow('Bugolobi Logistics REIT', 'Documents updated', '2h'),
          _ReviewRow('Kigali Green Offices', 'Legal review', '5h'),
          _ReviewRow('Nakasero Income Fund', 'Valuation review', '1d'),
          _ReviewRow('Mombasa Storage Trust', 'Issuer verification', '1d'),
        ],
      ),
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
            child: const Icon(
              Icons.apartment_outlined,
              color: AppColors.gold,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.fieldLabel),
                const SizedBox(height: 3),
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
    required this.repository,
    required this.onChanged,
  });

  final List<CryptoPaymentOption> options;
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
        child: _PaymentOptionTable(
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
      ),
    );
  }
}

class _ReportsPanel extends StatelessWidget {
  const _ReportsPanel();

  @override
  Widget build(BuildContext context) {
    return const _SectionPage(
      description:
          'Operational reporting for member growth, assets, and settlement.',
      child: _AdminPanel(
        title: 'Operations report',
        child: SizedBox(
          height: 320,
          child: _BarChart(
            values: [72, 112, 88, 154, 132, 190, 168, 218],
            labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8'],
          ),
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel();

  @override
  Widget build(BuildContext context) {
    return const _SectionPage(
      description:
          'Configure approval rules, payment networks, and administrator access.',
      child: _AdminPanel(
        title: 'Platform settings',
        child: Column(
          children: [
            _SettingRow(
              'Require dual approval',
              'Asset publication and refunds',
            ),
            _SettingRow('USDT settlement', 'Ethereum and Tron enabled'),
            _SettingRow('Admin session timeout', '30 minutes'),
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
        const SizedBox(height: 24),
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
        const SizedBox(height: 20),
        child,
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow(this.title, this.value);
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppText.fieldLabel),
      subtitle: Text(value, style: AppText.small),
      trailing: Switch(
        value: true,
        onChanged: (_) => showMessage(context, '$title updated'),
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
      columns: const ['Network', 'Asset', 'Wallet', 'Minimum', 'Status'],
      rows: [
        for (final option in options.take(compact ? 4 : options.length))
          _AdminTableRow(
            values: [
              option.network,
              option.assetSymbol,
              option.walletAddress,
              option.minimumAmount.toStringAsFixed(2),
              option.enabled ? 'Active' : 'Disabled',
            ],
            source: option,
          ),
      ],
      statusColumns: const {4},
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
            headingTextStyle: const TextStyle(
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
            border: const TableBorder(
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
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
        if (onDelete != null)
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
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
    }.contains(label);
    final warning = {'Review', 'Pending', 'Draft'}.contains(label);
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
                const SizedBox(height: 10),
                AppTextField(
                  controller: email,
                  hintText: 'member@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
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
                  title: const Text('Admin access'),
                  activeThumbColor: AppColors.gold,
                ),
                SwitchListTile(
                  value: disabled,
                  onChanged: (value) => setState(() => disabled = value),
                  title: const Text('Disabled'),
                  activeThumbColor: AppColors.gold,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
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
              child: const Text('Save'),
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
            const SizedBox(height: 10),
            AppTextField(controller: location, hintText: 'Location'),
            const SizedBox(height: 10),
            AppTextField(controller: type, hintText: 'Asset type'),
            const SizedBox(height: 10),
            AppTextField(
              controller: fundedPercent,
              hintText: 'Funded percent',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            AppTextField(controller: reviewStatus, hintText: 'Review status'),
            const SizedBox(height: 10),
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
          child: const Text('Cancel'),
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
          child: const Text('Save'),
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
                const SizedBox(height: 10),
                AppTextField(controller: assetSymbol, hintText: 'Asset symbol'),
                const SizedBox(height: 10),
                AppTextField(
                  controller: walletAddress,
                  hintText: 'Settlement wallet address',
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: minimumAmount,
                  hintText: 'Minimum amount',
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  value: enabled,
                  onChanged: (value) => setState(() => enabled = value),
                  title: const Text('Enabled'),
                  activeThumbColor: AppColors.gold,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final payload = CryptoPaymentOption(
                  id: value.id,
                  network: network.text,
                  assetSymbol: assetSymbol.text,
                  walletAddress: walletAddress.text,
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
              child: const Text('Save'),
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

Future<void> _runAdminAction(
  BuildContext context, {
  required Future<void> Function() action,
  required VoidCallback onChanged,
}) async {
  try {
    await action();
    onChanged();
    if (context.mounted) {
      showMessage(context, 'Admin change saved');
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
                    icon: const Icon(Icons.chevron_left, size: 34),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  const _BrandLockup(height: 112),
                  const SizedBox(height: 10),
                  const Text(
                    'Create your BrickShares account. Wallet verification '
                    'and KYC come next.',
                    style: AppText.bodyLarge,
                  ),
                  const SizedBox(height: 26),
                  Panel(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Create account', style: AppText.h2),
                        const Text(
                          'Use your legal names exactly as they appear on your ID.',
                          style: AppText.body,
                        ),
                        const SizedBox(height: 18),
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
                                  const SizedBox(height: 14),
                                  lastName,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: firstName),
                                const SizedBox(width: 12),
                                Expanded(child: lastName),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 14),
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
                        const SizedBox(height: 14),
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
                        const SizedBox(height: 14),
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
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: accepted,
                              onChanged: (value) =>
                                  setState(() => accepted = value ?? false),
                              side: const BorderSide(color: AppColors.border),
                              activeColor: AppColors.gold,
                            ),
                            const Expanded(
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
                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: creatingAccount
                        ? 'Creating account...'
                        : 'Create account',
                    onPressed: accepted && !creatingAccount
                        ? _createAccount
                        : null,
                  ),
                  const SizedBox(height: 10),
                  GoogleAuthButton(
                    key: const ValueKey('google-sign-up'),
                    label: signingUpWithGoogle
                        ? 'Connecting...'
                        : 'Sign up with Google',
                    onPressed: creatingAccount || signingUpWithGoogle
                        ? null
                        : _signUpWithGoogle,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Financial actions require KYC and verified wallet setup '
                    'after account creation.',
                    textAlign: TextAlign.center,
                    style: AppText.disclosure,
                  ),
                  const SizedBox(height: 10),
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
    setState(() => signingUpWithGoogle = true);
    try {
      await widget.authRepository.signInWithGoogle();

      if (mounted) {
        widget.onCreated();
      }
    } catch (error) {
      if (mounted) {
        showMessage(context, _authErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => signingUpWithGoogle = false);
      }
    }
  }

  Future<void> _createAccount() async {
    setState(() => creatingAccount = true);
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
        showMessage(context, _authErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => creatingAccount = false);
      }
    }
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
      children: [FieldLabel(label), const SizedBox(height: 7), child],
    );
  }
}

class BrickClubShell extends StatefulWidget {
  const BrickClubShell({
    super.key,
    required this.authRepository,
    required this.investmentRepository,
    required this.kycRepository,
  });

  final AuthRepository authRepository;
  final InvestmentRepository investmentRepository;
  final KycRepository kycRepository;

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
            onStartKyc: () => _openKyc(context),
            onOpenProfile: _openProfile,
          ),
          PortfolioScreen(onOpenProfile: _openProfile),
          ProfileScreen(
            user: widget.authRepository.currentUserDetails(),
            kyc: kyc,
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
          const Icon(Icons.verified_user_outlined, color: AppColors.gold),
          const SizedBox(height: 16),
          const Text('Complete KYC first', style: AppText.h2),
          const SizedBox(height: 8),
          Text(
            'Status: ${kyc.label}. Purchases, withdrawals, wallet changes, '
            'and crypto settlement unlock after approval.',
            style: AppText.bodyLarge,
          ),
          const SizedBox(height: 20),
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KYC ${kyc.label}', style: AppText.cardHeadingSmall),
                    const SizedBox(height: 4),
                    Text(_statusCopy(kyc), style: AppText.body),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ProgressLine(value: kyc.completionRatio.clamp(0, 1), height: 6),
          if (!compact) ...[
            const SizedBox(height: 14),
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
            const SizedBox(height: 16),
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
                      const SizedBox(height: 14),
                      _KycMessageBanner(message: kycMessage!),
                    ],
                    const SizedBox(height: 18),
                    const FieldLabel('Full legal name'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: fullNameController,
                      hintText: 'Name exactly as shown on your ID',
                    ),
                    const SizedBox(height: 16),
                    const FieldLabel('Date of birth'),
                    const SizedBox(height: 8),
                    _PickerTile(
                      key: const ValueKey('kyc-dob'),
                      icon: Icons.calendar_month_outlined,
                      title: dateOfBirth == null
                          ? 'Select date'
                          : DateFormat.yMMMd().format(dateOfBirth!),
                      onTap: _pickDateOfBirth,
                    ),
                    const SizedBox(height: 16),
                    const FieldLabel('Government ID or passport'),
                    const SizedBox(height: 8),
                    _PickerTile(
                      key: const ValueKey('kyc-government-id'),
                      icon: Icons.badge_outlined,
                      title: governmentId?.name ?? 'Upload ID document',
                      onTap: () => _pickFile((file) => governmentId = file),
                    ),
                    const SizedBox(height: 16),
                    const FieldLabel('Selfie / face verification'),
                    const SizedBox(height: 8),
                    _PickerTile(
                      key: const ValueKey('kyc-selfie'),
                      icon: Icons.face_retouching_natural_outlined,
                      title: selfie?.name ?? 'Capture selfie',
                      onTap: _pickSelfie,
                    ),
                    const SizedBox(height: 16),
                    const FieldLabel('Physical address proof'),
                    const SizedBox(height: 8),
                    _PickerTile(
                      key: const ValueKey('kyc-address-proof'),
                      icon: Icons.home_work_outlined,
                      title:
                          addressProof?.name ?? 'Upload utility bill or lease',
                      onTap: () => _pickFile((file) => addressProof = file),
                    ),
                    const SizedBox(height: 16),
                    const FieldLabel('Phone verification'),
                    const SizedBox(height: 8),
                    AppTextField(
                      key: const ValueKey('kyc-phone'),
                      controller: phoneController,
                      hintText: '+256774224734',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_iphone_rounded,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                    ),
                    const SizedBox(height: 10),
                    SecondaryButton(
                      key: const ValueKey('send-phone-code'),
                      label: sendingPhone ? 'Sending...' : 'Send code',
                      onPressed: sendingPhone ? null : _sendPhoneCode,
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      key: const ValueKey('kyc-phone-code'),
                      controller: phoneCodeController,
                      hintText: 'Verification code',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.sms_outlined,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                    const FieldLabel('Email verification'),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 26),
                    PrimaryButton(
                      key: const ValueKey('submit-kyc'),
                      label: submitting ? 'Submitting...' : 'Submit for review',
                      onPressed: submitting ? null : _submit,
                    ),
                    const SizedBox(height: 10),
                    const Text(
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
        showMessage(context, 'KYC submitted for review');
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
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.warning,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
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
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: AppText.fieldLabel)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
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
          const SizedBox(width: 12),
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
        const _PortfolioOverview(),
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
              return const Panel(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              );
            }
            if (opportunities.isEmpty) {
              return Panel(
                child: Column(
                  children: [
                    const Icon(
                      Icons.apartment_rounded,
                      color: AppColors.gold,
                      size: 34,
                    ),
                    const SizedBox(height: 10),
                    const Text('No live BrickShares yet', style: AppText.h2),
                    const SizedBox(height: 6),
                    const Text(
                      'Published, verified assets will appear here.',
                      textAlign: TextAlign.center,
                      style: AppText.body,
                    ),
                    const SizedBox(height: 16),
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
        const Panel(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              _HoldingRow(
                title: 'Kololo Heights Income Fund',
                subtitle: '32.45 BrickShares',
                value: 'UGX 6.8M',
                change: '+12.1%',
              ),
              Divider(height: 1, color: AppColors.border),
              _HoldingRow(
                title: 'Naalya Residences Fund',
                subtitle: '18.72 BrickShares',
                value: 'UGX 4.2M',
                change: '+7.3%',
              ),
            ],
          ),
        ),
        const SectionHeading(title: 'Recent activity', action: 'View all'),
        const Panel(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              _ActivityRow(
                icon: Icons.south_west_rounded,
                title: 'Dividend received',
                subtitle: 'Kololo Heights Income Fund',
                value: 'UGX 152,400',
              ),
              Divider(height: 1, color: AppColors.border),
              _ActivityRow(
                icon: Icons.verified_user_outlined,
                title: 'Wallet settlement verified',
                subtitle: 'Secure • Transparent • Trusted',
                value: 'Complete',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PortfolioOverview extends StatelessWidget {
  const _PortfolioOverview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Portfolio value', style: AppText.bodyLarge),
        const SizedBox(height: 4),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Text('UGX 18.6M', style: AppText.hero)),
            Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text('+8.4% this year', style: AppText.goldBody),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 96,
          width: double.infinity,
          child: CustomPaint(painter: _PortfolioChartPainter()),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Jan', style: AppText.tiny),
            Text('Feb', style: AppText.tiny),
            Text('Mar', style: AppText.tiny),
            Text('Apr', style: AppText.tiny),
            Text('May', style: AppText.tiny),
            Text('Jun', style: AppText.tiny),
          ],
        ),
      ],
    );
  }
}

class _PortfolioChartPainter extends CustomPainter {
  const _PortfolioChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    const values = [
      .64,
      .59,
      .61,
      .55,
      .63,
      .58,
      .66,
      .62,
      .71,
      .68,
      .76,
      .72,
      .79,
      .74,
      .82,
      .77,
      .84,
      .80,
      .88,
      .83,
      .91,
      .86,
      .94,
      .90,
      .98,
      .93,
      1.0,
    ];
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - (values[i] * size.height * .78);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.fieldLabel),
                const SizedBox(height: 3),
                Text(subtitle, style: AppText.tiny),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: AppText.fieldLabel),
              const SizedBox(height: 3),
              Text(
                change,
                style: const TextStyle(
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
            decoration: const BoxDecoration(
              color: AppColors.track,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.gold, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.fieldLabel),
                const SizedBox(height: 3),
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
      child: const Icon(
        Icons.apartment_rounded,
        color: AppColors.gold,
        size: 18,
      ),
    );
  }
}

class BrickShareFilters {
  const BrickShareFilters({
    this.asset = 'Real Estate',
    this.risk = 'Medium',
    this.payment = 'USDT',
  });

  final String asset;
  final String risk;
  final String payment;

  bool matches(InvestmentOpportunity opportunity) {
    return opportunity.assetClass == asset &&
        opportunity.riskLevel == risk &&
        opportunity.paymentMethods.contains(payment);
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
                    const SizedBox(width: 8),
                    ChoicePill(label: filters.asset),
                    const SizedBox(width: 8),
                    ChoicePill(label: filters.risk),
                    const SizedBox(width: 8),
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
                  const SizedBox(width: 22),
                  const Expanded(
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
              const Panel(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              )
            else if (opportunities.isEmpty)
              Panel(
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off_rounded,
                      color: AppColors.gold,
                      size: 34,
                    ),
                    const SizedBox(height: 10),
                    const Text('No BrickShares match', style: AppText.h2),
                    const SizedBox(height: 6),
                    Text(
                      allOpportunities.isEmpty
                          ? 'Admin-published verified assets will appear here.'
                          : 'Try a different asset class, risk level, or payment method.',
                      textAlign: TextAlign.center,
                      style: AppText.body,
                    ),
                    const SizedBox(height: 16),
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
    required this.onStartKyc,
    required this.onOpenProfile,
  });

  final KycProfile kyc;
  final VoidCallback onStartKyc;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Wallet',
      onProfileTap: onOpenProfile,
      children: [
        Container(
          height: 170,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.panel, AppColors.surface],
            ),
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Verified wallet balance', style: AppText.bodyLarge),
              SizedBox(height: 10),
              Text('UGX 4.2M', style: AppText.walletValue),
              SizedBox(height: 8),
              Text(
                'Crypto rails: USDT on Ethereum / Tron',
                style: AppText.eyebrow,
              ),
            ],
          ),
        ),
        KycStatusCard(kyc: kyc, onStartKyc: onStartKyc, compact: true),
        const SizedBox(height: 28),
        Panel(
          child: Column(
            children: [
              const Text(
                'Crypto funding readiness',
                style: AppText.cardHeading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Add a verified wallet before sending funds. Network, fees, '
                'quote expiry, and settlement status are shown before confirmation.',
                textAlign: TextAlign.center,
                style: AppText.body,
              ),
              const SizedBox(height: 20),
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
          child: const Column(
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
  const PortfolioScreen({super.key, required this.onOpenProfile});

  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Portfolio',
      onProfileTap: onOpenProfile,
      children: [
        Panel(
          radius: 22,
          padding: const EdgeInsets.all(18),
          child: const SizedBox(
            height: 112,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total BrickShares allocation', style: AppText.body),
                SizedBox(height: 10),
                Text('UGX 18.6M', style: AppText.portfolioValue),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Allocation', style: AppText.h2),
        const AllocationRow('Real Estate', .45, AppColors.gold),
        const AllocationRow('ETF', .22, Color(0xFF38BDF8)),
        const AllocationRow('REIT', .18, Color(0xFF22C55E)),
        const AllocationRow('Alternatives', .15, Color(0xFFF59E0B)),
        const SizedBox(height: 14),
        const Text('Recent activity', style: AppText.h2),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.kyc,
    required this.onStartKyc,
  });

  final SignedInUserDetails? user;
  final KycProfile kyc;
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
              const CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.track,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.gold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
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
        const SizedBox(height: 18),
        KycStatusCard(kyc: kyc, onStartKyc: onStartKyc),
        for (final item in const [
          ('Settings', 'Theme, currency, alerts'),
          ('Security & privacy', 'Verified wallet and biometrics'),
          ('Documents', 'Statements, risk disclosures'),
          ('Help center', 'Investor support'),
        ])
          ProfileRow(
            title: item.$1,
            subtitle: item.$2,
            onTap: () => showMessage(context, '${item.$1} opened'),
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
                            const Text('Asset class', style: AppText.h2),
                            const SizedBox(height: 16),
                            FilterChoices(
                              values: const [
                                'Real Estate',
                                'REIT',
                                'ETF',
                                'Index',
                              ],
                              selected: asset,
                              onChanged: (value) =>
                                  setState(() => asset = value),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Panel(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Risk level', style: AppText.h2),
                            const SizedBox(height: 16),
                            FilterChoices(
                              values: const ['Low', 'Medium', 'High'],
                              selected: risk,
                              onChanged: (value) =>
                                  setState(() => risk = value),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Panel(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Payment method', style: AppText.h2),
                            const SizedBox(height: 16),
                            FilterChoices(
                              values: const [
                                'USDT',
                                'USDC',
                                'BTC',
                                'UGX Wallet',
                              ],
                              selected: payment,
                              onChanged: (value) =>
                                  setState(() => payment = value),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
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
                  const SizedBox(width: 12),
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
              const SizedBox(height: 26),
              Text(opportunity.displayTitle, style: AppText.detailTitle),
              Text(
                '${opportunity.assetClass} BrickShares | ${opportunity.location}',
                style: AppText.body,
              ),
              const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
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
              const SizedBox(height: 24),
              Panel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
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
                    const SizedBox(height: 14),
                    ProgressLine(value: opportunity.fundedPercent / 100),
                    const SizedBox(height: 12),
                    const Text(
                      'Supported payment options and quote expiry are shown before settlement confirmation.',
                      style: AppText.small,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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

  @override
  Widget build(BuildContext context) {
    final paymentAsset = widget.opportunity.paymentMethods.contains('USDT')
        ? 'USDT'
        : widget.opportunity.paymentMethods.firstOrNull ?? 'USDT';
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, 'Confirm funding'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Buying BrickShares', style: AppText.eyebrow),
                    const SizedBox(height: 12),
                    Text(
                      widget.opportunity.displayTitle,
                      style: AppText.cardHeading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Panel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Crypto quote',
                            style: AppText.cardHeading,
                          ),
                        ),
                        Text('Expires after submit', style: AppText.warning),
                      ],
                    ),
                    const SizedBox(height: 18),
                    QuoteRow('Payment asset', paymentAsset),
                    QuoteRow('Amount', widget.opportunity.minimumText),
                    const QuoteRow('Network fee', 'Calculated by backend'),
                    const QuoteRow(
                      'Settlement',
                      'Pending confirmation',
                      warning: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Panel(
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
              const SizedBox(height: 36),
              PrimaryButton(
                key: const ValueKey('confirm-purchase'),
                label: submitting ? 'Submitting...' : 'Confirm purchase',
                onPressed: widget.kyc.canPerformFinancialActions && !submitting
                    ? () => _submit(paymentAsset)
                    : null,
              ),
              const SizedBox(height: 14),
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

  Future<void> _submit(String paymentAsset) async {
    setState(() => submitting = true);
    try {
      final order = await widget.investmentRepository.createPurchaseOrder(
        PurchaseRequest(
          opportunityId: widget.opportunity.id,
          amountUgx: widget.opportunity.minimumInvestment,
          paymentAsset: paymentAsset,
        ),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SuccessScreen(order: order)),
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
                  child: const Text('OK', style: AppText.goldMetricSmall),
                ),
                const SizedBox(height: 44),
                const Text('Purchase submitted', style: AppText.h1),
                const SizedBox(height: 12),
                Text(
                  'Your crypto payment is awaiting network confirmations. '
                  'We will update settlement status automatically.',
                  textAlign: TextAlign.center,
                  style: AppText.bodyLarge,
                ),
                const SizedBox(height: 38),
                Panel(
                  child: SizedBox(
                    height: 84,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
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
                const SizedBox(height: 62),
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
                    const SizedBox(height: 4),
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
              separatorBuilder: (_, _) => const SizedBox(height: 14),
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
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: AppText.topTitle)),
          HeaderCircle(
            onTap: () => showMessage(context, 'No new notifications'),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.secondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 9),
          HeaderCircle(
            key: const ValueKey('profile-header-button'),
            onTap:
                onProfileTap ??
                () => showMessage(context, 'Profile is in More'),
            child: const Icon(
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

  static const items = [
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
      decoration: const BoxDecoration(
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
            const SizedBox(height: 4),
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
                      const SizedBox(height: 4),
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
                          const SizedBox(width: 8),
                          Text(returnText, style: AppText.cardHeadingSmall),
                        ],
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 16),
                        const ProgressLine(value: .62, height: 6),
                        const SizedBox(height: 7),
                        const Row(
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
          side: const BorderSide(color: AppColors.border),
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
          side: const BorderSide(color: AppColors.border),
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
        style: const TextStyle(fontSize: 14, color: AppColors.primary),
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
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.compact ? 12 : 14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.compact ? 12 : 14),
            borderSide: const BorderSide(color: AppColors.gold, width: 1.3),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 58,
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
    this.color = AppColors.gold,
    this.height = 8,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value,
          color: color,
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
        const SizedBox(height: 4),
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
      icon: const Icon(Icons.chevron_left, size: 32),
    ),
    title: Text(title, style: AppText.detailAppBar),
    bottom: const PreferredSize(
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

void showMessage(BuildContext context, String message) {
  final displayMessage = message.trim().isEmpty
      ? 'Something went wrong. Please try again.'
      : message.trim();
  final messenger =
      rootScaffoldMessengerKey.currentState ?? ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(displayMessage), backgroundColor: AppColors.panel),
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

abstract final class AppColors {
  static const background = Color(0xFF0B0D0F);
  static const surface = Color(0xFF101316);
  static const panel = Color(0xFF15191D);
  static const track = Color(0xFF20252A);
  static const border = Color(0xFF2A3036);
  static const gold = Color(0xFFD8A94F);
  static const goldSoft = Color(0x1FD8A94F);
  static const primary = Color(0xFFF4F5F6);
  static const secondary = Color(0xFFB2B7BD);
  static const muted = Color(0xFF747B83);
  static const success = Color(0xFF51B96B);
  static const warning = Color(0xFFF59E0B);
}

abstract final class AppText {
  static const status = TextStyle(
    color: AppColors.secondary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
  static const authBrand = TextStyle(
    color: AppColors.primary,
    fontSize: 30,
    fontWeight: FontWeight.w700,
  );
  static const h1 = TextStyle(
    color: AppColors.primary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );
  static const h2 = TextStyle(
    color: AppColors.primary,
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
  static const topTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -.4,
  );
  static const detailAppBar = TextStyle(
    color: AppColors.primary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );
  static const bodyLarge = TextStyle(
    color: AppColors.secondary,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );
  static const body = TextStyle(
    color: AppColors.secondary,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );
  static const small = TextStyle(
    color: AppColors.secondary,
    fontSize: 11,
    height: 1.25,
    fontWeight: FontWeight.w500,
  );
  static const tiny = TextStyle(color: AppColors.muted, fontSize: 10);
  static const tinyLight = TextStyle(color: AppColors.secondary, fontSize: 10);
  static const disclosure = TextStyle(
    color: AppColors.muted,
    fontSize: 12,
    height: 1.25,
  );
  static const fieldLabel = TextStyle(
    color: AppColors.secondary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static const placeholder = TextStyle(
    color: AppColors.muted,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static const eyebrow = TextStyle(
    color: AppColors.gold,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static const goldBody = TextStyle(
    color: AppColors.gold,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );
  static const warning = TextStyle(
    color: AppColors.warning,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static const hero = TextStyle(
    color: AppColors.primary,
    fontSize: 42,
    height: 1.05,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
  );
  static const walletValue = TextStyle(
    color: AppColors.primary,
    fontSize: 35,
    fontWeight: FontWeight.w700,
  );
  static const portfolioValue = TextStyle(
    color: AppColors.primary,
    fontSize: 34,
    fontWeight: FontWeight.w700,
  );
  static const detailTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 27,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );
  static const cardHeading = TextStyle(
    color: AppColors.primary,
    fontSize: 20,
    height: 1.15,
    fontWeight: FontWeight.w700,
  );
  static const cardHeadingSmall = TextStyle(
    color: AppColors.primary,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
  static const investmentTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 17,
    height: 1.15,
    fontWeight: FontWeight.w700,
  );
  static const goldMetric = TextStyle(
    color: AppColors.gold,
    fontSize: 34,
    fontWeight: FontWeight.w700,
  );
  static const goldMetricSmall = TextStyle(
    color: AppColors.gold,
    fontSize: 19,
    fontWeight: FontWeight.w700,
  );
  static const brandMark = TextStyle(
    color: AppColors.gold,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static const headerIcon = TextStyle(
    color: AppColors.primary,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
  static const headerInitials = TextStyle(
    color: AppColors.gold,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
