import 'package:cloud_functions/cloud_functions.dart';

import '../domain/investment_models.dart';
import '../domain/investment_repository.dart';

class FirebaseInvestmentRepository implements InvestmentRepository {
  FirebaseInvestmentRepository({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<List<InvestmentOpportunity>> listOpportunities() async {
    final callable = _functions.httpsCallable('listMemberOpportunities');
    final result = await callable.call<Object?>();
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
      'amountUgx': request.amountUgx,
      'paymentAsset': request.paymentAsset,
    });
    return PurchaseOrder.fromJson(
      Map<String, dynamic>.from(result.data! as Map),
    );
  }
}
