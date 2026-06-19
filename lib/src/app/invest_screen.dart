part of 'brickclub_app.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(InvestmentOpportunity opportunity) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    final haystack = [
      opportunity.title,
      opportunity.location,
      opportunity.assetClass,
      opportunity.assetType,
      opportunity.description,
      opportunity.strategy,
    ].join(' ').toLowerCase();
    return haystack.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InvestmentOpportunity>>(
      future: widget.investmentRepository.listOpportunities(),
      builder: (context, snapshot) {
        final allOpportunities = snapshot.data ?? const [];
        final opportunities = allOpportunities
            .where(filters.matches)
            .where(_matchesSearch)
            .toList(growable: false);
        final featuredReturn = opportunities.isEmpty
            ? '0.0%'
            : opportunities.first.returnText;

        return AppPage(
          title: 'Invest',
          subtitle: 'Explore verified multi-asset BrickShares',
          onProfileTap: widget.onOpenProfile,
          children: [
            AppTextField(
              controller: _searchController,
              compact: true,
              hintText: 'Search by name, location, or asset class',
              prefixIcon: Icons.search_rounded,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
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
                          : _searchQuery.trim().isNotEmpty
                          ? 'No BrickShares match “${_searchQuery.trim()}”. Try a different search or adjust your filters.'
                          : 'Try a different asset class, risk level, or payment method.',
                      textAlign: TextAlign.center,
                      style: AppText.body,
                    ),
                    if (allOpportunities.isNotEmpty) ...[
                      SizedBox(height: 16),
                      SecondaryButton(
                        label: 'Reset filters',
                        onPressed: () => setState(() {
                          filters = const BrickShareFilters();
                          _searchQuery = '';
                          _searchController.clear();
                        }),
                      ),
                    ],
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
                  imageUrl: opportunity.images.isEmpty
                      ? null
                      : opportunity.images.first,
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
    final updated = await Navigator.of(context, rootNavigator: true)
        .push<BrickShareFilters>(
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

