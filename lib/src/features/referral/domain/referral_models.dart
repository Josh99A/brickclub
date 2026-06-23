/// A single commission a member earned from a referee's verified investment.
class ReferralCommission {
  const ReferralCommission({
    required this.id,
    required this.investmentAmountUsd,
    required this.rate,
    required this.commissionUsd,
    required this.createdAt,
  });

  factory ReferralCommission.fromJson(Map<String, dynamic> json) {
    return ReferralCommission(
      id: json['id'] as String? ?? '',
      investmentAmountUsd:
          (json['investmentAmountUsd'] as num?)?.toDouble() ?? 0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
      commissionUsd: (json['commissionUsd'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  final String id;
  final double investmentAmountUsd;
  final double rate;
  final double commissionUsd;
  final String createdAt;
}

/// The current member's referral standing: their share code, how many people
/// they have referred, lifetime earnings, the active commission rate, and their
/// recent commission history. Earnings are paid into the member's wallet.
class ReferralProfile {
  const ReferralProfile({
    required this.referralCode,
    required this.referralCount,
    required this.totalEarnedUsd,
    required this.commissionPercent,
    required this.referralsEnabled,
    required this.commissions,
  });

  factory ReferralProfile.empty() {
    return const ReferralProfile(
      referralCode: '',
      referralCount: 0,
      totalEarnedUsd: 0,
      commissionPercent: 0,
      referralsEnabled: false,
      commissions: [],
    );
  }

  factory ReferralProfile.fromJson(Map<String, dynamic> json) {
    final rawCommissions = json['commissions'];
    return ReferralProfile(
      referralCode: json['referralCode'] as String? ?? '',
      referralCount: (json['referralCount'] as num?)?.toInt() ?? 0,
      totalEarnedUsd: (json['totalEarnedUsd'] as num?)?.toDouble() ?? 0,
      commissionPercent: (json['commissionPercent'] as num?)?.toDouble() ?? 0,
      referralsEnabled: json['referralsEnabled'] as bool? ?? false,
      commissions: rawCommissions is List
          ? rawCommissions
                .whereType<Map>()
                .map(
                  (item) => ReferralCommission.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  final String referralCode;
  final int referralCount;
  final double totalEarnedUsd;
  final double commissionPercent;
  final bool referralsEnabled;
  final List<ReferralCommission> commissions;

  bool get hasCode => referralCode.isNotEmpty;

  /// Builds the shareable invite link for this code against [origin]
  /// (e.g. the web app origin). The `?ref=` param is read back at signup.
  String shareLink(String origin) {
    final base = origin.endsWith('/')
        ? origin.substring(0, origin.length - 1)
        : origin;
    return '$base/?ref=$referralCode';
  }
}
