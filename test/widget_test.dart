import 'dart:typed_data';

import 'package:brickclub/src/app/brickclub_app.dart';
import 'package:brickclub/src/features/admin/domain/admin_models.dart';
import 'package:brickclub/src/features/admin/domain/admin_repository.dart';
import 'package:brickclub/src/features/auth/domain/auth_credentials.dart';
import 'package:brickclub/src/features/auth/domain/auth_repository.dart';
import 'package:brickclub/src/features/investment/domain/investment_models.dart';
import 'package:brickclub/src/features/investment/domain/investment_repository.dart';
import 'package:brickclub/src/features/kyc/domain/kyc_models.dart';
import 'package:brickclub/src/features/kyc/domain/kyc_repository.dart';
import 'package:brickclub/src/features/support/domain/support_models.dart';
import 'package:brickclub/src/features/support/domain/support_repository.dart';
import 'package:file_picker/file_picker.dart';
// ignore: implementation_imports
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FilePickerPlatform originalFilePicker;
  final authRepository = FakeAuthRepository();
  final adminRepository = FakeAdminRepository();
  final investmentRepository = FakeInvestmentRepository();
  final kycRepository = FakeKycRepository.approved();
  final supportRepository = FakeSupportRepository();

  setUpAll(() {
    originalFilePicker = FilePickerPlatform.instance;
    FilePickerPlatform.instance = FakeFilePickerPlatform();
  });

  tearDownAll(() {
    FilePickerPlatform.instance = originalFilePicker;
  });

  Future<void> signIn(WidgetTester tester) async {
    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: kycRepository,
        supportRepository: supportRepository,
        showLandingPage: true,
      ),
    );
    expect(find.text('Own more than\na dream.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('landing-sign-in')));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('sign-in')));
    await tester.pumpAndSettle();
  }

  testWidgets('landing page exposes install and account CTAs', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: kycRepository,
        supportRepository: supportRepository,
        showLandingPage: true,
      ),
    );

    expect(find.text('Own more than\na dream.'), findsOneWidget);
    expect(find.byKey(const ValueKey('install-app')), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Built on investor confidence.'), findsOneWidget);
  });

  testWidgets('mobile startup moves from splash to sign in', (tester) async {
    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: kycRepository,
        supportRepository: supportRepository,
        showLandingPage: false,
        splashDuration: Duration.zero,
      ),
    );

    expect(find.text('Property-backed ownership'), findsOneWidget);
    expect(find.text('Own more than\na dream.'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byKey(const ValueKey('create-account-link')), findsOneWidget);
    expect(find.text('Own more than\na dream.'), findsNothing);
  });

  testWidgets('admin sign in opens the operations dashboard', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: kycRepository,
        supportRepository: supportRepository,
        showLandingPage: true,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('landing-sign-in')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('admin-access')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('sign-in')));
    await tester.pumpAndSettle();

    expect(find.text('Admin overview'), findsOneWidget);
    expect(find.text('Total users'), findsOneWidget);
    expect(find.text('Recent crypto payments'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('admin-crypto payments')));
    await tester.pumpAndSettle();
    expect(find.text('Crypto payments'), findsWidgets);
    expect(find.text('0x71B...8E4'), findsOneWidget);
  });

  testWidgets('sign in failure shows an inline frontend error', (tester) async {
    final failingAuthRepository = FakeAuthRepository(
      signInError: const AuthValidationException('Enter your password.'),
    );

    await tester.pumpWidget(
      BrickClubApp(
        authRepository: failingAuthRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: kycRepository,
        supportRepository: supportRepository,
        showLandingPage: true,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('landing-sign-in')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('sign-in')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('auth-message')), findsOneWidget);
    expect(find.text('Enter your password.'), findsWidgets);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('non-admin sign in shows an inline frontend error', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final memberAuthRepository = FakeAuthRepository(isAdmin: false);

    await tester.pumpWidget(
      BrickClubApp(
        authRepository: memberAuthRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: kycRepository,
        supportRepository: supportRepository,
        showLandingPage: true,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('landing-sign-in')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('admin-access')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('sign-in')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('auth-message')), findsOneWidget);
    expect(find.text('This account does not have admin access.'), findsWidgets);
    expect(find.text('Admin sign in'), findsOneWidget);
  });

  testWidgets('sign up failure shows an inline frontend error', (tester) async {
    final failingAuthRepository = FakeAuthRepository(
      createAccountError: const AuthValidationException(
        'Confirm your password.',
      ),
    );

    await tester.pumpWidget(
      BrickClubApp(
        authRepository: failingAuthRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: kycRepository,
        supportRepository: supportRepository,
        showLandingPage: true,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('landing-sign-in')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('create-account-link')),
    );
    await tester.tap(find.byKey(const ValueKey('create-account-link')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('create-account-submit')),
    );
    await tester.tap(find.byKey(const ValueKey('create-account-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('auth-message')), findsOneWidget);
    expect(find.text('Confirm your password.'), findsWidgets);
    expect(find.text('Create account'), findsWidgets);
  });

  testWidgets('matches the BrickClub authenticated navigation', (tester) async {
    await signIn(tester);

    expect(find.text('UGX 18.6M'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-invest')));
    await tester.pumpAndSettle();
    expect(find.text('1 opportunities'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-wallet')));
    await tester.pumpAndSettle();
    expect(find.text('UGX 4.2M'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-portfolio')));
    await tester.pumpAndSettle();
    expect(find.text('Allocation'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-more')));
    await tester.pumpAndSettle();
    expect(find.text('Amina Kato'), findsOneWidget);
  });

  testWidgets('profile header button opens the profile page', (tester) async {
    await signIn(tester);

    await tester.tap(find.byKey(const ValueKey('profile-header-button')));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Amina Kato'), findsOneWidget);
  });

  testWidgets('member can open support and create a request', (tester) async {
    await signIn(tester);

    await tester.tap(find.byKey(const ValueKey('nav-more')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('profile-support')),
      120,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('profile-support')));
    await tester.pumpAndSettle();

    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Wallet transfer delayed'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('new-support-ticket')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('support-subject')),
      'KYC review',
    );
    await tester.enterText(
      find.byKey(const ValueKey('support-message')),
      'Can you check my KYC documents?',
    );
    await tester.tap(find.byKey(const ValueKey('send-support-message')));
    await tester.pumpAndSettle();

    expect(supportRepository.createdSubject, 'KYC review');
    expect(supportRepository.createdMessage, 'Can you check my KYC documents?');
  });

  testWidgets('admin support section lists tickets', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: kycRepository,
        supportRepository: supportRepository,
        showLandingPage: true,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('landing-sign-in')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('admin-access')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('sign-in')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('admin-support')));
    await tester.pumpAndSettle();

    expect(find.text('Support conversations'), findsOneWidget);
    expect(find.text('Wallet transfer delayed'), findsOneWidget);
  });

  testWidgets('investment filters apply to the opportunities list', (
    tester,
  ) async {
    await signIn(tester);
    await tester.tap(find.byKey(const ValueKey('nav-invest')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('REIT'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('show-brickshares')));
    await tester.pumpAndSettle();

    expect(find.text('1 opportunities'), findsOneWidget);
    expect(find.text('Bugolobi\nLogistics REIT'), findsOneWidget);
  });

  testWidgets('account page login button returns to sign in', (tester) async {
    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: kycRepository,
        supportRepository: supportRepository,
        showLandingPage: false,
        splashDuration: Duration.zero,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('create-account-link')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('create-account-link')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('account-login-button')),
    );
    await tester.tap(find.byKey(const ValueKey('account-login-button')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('investment purchase flow reaches settlement success', (
    tester,
  ) async {
    await signIn(tester);
    await tester.tap(find.byKey(const ValueKey('nav-invest')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('investment-card')).first);
    await tester.pumpAndSettle();
    expect(find.text('Kololo Heights Income Fund'), findsOneWidget);

    await tester.drag(
      find.descendant(
        of: find.byType(DetailScreen),
        matching: find.byType(SingleChildScrollView),
      ),
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('invest-with-crypto')));
    await tester.pumpAndSettle();
    expect(find.text('Confirm funding'), findsOneWidget);

    await tester.drag(
      find.descendant(
        of: find.byType(PaymentScreen),
        matching: find.byType(SingleChildScrollView),
      ),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-purchase')));
    await tester.pumpAndSettle();
    expect(find.text('Deposit instructions'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('transaction-hash')),
      '0x1234567890abcdef',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('payment-proof')));
    await tester.tap(find.byKey(const ValueKey('payment-proof')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-purchase')));
    await tester.pumpAndSettle();

    expect(find.text('Proof submitted'), findsOneWidget);
  });

  testWidgets('unapproved members are gated before investing', (tester) async {
    final pendingKycRepository = FakeKycRepository.pending();
    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: pendingKycRepository,
        supportRepository: supportRepository,
        showLandingPage: true,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('landing-sign-in')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('sign-in')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-invest')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('investment-card')).first);
    await tester.pumpAndSettle();
    await tester.drag(
      find.descendant(
        of: find.byType(DetailScreen),
        matching: find.byType(SingleChildScrollView),
      ),
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('invest-with-crypto')));
    await tester.pumpAndSettle();

    expect(find.text('Complete KYC first'), findsOneWidget);
    expect(find.byKey(const ValueKey('start-kyc-gate')), findsOneWidget);
  });

  testWidgets('KYC phone errors appear inline with a useful message', (
    tester,
  ) async {
    final pendingKycRepository = FakeKycRepository.pending(
      phoneError: const KycValidationException(
        'Enter your phone number in international format, e.g. +256774224734.',
      ),
    );
    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: pendingKycRepository,
        supportRepository: supportRepository,
        showLandingPage: true,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('landing-sign-in')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('sign-in')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('kyc-status-cta')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('kyc-phone')),
      '0774224734',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('send-phone-code')));
    await tester.tap(find.byKey(const ValueKey('send-phone-code')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('kyc-message')), findsOneWidget);
    expect(
      find.text(
        'Enter your phone number in international format, e.g. +256774224734.',
      ),
      findsWidgets,
    );
  });
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.signInError,
    this.createAccountError,
    this.isAdmin = true,
  });

  final Object? signInError;
  final Object? createAccountError;
  final bool isAdmin;

  @override
  Future<void> createAccount(SignUpCredentials credentials) async {
    final error = createAccountError;
    if (error != null) {
      throw error;
    }
  }

  @override
  SignedInUserDetails? currentUserDetails() {
    return const SignedInUserDetails(
      displayName: 'Amina Kato',
      email: 'amina@brickclub.ug',
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<bool> currentUserIsAdmin() async => isAdmin;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signIn(SignInCredentials credentials) async {
    final error = signInError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> signInWithGoogle() async {}
}

class FakeAdminRepository implements AdminRepository {
  final data = const AdminDashboardData(
    users: [
      AdminUser(
        uid: 'admin-1',
        email: 'admin@brickclub.ug',
        displayName: 'Joshua Admin',
        disabled: false,
        emailVerified: true,
        admin: true,
        createdAt: null,
        lastSignInAt: null,
      ),
      AdminUser(
        uid: 'member-1',
        email: 'sarah@brickclub.ug',
        displayName: 'Sarah Namuli',
        disabled: false,
        emailVerified: true,
        admin: false,
        createdAt: null,
        lastSignInAt: null,
      ),
    ],
    assets: [
      AdminAsset(
        id: 'asset-1',
        title: 'Kololo Heights',
        location: 'Kampala',
        type: 'Real estate',
        fundedPercent: 62,
        reviewStatus: 'Verified',
        publishedStatus: 'Live',
      ),
    ],
    cryptoPaymentOptions: [
      CryptoPaymentOption(
        id: 'payment-1',
        network: 'Tron',
        assetSymbol: 'USDT',
        walletAddress: '0x71B...8E4',
        qrCodeUrl: 'https://example.com/usdt-qr.png',
        enabled: true,
        minimumAmount: 100,
      ),
    ],
    depositRequests: [
      AdminDepositRequest(
        id: 'order-1',
        uid: 'member-1',
        opportunityTitle: 'Kololo Heights Income Fund',
        amountUgx: 250000,
        paymentNetwork: 'Tron',
        paymentAsset: 'USDT',
        paymentWalletAddress: '0x71B...8E4',
        transactionHash: '0x1234567890abcdef',
        proofUrl: 'https://example.com/proof.png',
        status: 'proof_submitted',
      ),
    ],
    supportTickets: [
      AdminSupportTicket(
        id: 'support-1',
        uid: 'member-1',
        subject: 'Wallet transfer delayed',
        status: 'waiting_for_admin',
        messageCount: 1,
        latestMessage: 'My wallet transfer is still pending.',
        userEmail: 'sarah@brickclub.ug',
        userDisplayName: 'Sarah Namuli',
        updatedAt: '2026-06-16T10:00:00.000Z',
      ),
    ],
  );

  @override
  Future<AdminDashboardData> loadDashboard() async => data;

  @override
  Future<void> createAsset(AdminAsset asset) async {}

  @override
  Future<void> createCryptoPaymentOption(CryptoPaymentOption option) async {}

  @override
  Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    required bool disabled,
    required bool admin,
  }) async {}

  @override
  Future<void> deleteAsset(String id) async {}

  @override
  Future<void> deleteCryptoPaymentOption(String id) async {}

  @override
  Future<void> deleteUser(String uid) async {}

  @override
  Future<void> setUserAdmin({required String uid, required bool admin}) async {}

  @override
  Future<void> updateAsset(AdminAsset asset) async {}

  @override
  Future<void> updateCryptoPaymentOption(CryptoPaymentOption option) async {}

  @override
  Future<void> updateUser({
    required String uid,
    required String email,
    required String displayName,
    required bool disabled,
    required bool admin,
    String? password,
  }) async {}

  @override
  Future<String> uploadCryptoPaymentQrCode(AdminUploadFile file) async =>
      'https://example.com/${file.name}';

  @override
  Future<void> verifyDepositRequest(String id) async {}

  @override
  Future<void> rejectDepositRequest({
    required String id,
    required String reason,
  }) async {}

  @override
  Future<void> replyToSupportTicket({
    required String id,
    required String message,
  }) async {}

  @override
  Future<void> closeSupportTicket(String id) async {}
}

class FakeSupportRepository implements SupportRepository {
  String? createdSubject;
  String? createdMessage;
  String? replyTicketId;
  String? replyMessage;

  @override
  Future<void> createTicket({
    required String subject,
    required String message,
  }) async {
    createdSubject = subject;
    createdMessage = message;
  }

  @override
  Future<void> replyToTicket({
    required String ticketId,
    required String message,
  }) async {
    replyTicketId = ticketId;
    replyMessage = message;
  }

  @override
  Stream<List<SupportTicket>> watchMyTickets() {
    return Stream.value(const [
      SupportTicket(
        id: 'support-1',
        uid: 'member-1',
        subject: 'Wallet transfer delayed',
        status: SupportTicketStatus.waitingForAdmin,
        createdAt: null,
        updatedAt: null,
        messages: [
          SupportMessage(
            id: 'message-1',
            sender: SupportMessageSender.member,
            body: 'My wallet transfer is still pending.',
            createdAt: null,
          ),
        ],
      ),
    ]);
  }
}

class FakeInvestmentRepository implements InvestmentRepository {
  static const opportunities = [
    InvestmentOpportunity(
      id: 'asset-1',
      assetClass: 'Real Estate',
      riskLevel: 'Medium',
      paymentMethods: ['USDT', 'USDC', 'UGX Wallet'],
      title: 'Kololo Heights Income Fund',
      location: 'Kampala Central',
      minimumInvestment: 250000,
      targetReturn: 11.8,
      fundedPercent: 62,
    ),
    InvestmentOpportunity(
      id: 'asset-2',
      assetClass: 'REIT',
      riskLevel: 'Medium',
      paymentMethods: ['USDT', 'UGX Wallet'],
      title: 'Bugolobi\nLogistics REIT',
      location: 'Income portfolio',
      minimumInvestment: 500000,
      targetReturn: 9.6,
      fundedPercent: 41,
    ),
    InvestmentOpportunity(
      id: 'asset-3',
      assetClass: 'ETF',
      riskLevel: 'Low',
      paymentMethods: ['USDC', 'UGX Wallet'],
      title: 'East Africa\nProperty ETF',
      location: 'Diversified fund',
      minimumInvestment: 150000,
      targetReturn: 7.4,
      fundedPercent: 78,
    ),
    InvestmentOpportunity(
      id: 'asset-4',
      assetClass: 'Index',
      riskLevel: 'Low',
      paymentMethods: ['BTC', 'USDC'],
      title: 'Kampala Core\nIndex',
      location: 'Prime property basket',
      minimumInvestment: 200000,
      targetReturn: 8.1,
      fundedPercent: 54,
    ),
    InvestmentOpportunity(
      id: 'asset-5',
      assetClass: 'Real Estate',
      riskLevel: 'High',
      paymentMethods: ['USDT', 'BTC'],
      title: 'Entebbe Bay\nDevelopment',
      location: 'Growth project',
      minimumInvestment: 750000,
      targetReturn: 14.2,
      fundedPercent: 29,
    ),
  ];

  @override
  Future<PurchaseOrder> createPurchaseOrder(PurchaseRequest request) async {
    final opportunity = opportunities.firstWhere(
      (item) => item.id == request.opportunityId,
    );
    return PurchaseOrder(
      id: 'order-1',
      opportunityId: opportunity.id,
      opportunityTitle: opportunity.title,
      amountUgx: request.amountUgx,
      paymentNetwork: 'Tron',
      paymentAsset: request.paymentAsset,
      paymentWalletAddress: '0x71B...8E4',
      paymentQrCodeUrl: '',
      quoteAmount: 67.57,
      networkFee: 1,
      status: 'pending_payment',
      expiresAt: '2026-06-16T10:00:00.000Z',
    );
  }

  @override
  Future<List<InvestmentOpportunity>> listOpportunities() async =>
      opportunities;

  @override
  Future<PurchaseOrder> submitDepositProof({
    required String orderId,
    required String transactionHash,
    required DepositProofFile proof,
  }) async {
    return const PurchaseOrder(
      id: 'order-1',
      opportunityId: 'asset-1',
      opportunityTitle: 'Kololo Heights Income Fund',
      amountUgx: 250000,
      paymentNetwork: 'Tron',
      paymentAsset: 'USDT',
      paymentWalletAddress: '0x71B...8E4',
      paymentQrCodeUrl: '',
      quoteAmount: 67.57,
      networkFee: 1,
      status: 'proof_submitted',
      expiresAt: '2026-06-16T10:00:00.000Z',
      transactionHash: '0x1234567890abcdef',
      proofUrl: 'https://example.com/proof.png',
    );
  }
}

class FakeKycRepository implements KycRepository {
  FakeKycRepository.approved({this.phoneError})
    : profile = const KycProfile(
        status: KycStatus.approved,
        emailVerified: true,
        phoneVerified: true,
        fullLegalName: 'Awule Joshua',
      );

  FakeKycRepository.pending({this.phoneError})
    : profile = const KycProfile(
        status: KycStatus.notStarted,
        emailVerified: false,
        phoneVerified: false,
      );

  final KycProfile profile;
  final Object? phoneError;

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPhoneVerificationCode(String phoneNumber) async {
    final error = phoneError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> submit(KycSubmission submission) async {}

  @override
  Stream<KycProfile> watchProfile() => Stream.value(profile);
}

class FakeFilePickerPlatform extends FilePickerPlatform {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    bool cancelUploadOnWindowBlur = true,
  }) async {
    return FilePickerResult([
      PlatformFile(
        name: 'proof.png',
        size: 3,
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
    ]);
  }
}
