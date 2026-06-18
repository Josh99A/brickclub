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

