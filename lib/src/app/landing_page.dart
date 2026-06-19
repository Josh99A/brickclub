part of 'brickclub_app.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scrollController = ScrollController();
  final _topKey = GlobalKey();
  final _howItWorksKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _testimonialsKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SelectionArea(
        child: _ScrollScope(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _LandingHeader(
                  key: _topKey,
                  onSignIn: widget.onSignIn,
                  onSignUp: widget.onSignUp,
                  onBrand: () => _scrollTo(_topKey),
                  onNavigate: _scrollTo,
                  navKeys: {
                    'features': _featuresKey,
                    'how-it-works': _howItWorksKey,
                    'testimonials': _testimonialsKey,
                  },
                ),
                _HeroSection(
                  onInstall: _install,
                  onExplore: widget.onSignUp,
                ),
                const _TrustStrip(),
                const _Reveal(child: _StatsBand()),
                KeyedSubtree(
                  key: _howItWorksKey,
                  child: const _Reveal(child: _HowItWorksSection()),
                ),
                KeyedSubtree(
                  key: _featuresKey,
                  child: const _Reveal(child: _FeatureSection()),
                ),
                KeyedSubtree(
                  key: _testimonialsKey,
                  child: const _Reveal(child: _TestimonialsSection()),
                ),
                _Reveal(
                  child: _FinalCta(
                    onInstall: _install,
                    onSignIn: widget.onSignIn,
                    onSignUp: widget.onSignUp,
                  ),
                ),
                _LandingFooter(
                  onSignIn: widget.onSignIn,
                  onSignUp: widget.onSignUp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scrollTo(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext == null) {
      return;
    }
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeInOutCubic,
      alignment: 0,
    );
  }

  Future<void> _install() async {
    // Already added to the home screen / app drawer and launched standalone.
    if (isPwaStandalone()) {
      showMessage(context, 'BrickClub is already installed on this device.');
      return;
    }

    // Chromium-based browsers (Android Chrome, desktop Chrome/Edge) expose a
    // native install prompt we can fire directly.
    if (canInstallPwa()) {
      final outcome = await promptPwaInstall();
      if (!mounted) {
        return;
      }
      switch (outcome) {
        case 'accepted':
          showMessage(context, 'Installing BrickClub on your device…');
        case 'dismissed':
          showMessage(context, 'Install dismissed. You can install any time.');
        default:
          // Prompt was lost (e.g. already consumed) — fall back to guidance.
          await _showInstallInstructions();
      }
      return;
    }

    // No native prompt available. iOS Safari never fires one, and other
    // browsers may not have captured it yet — guide the user manually.
    await _showInstallInstructions();
  }

  Future<void> _showInstallInstructions() {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _InstallInstructionsSheet(platform: pwaPlatform()),
    );
  }
}

/// Step-by-step guidance for adding BrickClub to a phone home screen / app
/// drawer when the browser does not expose a one-tap install prompt (always
/// the case on iOS Safari).
class _InstallInstructionsSheet extends StatelessWidget {
  const _InstallInstructionsSheet({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    final ({String title, String intro, List<_InstallStep> steps}) content =
        switch (platform) {
      'ios' => (
          title: 'Install on iPhone or iPad',
          intro: 'Add BrickClub to your home screen straight from Safari — no '
              'App Store needed.',
          steps: const [
            _InstallStep(
              Icons.ios_share_rounded,
              'Tap the Share button in Safari\'s toolbar.',
            ),
            _InstallStep(
              Icons.add_box_outlined,
              'Scroll down and choose “Add to Home Screen”.',
            ),
            _InstallStep(
              Icons.check_circle_outline_rounded,
              'Tap “Add” — BrickClub lands on your home screen.',
            ),
          ],
        ),
      'android' => (
          title: 'Install on Android',
          intro: 'Add BrickClub to your device in a couple of taps from your '
              'browser.',
          steps: const [
            _InstallStep(
              Icons.more_vert_rounded,
              'Open your browser menu (⋮ in the top corner).',
            ),
            _InstallStep(
              Icons.install_mobile_rounded,
              'Tap “Install app” or “Add to Home screen”.',
            ),
            _InstallStep(
              Icons.check_circle_outline_rounded,
              'Confirm — BrickClub appears in your app drawer.',
            ),
          ],
        ),
      _ => (
          title: 'Install on desktop',
          intro: 'Install BrickClub as an app from Chrome or Edge.',
          steps: const [
            _InstallStep(
              Icons.install_desktop_rounded,
              'Click the install icon in the address bar, or open the '
                  'browser menu.',
            ),
            _InstallStep(
              Icons.check_circle_outline_rounded,
              'Choose “Install” to launch BrickClub in its own window.',
            ),
          ],
        ),
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.track,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    color: AppColors.gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(content.title, style: AppText.h2)),
              ],
            ),
            const SizedBox(height: 12),
            Text(content.intro, style: AppText.bodyLarge),
            const SizedBox(height: 20),
            for (var i = 0; i < content.steps.length; i++) ...[
              _InstallStepRow(index: i + 1, step: content.steps[i]),
              if (i < content.steps.length - 1) const SizedBox(height: 14),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _WebButton(
                label: 'Got it',
                icon: Icons.check_rounded,
                filled: true,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstallStep {
  const _InstallStep(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _InstallStepRow extends StatelessWidget {
  const _InstallStepRow({required this.index, required this.step});

  final int index;
  final _InstallStep step;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.track,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$index',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(step.icon, color: AppColors.gold, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              step.label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LandingHeader extends StatelessWidget {
  const _LandingHeader({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
    required this.onBrand,
    required this.onNavigate,
    required this.navKeys,
  });

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  final VoidCallback onBrand;
  final void Function(GlobalKey) onNavigate;
  final Map<String, GlobalKey> navKeys;

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
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onBrand,
                      child: const _BrandLockup(),
                    ),
                  ),
                  const Spacer(),
                  if (!compact) ...[
                    for (final item in [
                      ('Features', 'features'),
                      ('How it works', 'how-it-works'),
                      ('Testimonials', 'testimonials'),
                    ])
                      _NavLink(
                        label: item.$1,
                        onTap: () {
                          final key = navKeys[item.$2];
                          if (key != null) {
                            onNavigate(key);
                          }
                        },
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

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 28),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Text(
            widget.label,
            style: TextStyle(
              color: _hovered ? AppColors.primary : AppColors.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
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
  const _HeroSection({required this.onInstall, required this.onExplore});

  final VoidCallback onInstall;
  final VoidCallback onExplore;

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
                final copy = _HeroCopy(
                  onInstall: onInstall,
                  onExplore: onExplore,
                );
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
  const _HeroCopy({required this.onInstall, required this.onExplore});

  final VoidCallback onInstall;
  final VoidCallback onExplore;

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
              onPressed: onExplore,
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

class _HeroVisual extends StatefulWidget {
  const _HeroVisual();

  @override
  State<_HeroVisual> createState() => _HeroVisualState();
}

class _HeroVisualState extends State<_HeroVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();
  late final Animation<double> _introImage = _interval(0.0, 0.55);
  late final Animation<double> _introPhone = _interval(0.12, 0.7);
  late final Animation<double> _introCard = _interval(0.28, 0.85);
  late final Animation<double> _metric = _interval(0.35, 1.0);

  Animation<double> _interval(double begin, double end) => CurvedAnimation(
    parent: _controller,
    curve: Interval(begin, end, curve: Curves.easeOutCubic),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _entrance(Animation<double> anim, Widget child, {double dy = 26}) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, inner) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - anim.value) * dy),
          child: inner,
        ),
      ),
      child: child,
    );
  }

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
            child: _entrance(
              _introImage,
              Container(
                width: 410,
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/skyline_heights.png'),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: AppColors.border),
                ),
              ),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 0,
            child: _entrance(
              _introPhone,
              Container(
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
              dy: 34,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 30,
            child: _entrance(
              _introCard,
              Container(
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
                    _CountUp(
                      progress: _metric,
                      value: 12.4,
                      decimals: 1,
                      suffix: '%',
                      style: AppText.goldMetric,
                    ),
                    SizedBox(height: 10),
                    AnimatedBuilder(
                      animation: _metric,
                      builder: (context, _) =>
                          ProgressLine(value: .74 * _metric.value, height: 6),
                    ),
                  ],
                ),
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
              '\$5,000',
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
                'assets/images/skyline_heights.png',
                height: 116,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Skyline Heights\nIncome Fund',
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
                Text('\$50', style: AppText.goldBody),
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
          for (final (index, step) in steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: _Reveal(
                delay: Duration(milliseconds: index * 110),
                child: step,
              ),
            ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, step) in steps.indexed)
          Expanded(
            child: _Reveal(
              delay: Duration(milliseconds: index * 110),
              child: step,
            ),
          ),
      ],
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
    return _HoverLift(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.panel,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/skyline_heights.png',
                    height: 230,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC0B0D0F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: AppColors.gold,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'VERIFIED ASSET',
                          style: TextStyle(
                            color: Color(0xFFF4F5F6),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 22),
            Text('Skyline Heights', style: AppText.cardHeading),
            SizedBox(height: 8),
            Text(
              'Income-producing residential property',
              style: AppText.bodyLarge,
            ),
            SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Metric('12.4%', 'Target return', gold: true),
                      const SizedBox(height: 18),
                      Metric('\$50', 'Minimum'),
                    ],
                  ),
                ),
                const _FundingRing(value: .62, label: 'Funded'),
              ],
            ),
          ],
        ),
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
        'Entrepreneur, London',
      ),
      _Testimonial(
        'The verification and confirmation flow gave me confidence. It feels '
            'like a serious investment platform, not another crypto shortcut.',
        'Daniel K.',
        'Product lead, Singapore',
      ),
      _Testimonial(
        'I can start at a practical amount and still get access to assets I '
            'would normally only watch from the outside.',
        'Amina M.',
        'Consultant, Dubai',
      ),
    ];
    if (constraints.maxWidth < 820) {
      return Column(
        children: [
          for (final (index, item) in items.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _Reveal(
                delay: Duration(milliseconds: index * 110),
                child: item,
              ),
            ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, item) in items.indexed)
          Expanded(
            child: _Reveal(
              delay: Duration(milliseconds: index * 110),
              child: item,
            ),
          ),
      ],
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
    return _HoverLift(
      child: Container(
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x14000000),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: const Color(0x29000000)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      color: AppColors.background,
                      size: 15,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'GET STARTED IN MINUTES',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
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
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  'Install BrickClub, create your account, and explore verified '
                  'BrickShares built for long-term ownership.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xCC0B0D0F),
                    fontSize: 17,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 34),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 14,
                runSpacing: 14,
                children: [
                  _WebButton(
                    label: 'Install the app',
                    icon: Icons.download_rounded,
                    onPressed: onInstall,
                    dark: true,
                  ),
                  _WebButton(
                    label: 'Create account',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: onSignUp,
                    darkOutline: true,
                  ),
                  TextButton(
                    onPressed: onSignIn,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.background,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('I already have an account'),
                  ),
                ],
              ),
              SizedBox(height: 22),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 22,
                runSpacing: 8,
                children: const [
                  _CtaReassurance(Icons.lock_outline_rounded, 'Secure KYC'),
                  _CtaReassurance(Icons.payments_outlined, 'Free to browse'),
                  _CtaReassurance(
                    Icons.verified_outlined,
                    'Verified assets only',
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

class _CtaReassurance extends StatelessWidget {
  const _CtaReassurance(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xCC0B0D0F), size: 16),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xCC0B0D0F),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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

class _WebButton extends StatefulWidget {
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
  State<_WebButton> createState() => _WebButtonState();
}

class _WebButtonState extends State<_WebButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // Light cream used for labels sitting on the near-black "dark" button so
    // they stay legible against the dark fill (the button is used on the gold
    // CTA band).
    const onDark = Color(0xFFFAF6EE);
    final foreground = widget.dark
        ? onDark
        : widget.darkOutline
        ? AppColors.background
        : widget.filled
        ? AppColors.background
        : AppColors.primary;
    final background = widget.dark
        ? (_hovered ? const Color(0xFF1B1F24) : AppColors.background)
        : widget.filled
        ? AppColors.gold
        : Colors.transparent;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.04 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: widget.onPressed,
            icon: widget.icon == null
                ? const SizedBox.shrink()
                : Icon(widget.icon, size: 18),
            label: Text(widget.label),
            style: OutlinedButton.styleFrom(
              foregroundColor: foreground,
              backgroundColor: background,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              side: BorderSide(
                color: widget.darkOutline
                    ? AppColors.background
                    : widget.filled || widget.dark
                    ? background
                    : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animation + infographic infrastructure
// ---------------------------------------------------------------------------

/// Exposes the landing page scroll controller to descendant reveal widgets.
class _ScrollScope extends InheritedWidget {
  const _ScrollScope({required this.controller, required super.child});

  final ScrollController controller;

  static ScrollController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ScrollScope>()?.controller;

  @override
  bool updateShouldNotify(_ScrollScope oldWidget) =>
      controller != oldWidget.controller;
}

/// Fires [onReveal] exactly once when the widget scrolls into the viewport.
mixin _RevealOnScroll<T extends StatefulWidget> on State<T> {
  ScrollController? _revealScroll;
  bool _revealed = false;

  /// Fraction of the viewport height below which the element counts as visible.
  double get revealThreshold => 0.9;

  void onReveal();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scroll = _ScrollScope.maybeOf(context);
    if (scroll != _revealScroll) {
      _revealScroll?.removeListener(_revealCheck);
      _revealScroll = scroll;
      _revealScroll?.addListener(_revealCheck);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealCheck());
  }

  void _revealCheck() {
    if (_revealed || !mounted) {
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }
    final dy = box.localToGlobal(Offset.zero).dy;
    final height = MediaQuery.of(context).size.height;
    if (dy < height * revealThreshold) {
      _revealed = true;
      onReveal();
    }
  }

  @override
  void dispose() {
    _revealScroll?.removeListener(_revealCheck);
    super.dispose();
  }
}

/// Fades and slides its [child] up when it first enters the viewport.
class _Reveal extends StatefulWidget {
  const _Reveal({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal>
    with SingleTickerProviderStateMixin, _RevealOnScroll {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 640),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void onReveal() {
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _curve.value) * 38),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Lifts and brightens a card on hover for a tactile feel.
class _HoverLift extends StatefulWidget {
  const _HoverLift({required this.child});

  final Widget child;

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        offset: _hovered ? const Offset(0, -0.06) : Offset.zero,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: const Color(0x33000000),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ]
                : const [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Animated number that counts up from zero as [progress] advances 0 → 1.
class _CountUp extends StatelessWidget {
  const _CountUp({
    required this.progress,
    required this.value,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
  });

  final Animation<double> progress;
  final double value;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final current = value * progress.value;
        final text = decimals == 0
            ? current.round().toString()
            : current.toStringAsFixed(decimals);
        return Text('$prefix$text$suffix', style: style);
      },
    );
  }
}

/// Headline metrics band with count-up numbers, revealed on scroll.
class _StatsBand extends StatefulWidget {
  const _StatsBand();

  @override
  State<_StatsBand> createState() => _StatsBandState();
}

class _StatsBandState extends State<_StatsBand>
    with SingleTickerProviderStateMixin, _RevealOnScroll {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void onReveal() => _controller.forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _StatTile(
        progress: _progress,
        value: 12.4,
        decimals: 1,
        suffix: '%',
        label: 'Average target return',
        icon: Icons.trending_up_rounded,
      ),
      _StatTile(
        progress: _progress,
        value: 50,
        prefix: '\$',
        label: 'Minimum to start',
        icon: Icons.savings_outlined,
      ),
      _StatTile(
        progress: _progress,
        value: 100,
        suffix: '%',
        label: 'On-chain settlement',
        icon: Icons.shield_moon_outlined,
      ),
      _StatTile(
        progress: _progress,
        value: 24,
        suffix: '/7',
        label: 'Portfolio visibility',
        icon: Icons.visibility_outlined,
      ),
    ];
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 54),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth < 720 ? 2 : 4;
                final spacing = 20.0;
                final width =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final tile in tiles)
                      SizedBox(width: width, child: tile),
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.progress,
    required this.value,
    required this.label,
    required this.icon,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
  });

  final Animation<double> progress;
  final double value;
  final String label;
  final IconData icon;
  final String prefix;
  final String suffix;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.goldSoft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppColors.gold, size: 19),
        ),
        const SizedBox(height: 16),
        _CountUp(
          progress: progress,
          value: value,
          prefix: prefix,
          suffix: suffix,
          decimals: decimals,
          style: AppText.goldMetric,
        ),
        const SizedBox(height: 6),
        Text(label, style: AppText.small),
      ],
    );
  }
}

/// Animated circular funding gauge revealed on scroll.
class _FundingRing extends StatefulWidget {
  const _FundingRing({required this.value, required this.label});

  final double value;
  final String label;
  static const double size = 116;

  @override
  State<_FundingRing> createState() => _FundingRingState();
}

class _FundingRingState extends State<_FundingRing>
    with SingleTickerProviderStateMixin, _RevealOnScroll {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final Animation<double> _sweep = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void onReveal() => _controller.forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _FundingRing.size,
      height: _FundingRing.size,
      child: AnimatedBuilder(
        animation: _sweep,
        builder: (context, _) {
          final fraction = widget.value * _sweep.value;
          return CustomPaint(
            painter: _RingPainter(
              fraction: fraction,
              track: AppColors.track,
              fill: AppColors.gold,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(fraction * 100).round()}%',
                    style: AppText.goldMetricSmall,
                  ),
                  Text(widget.label, style: AppText.tinyLight),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.track,
    required this.fill,
  });

  final double fraction;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - stroke) / 2;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = fill;
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction.clamp(0.0, 1.0),
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.fill != fill ||
      oldDelegate.track != track;
}

