import 'package:brickclub/src/app/brickclub_app.dart';
import 'package:brickclub/src/features/admin/domain/admin_models.dart';
import 'package:brickclub/src/features/admin/domain/admin_repository.dart';
import 'package:brickclub/src/features/auth/domain/auth_credentials.dart';
import 'package:brickclub/src/features/auth/domain/auth_repository.dart';
import 'package:brickclub/src/features/kyc/domain/kyc_models.dart';
import 'package:brickclub/src/features/kyc/domain/kyc_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final authRepository = FakeAuthRepository();
  final adminRepository = FakeAdminRepository();
  final kycRepository = FakeKycRepository.approved();

  Future<void> signIn(WidgetTester tester) async {
    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        kycRepository: kycRepository,
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
        kycRepository: kycRepository,
        showLandingPage: true,
      ),
    );

    expect(find.text('Own more than\na dream.'), findsOneWidget);
    expect(find.byKey(const ValueKey('install-app')), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Built on investor confidence.'), findsOneWidget);
  });

  testWidgets('mobile startup moves from splash to signup', (tester) async {
    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        kycRepository: kycRepository,
        showLandingPage: false,
        splashDuration: Duration.zero,
      ),
    );

    expect(find.text('Property-backed ownership'), findsOneWidget);
    expect(find.text('Own more than\na dream.'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsWidgets);
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
        kycRepository: kycRepository,
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

  testWidgets('matches the BrickClub authenticated navigation', (tester) async {
    await signIn(tester);

    expect(find.text('UGX 18.6M'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-invest')));
    await tester.pumpAndSettle();
    expect(find.text('12 opportunities'), findsOneWidget);

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
    expect(find.text('Purchase submitted'), findsOneWidget);
  });

  testWidgets('unapproved members are gated before investing', (tester) async {
    final pendingKycRepository = FakeKycRepository.pending();
    await tester.pumpWidget(
      BrickClubApp(
        authRepository: authRepository,
        adminRepository: adminRepository,
        kycRepository: pendingKycRepository,
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
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> createAccount(SignUpCredentials credentials) async {}

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
  Future<bool> currentUserIsAdmin() async => true;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signIn(SignInCredentials credentials) async {}
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
        enabled: true,
        minimumAmount: 100,
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
}

class FakeKycRepository implements KycRepository {
  FakeKycRepository.approved()
    : profile = const KycProfile(
        status: KycStatus.approved,
        emailVerified: true,
        phoneVerified: true,
        fullLegalName: 'Awule Joshua',
      );

  FakeKycRepository.pending()
    : profile = const KycProfile(
        status: KycStatus.notStarted,
        emailVerified: false,
        phoneVerified: false,
      );

  final KycProfile profile;

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPhoneVerificationCode(String phoneNumber) async {}

  @override
  Future<void> submit(KycSubmission submission) async {}

  @override
  Stream<KycProfile> watchProfile() => Stream.value(profile);
}
