import 'admin_models.dart';

abstract interface class AdminRepository {
  Future<AdminDashboardData> loadDashboard();

  Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    required bool disabled,
    required bool admin,
    bool emailVerified = false,
    String phoneNumber = '',
  });

  Future<void> updateUser({
    required String uid,
    required String email,
    required String displayName,
    required bool disabled,
    required bool admin,
    String? password,
    bool? emailVerified,
    String phoneNumber = '',
  });

  Future<void> deleteUser(String uid);

  Future<void> setUserAdmin({required String uid, required bool admin});

  Future<AdminUserDetail> loadUserDetail(String uid);

  Future<void> createAsset(AdminAsset asset);

  Future<void> updateAsset(AdminAsset asset);

  Future<void> deleteAsset(String id);

  Future<void> updateAssetValuation({
    required String id,
    required double currentAssetValue,
    String valuationDate,
    String performanceNotes,
    double assetIncome,
    double expenses,
    double netIncome,
    double occupancyRate,
  });

  /// Splits [totalAmountUsd] of rental income across every funded holder of the
  /// asset, proportional to invested capital, crediting each member's wallet.
  Future<RentalIncomeDistribution> distributeRentalIncome({
    required String assetId,
    required double totalAmountUsd,
    String note,
  });

  Future<void> createPaymentOption(PaymentOption option);

  Future<void> updatePaymentOption(PaymentOption option);

  Future<void> deletePaymentOption(String id);

  Future<String> uploadPaymentQrCode(AdminUploadFile file);

  Future<String> uploadAssetImage(AdminUploadFile file);

  Future<String> uploadAssetDocument(AdminUploadFile file);

  Future<void> verifyDepositRequest(String id);

  /// Force a member's investment plan to pay out now (principal + profit to
  /// their wallet), regardless of maturity.
  Future<void> settleInvestment(String investmentId);

  Future<void> adjustMemberWallet({
    required String uid,
    required double amountUsd,
    required String direction,
    required String reason,
  });

  Future<void> rejectDepositRequest({
    required String id,
    required String reason,
  });

  Future<void> approveWithdrawalRequest(String id);

  Future<void> rejectWithdrawalRequest({
    required String id,
    required String reason,
  });

  Future<void> replyToSupportTicket({
    required String id,
    required String message,
  });

  Future<void> closeSupportTicket(String id);

  Future<void> updateWithdrawalPolicy(WithdrawalPolicy policy);

  Future<void> updateReferralPolicy(ReferralPolicy policy);

  Future<void> updateLandingContent(LandingContent content);

  Future<void> markNotificationsRead();

  Future<void> approveKycProfile(String uid);

  Future<void> rejectKycProfile({required String uid, required String reason});
}
