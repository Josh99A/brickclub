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
      future: widget.investmentRepository.listOpportunities(
        localeCode: Localizations.localeOf(context).languageCode,
      ),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context);
        final allOpportunities = snapshot.data ?? const [];
        final opportunities = allOpportunities
            .where(filters.matches)
            .where(_matchesSearch)
            .toList(growable: false);
        final featuredReturn = opportunities.isEmpty
            ? '0.0%'
            : opportunities.first.returnText;

        return AppPage(
          title: l10n.navInvest,
          subtitle: l10n.investSubtitle,
          onProfileTap: widget.onOpenProfile,
          children: [
            AppTextField(
              controller: _searchController,
              compact: true,
              hintText: l10n.investSearchHint,
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
                      label: l10n.investAvailable(opportunities.length),
                      selected: true,
                    ),
                    SizedBox(width: 8),
                    _filterPill(
                      l10n: l10n,
                      value: filters.asset,
                      defaultLabel: l10n.filtersAssetClass,
                      opportunities: allOpportunities,
                    ),
                    SizedBox(width: 8),
                    _filterPill(
                      l10n: l10n,
                      value: filters.risk,
                      defaultLabel: l10n.filtersRiskLevel,
                      opportunities: allOpportunities,
                    ),
                    SizedBox(width: 8),
                    _filterPill(
                      l10n: l10n,
                      value: filters.payment,
                      defaultLabel: l10n.filtersPaymentMethod,
                      opportunities: allOpportunities,
                    ),
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
                      l10n.investFilteredIncome,
                      style: AppText.cardHeadingSmall,
                    ),
                  ),
                ],
              ),
            ),
            SectionHeading(
              title: snapshot.connectionState == ConnectionState.done
                  ? l10n.investOpportunitiesCount(opportunities.length)
                  : l10n.investLoadingOpportunities,
              action: l10n.investFiltersAction,
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
                    Text(l10n.investNoMatchTitle, style: AppText.h2),
                    SizedBox(height: 6),
                    Text(
                      allOpportunities.isEmpty
                          ? l10n.investNoMatchEmpty
                          : _searchQuery.trim().isNotEmpty
                          ? l10n.investNoMatchSearch(_searchQuery.trim())
                          : l10n.investNoMatchFilters,
                      textAlign: TextAlign.center,
                      style: AppText.body,
                    ),
                    if (allOpportunities.isNotEmpty) ...[
                      SizedBox(height: 16),
                      SecondaryButton(
                        label: l10n.investResetFilters,
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
                  category: localizeAssetTerm(l10n, opportunity.assetClass),
                  title: opportunity.displayTitle,
                  location: opportunity.location,
                  minimum: opportunity.minimumText,
                  returnText: opportunity.returnText,
                  fundedPercent: opportunity.fundedPercentage,
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

  /// A filter shortcut pill: shows the dimension name (e.g. "Risk level") while
  /// unset, or the chosen value highlighted once a filter is applied. Tapping it
  /// opens the full filters screen. Disabled when there are no opportunities.
  Widget _filterPill({
    required AppLocalizations l10n,
    required String value,
    required String defaultLabel,
    required List<InvestmentOpportunity> opportunities,
  }) {
    final active = value != 'All';
    return ChoicePill(
      label: active ? localizeAssetTerm(l10n, value) : defaultLabel,
      selected: active,
      onTap: opportunities.isEmpty ? null : () => _openFilters(opportunities),
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

