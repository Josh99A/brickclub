import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../admin/domain/admin_models.dart' show LandingContent;
import '../domain/investment_models.dart';
import '../domain/investment_repository.dart';

class FirebaseInvestmentRepository implements InvestmentRepository {
  FirebaseInvestmentRepository({
    FirebaseFunctions? functions,
    FirebaseStorage? storage,
  }) : _functions = functions ?? FirebaseFunctions.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;

  @override
  Future<MemberDashboardData> loadMemberDashboard() async {
    final callable = _functions.httpsCallable('getMemberDashboard');
    final result = await callable.call<Object?>();
    return MemberDashboardData.fromJson(
      Map<String, dynamic>.from(result.data! as Map),
    );
  }

  @override
  Future<LandingContent> getLandingContent() async {
    try {
      final callable = _functions.httpsCallable('getLandingContent');
      final result = await callable.call<Object?>();
      return LandingContent.fromJson(
        Map<String, dynamic>.from(result.data! as Map),
      );
    } catch (_) {
      // The landing page is pre-auth marketing; never block it on a backend
      // hiccup or cold start. Fall back to the built-in defaults.
      return LandingContent.defaults();
    }
  }

  @override
  Future<List<InvestmentOpportunity>> listOpportunities({
    String? localeCode,
  }) async {
    final callable = _functions.httpsCallable('listMemberOpportunities');
    final result = await callable.call<Object?>(
      localeCode == null ? null : {'locale': localeCode},
    );
    final data = Map<String, dynamic>.from(result.data! as Map);
    final opportunities = data['opportunities'];
    if (opportunities is! List) return const [];

    return opportunities
        .whereType<Map>()
        .map(
          (item) =>
              InvestmentOpportunity.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  @override
  Future<PurchaseOrder> createPurchaseOrder(PurchaseRequest request) async {
    final callable = _functions.httpsCallable('createPurchaseOrder');
    final result = await callable.call<Object?>({
      'opportunityId': request.opportunityId,
      'amountUsd': request.amountUsd,
      'paymentAsset': request.paymentAsset,
    });
    return PurchaseOrder.fromJson(
      Map<String, dynamic>.from(result.data! as Map),
    );
  }

  @override
  Future<PurchaseOrder> submitDepositProof({
    required String orderId,
    required String transactionHash,
    required DepositProofFile proof,
  }) async {
    final proofUrl = await _uploadProof(orderId, proof);
    final callable = _functions.httpsCallable('submitDepositProof');
    final result = await callable.call<Object?>({
      'orderId': orderId,
      'transactionHash': transactionHash.trim(),
      'proofUrl': proofUrl,
    });
    return PurchaseOrder.fromJson(
      Map<String, dynamic>.from(result.data! as Map),
    );
  }

  Future<String> _uploadProof(String orderId, DepositProofFile proof) async {
    final safeName = proof.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '-');
    final reference = _storage.ref(
      'payment-proofs/$orderId/${DateTime.now().millisecondsSinceEpoch}-$safeName',
    );
    await reference.putData(
      Uint8List.fromList(proof.bytes),
      SettableMetadata(
        contentType: proof.contentType,
        customMetadata: {'originalName': proof.name},
      ),
    );
    return reference.getDownloadURL();
  }
}
