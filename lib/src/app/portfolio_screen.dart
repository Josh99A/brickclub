part of 'brickclub_app.dart';

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
    final l10n = AppLocalizations.of(context);
    return AppPage(
      title: l10n.navPortfolio,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.portfolioCurrentValue, style: AppText.body),
                      SizedBox(height: 10),
                      Text(
                        data.totalCurrentValueText,
                        style: AppText.portfolioValue,
                      ),
                      SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Metric(
                              data.totalInvestedText,
                              l10n.portfolioInvested,
                            ),
                          ),
                          Expanded(
                            child: Metric(
                              data.totalProfitLossText,
                              l10n.portfolioProfitLoss,
                              gold: data.totalProfitLoss >= 0,
                            ),
                          ),
                          Expanded(
                            child: Metric(
                              data.overallReturnText,
                              l10n.portfolioReturn,
                            ),
                          ),
                        ],
                      ),
                      if (data.totalDividends > 0) ...[
                        SizedBox(height: 12),
                        Text(
                          l10n.portfolioDividends(data.totalDividendsText),
                          style: AppText.small,
                        ),
                      ],
                    ],
                  ),
                ),
                if (data.expectedProfitUsd > 0) ...[
                  SizedBox(height: 8),
                  Text(
                    l10n.portfolioExpectedProfit(data.expectedProfitText),
                    style: AppText.small,
                  ),
                ],
                SizedBox(height: 14),
                Text(l10n.portfolioPlansTitle, style: AppText.h2),
                if (data.activeInvestments.isEmpty)
                  _EmptyFinancePanel(
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n.holdingsEmptyTitle,
                    message: l10n.portfolioHoldingsEmptyBody,
                  )
                else
                  for (final plan in data.activeInvestments)
                    _PortfolioPlanRow(plan: plan),
                if (data.holdings.isNotEmpty) ...[
                  SizedBox(height: 14),
                  Text(l10n.portfolioHoldings, style: AppText.h2),
                  for (final holding in data.holdings)
                    _PortfolioHoldingRow(holding: holding),
                ],
                SizedBox(height: 8),
                Text(l10n.portfolioAllocation, style: AppText.h2),
                if (data.allocation.isEmpty)
                  _EmptyFinancePanel(
                    icon: Icons.pie_chart_outline_rounded,
                    title: l10n.portfolioAllocationEmptyTitle,
                    message: l10n.portfolioAllocationEmptyBody,
                  )
                else
                  for (final entry in data.allocation.indexed)
                    AllocationRow(
                      entry.$2.label,
                      entry.$2.percent,
                      _allocationColor(entry.$1),
                    ),
                SizedBox(height: 14),
                Text(l10n.homeRecentActivity, style: AppText.h2),
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

class _PortfolioPlanRow extends StatelessWidget {
  const _PortfolioPlanRow({required this.plan});

  final MemberInvestment plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maturity = plan.maturityDate;
    final maturityText = maturity == null
        ? '—'
        : '${maturity.year}-'
              '${maturity.month.toString().padLeft(2, '0')}-'
              '${maturity.day.toString().padLeft(2, '0')}';
    return Panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.assetTitle,
                  style: AppText.cardHeadingSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(plan.payoutText, style: AppText.cardHeadingSmall),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.portfolioPlanSummary(
                    plan.rateText,
                    plan.durationLabel,
                    maturityText,
                  ),
                  style: AppText.small,
                ),
              ),
              Text(
                plan.profitText,
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 13,
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

class _PortfolioHoldingRow extends StatelessWidget {
  const _PortfolioHoldingRow({required this.holding});

  final MemberHolding holding;

  @override
  Widget build(BuildContext context) {
    final positive = holding.profitLoss >= 0;
    return Panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  holding.assetTitle.isNotEmpty
                      ? holding.assetTitle
                      : holding.title,
                  style: AppText.cardHeadingSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                holding.currentValueText,
                style: AppText.cardHeadingSmall,
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).portfolioInvestedOwnership(
                    holding.amountInvestedText,
                    holding.ownershipText,
                  ),
                  style: AppText.small,
                ),
              ),
              Text(
                holding.profitLossText,
                style: TextStyle(
                  color: positive ? AppColors.success : const Color(0xFFE36D6D),
                  fontSize: 13,
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

