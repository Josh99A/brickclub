import 'package:cloud_functions/cloud_functions.dart';

import '../domain/admin_models.dart';
import '../domain/admin_repository.dart';

class FirebaseAdminRepository implements AdminRepository {
  FirebaseAdminRepository({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<AdminDashboardData> loadDashboard() async {
    final data = await _callMap('listAdminDashboard');
    return AdminDashboardData.fromJson(data);
  }

  @override
  Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    required bool disabled,
    required bool admin,
  }) {
    return _callVoid('createAdminUser', {
      'email': email,
      'password': password,
      'displayName': displayName,
      'disabled': disabled,
      'admin': admin,
    });
  }

  @override
  Future<void> updateUser({
    required String uid,
    required String email,
    required String displayName,
    required bool disabled,
    required bool admin,
    String? password,
  }) {
    return _callVoid('updateAdminUser', {
      'uid': uid,
      'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
      'displayName': displayName,
      'disabled': disabled,
      'admin': admin,
    });
  }

  @override
  Future<void> deleteUser(String uid) {
    return _callVoid('deleteAdminUser', {'uid': uid});
  }

  @override
  Future<void> setUserAdmin({required String uid, required bool admin}) {
    return _callVoid('setUserAdmin', {'uid': uid, 'admin': admin});
  }

  @override
  Future<void> createAsset(AdminAsset asset) {
    return _callVoid('createAdminAsset', asset.toJson());
  }

  @override
  Future<void> updateAsset(AdminAsset asset) {
    return _callVoid('updateAdminAsset', asset.toJson());
  }

  @override
  Future<void> deleteAsset(String id) {
    return _callVoid('deleteAdminAsset', {'id': id});
  }

  @override
  Future<void> createCryptoPaymentOption(CryptoPaymentOption option) {
    return _callVoid('createCryptoPaymentOption', option.toJson());
  }

  @override
  Future<void> updateCryptoPaymentOption(CryptoPaymentOption option) {
    return _callVoid('updateCryptoPaymentOption', option.toJson());
  }

  @override
  Future<void> deleteCryptoPaymentOption(String id) {
    return _callVoid('deleteCryptoPaymentOption', {'id': id});
  }

  Future<Map<String, dynamic>> _callMap(
    String name, [
    Map<String, dynamic>? data,
  ]) async {
    final callable = _functions.httpsCallable(name);
    final result = await callable.call<Object?>(data);
    return Map<String, dynamic>.from(result.data! as Map);
  }

  Future<void> _callVoid(String name, [Map<String, dynamic>? data]) async {
    final callable = _functions.httpsCallable(name);
    await callable.call<Object?>(data);
  }
}
