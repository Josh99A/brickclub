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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current portfolio value', style: AppText.body),
                      SizedBox(height: 10),
                      Text(
                        data.totalCurrentValueText,
                        style: AppText.portfolioValue,
                      ),
                      SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Metric(data.totalInvestedText, 'Invested'),
                          ),
                          Expanded(
                            child: Metric(
                              data.totalProfitLossText,
                              'Profit / loss',
                              gold: data.totalProfitLoss >= 0,
                            ),
                          ),
                          Expanded(
                            child: Metric(data.overallReturnText, 'Return'),
                          ),
                        ],
                      ),
                      if (data.totalDividends > 0) ...[
                        SizedBox(height: 12),
                        Text(
                          'Dividends received: ${data.totalDividendsText}',
                          style: AppText.small,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 14),
                Text('Holdings', style: AppText.h2),
                if (data.holdings.isEmpty)
                  const _EmptyFinancePanel(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'No holdings yet',
                    message: 'Approved investments appear here automatically.',
                  )
                else
                  for (final holding in data.holdings)
                    _PortfolioHoldingRow(holding: holding),
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
                  'Invested ${holding.amountInvestedText} · ${holding.ownershipText} ownership',
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

