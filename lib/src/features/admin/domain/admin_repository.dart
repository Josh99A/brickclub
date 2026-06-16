import 'admin_models.dart';

abstract interface class AdminRepository {
  Future<AdminDashboardData> loadDashboard();

  Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    required bool disabled,
    required bool admin,
  });

  Future<void> updateUser({
    required String uid,
    required String email,
    required String displayName,
    required bool disabled,
    required bool admin,
    String? password,
  });

  Future<void> deleteUser(String uid);

  Future<void> setUserAdmin({required String uid, required bool admin});

  Future<void> createAsset(AdminAsset asset);

  Future<void> updateAsset(AdminAsset asset);

  Future<void> deleteAsset(String id);

  Future<void> createCryptoPaymentOption(CryptoPaymentOption option);

  Future<void> updateCryptoPaymentOption(CryptoPaymentOption option);

  Future<void> deleteCryptoPaymentOption(String id);
}
