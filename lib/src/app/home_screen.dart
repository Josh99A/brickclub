part of 'brickclub_app.dart';

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
    // Load the member dashboard once and share it across the portfolio,
    // holdings, and activity sections. Building one future here (rather than a
    // separate call inside each FutureBuilder) collapses three identical
    // backend round-trips into one while still refetching on rebuild.
    final dashboardFuture = investmentRepository.loadMemberDashboard();
    return AppPage(
      title: 'BrickClub',
      onProfileTap: onOpenProfile,
      children: [
        KycStatusCard(kyc: kyc, onStartKyc: onStartKyc, compact: true),
        FutureBuilder<MemberDashboardData>(
          future: dashboardFuture,
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
              imageUrl: opportunity.images.isEmpty
                  ? null
                  : opportunity.images.first,
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
          future: dashboardFuture,
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
          future: dashboardFuture,
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

