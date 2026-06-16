import 'investment_models.dart';

abstract interface class InvestmentRepository {
  Future<List<InvestmentOpportunity>> listOpportunities();

  Future<PurchaseOrder> createPurchaseOrder(PurchaseRequest request);
}
