class AdminDashboardData {
  const AdminDashboardData({
    required this.users,
    required this.assets,
    required this.cryptoPaymentOptions,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      users: _list(json['users'], AdminUser.fromJson),
      assets: _list(json['assets'], AdminAsset.fromJson),
      cryptoPaymentOptions: _list(
        json['cryptoPaymentOptions'],
        CryptoPaymentOption.fromJson,
      ),
    );
  }

  final List<AdminUser> users;
  final List<AdminAsset> assets;
  final List<CryptoPaymentOption> cryptoPaymentOptions;
}

class AdminUser {
  const AdminUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.disabled,
    required this.emailVerified,
    required this.admin,
    required this.createdAt,
    required this.lastSignInAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      uid: json['uid'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      disabled: json['disabled'] as bool? ?? false,
      emailVerified: json['emailVerified'] as bool? ?? false,
      admin: json['admin'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      lastSignInAt: json['lastSignInAt'] as String?,
    );
  }

  final String uid;
  final String email;
  final String? displayName;
  final bool disabled;
  final bool emailVerified;
  final bool admin;
  final String? createdAt;
  final String? lastSignInAt;
}

class AdminAsset {
  const AdminAsset({
    required this.id,
    required this.title,
    required this.location,
    required this.type,
    required this.fundedPercent,
    required this.reviewStatus,
    required this.publishedStatus,
  });

  factory AdminAsset.empty() {
    return const AdminAsset(
      id: '',
      title: '',
      location: '',
      type: 'Real estate',
      fundedPercent: 0,
      reviewStatus: 'Pending',
      publishedStatus: 'Draft',
    );
  }

  factory AdminAsset.fromJson(Map<String, dynamic> json) {
    return AdminAsset(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      type: json['type'] as String? ?? '',
      fundedPercent: (json['fundedPercent'] as num?)?.toDouble() ?? 0,
      reviewStatus: json['reviewStatus'] as String? ?? 'Pending',
      publishedStatus: json['publishedStatus'] as String? ?? 'Draft',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'location': location,
      'type': type,
      'fundedPercent': fundedPercent,
      'reviewStatus': reviewStatus,
      'publishedStatus': publishedStatus,
    };
  }

  final String id;
  final String title;
  final String location;
  final String type;
  final double fundedPercent;
  final String reviewStatus;
  final String publishedStatus;
}

class CryptoPaymentOption {
  const CryptoPaymentOption({
    required this.id,
    required this.network,
    required this.assetSymbol,
    required this.walletAddress,
    required this.enabled,
    required this.minimumAmount,
  });

  factory CryptoPaymentOption.empty() {
    return const CryptoPaymentOption(
      id: '',
      network: 'Tron',
      assetSymbol: 'USDT',
      walletAddress: '',
      enabled: true,
      minimumAmount: 0,
    );
  }

  factory CryptoPaymentOption.fromJson(Map<String, dynamic> json) {
    return CryptoPaymentOption(
      id: json['id'] as String,
      network: json['network'] as String? ?? '',
      assetSymbol: json['assetSymbol'] as String? ?? '',
      walletAddress: json['walletAddress'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      minimumAmount: (json['minimumAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'network': network,
      'assetSymbol': assetSymbol,
      'walletAddress': walletAddress,
      'enabled': enabled,
      'minimumAmount': minimumAmount,
    };
  }

  final String id;
  final String network;
  final String assetSymbol;
  final String walletAddress;
  final bool enabled;
  final double minimumAmount;
}

List<T> _list<T>(
  Object? value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) {
    return const [];
  }

  return value
      .whereType<Map>()
      .map((item) => fromJson(Map<String, dynamic>.from(item)))
      .toList();
}
