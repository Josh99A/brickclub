part of 'brickclub_app.dart';

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

