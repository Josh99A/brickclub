import 'investment_models.dart';

abstract interface class InvestmentRepository {
  Future<List<InvestmentOpportunity>> listOpportunities();

  Future<PurchaseOrder> createPurchaseOrder(PurchaseRequest request);

  Future<PurchaseOrder> submitDepositProof({
    required String orderId,
    required String transactionHash,
    required DepositProofFile proof,
  });
}
