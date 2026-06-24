import '../../admin/domain/admin_models.dart' show LandingContent;
import 'investment_models.dart';

abstract interface class InvestmentRepository {
  Future<MemberDashboardData> loadMemberDashboard();

  /// Public marketing figures for the pre-auth landing page. Callable without
  /// authentication; resolves to [LandingContent.defaults] on any failure so
  /// the landing page always renders immediately.
  Future<LandingContent> getLandingContent();

  Future<List<InvestmentOpportunity>> listOpportunities({String? localeCode});

  Future<PurchaseOrder> createPurchaseOrder(PurchaseRequest request);

  Future<PurchaseOrder> submitDepositProof({
    required String orderId,
    required String transactionHash,
    required DepositProofFile proof,
  });
}
