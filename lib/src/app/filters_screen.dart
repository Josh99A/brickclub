part of 'brickclub_app.dart';

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

