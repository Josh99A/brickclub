// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => 'Language';

  @override
  String get languageScreenTitle => 'Language';

  @override
  String get languageHeading => 'Display language';

  @override
  String get languageDescription =>
      'Choose the language BrickClub uses on this device.';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonEmailHint => 'you@example.com';

  @override
  String get commonPassword => 'Password';

  @override
  String get authConnecting => 'Connecting...';

  @override
  String get signInWelcomeTitle => 'Welcome back';

  @override
  String get signInAdminTitle => 'Admin sign in';

  @override
  String get signInMemberSubtitle => 'Continue to your BrickShares portfolio.';

  @override
  String get signInAdminSubtitle =>
      'Access user, asset, and crypto payment operations.';

  @override
  String get signInPasswordHint => 'Enter your password';

  @override
  String get signInForgotPassword => 'Forgot password?';

  @override
  String get signInProgress => 'Signing in...';

  @override
  String get signInOpenAdminDashboard => 'Open admin dashboard';

  @override
  String get signInSubmit => 'Sign in securely';

  @override
  String get signInGoogleAdmin => 'Continue as admin with Google';

  @override
  String get signInGoogle => 'Continue with Google';

  @override
  String get signInPhone => 'Continue with phone';

  @override
  String get signInUseMember => 'Use member sign in';

  @override
  String get signInUseAdmin => 'Sign in as an admin';

  @override
  String get signInCreateAccount => 'Create a BrickClub account';

  @override
  String get signInGoogleNoAdmin =>
      'This Google account does not have admin access.';

  @override
  String get signInNoAdmin => 'This account does not have admin access.';

  @override
  String get signInResetSent => 'Password reset instructions sent';

  @override
  String get signInStoryTitle => 'Ownership, made\nmore accessible.';

  @override
  String get signInStoryBody =>
      'Review verified opportunities, settle with confidence, and keep every asset in view.';

  @override
  String get signUpIntro =>
      'Create your BrickShares account. Wallet verification and KYC come next.';

  @override
  String get signUpCreateAccount => 'Create account';

  @override
  String get signUpLegalNamesHint =>
      'Use your legal names exactly as they appear on your ID.';

  @override
  String get signUpFirstName => 'First name';

  @override
  String get signUpFirstNameHint => 'Legal first name';

  @override
  String get signUpLastName => 'Last name';

  @override
  String get signUpLastNameHint => 'Legal last name';

  @override
  String get signUpPasswordHint => 'Create a password';

  @override
  String get signUpConfirmPassword => 'Confirm password';

  @override
  String get signUpConfirmPasswordHint => 'Confirm your password';

  @override
  String get signUpAgree =>
      'I agree to terms, risk disclosures, and settlement confirmation notices.';

  @override
  String get signUpProgress => 'Creating account...';

  @override
  String get signUpGoogle => 'Sign up with Google';

  @override
  String get signUpDisclosure =>
      'Financial actions require KYC and verified wallet setup after account creation.';

  @override
  String get signUpHaveAccount => 'Already have an account? Sign in';

  @override
  String get phoneTitle => 'Sign in with phone';

  @override
  String get phoneOtpTitle => 'Enter verification code';

  @override
  String get phoneSubtitle =>
      'Enter your phone number with country code (e.g. +1 415 555 2671).';

  @override
  String phoneOtpSubtitle(String phone) {
    return 'We sent a 6-digit code to $phone.';
  }

  @override
  String get phoneHint => '+1 415 555 2671';

  @override
  String get phoneCodeHint => '000000';

  @override
  String get phoneSendingCode => 'Sending code…';

  @override
  String get phoneSendCode => 'Send verification code';

  @override
  String get phoneVerifying => 'Verifying…';

  @override
  String get phoneConfirmCode => 'Confirm code';

  @override
  String get phoneUseDifferentNumber => 'Use a different number';

  @override
  String get installIosTitle => 'Install on iPhone or iPad';

  @override
  String get installIosIntro =>
      'Add BrickClub to your home screen straight from Safari — no App Store needed.';

  @override
  String get installIosStep1 => 'Tap the Share button in Safari\'s toolbar.';

  @override
  String get installIosStep2 => 'Scroll down and choose “Add to Home Screen”.';

  @override
  String get installIosStep3 =>
      'Tap “Add” — BrickClub lands on your home screen.';

  @override
  String get installAndroidTitle => 'Install on Android';

  @override
  String get installAndroidIntro =>
      'Add BrickClub to your device in a couple of taps from your browser.';

  @override
  String get installAndroidStep1 =>
      'Open your browser menu (⋮ in the top corner).';

  @override
  String get installAndroidStep2 =>
      'Tap “Install app” or “Add to Home screen”.';

  @override
  String get installAndroidStep3 =>
      'Confirm — BrickClub appears in your app drawer.';

  @override
  String get installDesktopTitle => 'Install on desktop';

  @override
  String get installDesktopIntro =>
      'Install BrickClub as an app from Chrome or Edge.';

  @override
  String get installDesktopStep1 =>
      'Click the install icon in the address bar, or open the browser menu.';

  @override
  String get installDesktopStep2 =>
      'Choose “Install” to launch BrickClub in its own window.';

  @override
  String get installGotIt => 'Got it';

  @override
  String get installAlready => 'BrickClub is already installed on this device.';

  @override
  String get installInstalling => 'Installing BrickClub on your device…';

  @override
  String get installDismissed => 'Install dismissed. You can install any time.';

  @override
  String get navFeatures => 'Features';

  @override
  String get navHowItWorks => 'How it works';

  @override
  String get navTestimonials => 'Testimonials';

  @override
  String get landingSignIn => 'Sign in';

  @override
  String get landingSignUp => 'Sign up';

  @override
  String get landingJoin => 'Join';

  @override
  String get landingCreateAccount => 'Create account';

  @override
  String get heroTitle => 'Own more than\na dream.';

  @override
  String get heroBody =>
      'Build real ownership through verified property-backed BrickShares, with transparent performance and trusted crypto settlement from one secure app.';

  @override
  String get heroInstall => 'Install the app';

  @override
  String get heroExplore => 'Explore BrickShares';

  @override
  String get proofVerifiedAssets => 'Verified assets';

  @override
  String get proofTrustedSettlement => 'Trusted settlement';

  @override
  String get proofClearPerformance => 'Clear performance';

  @override
  String get previewPortfolioValue => 'Portfolio value';

  @override
  String get previewMinimum => 'Minimum';

  @override
  String get previewTargetReturn => 'Target return';

  @override
  String get heroCardTargetReturn => 'Target annual return';

  @override
  String get assetVerifiedBadge => 'VERIFIED ASSET';

  @override
  String get assetSampleDescription => 'Income-producing residential property';

  @override
  String get assetFunded => 'Funded';

  @override
  String get trustDueDiligence => 'PROPERTY DUE DILIGENCE';

  @override
  String get trustKycVerified => 'KYC VERIFIED MEMBERS';

  @override
  String get trustUsdtSettlement => 'USDT SETTLEMENT';

  @override
  String get trustOwnershipRecords => 'CLEAR OWNERSHIP RECORDS';

  @override
  String get statTargetReturn => 'Average target return';

  @override
  String get statMinimum => 'Minimum to start';

  @override
  String get statSettlement => 'On-chain settlement';

  @override
  String get statVisibility => 'Portfolio visibility';

  @override
  String get howTitle => 'From signup to ownership.';

  @override
  String get howSubtitle =>
      'A clear path designed for investors who want confidence at every step.';

  @override
  String get howStep1Title => 'Create and verify';

  @override
  String get howStep1Body =>
      'Open your account, complete KYC, and connect a verified wallet.';

  @override
  String get howStep2Title => 'Choose BrickShares';

  @override
  String get howStep2Body =>
      'Review verified assets, target returns, risks, and ownership terms.';

  @override
  String get howStep3Title => 'Fund and track';

  @override
  String get howStep3Body =>
      'Settle securely with supported crypto and monitor your portfolio.';

  @override
  String get featuresTitle => 'Built for clarity,\nnot speculation.';

  @override
  String get featuresBody =>
      'Every opportunity brings the important information forward: ownership structure, asset verification, target returns, risks, funding network, and settlement status.';

  @override
  String get feature1 => 'Verified asset documentation';

  @override
  String get feature2 => 'Transparent crypto quotes and network fees';

  @override
  String get feature3 => 'Confirmation before every financial action';

  @override
  String get testimonialsTitle => 'Built on investor confidence.';

  @override
  String get testimonialsSubtitle =>
      'What early BrickClub members value most about the experience.';

  @override
  String get testimonial1Quote =>
      'BrickClub makes the important details easy to understand. I know what I own, how it is performing, and what happens before I fund.';

  @override
  String get testimonial1Role => 'Entrepreneur, London';

  @override
  String get testimonial2Quote =>
      'The verification and confirmation flow gave me confidence. It feels like a serious investment platform, not another crypto shortcut.';

  @override
  String get testimonial2Role => 'Product lead, Singapore';

  @override
  String get testimonial3Quote =>
      'I can start at a practical amount and still get access to assets I would normally only watch from the outside.';

  @override
  String get testimonial3Role => 'Consultant, Dubai';

  @override
  String get ctaBadge => 'GET STARTED IN MINUTES';

  @override
  String get ctaTitle => 'Your next asset can start here.';

  @override
  String get ctaBody =>
      'Install BrickClub, create your account, and explore verified BrickShares built for long-term ownership.';

  @override
  String get ctaHaveAccount => 'I already have an account';

  @override
  String get ctaSecureKyc => 'Secure KYC';

  @override
  String get ctaFreeToBrowse => 'Free to browse';

  @override
  String get ctaVerifiedOnly => 'Verified assets only';

  @override
  String get footerCopyright => '© 2026 BrickClub';

  @override
  String get commonViewAll => 'View all';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get navInvest => 'Invest';

  @override
  String get navWallet => 'Wallet';

  @override
  String get navPortfolio => 'Portfolio';

  @override
  String get navProfile => 'Profile';

  @override
  String get kycGateTitle => 'Complete KYC first';

  @override
  String kycGateBody(String status) {
    return 'Status: $status. Purchases, withdrawals, wallet changes, and crypto settlement unlock after approval.';
  }

  @override
  String get kycGateViewStatus => 'View KYC status';

  @override
  String get kycGateComplete => 'Complete KYC';

  @override
  String get homeFeaturedOpportunity => 'Featured opportunity';

  @override
  String get homeNoLiveTitle => 'No live BrickShares yet';

  @override
  String get homeNoLiveBody => 'Published, verified assets will appear here.';

  @override
  String get homeViewInvest => 'View invest';

  @override
  String get homeYourHoldings => 'Your holdings';

  @override
  String get homeRecentActivity => 'Recent activity';

  @override
  String get holdingsEmptyTitle => 'No holdings yet';

  @override
  String get holdingsEmptyHome =>
      'Verified deposits will appear here as BrickShares.';

  @override
  String get activityEmptyTitle => 'No activity yet';

  @override
  String get activityEmptyBody =>
      'Deposit requests and settlement updates will appear here.';

  @override
  String get dashboardErrorTitle => 'Unable to load account data';

  @override
  String get dashboardErrorBody =>
      'Check the backend connection and try again.';

  @override
  String get investSubtitle => 'Explore verified multi-asset BrickShares';

  @override
  String get investSearchHint => 'Search by name, location, or asset class';

  @override
  String investAvailable(int count) {
    return 'Available $count';
  }

  @override
  String get investFilteredIncome => 'Filtered income\nBrickShares';

  @override
  String investOpportunitiesCount(int count) {
    return '$count opportunities';
  }

  @override
  String get investLoadingOpportunities => 'Loading opportunities';

  @override
  String get investFiltersAction => 'Filters';

  @override
  String get investNoMatchTitle => 'No BrickShares match';

  @override
  String get investNoMatchEmpty =>
      'Admin-published verified assets will appear here.';

  @override
  String investNoMatchSearch(String query) {
    return 'No BrickShares match “$query”. Try a different search or adjust your filters.';
  }

  @override
  String get investNoMatchFilters =>
      'Try a different asset class, risk level, or payment method.';

  @override
  String get investResetFilters => 'Reset filters';

  @override
  String get walletCryptoActivity => 'Crypto order activity';

  @override
  String get walletFundingTitle => 'Crypto funding readiness';

  @override
  String get walletFundingBody =>
      'Add a verified wallet before sending funds. Network, fees, quote expiry, and settlement status are shown before confirmation.';

  @override
  String get walletAddWallet => 'Add verified wallet';

  @override
  String get walletVerificationStarted => 'Wallet verification started';

  @override
  String get walletSettlementTitle => 'Settlement confirmation required';

  @override
  String get walletSettlementBody =>
      'Purchases, withdrawals, and wallet changes require final confirmation.';

  @override
  String get walletVerifiedBalance => 'Verified wallet balance';

  @override
  String get portfolioCurrentValue => 'Current portfolio value';

  @override
  String get portfolioInvested => 'Invested';

  @override
  String get portfolioProfitLoss => 'Profit / loss';

  @override
  String get portfolioReturn => 'Return';

  @override
  String portfolioDividends(String amount) {
    return 'Dividends received: $amount';
  }

  @override
  String get portfolioHoldings => 'Holdings';

  @override
  String get portfolioHoldingsEmptyBody =>
      'Approved investments appear here automatically.';

  @override
  String get portfolioAllocation => 'Allocation';

  @override
  String get portfolioAllocationEmptyTitle => 'No allocation yet';

  @override
  String get portfolioAllocationEmptyBody =>
      'Your asset mix appears after deposits verify.';

  @override
  String portfolioInvestedOwnership(String invested, String ownership) {
    return 'Invested $invested · $ownership ownership';
  }

  @override
  String get profileSettings => 'Settings';

  @override
  String profileThemeSubtitle(String mode) {
    return '$mode theme';
  }

  @override
  String get profileSecurityTitle => 'Security & privacy';

  @override
  String get profileSecuritySubtitle => 'Verified wallet and biometrics';

  @override
  String get profileDocumentsTitle => 'Documents';

  @override
  String get profileDocumentsSubtitle => 'Statements, risk disclosures';

  @override
  String profileRowOpened(String title) {
    return '$title opened';
  }

  @override
  String get profileSupport => 'Support';

  @override
  String get profileSupportSubtitle => 'Message the BrickClub team';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileLogoutConfirmTitle => 'Log out?';

  @override
  String get profileLogoutConfirmBody =>
      'You will need to sign in again to access your account.';

  @override
  String get profileDefaultName => 'BrickClub member';

  @override
  String get profileDefaultSubtitle => 'Your account and BrickShares details';

  @override
  String get commonRetry => 'Try again';

  @override
  String get profileReferral => 'Refer & earn';

  @override
  String get profileReferralSubtitle => 'Invite friends and earn commission';

  @override
  String get referralScreenTitle => 'Refer & earn';

  @override
  String get referralHeadline => 'Invite friends, earn commission';

  @override
  String referralHowItWorksBody(String rate) {
    return 'Share your code. When someone you invited makes an investment, you earn $rate of the amount they invest — credited straight to your wallet.';
  }

  @override
  String get referralYourCodeTitle => 'Your referral code';

  @override
  String get referralCopyCode => 'Copy code';

  @override
  String get referralCopied => 'Referral code copied';

  @override
  String get referralLinkCopied => 'Invite link copied';

  @override
  String get referralShareInvite => 'Share invite';

  @override
  String get referralFriendsJoined => 'Friends joined';

  @override
  String get referralTotalEarned => 'Total earned';

  @override
  String referralPaidToWalletNote(String rate) {
    return 'You earn $rate of every investment your referrals make, paid to your wallet.';
  }

  @override
  String get referralDisabledNote =>
      'Referral rewards are currently paused. Your code still works — earnings resume when rewards are switched back on.';

  @override
  String get referralRecentEarningsTitle => 'Recent earnings';

  @override
  String get referralNoEarningsYet =>
      'No referral earnings yet. Share your code to get started.';

  @override
  String referralCommissionSubtitle(String rate, String amount) {
    return '$rate of a $amount investment';
  }

  @override
  String get referralLoadError =>
      'We couldn\'t load your referral details. Please try again.';

  @override
  String get signUpReferralCode => 'Referral code (optional)';

  @override
  String get signUpReferralCodeHint => 'Enter a friend\'s code';

  @override
  String get themeScreenTitle => 'Theme';

  @override
  String get themeAppearance => 'Appearance';

  @override
  String get themeAppearanceDescription =>
      'Choose how BrickClub looks on this device.';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystemDescription => 'Follow this device automatically.';

  @override
  String get themeLightDescription => 'Use a bright interface with dark text.';

  @override
  String get themeDarkDescription =>
      'Use the classic dark BrickClub interface.';

  @override
  String get commonSending => 'Sending...';

  @override
  String get commonSubmitting => 'Submitting...';

  @override
  String get filtersAssetClass => 'Asset class';

  @override
  String get filtersRiskLevel => 'Risk level';

  @override
  String get filtersPaymentMethod => 'Payment method';

  @override
  String get filtersReset => 'Reset';

  @override
  String filtersShow(int count) {
    return 'Show $count';
  }

  @override
  String get successTitle => 'Proof submitted';

  @override
  String get successBody =>
      'Your proof of payment is awaiting admin verification. We will notify you after review.';

  @override
  String get successSettlementStatus => 'Settlement status';

  @override
  String get successViewPortfolio => 'View portfolio';

  @override
  String get detailVerifiedDocs => 'Verified docs';

  @override
  String detailAssetLine(String assetClass, String location) {
    return '$assetClass BrickShares | $location';
  }

  @override
  String get detailLiquidity => 'Liquidity';

  @override
  String get detailFundingStatus => 'Funding status';

  @override
  String detailFundedPercent(String percent) {
    return '$percent% funded';
  }

  @override
  String get detailFundingNote =>
      'Supported payment options and quote expiry are shown before settlement confirmation.';

  @override
  String get detailInvestButton => 'Invest with crypto funding';

  @override
  String get kycStatusApproved => 'Financial actions are unlocked.';

  @override
  String get kycStatusSubmitted => 'Your documents are under review.';

  @override
  String get kycStatusRejectedDefault => 'Review the request and resubmit.';

  @override
  String get kycStatusDefault =>
      'Required before purchases and wallet changes.';

  @override
  String get kycChipPhone => 'Phone';

  @override
  String get kycChipIdentity => 'Identity';

  @override
  String get kycChipOk => 'OK';

  @override
  String get kycChipNeeded => 'Needed';

  @override
  String get kycViewDetails => 'View KYC details';

  @override
  String get kycVerifyIdentity => 'Verify identity';

  @override
  String get kycFullName => 'Full legal name';

  @override
  String get kycFullNameHint => 'Name exactly as shown on your ID';

  @override
  String get kycDob => 'Date of birth';

  @override
  String get kycSelectDate => 'Select date';

  @override
  String get kycGovId => 'Government ID or passport';

  @override
  String get kycUploadId => 'Upload ID document';

  @override
  String get kycSelfie => 'Selfie / face verification';

  @override
  String get kycCaptureSelfie => 'Capture selfie';

  @override
  String get kycAddressProof => 'Physical address proof';

  @override
  String get kycUploadAddress => 'Upload utility bill or lease';

  @override
  String get kycPhoneVerification => 'Phone verification';

  @override
  String get kycSendCode => 'Send code';

  @override
  String get kycVerificationCodeHint => 'Verification code';

  @override
  String get kycEmailVerification => 'Email verification';

  @override
  String get kycEmailVerified => 'Email verified';

  @override
  String get kycEmailNotVerified => 'Email not verified';

  @override
  String get kycSendEmail => 'Send email';

  @override
  String get kycSubmitForReview => 'Submit for review';

  @override
  String get kycEmulatorNote =>
      'Phone codes appear in the Firebase Auth emulator. Development emails appear in Mailpit.';

  @override
  String get kycEmailSent => 'Verification email sent';

  @override
  String get kycEnterPhoneFirst => 'Enter your phone number first';

  @override
  String get kycCodeSent => 'Code sent. Check the Firebase Auth emulator.';

  @override
  String get kycSubmitted => 'KYC submitted for automatic checks';

  @override
  String get kycMissingName => 'Enter your legal name';

  @override
  String get kycMissingDob => 'Select your date of birth';

  @override
  String get kycMissingId => 'Upload your ID or passport';

  @override
  String get kycMissingSelfie => 'Capture a selfie';

  @override
  String get kycMissingAddress => 'Upload address proof';

  @override
  String get kycMissingPhone => 'Enter your phone number';

  @override
  String get kycInvalidPhone =>
      'Enter your phone number in international format, e.g. +12025550190.';

  @override
  String get kycMissingCode => 'Enter the phone verification code';

  @override
  String get kycUpdateFailed =>
      'We could not update your KYC details. Please try again.';

  @override
  String get paymentConfirmFunding => 'Confirm funding';

  @override
  String get paymentSetup => 'Crypto funding setup';

  @override
  String get paymentStatusDraft => 'Draft';

  @override
  String get paymentStatusActive => 'Active';

  @override
  String get paymentRail => 'Payment rail';

  @override
  String get paymentAmount => 'Investment amount';

  @override
  String get paymentAmountHint => 'Amount in USD';

  @override
  String paymentBelowMinimum(String minimum) {
    return 'Minimum for this opportunity is $minimum.';
  }

  @override
  String get paymentDemoAmount =>
      'Demo amount can be adjusted before creating the deposit request.';

  @override
  String get paymentQuotePaymentAsset => 'Payment asset';

  @override
  String get paymentQuoteAmount => 'Amount';

  @override
  String get paymentQuoteNetwork => 'Network';

  @override
  String get paymentNetworkAfterRequest => 'Selected after request';

  @override
  String get paymentQuote => 'Quote';

  @override
  String get paymentQuoteByBackend => 'Created by backend';

  @override
  String get paymentNetworkFee => 'Network fee';

  @override
  String get paymentFeeByBackend => 'Calculated by backend';

  @override
  String get paymentSettlement => 'Settlement';

  @override
  String get paymentPendingConfirmation => 'Pending confirmation';

  @override
  String get paymentConfirmableTitle => 'Confirmable financial action';

  @override
  String get paymentConfirmableBody =>
      'You are authorizing a crypto-funded BrickShares purchase. Settlement may take network confirmations.';

  @override
  String get paymentCreateRequest => 'Create deposit request';

  @override
  String get paymentSubmitProof => 'Submit proof for review';

  @override
  String get paymentIncreaseAmount =>
      'Increase the amount to the opportunity minimum.';

  @override
  String get paymentDepositCreated => 'Deposit request created';

  @override
  String get paymentEnterHash => 'Enter the transaction hash';

  @override
  String get paymentUploadProof => 'Upload proof of payment';

  @override
  String get paymentDepositInstructions => 'Deposit instructions';

  @override
  String get paymentWalletAddress => 'Wallet address';

  @override
  String get paymentTransactionHash => 'Transaction hash';

  @override
  String get paymentHashHint => 'Paste blockchain transaction hash';

  @override
  String get paymentStepQuote => 'Quote';

  @override
  String get paymentStepSend => 'Send';

  @override
  String get paymentStepReview => 'Review';

  @override
  String get paymentCopy => 'Copy';

  @override
  String get paymentWalletCopied => 'Wallet address copied';

  @override
  String get supportNewRequest => 'New support request';

  @override
  String get supportNoRequestsTitle => 'No support requests yet';

  @override
  String get supportNoRequestsBody =>
      'Start a conversation with the BrickClub team when you need account, KYC, wallet, or investment help.';

  @override
  String get supportSendRequest => 'Send request';

  @override
  String get supportReplyTitle => 'Reply to support';

  @override
  String get supportSendReply => 'Send reply';

  @override
  String supportMessagesCount(int count) {
    return '$count messages';
  }

  @override
  String get supportRequestClosed => 'Request closed';

  @override
  String get supportReply => 'Reply';

  @override
  String get supportTalkDirectly => 'Talk to us directly';

  @override
  String get supportTalkBody =>
      'Prefer a quick chat? Reach the BrickClub support team on WhatsApp or Telegram for faster help.';

  @override
  String get supportNoMessagesYet => 'No messages yet';

  @override
  String get supportTeamName => 'BrickClub support';

  @override
  String get supportYou => 'You';

  @override
  String get supportSubject => 'Subject';

  @override
  String get supportSubjectHint => 'What do you need help with?';

  @override
  String get supportMessage => 'Message';

  @override
  String get supportMessageHint => 'Type your message';

  @override
  String get supportEnterSubject => 'Enter a subject';

  @override
  String get supportEnterMessage => 'Enter a message';

  @override
  String get supportMessageSent => 'Message sent';

  @override
  String supportCouldNotOpen(String url) {
    return 'Could not open $url';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navMore => 'More';

  @override
  String get notificationsNone => 'No new notifications';

  @override
  String get profileInMore => 'Profile is in More';

  @override
  String get investmentCardCryptoFunding => 'Crypto funding';

  @override
  String get commonShowPassword => 'Show password';

  @override
  String get commonHidePassword => 'Hide password';

  @override
  String get errAuthEmulatorUnreachable =>
      'The app could not reach the Firebase Auth emulator. Rebuild the debug app and make sure the Firebase emulators are running.';

  @override
  String get errInvalidEmail => 'Enter a valid email address.';

  @override
  String get errMissingEmail => 'Enter your email address.';

  @override
  String get errMissingPassword => 'Enter your password.';

  @override
  String get errUserNotFound => 'No account exists for that email.';

  @override
  String get errWrongPassword => 'Email or password is incorrect.';

  @override
  String get errEmailInUse => 'An account already exists for that email.';

  @override
  String get errWeakPassword =>
      'Use a stronger password with at least 6 characters.';

  @override
  String get errOperationNotAllowed =>
      'Email sign in is not enabled yet. Contact support.';

  @override
  String get errUserDisabled =>
      'This account has been disabled. Contact support for help.';

  @override
  String get errTooManyRequests =>
      'Too many attempts. Please wait a moment before trying again.';

  @override
  String get errNetworkFailed =>
      'We could not connect. Check your internet and try again.';

  @override
  String get errRequiresRecentLogin =>
      'Sign in again before making this change.';

  @override
  String get errExpiredActionCode =>
      'This link has expired. Request a new one and try again.';

  @override
  String get errInvalidActionCode =>
      'This link is no longer valid. Request a new one and try again.';

  @override
  String get errAccountRequestFailed =>
      'We could not complete that account request. Please try again.';

  @override
  String get errResetUnavailable =>
      'Password reset email is temporarily unavailable. Please try again shortly.';

  @override
  String get errResetNotAvailable =>
      'Password reset is not available right now.';

  @override
  String get errResetFailed =>
      'We could not send the reset email. Please try again.';

  @override
  String get errSignInAgain => 'Sign in again to continue.';

  @override
  String get errAdminNoPermission =>
      'Your account does not have permission to do that.';

  @override
  String get errEmailEnvUnavailable =>
      'Email sending is not available in this environment.';

  @override
  String get errAddEmailFirst => 'Add an email address to your account first.';

  @override
  String get errPermissionDenied => 'You do not have permission to do that.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String get errKycInvalidCode => 'Enter the SMS code from the emulator.';

  @override
  String get errKycCredentialInUse =>
      'That phone number is already linked to another account.';

  @override
  String get errKycTooManyRequests =>
      'Too many verification attempts. Try again later.';

  @override
  String get errKycPhoneFailed =>
      'Phone verification failed. Please try again.';

  @override
  String get errKycSignInAgain => 'Sign in again to continue with KYC.';

  @override
  String get errKycNoPermission =>
      'You do not have permission to update this KYC profile.';

  @override
  String get errKycUnavailable =>
      'KYC services are temporarily unavailable. Please try again shortly.';

  @override
  String get errKycDeadline =>
      'The request took too long. Please check your connection and try again.';

  @override
  String get errKycStorageUnauthorized =>
      'You do not have permission to upload this document.';

  @override
  String get errKycStorageCanceled => 'Document upload was cancelled.';

  @override
  String get errKycStorageRetry =>
      'The upload took too long. Please check your connection and try again.';

  @override
  String get errKycStorageQuota =>
      'Document uploads are temporarily unavailable. Please try again later.';

  @override
  String get filterAll => 'All';

  @override
  String get enumAssetRealEstate => 'Real Estate';

  @override
  String get enumAssetReit => 'REIT';

  @override
  String get enumAssetEtf => 'ETF';

  @override
  String get enumAssetIndex => 'Index Fund';

  @override
  String get enumAssetAlternative => 'Alternative';

  @override
  String get enumRiskConservative => 'Conservative';

  @override
  String get enumRiskBalanced => 'Balanced';

  @override
  String get enumRiskGrowth => 'Growth';
}
