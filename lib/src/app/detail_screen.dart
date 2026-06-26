part of 'brickclub_app.dart';

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
    final l10n = AppLocalizations.of(context);
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
                    child: _AssetGalleryHero(images: opportunity.images),
                  ),
                  PositionedDirectional(
                    top: 16,
                    start: 14,
                    child: ChoicePill(
                      label: l10n.detailVerifiedDocs,
                      selected: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26),
              Text(opportunity.displayTitle, style: AppText.detailTitle),
              Text(
                l10n.detailAssetLine(
                  localizeAssetTerm(l10n, opportunity.assetClass),
                  opportunity.location,
                ),
                style: AppText.body,
              ),
              SizedBox(height: 20),
              Panel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Metric(
                            opportunity.returnText,
                            l10n.previewTargetReturn,
                            gold: true,
                          ),
                        ),
                        Expanded(
                          child: Metric(
                            opportunity.minimumText,
                            l10n.previewMinimum,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Metric(
                            opportunity.exitPeriod.isNotEmpty
                                ? opportunity.exitPeriod
                                : '—',
                            l10n.detailLiquidity,
                          ),
                        ),
                        Expanded(
                          child: Metric(
                            localizeAssetTerm(l10n, opportunity.riskLevel),
                            l10n.filtersRiskLevel,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Panel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.detailFundingStatus,
                            style: AppText.cardHeadingSmall,
                          ),
                        ),
                        Text(
                          l10n.detailFundedPercent(
                            opportunity.fundedPercentage.toStringAsFixed(0),
                          ),
                          style: AppText.goldBody,
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    ProgressLine(
                      value: (opportunity.fundedPercentage / 100)
                          .clamp(0.0, 1.0)
                          .toDouble(),
                    ),
                    SizedBox(height: 12),
                    Text(
                      l10n.detailFundingNote,
                      style: AppText.small,
                    ),
                  ],
                ),
              ),
              if (opportunity.documents.isNotEmpty) ...[
                SizedBox(height: 24),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.detailDocuments,
                        style: AppText.cardHeadingSmall,
                      ),
                      SizedBox(height: 12),
                      for (var index = 0;
                          index < opportunity.documents.length;
                          index++) ...[
                        if (index > 0) SizedBox(height: 8),
                        _AssetDocumentTile(url: opportunity.documents[index]),
                      ],
                    ],
                  ),
                ),
              ],
              SizedBox(height: 20),
              PrimaryButton(
                key: const ValueKey('invest-with-crypto'),
                label: l10n.detailInvestButton,
                onPressed: () => requireApprovedKyc(
                  context,
                  kyc,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InvestPlanScreen(
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

/// Hero image area for an asset. Shows a swipeable carousel with page dots when
/// the asset has multiple photos, a single image for one photo, and the bundled
/// placeholder when none have been uploaded.
class _AssetGalleryHero extends StatefulWidget {
  const _AssetGalleryHero({required this.images});

  final List<String> images;

  @override
  State<_AssetGalleryHero> createState() => _AssetGalleryHeroState();
}

class _AssetGalleryHeroState extends State<_AssetGalleryHero> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const height = 206.0;
    final images = widget.images;

    if (images.length <= 1) {
      return AssetImageView(
        imageUrl: images.isEmpty ? null : images.first,
        width: double.infinity,
        height: height,
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (value) => setState(() => _page = value),
            itemBuilder: (context, index) => AssetImageView(
              imageUrl: images[index],
              width: double.infinity,
              height: height,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < images.length; index++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _page == index ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _page == index
                          ? AppColors.gold
                          : Colors.white.withValues(alpha: .7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable row for an asset document on the member detail screen. Opens the
/// stored file (PDF/image/spreadsheet) in an external viewer.
class _AssetDocumentTile extends StatelessWidget {
  const _AssetDocumentTile({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openExternalUrl(context, url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.description_outlined, color: AppColors.gold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _documentLabelFromUrl(url),
                style: AppText.fieldLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.open_in_new_rounded, color: AppColors.muted, size: 18),
          ],
        ),
      ),
    );
  }
}

