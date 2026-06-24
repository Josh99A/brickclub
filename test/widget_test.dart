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
import 'package:brickclub/src/features/referral/domain/referral_models.dart';
import 'package:brickclub/src/features/referral/domain/referral_repository.dart';
import 'package:brickclub/src/features/support/domain/support_models.dart';
import 'package:brickclub/src/features/support/domain/support_repository.dart';
import 'package:file_picker/file_picker.dart';
// ignore: implementation_imports
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FilePickerPlatform originalFilePicker;
  final authRepository = FakeAuthRepository();
  final adminRepository = FakeAdminRepository();
  final investmentRepository = FakeInvestmentRepository();
  final kycRepository = FakeKycRepository.approved();
  final referralRepository = FakeReferralRepository();
  final supportRepository = FakeSupportRepository();

  setUpAll(() {
    originalFilePicker = FilePickerPlatform.instance;
    FilePickerPlatform.instance = FakeFilePickerPlatform();
  });

  tearDownAll(() {
    FilePickerPlatform.instance = originalFilePicker;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> signIn(WidgetTester tester) async {
    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: kycRepository,
        referralRepository: referralRepository,
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
        referralRepository: referralRepository,
        supportRepository: supportRepository,
        showLandingPage: true,
      ),
    );

    expect(find.text('Own more than\na dream.'), findsOneWidget);
    expect(find.byKey(const ValueKey('install-app')), findsOneWidget);
    // At desktop width the landing page exposes the "Create account" CTA in
    // both the top nav and the hero, so assert at least one is present.
    expect(find.text('Create account'), findsWidgets);
    expect(find.text('Built on investor confidence.'), findsOneWidget);
  });

  testWidgets('mobile startup moves from splash to sign in', (tester) async {
    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: kycRepository,
        referralRepository: referralRepository,
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
        referralRepository: referralRepository,
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
    expect(find.text('Payment methods'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('admin-payments')));
    await tester.pumpAndSettle();
    expect(find.text('Payment methods'), findsWidgets);
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
        referralRepository: referralRepository,
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
        referralRepository: referralRepository,
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
        referralRepository: referralRepository,
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

    expect(find.text('\$11K'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-invest')));
    await tester.pumpAndSettle();
    expect(find.text('5 opportunities'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-wallet')));
    await tester.pumpAndSettle();
    expect(find.text('\$0'), findsOneWidget);

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

  testWidgets('member can control the app theme from settings', (tester) async {
    await signIn(tester);

    await tester.tap(find.byKey(const ValueKey('nav-more')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('profile-settings')),
      120,
    );
    await tester.pumpAndSettle();
    final settingsTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('profile-settings')),
    );
    await tester.tapAt(settingsTopLeft + const Offset(32, 29));
    await tester.pumpAndSettle();

    expect(find.text('Theme'), findsOneWidget);
    expect(find.byKey(const ValueKey('theme-system')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('theme-light')));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('brickclub.themeMode'), 'light');
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
        referralRepository: referralRepository,
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

  testWidgets('admin notifications bell lists and clears alerts', (
    tester,
  ) async {
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
        referralRepository: referralRepository,
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

    await tester.tap(find.byKey(const ValueKey('admin-notifications')));
    await tester.pumpAndSettle();

    expect(find.text('Deposit proof submitted'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('mark-notifications-read')));
    await tester.pumpAndSettle();

    expect(adminRepository.markedNotificationsRead, isTrue);
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
    expect(find.text('Harbor District\nLogistics REIT'), findsOneWidget);
  });

  testWidgets('account page login button returns to sign in', (tester) async {
    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: kycRepository,
        referralRepository: referralRepository,
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
    // A taller surface keeps the invest card's center clear of the bottom
    // navigation bar; on the default 800x600 surface the card center lands on
    // the nav, so tapping it switches tabs instead of opening the detail.
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await signIn(tester);
    await tester.tap(find.byKey(const ValueKey('nav-invest')));
    await tester.pumpAndSettle();

    // InvestmentCard reuses one key across the home and invest tabs (both alive
    // in the IndexedStack shell), so scope to the visible InvestScreen card —
    // otherwise the offstage home card is tapped and navigation never happens.
    await tester.tap(
      find
          .descendant(
            of: find.byType(InvestScreen),
            matching: find.byKey(const ValueKey('investment-card')),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Skyline Heights Income Fund'), findsOneWidget);

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
    await tester.ensureVisible(find.byKey(const ValueKey('confirm-purchase')));
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
    await tester.ensureVisible(find.byKey(const ValueKey('confirm-purchase')));
    await tester.tap(find.byKey(const ValueKey('confirm-purchase')));
    await tester.pumpAndSettle();

    expect(find.text('Proof submitted'), findsOneWidget);
  });

  testWidgets('unapproved members are gated before investing', (tester) async {
    // A taller surface keeps the invest card's center clear of the bottom
    // navigation bar; on the default 800x600 surface the card center lands on
    // the nav, so tapping it switches tabs instead of opening the detail.
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final pendingKycRepository = FakeKycRepository.pending();
    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: pendingKycRepository,
        referralRepository: referralRepository,
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
    // InvestmentCard reuses one key across the home and invest tabs (both alive
    // in the IndexedStack shell), so scope to the visible InvestScreen card —
    // otherwise the offstage home card is tapped and navigation never happens.
    await tester.tap(
      find
          .descendant(
            of: find.byType(InvestScreen),
            matching: find.byKey(const ValueKey('investment-card')),
          )
          .first,
    );
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
        'Enter your phone number in international format, e.g. +12025550190.',
      ),
    );
    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        investmentRepository: investmentRepository,
        kycRepository: pendingKycRepository,
        referralRepository: referralRepository,
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
        'Enter your phone number in international format, e.g. +12025550190.',
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
      email: 'amina@brickclub.com',
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

  @override
  Future<String> sendPhoneVerificationCode(String phoneNumber) async =>
      'verification-id';

  @override
  Future<void> signInWithPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {}
}

class FakeAdminRepository implements AdminRepository {
  final data = const AdminDashboardData(
    users: [
      AdminUser(
        uid: 'admin-1',
        email: 'admin@brickclub.com',
        displayName: 'Joshua Admin',
        disabled: false,
        emailVerified: true,
        admin: true,
        createdAt: null,
        lastSignInAt: null,
      ),
      AdminUser(
        uid: 'member-1',
        email: 'sarah@brickclub.com',
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
        title: 'Skyline Heights',
        location: 'Central Business District',
        type: 'Real estate',
        fundedPercent: 62,
        reviewStatus: 'Verified',
        publishedStatus: 'Live',
      ),
    ],
    paymentOptions: [
      PaymentOption(
        id: 'payment-1',
        type: PaymentMethodType.crypto,
        network: 'Tron',
        assetSymbol: 'USDT',
        walletAddress: '0x71B...8E4',
        qrCodeUrl: 'https://example.com/usdt-qr.png',
        accountDetails: [],
        enabled: true,
        minimumAmount: 100,
      ),
    ],
    depositRequests: [
      AdminDepositRequest(
        id: 'order-1',
        uid: 'member-1',
        opportunityTitle: 'Skyline Heights Income Fund',
        amountUsd: 100,
        paymentNetwork: 'Tron',
        paymentAsset: 'USDT',
        paymentWalletAddress: '0x71B...8E4',
        paymentType: PaymentMethodType.crypto,
        paymentAccountDetails: [],
        transactionHash: '0x1234567890abcdef',
        proofUrl: 'https://example.com/proof.png',
        status: 'proof_submitted',
      ),
    ],
    withdrawalRequests: [
      AdminWithdrawalRequest(
        id: 'withdrawal-1',
        uid: 'member-1',
        userEmail: 'sarah@brickclub.com',
        userDisplayName: 'Sarah Namuli',
        amountUsd: 200,
        feeUsd: 4,
        netAmountUsd: 196,
        destinationAddress: '0x71B...8E4',
        assetSymbol: 'USDT',
        status: 'submitted',
        rejectionReason: '',
        createdAt: '2026-06-17T09:30:00.000Z',
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
        userEmail: 'sarah@brickclub.com',
        userDisplayName: 'Sarah Namuli',
        updatedAt: '2026-06-16T10:00:00.000Z',
      ),
    ],
    withdrawalPolicy: WithdrawalPolicy(
      minimumAmountUsd: 25,
      flatFeeUsd: 1,
      percentageFee: 1.5,
      requiresDestinationWalletVerification: true,
      requiredApprovals: 2,
      processingTime: '1-2 business days',
      enabled: true,
      notes: 'Withdrawals are reviewed by operations.',
    ),
    referralPolicy: ReferralPolicy(
      enabled: true,
      commissionPercent: 5,
      firstInvestmentOnly: false,
    ),
    landingContent: LandingContent(
      targetReturnPercent: 12.4,
      minimumInvestmentUsd: 50,
      settlementPercent: 100,
      showcasePortfolioValueUsd: 5000,
      showcaseAssetName: 'Skyline Heights Income Fund',
    ),
    notifications: [
      AdminNotification(
        id: 'notification-1',
        type: 'deposit_proof_submitted',
        title: 'Deposit proof submitted',
        body: 'Skyline Heights Income Fund proof is ready for verification.',
        read: false,
        createdAt: '2026-06-17T09:30:00.000Z',
      ),
    ],
  );

  @override
  Future<AdminDashboardData> loadDashboard() async => data;

  @override
  Future<void> createAsset(AdminAsset asset) async {}

  @override
  Future<void> createPaymentOption(PaymentOption option) async {}

  @override
  Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    required bool disabled,
    required bool admin,
    bool emailVerified = false,
    String phoneNumber = '',
  }) async {}

  @override
  Future<void> deleteAsset(String id) async {}

  @override
  Future<void> deletePaymentOption(String id) async {}

  @override
  Future<void> deleteUser(String uid) async {}

  @override
  Future<void> setUserAdmin({required String uid, required bool admin}) async {}

  @override
  Future<void> updateAsset(AdminAsset asset) async {}

  @override
  Future<void> updatePaymentOption(PaymentOption option) async {}

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
  }) async {}

  @override
  Future<AdminUserDetail> loadUserDetail(String uid) async {
    return AdminUserDetail(
      user: data.users.firstWhere(
        (user) => user.uid == uid,
        orElse: () => data.users.first,
      ),
      kyc: null,
      portfolio: const AdminUserPortfolio(
        totalInvested: 0,
        totalCurrentValue: 0,
        totalDividends: 0,
        totalProfitLoss: 0,
        overallReturnPercentage: 0,
        holdings: [],
      ),
      orders: const [],
      wallet: const AdminUserWallet(balanceUsd: 0, transactions: []),
    );
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
  }) async {}

  @override
  Future<RentalIncomeDistribution> distributeRentalIncome({
    required String assetId,
    required double totalAmountUsd,
    String note = '',
  }) async => const RentalIncomeDistribution(
    totalAmountUsd: 0,
    distributedUsd: 0,
    recipientCount: 0,
    failedCount: 0,
  );

  @override
  Future<void> approveKycProfile(String uid) async {}

  @override
  Future<void> rejectKycProfile({
    required String uid,
    required String reason,
  }) async {}

  @override
  Future<String> uploadPaymentQrCode(AdminUploadFile file) async =>
      'https://example.com/${file.name}';

  @override
  Future<String> uploadAssetImage(AdminUploadFile file) async =>
      'https://example.com/asset/${file.name}';

  @override
  Future<void> verifyDepositRequest(String id) async {}

  @override
  Future<void> adjustMemberWallet({
    required String uid,
    required double amountUsd,
    required String direction,
    required String reason,
  }) async {}

  @override
  Future<void> rejectDepositRequest({
    required String id,
    required String reason,
  }) async {}

  @override
  Future<void> approveWithdrawalRequest(String id) async {}

  @override
  Future<void> rejectWithdrawalRequest({
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

  @override
  Future<void> updateWithdrawalPolicy(WithdrawalPolicy policy) async {}

  @override
  Future<void> updateReferralPolicy(ReferralPolicy policy) async {}

  @override
  Future<void> updateLandingContent(LandingContent content) async {}

  bool markedNotificationsRead = false;

  @override
  Future<void> markNotificationsRead() async {
    markedNotificationsRead = true;
  }
}

class FakeReferralRepository implements ReferralRepository {
  @override
  Future<ReferralProfile> getReferralProfile() async {
    return const ReferralProfile(
      referralCode: 'BRICK42',
      referralCount: 2,
      totalEarnedUsd: 75,
      commissionPercent: 5,
      referralsEnabled: true,
      commissions: [],
    );
  }
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
      paymentMethods: ['USDT', 'USDC', 'USD Wallet'],
      title: 'Skyline Heights Income Fund',
      location: 'Central Business District',
      minimumInvestment: 100,
      targetReturn: 11.8,
      fundedPercent: 62,
    ),
    InvestmentOpportunity(
      id: 'asset-2',
      assetClass: 'REIT',
      riskLevel: 'Medium',
      paymentMethods: ['USDT', 'USD Wallet'],
      title: 'Harbor District\nLogistics REIT',
      location: 'Income portfolio',
      minimumInvestment: 150,
      targetReturn: 9.6,
      fundedPercent: 41,
    ),
    InvestmentOpportunity(
      id: 'asset-3',
      assetClass: 'ETF',
      riskLevel: 'Low',
      paymentMethods: ['USDC', 'USD Wallet'],
      title: 'Global\nProperty ETF',
      location: 'Diversified fund',
      minimumInvestment: 50,
      targetReturn: 7.4,
      fundedPercent: 78,
    ),
    InvestmentOpportunity(
      id: 'asset-4',
      assetClass: 'Index',
      riskLevel: 'Low',
      paymentMethods: ['BTC', 'USDC'],
      title: 'Metro Core\nIndex',
      location: 'Prime property basket',
      minimumInvestment: 75,
      targetReturn: 8.1,
      fundedPercent: 54,
    ),
    InvestmentOpportunity(
      id: 'asset-5',
      assetClass: 'Real Estate',
      riskLevel: 'High',
      paymentMethods: ['USDT', 'BTC'],
      title: 'Marina Bay\nDevelopment',
      location: 'Growth project',
      minimumInvestment: 200,
      targetReturn: 14.2,
      fundedPercent: 29,
    ),
  ];

  @override
  Future<LandingContent> getLandingContent() async {
    return LandingContent.defaults();
  }

  @override
  Future<MemberDashboardData> loadMemberDashboard() async {
    return const MemberDashboardData(
      portfolioValueUsd: 11000,
      walletBalanceUsd: 0,
      yearReturnPercent: 10.2,
      cryptoRails: ['USDT on Tron', 'USDC on Ethereum'],
      holdings: [
        MemberHolding(
          opportunityId: 'asset-1',
          title: 'Skyline Heights Income Fund',
          assetClass: 'Real Estate',
          brickShares: 32.45,
          valueUsd: 6800,
          returnPercent: 12.1,
        ),
        MemberHolding(
          opportunityId: 'asset-2',
          title: 'Harbor District Logistics REIT',
          assetClass: 'REIT',
          brickShares: 18.72,
          valueUsd: 4200,
          returnPercent: 7.3,
        ),
      ],
      activity: [
        MemberActivity(
          title: 'Deposit verified',
          subtitle: 'Skyline Heights Income Fund',
          value: '\$6,800',
          status: 'deposit_verified',
        ),
      ],
      allocation: [
        MemberAllocation(label: 'Real Estate', percent: .62),
        MemberAllocation(label: 'REIT', percent: .38),
      ],
      chartValues: [0, 0, 2500, 6800, 9000, 11000],
      chartLabels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    );
  }

  @override
  Future<PurchaseOrder> createPurchaseOrder(PurchaseRequest request) async {
    final opportunity = opportunities.firstWhere(
      (item) => item.id == request.opportunityId,
    );
    return PurchaseOrder(
      id: 'order-1',
      opportunityId: opportunity.id,
      opportunityTitle: opportunity.title,
      amountUsd: request.amountUsd,
      paymentNetwork: 'Tron',
      paymentAsset: request.paymentAsset,
      paymentWalletAddress: '0x71B...8E4',
      paymentQrCodeUrl: '',
      quoteAmount: 100,
      networkFee: 1,
      status: 'pending_payment',
      expiresAt: '2026-06-16T10:00:00.000Z',
    );
  }

  @override
  Future<List<InvestmentOpportunity>> listOpportunities({
    String? localeCode,
  }) async =>
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
      opportunityTitle: 'Skyline Heights Income Fund',
      amountUsd: 100,
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

  @override
  Future<List<MemberNotification>> listNotifications() async => const [];

  @override
  Future<void> markNotificationsRead() async {}
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
