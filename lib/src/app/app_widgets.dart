part of 'brickclub_app.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.simpleHeader = false,
    this.onProfileTap,
  });

  final String title;
  final String? subtitle;
  final bool simpleHeader;
  final VoidCallback? onProfileTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (simpleHeader)
                    Center(child: Text(title, style: AppText.topTitle))
                  else
                    AppHeader(title: title, onProfileTap: onProfileTap),
                  if (subtitle != null) ...[
                    SizedBox(height: 4),
                    Text(subtitle!, style: AppText.body),
                  ],
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            sliver: SliverList.separated(
              itemCount: children.length,
              itemBuilder: (_, index) => children[index],
              separatorBuilder: (_, _) => SizedBox(height: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.title, this.onProfileTap});

  final String title;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const _BrickMark(),
          SizedBox(width: 10),
          Expanded(child: Text(title, style: AppText.topTitle)),
          HeaderCircle(
            onTap: () => showMessage(context, l10n.notificationsNone),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.secondary,
              size: 18,
            ),
          ),
          SizedBox(width: 9),
          HeaderCircle(
            key: const ValueKey('profile-header-button'),
            onTap:
                onProfileTap ??
                () => showMessage(context, l10n.profileInMore),
            child: Icon(
              Icons.person_outline_rounded,
              color: AppColors.gold,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  // The third field is a stable id used for the widget key (e.g. 'nav-home');
  // the visible label is resolved from it via [_label] so localization never
  // changes the key.
  static const items = [
    (Icons.home_outlined, Icons.home_rounded, 'home'),
    (Icons.trending_up_rounded, Icons.trending_up_rounded, 'invest'),
    (
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet_rounded,
      'wallet',
    ),
    (Icons.pie_chart_outline_rounded, Icons.pie_chart_rounded, 'portfolio'),
    (Icons.menu_rounded, Icons.menu_rounded, 'more'),
  ];

  static String _label(AppLocalizations l10n, String id) => switch (id) {
    'home' => l10n.navHome,
    'invest' => l10n.navInvest,
    'wallet' => l10n.navWallet,
    'portfolio' => l10n.navPortfolio,
    _ => l10n.navMore,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _BottomNavItem(
                    key: ValueKey('nav-${items[i].$3}'),
                    icon: items[i].$1,
                    selectedIcon: items[i].$2,
                    label: _label(l10n, items[i].$3),
                    selected: i == index,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 42,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.goldSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                selected ? selectedIcon : icon,
                color: selected ? AppColors.gold : AppColors.muted,
                size: 21,
              ),
            ),
            SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                color: selected ? AppColors.gold : AppColors.muted,
                fontSize: 10,
                height: 1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows an asset photo from a remote [imageUrl], falling back to the bundled
/// placeholder while loading, on error, or when no URL is provided.
class AssetImageView extends StatelessWidget {
  const AssetImageView({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  final String? imageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _fallback();
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: AppColors.surface,
          alignment: Alignment.center,
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.gold,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }

  Widget _fallback() {
    return Image.asset(
      'assets/images/skyline_heights.png',
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}

class InvestmentCard extends StatelessWidget {
  const InvestmentCard({
    super.key,
    required this.onTap,
    this.compact = false,
    this.category = 'Real Estate',
    this.title = 'Skyline Heights\nIncome Fund',
    this.location = 'Central Business District',
    this.minimum = '\$50',
    this.returnText = '11.8%',
    this.imageUrl,
  });

  final VoidCallback onTap;
  final bool compact;
  final String category;
  final String title;
  final String location;
  final String minimum;
  final String returnText;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 176.0 : 188.0;
    return Material(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: const ValueKey('investment-card'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SizedBox(
                width: compact ? 134 : 128,
                height: height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AssetImageView(
                        imageUrl: imageUrl,
                        width: compact ? 134 : 128,
                        height: height,
                      ),
                    ),
                    PositionedDirectional(
                      top: 12,
                      start: 12,
                      child: ChoicePill(label: category, selected: true),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 18, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: AppText.investmentTitle),
                      SizedBox(height: 4),
                      Text(location, style: AppText.small),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              minimum,
                              style: AppText.goldBody,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(returnText, style: AppText.cardHeadingSmall),
                        ],
                      ),
                      if (!compact) ...[
                        SizedBox(height: 16),
                        const ProgressLine(value: .62, height: 6),
                        SizedBox(height: 7),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .investmentCardCryptoFunding,
                              style: AppText.tiny,
                            ),
                            Text('62%', style: AppText.tinyLight),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 18,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.panel,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.actionButton = false,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final bool actionButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: AppText.h2)),
        if (action != null)
          actionButton
              ? SecondaryButton(
                  label: action!,
                  onPressed: onAction,
                  compact: true,
                )
              : TextButton(
                  onPressed: onAction,
                  child: Text(action!, style: AppText.body),
                ),
      ],
    );
  }
}

class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : AppColors.panel,
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.background : AppColors.secondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class FilterChoices extends StatelessWidget {
  const FilterChoices({
    super.key,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final value in values)
          ChoicePill(
            label: value,
            selected: selected == value,
            onTap: () => onChanged(value),
          ),
      ],
    );
  }
}

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.border),
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        icon: const GoogleIcon(),
        label: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .16;
    final rect = Offset.zero & size;

    void drawArc(Color color, double start, double sweep) {
      canvas.drawArc(
        rect.deflate(stroke / 2),
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }

    drawArc(const Color(0xFF4285F4), -0.08, 1.32);
    drawArc(const Color(0xFF34A853), 1.18, 1.34);
    drawArc(const Color(0xFFFBBC05), 2.43, 1.06);
    drawArc(const Color(0xFFEA4335), 3.43, 1.54);

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final centerY = size.height * .52;
    canvas.drawLine(
      Offset(size.width * .52, centerY),
      Offset(size.width * .94, centerY),
      bluePaint,
    );
    canvas.drawLine(
      Offset(size.width * .94, centerY),
      Offset(size.width * .94, size.height * .65),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          disabledBackgroundColor: AppColors.muted,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? null : double.infinity,
      height: compact ? 40 : 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.border),
          backgroundColor: AppColors.panel,
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: 18)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.initialValue,
    this.controller,
    this.label,
    this.hintText,
    this.obscureText = false,
    this.compact = false,
    this.keyboardType,
    this.prefixIcon,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
  });

  final String? initialValue;
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final bool obscureText;
  final bool compact;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool obscured;

  @override
  void initState() {
    super.initState();
    obscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      obscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      height: widget.compact ? 44 : 50,
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.controller == null ? widget.initialValue : null,
        obscureText: obscured,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints,
        onChanged: widget.onChanged,
        style: TextStyle(fontSize: 14, color: AppColors.primary),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.prefixIcon == null ? 16 : 12,
          ),
          filled: true,
          fillColor: AppColors.surface,
          hintText: widget.hintText,
          hintStyle: AppText.placeholder,
          prefixIcon: widget.prefixIcon == null
              ? null
              : Icon(widget.prefixIcon, color: AppColors.muted, size: 19),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 42,
            minHeight: 42,
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  tooltip: obscured
                      ? AppLocalizations.of(context).commonShowPassword
                      : AppLocalizations.of(context).commonHidePassword,
                  onPressed: () => setState(() => obscured = !obscured),
                  icon: Icon(
                    obscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.muted,
                    size: 20,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.compact ? 12 : 14),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.compact ? 12 : 14),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.compact ? 12 : 14),
            borderSide: BorderSide(color: AppColors.gold, width: 1.3),
          ),
        ),
      ),
    );

    if (widget.label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 2, bottom: 6),
          child: Text(widget.label!, style: AppText.fieldLabel),
        ),
        field,
      ],
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Text(label, style: AppText.fieldLabel);
}

class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 58,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.panel,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: AppText.cardHeadingSmall),
              Text(subtitle, style: AppText.tinyLight),
            ],
          ),
        ),
      ),
    );
  }
}

class AllocationRow extends StatelessWidget {
  const AllocationRow(this.label, this.value, this.color, {super.key});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 128, child: Text(label, style: AppText.fieldLabel)),
          Expanded(
            child: ProgressLine(value: value, color: color, height: 7),
          ),
        ],
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
  });

  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? AppColors.gold;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value,
          color: lineColor,
          backgroundColor: AppColors.track,
        ),
      ),
    );
  }
}

class Metric extends StatelessWidget {
  const Metric(this.value, this.label, {super.key, this.gold = false});

  final String value;
  final String label;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: gold ? AppColors.gold : AppColors.primary,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: AppText.small),
      ],
    );
  }
}

class QuoteRow extends StatelessWidget {
  const QuoteRow(this.label, this.value, {super.key, this.warning = false});

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.body)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: warning ? AppText.warning : AppText.fieldLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderPill extends StatelessWidget {
  const HeaderPill(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 31,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.panel,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: AppText.headerInitials),
    );
  }
}

class HeaderCircle extends StatelessWidget {
  const HeaderCircle({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.panel,
          border: Border.all(color: AppColors.border),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}

class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 393),
          child: Material(color: AppColors.background, child: child),
        ),
      ),
    );
  }
}

PreferredSizeWidget detailAppBar(BuildContext context, String title) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  return AppBar(
    toolbarHeight: 76,
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.primary,
    centerTitle: true,
    leading: IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Icon(isRtl ? Icons.chevron_right : Icons.chevron_left, size: 32),
    ),
    title: Text(title, style: AppText.detailAppBar),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: AppColors.border),
    ),
  );
}

void openDetail(
  BuildContext context,
  KycProfile kyc,
  InvestmentOpportunity opportunity,
  InvestmentRepository investmentRepository,
  VoidCallback onStartKyc,
) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (_) => DetailScreen(
        kyc: kyc,
        opportunity: opportunity,
        investmentRepository: investmentRepository,
        onStartKyc: onStartKyc,
      ),
    ),
  );
}

String _shortHash(String hash) {
  final trimmed = hash.trim();
  if (trimmed.length <= 14) return trimmed.isEmpty ? '-' : trimmed;
  return '${trimmed.substring(0, 8)}...${trimmed.substring(trimmed.length - 6)}';
}

String _formatUsdCompact(double value) {
  if (value <= 0) return '\$0';
  return '\$${NumberFormat.compact().format(value)}';
}

String _contentTypeForName(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.png')) return 'image/png';
  return 'image/jpeg';
}

void showMessage(BuildContext context, String message) {
  final displayMessage = message.trim();
  if (displayMessage.isEmpty) {
    return;
  }
  final messenger =
      rootScaffoldMessengerKey.currentState ?? ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 22),
        elevation: 10,
        backgroundColor: AppColors.panel,
        showCloseIcon: true,
        closeIconColor: AppColors.secondary,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.border),
        ),
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayMessage,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

String _authErrorMessage(AppLocalizations l10n, Object error) {
  if (error is AuthValidationException) {
    return error.message;
  }
  if (error is AuthOperationTimeoutException) {
    return error.message;
  }
  if (error is FirebaseAuthException) {
    final message = error.message?.toLowerCase() ?? '';
    if (message.contains('cleartext') || message.contains('10.0.2.2')) {
      return l10n.errAuthEmulatorUnreachable;
    }

    return switch (error.code) {
      'invalid-email' => l10n.errInvalidEmail,
      'missing-email' => l10n.errMissingEmail,
      'missing-password' => l10n.errMissingPassword,
      'user-not-found' => l10n.errUserNotFound,
      'wrong-password' || 'invalid-credential' => l10n.errWrongPassword,
      'email-already-in-use' => l10n.errEmailInUse,
      'weak-password' => l10n.errWeakPassword,
      'operation-not-allowed' => l10n.errOperationNotAllowed,
      'user-disabled' => l10n.errUserDisabled,
      'too-many-requests' => l10n.errTooManyRequests,
      'network-request-failed' => l10n.errNetworkFailed,
      'requires-recent-login' => l10n.errRequiresRecentLogin,
      'expired-action-code' => l10n.errExpiredActionCode,
      'invalid-action-code' => l10n.errInvalidActionCode,
      'internal-error' => l10n.errAccountRequestFailed,
      _ => l10n.errAccountRequestFailed,
    };
  }

  if (error is FirebaseFunctionsException) {
    return switch (error.code) {
      'invalid-argument' => l10n.errInvalidEmail,
      'unavailable' => l10n.errResetUnavailable,
      'failed-precondition' => _friendlyFirebaseMessage(
        error.message,
        fallback: l10n.errResetNotAvailable,
        l10n: l10n,
      ),
      _ => l10n.errResetFailed,
    };
  }

  return _friendlyUnexpectedMessage(error, l10n);
}

String _friendlyFirebaseMessage(
  String? message, {
  required String fallback,
  AppLocalizations? l10n,
}) {
  final normalized = message?.trim();
  if (normalized == null || normalized.isEmpty) return fallback;

  // Admin (English-only) callers omit l10n and keep the English copy.
  if (l10n == null) {
    return switch (normalized) {
      'Authentication is required.' => 'Sign in again to continue.',
      'Admin access is required.' =>
        'Your account does not have permission to do that.',
      'Development email is only available in the Functions emulator.' =>
        'Email sending is not available in this environment.',
      'User has no email address.' =>
        'Add an email address to your account first.',
      _ => fallback,
    };
  }

  return switch (normalized) {
    'Authentication is required.' => l10n.errSignInAgain,
    'Admin access is required.' => l10n.errAdminNoPermission,
    'Development email is only available in the Functions emulator.' =>
      l10n.errEmailEnvUnavailable,
    'User has no email address.' => l10n.errAddEmailFirst,
    _ => fallback,
  };
}

String _friendlyUnexpectedMessage(Object error, [AppLocalizations? l10n]) {
  // Callable backend errors carry a deliberate, user-facing message (e.g.
  // "Selected payment asset is not enabled."). For the validation codes our
  // Cloud Functions throw on purpose, surface that message instead of a generic
  // fallback so members know exactly what to fix. Reserve the generic handling
  // below for internal/unknown failures that leak no useful detail.
  if (error is FirebaseFunctionsException) {
    final message = error.message?.trim();
    switch (error.code) {
      case 'failed-precondition':
      case 'invalid-argument':
      case 'not-found':
      case 'already-exists':
      case 'out-of-range':
      case 'resource-exhausted':
        if (message != null && message.isNotEmpty) {
          return message;
        }
      case 'unauthenticated':
        return l10n?.errSignInAgain ?? 'Sign in again to continue.';
      case 'permission-denied':
        return l10n?.errPermissionDenied ??
            'You do not have permission to do that.';
    }
  }

  final text = error.toString().toLowerCase();
  if (text.contains('network') ||
      text.contains('socket') ||
      text.contains('host lookup') ||
      text.contains('unavailable')) {
    return l10n?.errNetworkFailed ??
        'We could not connect. Check your internet and try again.';
  }

  if (text.contains('permission-denied') ||
      text.contains('permission denied')) {
    return l10n?.errPermissionDenied ??
        'You do not have permission to do that.';
  }

  return l10n?.errGeneric ?? 'Something went wrong. Please try again.';
}

