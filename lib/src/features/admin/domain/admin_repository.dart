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

  Future<void> createCryptoPaymentOption(CryptoPaymentOption option);

  Future<void> updateCryptoPaymentOption(CryptoPaymentOption option);

  Future<void> deleteCryptoPaymentOption(String id);

  Future<String> uploadCryptoPaymentQrCode(AdminUploadFile file);

  Future<String> uploadAssetImage(AdminUploadFile file);

  Future<void> verifyDepositRequest(String id);

  Future<void> rejectDepositRequest({
    required String id,
    required String reason,
  });

  Future<void> replyToSupportTicket({
    required String id,
    required String message,
  });

  Future<void> closeSupportTicket(String id);

  Future<void> updateWithdrawalPolicy(WithdrawalPolicy policy);

  Future<void> markNotificationsRead();

  Future<void> approveKycProfile(String uid);

  Future<void> rejectKycProfile({required String uid, required String reason});
}
