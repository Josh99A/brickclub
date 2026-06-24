import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/admin_models.dart';
import '../domain/admin_repository.dart';

class FirebaseAdminRepository implements AdminRepository {
  FirebaseAdminRepository({
    FirebaseFunctions? functions,
    FirebaseStorage? storage,
  }) : _functions = functions ?? FirebaseFunctions.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;

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
    bool emailVerified = false,
    String phoneNumber = '',
  }) {
    return _callVoid('createAdminUser', {
      'email': email,
      'password': password,
      'displayName': displayName,
      'disabled': disabled,
      'admin': admin,
      'emailVerified': emailVerified,
      'phoneNumber': phoneNumber,
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
    bool? emailVerified,
    String phoneNumber = '',
  }) {
    return _callVoid('updateAdminUser', {
      'uid': uid,
      'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
      'displayName': displayName,
      'disabled': disabled,
      'admin': admin,
      'emailVerified': ?emailVerified,
      'phoneNumber': phoneNumber,
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
  Future<AdminUserDetail> loadUserDetail(String uid) async {
    final data = await _callMap('getAdminUserDetail', {'uid': uid});
    return AdminUserDetail.fromJson(data);
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
  Future<void> updateAssetValuation({
    required String id,
    required double currentAssetValue,
    String valuationDate = '',
    String performanceNotes = '',
    double assetIncome = 0,
    double expenses = 0,
    double netIncome = 0,
    double occupancyRate = 0,
  }) {
    return _callVoid('updateAssetValuation', {
      'id': id,
      'currentAssetValue': currentAssetValue,
      if (valuationDate.isNotEmpty) 'valuationDate': valuationDate,
      if (performanceNotes.isNotEmpty) 'performanceNotes': performanceNotes,
      'assetIncome': assetIncome,
      'expenses': expenses,
      'netIncome': netIncome,
      'occupancyRate': occupancyRate,
    });
  }

  @override
  Future<void> createPaymentOption(PaymentOption option) {
    // Callable name is kept for backend-contract stability.
    return _callVoid('createCryptoPaymentOption', option.toJson());
  }

  @override
  Future<void> updatePaymentOption(PaymentOption option) {
    return _callVoid('updateCryptoPaymentOption', option.toJson());
  }

  @override
  Future<void> deletePaymentOption(String id) {
    return _callVoid('deleteCryptoPaymentOption', {'id': id});
  }

  @override
  Future<String> uploadPaymentQrCode(AdminUploadFile file) async {
    final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '-');
    final reference = _storage.ref(
      'admin/payment-qr/${DateTime.now().millisecondsSinceEpoch}-$safeName',
    );
    await reference.putData(
      Uint8List.fromList(file.bytes),
      SettableMetadata(
        contentType: file.contentType,
        customMetadata: {'originalName': file.name},
      ),
    );
    return reference.getDownloadURL();
  }

  @override
  Future<String> uploadAssetImage(AdminUploadFile file) async {
    final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '-');
    final reference = _storage.ref(
      'admin/asset-images/${DateTime.now().millisecondsSinceEpoch}-$safeName',
    );
    await reference.putData(
      Uint8List.fromList(file.bytes),
      SettableMetadata(
        contentType: file.contentType,
        customMetadata: {'originalName': file.name},
      ),
    );
    return reference.getDownloadURL();
  }

  @override
  Future<void> verifyDepositRequest(String id) {
    return _callVoid('verifyDepositProof', {'orderId': id});
  }

  @override
  Future<void> adjustMemberWallet({
    required String uid,
    required double amountUsd,
    required String direction,
    required String reason,
  }) {
    return _callVoid('adjustMemberWallet', {
      'uid': uid,
      'amountUsd': amountUsd,
      'direction': direction,
      'reason': reason,
    });
  }

  @override
  Future<void> rejectDepositRequest({
    required String id,
    required String reason,
  }) {
    return _callVoid('rejectDepositProof', {'orderId': id, 'reason': reason});
  }

  @override
  Future<void> replyToSupportTicket({
    required String id,
    required String message,
  }) {
    return _callVoid('adminReplyToSupportTicket', {
      'ticketId': id,
      'message': message,
    });
  }

  @override
  Future<void> closeSupportTicket(String id) {
    return _callVoid('closeSupportTicket', {'ticketId': id});
  }

  @override
  Future<void> updateWithdrawalPolicy(WithdrawalPolicy policy) {
    return _callVoid('updateWithdrawalPolicy', policy.toJson());
  }

  @override
  Future<void> updateReferralPolicy(ReferralPolicy policy) {
    return _callVoid('updateReferralPolicy', policy.toJson());
  }

  @override
  Future<void> updateLandingContent(LandingContent content) {
    return _callVoid('updateLandingContent', content.toJson());
  }

  @override
  Future<void> markNotificationsRead() {
    return _callVoid('markAdminNotificationsRead');
  }

  @override
  Future<void> approveKycProfile(String uid) {
    return _callVoid('approveKycProfile', {'uid': uid});
  }

  @override
  Future<void> rejectKycProfile({
    required String uid,
    required String reason,
  }) {
    return _callVoid('rejectKycProfile', {'uid': uid, 'rejectionReason': reason});
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
