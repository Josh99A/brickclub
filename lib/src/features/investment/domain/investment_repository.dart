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

  /// Lock spendable wallet cash into an asset's fixed-return plan. [durationKey]
  /// is one of 'week', 'month', 'year'. Throws if the amount falls outside the
  /// asset's bands or exceeds the wallet balance.
  Future<InvestmentPlanResult> createInvestmentPlan({
    required String assetId,
    required double amountUsd,
    required String durationKey,
  });

  Future<PurchaseOrder> submitDepositProof({
    required String orderId,
    required String transactionHash,
    required DepositProofFile proof,
  });

  /// The signed-in member's most recent in-app notifications (deposit, wallet,
  /// support, referral), newest first.
  Future<List<MemberNotification>> listNotifications();

  /// Marks all of the member's unread notifications as read.
  Future<void> markNotificationsRead();
}
