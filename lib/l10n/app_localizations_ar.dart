// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get languageScreenTitle => 'اللغة';

  @override
  String get languageHeading => 'لغة العرض';

  @override
  String get languageDescription =>
      'اختر اللغة التي يستخدمها BrickClub على هذا الجهاز.';

  @override
  String get languageSystemDefault => 'إعداد النظام الافتراضي';

  @override
  String get commonEmail => 'البريد الإلكتروني';

  @override
  String get commonEmailHint => 'you@example.com';

  @override
  String get commonPassword => 'كلمة المرور';

  @override
  String get authConnecting => 'جارٍ الاتصال…';

  @override
  String get signInWelcomeTitle => 'مرحبًا بعودتك';

  @override
  String get signInAdminTitle => 'تسجيل دخول المسؤول';

  @override
  String get signInMemberSubtitle => 'تابع إلى محفظة BrickShares الخاصة بك.';

  @override
  String get signInAdminSubtitle =>
      'الوصول إلى عمليات المستخدمين والأصول ومدفوعات العملات المشفرة.';

  @override
  String get signInPasswordHint => 'أدخل كلمة المرور';

  @override
  String get signInForgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get signInProgress => 'جارٍ تسجيل الدخول…';

  @override
  String get signInOpenAdminDashboard => 'فتح لوحة تحكم المسؤول';

  @override
  String get signInSubmit => 'تسجيل دخول آمن';

  @override
  String get signInGoogleAdmin => 'المتابعة كمسؤول باستخدام Google';

  @override
  String get signInGoogle => 'المتابعة باستخدام Google';

  @override
  String get signInPhone => 'المتابعة عبر الهاتف';

  @override
  String get signInUseMember => 'استخدام تسجيل دخول الأعضاء';

  @override
  String get signInUseAdmin => 'تسجيل الدخول كمسؤول';

  @override
  String get signInCreateAccount => 'إنشاء حساب BrickClub';

  @override
  String get signInGoogleNoAdmin => 'حساب Google هذا لا يملك صلاحية المسؤول.';

  @override
  String get signInNoAdmin => 'هذا الحساب لا يملك صلاحية المسؤول.';

  @override
  String get signInResetSent => 'تم إرسال تعليمات إعادة تعيين كلمة المرور';

  @override
  String get signInStoryTitle => 'الملكية، أصبحت\nأكثر سهولة.';

  @override
  String get signInStoryBody =>
      'راجع الفرص الموثَّقة، وسوِّ معاملاتك بثقة، واحتفظ بكل أصل أمام عينيك.';

  @override
  String get signUpIntro =>
      'أنشئ حساب BrickShares الخاص بك. يأتي بعد ذلك التحقق من المحفظة وإجراءات اعرف عميلك (KYC).';

  @override
  String get signUpCreateAccount => 'إنشاء حساب';

  @override
  String get signUpLegalNamesHint =>
      'استخدم أسماءك القانونية تمامًا كما تظهر في هويتك.';

  @override
  String get signUpFirstName => 'الاسم الأول';

  @override
  String get signUpFirstNameHint => 'الاسم الأول القانوني';

  @override
  String get signUpLastName => 'اسم العائلة';

  @override
  String get signUpLastNameHint => 'اسم العائلة القانوني';

  @override
  String get signUpPasswordHint => 'أنشئ كلمة مرور';

  @override
  String get signUpConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get signUpConfirmPasswordHint => 'أكِّد كلمة المرور';

  @override
  String get signUpAgree =>
      'أوافق على الشروط وإفصاحات المخاطر وإشعارات تأكيد التسوية.';

  @override
  String get signUpProgress => 'جارٍ إنشاء الحساب…';

  @override
  String get signUpGoogle => 'التسجيل باستخدام Google';

  @override
  String get signUpDisclosure =>
      'تتطلب الإجراءات المالية إكمال اعرف عميلك (KYC) وإعداد محفظة موثَّقة بعد إنشاء الحساب.';

  @override
  String get signUpHaveAccount => 'هل لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get phoneTitle => 'تسجيل الدخول عبر الهاتف';

  @override
  String get phoneOtpTitle => 'أدخل رمز التحقق';

  @override
  String get phoneSubtitle =>
      'أدخل رقم هاتفك مع رمز الدولة (مثال: +1 415 555 2671).';

  @override
  String phoneOtpSubtitle(String phone) {
    return 'أرسلنا رمزًا مكوّنًا من 6 أرقام إلى $phone.';
  }

  @override
  String get phoneHint => '+1 415 555 2671';

  @override
  String get phoneCodeHint => '000000';

  @override
  String get phoneSendingCode => 'جارٍ إرسال الرمز…';

  @override
  String get phoneSendCode => 'إرسال رمز التحقق';

  @override
  String get phoneVerifying => 'جارٍ التحقق…';

  @override
  String get phoneConfirmCode => 'تأكيد الرمز';

  @override
  String get phoneUseDifferentNumber => 'استخدام رقم آخر';

  @override
  String get installIosTitle => 'التثبيت على iPhone أو iPad';

  @override
  String get installIosIntro =>
      'أضف BrickClub إلى الشاشة الرئيسية مباشرةً من Safari — دون الحاجة إلى App Store.';

  @override
  String get installIosStep1 => 'اضغط على زر المشاركة في شريط أدوات Safari.';

  @override
  String get installIosStep2 => 'مرِّر للأسفل واختر «أضف إلى الشاشة الرئيسية».';

  @override
  String get installIosStep3 =>
      'اضغط «إضافة» — وسيظهر BrickClub على شاشتك الرئيسية.';

  @override
  String get installAndroidTitle => 'التثبيت على Android';

  @override
  String get installAndroidIntro =>
      'أضف BrickClub إلى جهازك بنقرتين من متصفحك.';

  @override
  String get installAndroidStep1 =>
      'افتح قائمة المتصفح (⋮ في الزاوية العلوية).';

  @override
  String get installAndroidStep2 =>
      'اضغط «تثبيت التطبيق» أو «إضافة إلى الشاشة الرئيسية».';

  @override
  String get installAndroidStep3 =>
      'أكِّد — وسيظهر BrickClub في درج التطبيقات.';

  @override
  String get installDesktopTitle => 'التثبيت على سطح المكتب';

  @override
  String get installDesktopIntro => 'ثبِّت BrickClub كتطبيق من Chrome أو Edge.';

  @override
  String get installDesktopStep1 =>
      'انقر أيقونة التثبيت في شريط العناوين، أو افتح قائمة المتصفح.';

  @override
  String get installDesktopStep2 =>
      'اختر «تثبيت» لتشغيل BrickClub في نافذته الخاصة.';

  @override
  String get installGotIt => 'حسنًا';

  @override
  String get installAlready => 'BrickClub مثبَّت بالفعل على هذا الجهاز.';

  @override
  String get installInstalling => 'جارٍ تثبيت BrickClub على جهازك…';

  @override
  String get installDismissed => 'تم إلغاء التثبيت. يمكنك التثبيت في أي وقت.';

  @override
  String get navFeatures => 'المميزات';

  @override
  String get navHowItWorks => 'كيف يعمل';

  @override
  String get navTestimonials => 'آراء العملاء';

  @override
  String get landingSignIn => 'تسجيل الدخول';

  @override
  String get landingSignUp => 'إنشاء حساب';

  @override
  String get landingJoin => 'انضم';

  @override
  String get landingCreateAccount => 'إنشاء حساب';

  @override
  String get heroTitle => 'امتلك أكثر من\nمجرد حلم.';

  @override
  String get heroBody =>
      'ابنِ ملكية حقيقية عبر BrickShares موثَّقة ومدعومة بعقارات، مع أداء شفاف وتسوية موثوقة بالعملات المشفرة من تطبيق واحد آمن.';

  @override
  String get heroInstall => 'تثبيت التطبيق';

  @override
  String get heroExplore => 'استكشاف BrickShares';

  @override
  String get proofVerifiedAssets => 'أصول موثَّقة';

  @override
  String get proofTrustedSettlement => 'تسوية موثوقة';

  @override
  String get proofClearPerformance => 'أداء واضح';

  @override
  String get previewPortfolioValue => 'قيمة المحفظة';

  @override
  String get previewMinimum => 'الحد الأدنى';

  @override
  String get previewTargetReturn => 'العائد المستهدف';

  @override
  String get heroCardTargetReturn => 'العائد السنوي المستهدف';

  @override
  String get assetVerifiedBadge => 'أصل موثَّق';

  @override
  String get assetSampleDescription => 'عقار سكني مُدِرّ للدخل';

  @override
  String get assetFunded => 'تم تمويله';

  @override
  String get trustDueDiligence => 'العناية الواجبة للعقارات';

  @override
  String get trustKycVerified => 'أعضاء موثَّقون عبر KYC';

  @override
  String get trustUsdtSettlement => 'تسوية بعملة USDT';

  @override
  String get trustOwnershipRecords => 'سجلات ملكية واضحة';

  @override
  String get statTargetReturn => 'متوسط العائد المستهدف';

  @override
  String get statMinimum => 'الحد الأدنى للبدء';

  @override
  String get statSettlement => 'تسوية على السلسلة';

  @override
  String get statVisibility => 'وضوح المحفظة';

  @override
  String get howTitle => 'من التسجيل إلى التملُّك.';

  @override
  String get howSubtitle =>
      'مسار واضح مصمَّم للمستثمرين الذين يريدون الثقة في كل خطوة.';

  @override
  String get howStep1Title => 'أنشئ وتحقَّق';

  @override
  String get howStep1Body =>
      'افتح حسابك، وأكمل إجراءات اعرف عميلك (KYC)، واربط محفظة موثَّقة.';

  @override
  String get howStep2Title => 'اختر BrickShares';

  @override
  String get howStep2Body =>
      'راجع الأصول الموثَّقة والعوائد المستهدفة والمخاطر وشروط الملكية.';

  @override
  String get howStep3Title => 'موِّل وتابِع';

  @override
  String get howStep3Body =>
      'سوِّ معاملاتك بأمان عبر العملات المشفرة المدعومة وتابع محفظتك.';

  @override
  String get featuresTitle => 'صُمِّم للوضوح،\nلا للمضاربة.';

  @override
  String get featuresBody =>
      'كل فرصة تُبرز المعلومات المهمة: هيكل الملكية، والتحقق من الأصل، والعوائد المستهدفة، والمخاطر، وشبكة التمويل، وحالة التسوية.';

  @override
  String get feature1 => 'وثائق أصول موثَّقة';

  @override
  String get feature2 => 'عروض أسعار مشفرة ورسوم شبكة شفافة';

  @override
  String get feature3 => 'تأكيد قبل كل إجراء مالي';

  @override
  String get testimonialsTitle => 'مبني على ثقة المستثمرين.';

  @override
  String get testimonialsSubtitle =>
      'ما يقدّره أوائل أعضاء BrickClub أكثر في التجربة.';

  @override
  String get testimonial1Quote =>
      'يجعل BrickClub التفاصيل المهمة سهلة الفهم. أعرف ما أملكه، وكيف يؤدّي، وما الذي يحدث قبل التمويل.';

  @override
  String get testimonial1Role => 'رائدة أعمال، لندن';

  @override
  String get testimonial2Quote =>
      'منحني مسار التحقق والتأكيد الثقة. يبدو كمنصة استثمار جادة، لا مجرد اختصار مشفَّر آخر.';

  @override
  String get testimonial2Role => 'قائد منتج، سنغافورة';

  @override
  String get testimonial3Quote =>
      'يمكنني البدء بمبلغ عملي وفي الوقت نفسه الوصول إلى أصول كنت عادةً أراقبها من الخارج فقط.';

  @override
  String get testimonial3Role => 'مستشارة، دبي';

  @override
  String get ctaBadge => 'ابدأ خلال دقائق';

  @override
  String get ctaTitle => 'أصلك التالي يمكن أن يبدأ من هنا.';

  @override
  String get ctaBody =>
      'ثبِّت BrickClub، وأنشئ حسابك، واستكشف BrickShares موثَّقة مصمَّمة للملكية طويلة الأمد.';

  @override
  String get ctaHaveAccount => 'لديّ حساب بالفعل';

  @override
  String get ctaSecureKyc => 'تحقق KYC آمن';

  @override
  String get ctaFreeToBrowse => 'التصفح مجاني';

  @override
  String get ctaVerifiedOnly => 'أصول موثَّقة فقط';

  @override
  String get footerCopyright => '© 2026 BrickClub';

  @override
  String get commonViewAll => 'عرض الكل';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get navInvest => 'استثمر';

  @override
  String get navWallet => 'المحفظة';

  @override
  String get navPortfolio => 'المحفظة الاستثمارية';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get kycGateTitle => 'أكمل إجراءات KYC أولًا';

  @override
  String kycGateBody(String status) {
    return 'الحالة: $status. تُفتح عمليات الشراء والسحب وتغييرات المحفظة وتسوية العملات المشفرة بعد الموافقة.';
  }

  @override
  String get kycGateViewStatus => 'عرض حالة KYC';

  @override
  String get kycGateComplete => 'إكمال KYC';

  @override
  String get homeFeaturedOpportunity => 'فرصة مميزة';

  @override
  String get homeNoLiveTitle => 'لا توجد BrickShares نشطة بعد';

  @override
  String get homeNoLiveBody => 'ستظهر هنا الأصول المنشورة والموثَّقة.';

  @override
  String get homeViewInvest => 'عرض الاستثمار';

  @override
  String get homeYourHoldings => 'حيازاتك';

  @override
  String get homeRecentActivity => 'النشاط الأخير';

  @override
  String get holdingsEmptyTitle => 'لا توجد حيازات بعد';

  @override
  String get holdingsEmptyHome =>
      'ستظهر الإيداعات الموثَّقة هنا كـ BrickShares.';

  @override
  String get activityEmptyTitle => 'لا يوجد نشاط بعد';

  @override
  String get activityEmptyBody => 'ستظهر هنا طلبات الإيداع وتحديثات التسوية.';

  @override
  String get dashboardErrorTitle => 'تعذّر تحميل بيانات الحساب';

  @override
  String get dashboardErrorBody => 'تحقق من اتصال الخادم وحاول مرة أخرى.';

  @override
  String get investSubtitle => 'استكشف BrickShares متعددة الأصول وموثَّقة';

  @override
  String get investSearchHint => 'ابحث بالاسم أو الموقع أو فئة الأصل';

  @override
  String investAvailable(int count) {
    return 'متاح $count';
  }

  @override
  String get investFilteredIncome => 'BrickShares ذات الدخل\nالمُصفّاة';

  @override
  String investOpportunitiesCount(int count) {
    return '$count فرصة';
  }

  @override
  String get investLoadingOpportunities => 'جارٍ تحميل الفرص';

  @override
  String get investFiltersAction => 'عوامل التصفية';

  @override
  String get investNoMatchTitle => 'لا توجد BrickShares مطابقة';

  @override
  String get investNoMatchEmpty =>
      'ستظهر هنا الأصول الموثَّقة التي ينشرها المسؤول.';

  @override
  String investNoMatchSearch(String query) {
    return 'لا توجد BrickShares تطابق «$query». جرّب بحثًا آخر أو عدّل عوامل التصفية.';
  }

  @override
  String get investNoMatchFilters =>
      'جرّب فئة أصل أو مستوى مخاطر أو طريقة دفع مختلفة.';

  @override
  String get investResetFilters => 'إعادة تعيين عوامل التصفية';

  @override
  String get walletCryptoActivity => 'نشاط أوامر العملات المشفرة';

  @override
  String get walletFundingTitle => 'جاهزية التمويل بالعملات المشفرة';

  @override
  String get walletFundingBody =>
      'أضف محفظة موثَّقة قبل إرسال الأموال. تُعرض الشبكة والرسوم وانتهاء صلاحية العرض وحالة التسوية قبل التأكيد.';

  @override
  String get walletAddWallet => 'إضافة محفظة موثَّقة';

  @override
  String get walletVerificationStarted => 'بدأ التحقق من المحفظة';

  @override
  String get walletSettlementTitle => 'التأكيد على التسوية مطلوب';

  @override
  String get walletSettlementBody =>
      'تتطلب عمليات الشراء والسحب وتغييرات المحفظة تأكيدًا نهائيًا.';

  @override
  String get walletVerifiedBalance => 'رصيد المحفظة الموثَّقة';

  @override
  String get portfolioCurrentValue => 'القيمة الحالية للمحفظة';

  @override
  String get portfolioInvested => 'المستثمَر';

  @override
  String get portfolioProfitLoss => 'الربح / الخسارة';

  @override
  String get portfolioReturn => 'العائد';

  @override
  String portfolioDividends(String amount) {
    return 'الأرباح المستلمة: $amount';
  }

  @override
  String get portfolioHoldings => 'الحيازات';

  @override
  String get portfolioHoldingsEmptyBody =>
      'تظهر الاستثمارات المعتمدة هنا تلقائيًا.';

  @override
  String get portfolioAllocation => 'التوزيع';

  @override
  String get portfolioAllocationEmptyTitle => 'لا يوجد توزيع بعد';

  @override
  String get portfolioAllocationEmptyBody =>
      'يظهر مزيج أصولك بعد التحقق من الإيداعات.';

  @override
  String portfolioInvestedOwnership(String invested, String ownership) {
    return 'المستثمَر $invested · ملكية $ownership';
  }

  @override
  String get profileSettings => 'الإعدادات';

  @override
  String profileThemeSubtitle(String mode) {
    return 'سمة $mode';
  }

  @override
  String get profileSecurityTitle => 'الأمان والخصوصية';

  @override
  String get profileSecuritySubtitle => 'محفظة موثَّقة وبيانات حيوية';

  @override
  String get profileDocumentsTitle => 'المستندات';

  @override
  String get profileDocumentsSubtitle => 'كشوف الحساب وإفصاحات المخاطر';

  @override
  String profileRowOpened(String title) {
    return 'تم فتح $title';
  }

  @override
  String get profileSupport => 'الدعم';

  @override
  String get profileSupportSubtitle => 'راسل فريق BrickClub';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileLogoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get profileLogoutConfirmBody =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى للوصول إلى حسابك.';

  @override
  String get profileDefaultName => 'عضو BrickClub';

  @override
  String get profileDefaultSubtitle => 'تفاصيل حسابك وBrickShares الخاصة بك';

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
  String get themeScreenTitle => 'السمة';

  @override
  String get themeAppearance => 'المظهر';

  @override
  String get themeAppearanceDescription =>
      'اختر كيف يظهر BrickClub على هذا الجهاز.';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystemDescription => 'اتباع هذا الجهاز تلقائيًا.';

  @override
  String get themeLightDescription => 'استخدام واجهة فاتحة بنص داكن.';

  @override
  String get themeDarkDescription =>
      'استخدام واجهة BrickClub الداكنة الكلاسيكية.';

  @override
  String get commonSending => 'جارٍ الإرسال…';

  @override
  String get commonSubmitting => 'جارٍ الإرسال…';

  @override
  String get filtersAssetClass => 'فئة الأصل';

  @override
  String get filtersRiskLevel => 'مستوى المخاطر';

  @override
  String get filtersPaymentMethod => 'طريقة الدفع';

  @override
  String get filtersReset => 'إعادة تعيين';

  @override
  String filtersShow(int count) {
    return 'عرض $count';
  }

  @override
  String get successTitle => 'تم إرسال الإثبات';

  @override
  String get successBody =>
      'إثبات الدفع الخاص بك في انتظار التحقق من قِبل المسؤول. سنُعلمك بعد المراجعة.';

  @override
  String get successSettlementStatus => 'حالة التسوية';

  @override
  String get successViewPortfolio => 'عرض المحفظة';

  @override
  String get detailVerifiedDocs => 'مستندات موثَّقة';

  @override
  String detailAssetLine(String assetClass, String location) {
    return '$assetClass BrickShares | $location';
  }

  @override
  String get detailLiquidity => 'السيولة';

  @override
  String get detailFundingStatus => 'حالة التمويل';

  @override
  String detailFundedPercent(String percent) {
    return 'تم تمويل $percent%';
  }

  @override
  String get detailFundingNote =>
      'تُعرض خيارات الدفع المدعومة وانتهاء صلاحية العرض قبل تأكيد التسوية.';

  @override
  String get detailInvestButton => 'الاستثمار بالتمويل المشفَّر';

  @override
  String get kycStatusApproved => 'تم فتح الإجراءات المالية.';

  @override
  String get kycStatusSubmitted => 'مستنداتك قيد المراجعة.';

  @override
  String get kycStatusRejectedDefault => 'راجع الطلب وأعد الإرسال.';

  @override
  String get kycStatusDefault => 'مطلوب قبل عمليات الشراء وتغييرات المحفظة.';

  @override
  String get kycChipPhone => 'الهاتف';

  @override
  String get kycChipIdentity => 'الهوية';

  @override
  String get kycChipOk => 'تم';

  @override
  String get kycChipNeeded => 'مطلوب';

  @override
  String get kycViewDetails => 'عرض تفاصيل KYC';

  @override
  String get kycVerifyIdentity => 'التحقق من الهوية';

  @override
  String get kycFullName => 'الاسم القانوني الكامل';

  @override
  String get kycFullNameHint => 'الاسم تمامًا كما يظهر في هويتك';

  @override
  String get kycDob => 'تاريخ الميلاد';

  @override
  String get kycSelectDate => 'اختر التاريخ';

  @override
  String get kycGovId => 'هوية حكومية أو جواز سفر';

  @override
  String get kycUploadId => 'رفع وثيقة الهوية';

  @override
  String get kycSelfie => 'صورة ذاتية / التحقق من الوجه';

  @override
  String get kycCaptureSelfie => 'التقاط صورة ذاتية';

  @override
  String get kycAddressProof => 'إثبات العنوان الفعلي';

  @override
  String get kycUploadAddress => 'رفع فاتورة خدمات أو عقد إيجار';

  @override
  String get kycPhoneVerification => 'التحقق من الهاتف';

  @override
  String get kycSendCode => 'إرسال الرمز';

  @override
  String get kycVerificationCodeHint => 'رمز التحقق';

  @override
  String get kycEmailVerification => 'التحقق من البريد الإلكتروني';

  @override
  String get kycEmailVerified => 'تم التحقق من البريد الإلكتروني';

  @override
  String get kycEmailNotVerified => 'لم يتم التحقق من البريد الإلكتروني';

  @override
  String get kycSendEmail => 'إرسال بريد إلكتروني';

  @override
  String get kycSubmitForReview => 'إرسال للمراجعة';

  @override
  String get kycEmulatorNote =>
      'تظهر رموز الهاتف في محاكي Firebase Auth. تظهر رسائل التطوير في Mailpit.';

  @override
  String get kycEmailSent => 'تم إرسال بريد التحقق';

  @override
  String get kycEnterPhoneFirst => 'أدخل رقم هاتفك أولًا';

  @override
  String get kycCodeSent => 'تم إرسال الرمز. تحقق من محاكي Firebase Auth.';

  @override
  String get kycSubmitted => 'تم إرسال KYC لإجراء الفحوص التلقائية';

  @override
  String get kycMissingName => 'أدخل اسمك القانوني';

  @override
  String get kycMissingDob => 'اختر تاريخ ميلادك';

  @override
  String get kycMissingId => 'ارفع هويتك أو جواز سفرك';

  @override
  String get kycMissingSelfie => 'التقط صورة ذاتية';

  @override
  String get kycMissingAddress => 'ارفع إثبات العنوان';

  @override
  String get kycMissingPhone => 'أدخل رقم هاتفك';

  @override
  String get kycInvalidPhone =>
      'أدخل رقم هاتفك بالصيغة الدولية، مثال: +12025550190.';

  @override
  String get kycMissingCode => 'أدخل رمز التحقق من الهاتف';

  @override
  String get kycUpdateFailed =>
      'تعذّر تحديث بيانات KYC الخاصة بك. يُرجى المحاولة مرة أخرى.';

  @override
  String get paymentConfirmFunding => 'تأكيد التمويل';

  @override
  String get paymentSetup => 'إعداد التمويل المشفَّر';

  @override
  String get paymentStatusDraft => 'مسودة';

  @override
  String get paymentStatusActive => 'نشط';

  @override
  String get paymentRail => 'قناة الدفع';

  @override
  String get paymentAmount => 'مبلغ الاستثمار';

  @override
  String get paymentAmountHint => 'المبلغ بالدولار الأمريكي';

  @override
  String paymentBelowMinimum(String minimum) {
    return 'الحد الأدنى لهذه الفرصة هو $minimum.';
  }

  @override
  String get paymentDemoAmount =>
      'يمكن تعديل المبلغ التجريبي قبل إنشاء طلب الإيداع.';

  @override
  String get paymentQuotePaymentAsset => 'أصل الدفع';

  @override
  String get paymentQuoteAmount => 'المبلغ';

  @override
  String get paymentQuoteNetwork => 'الشبكة';

  @override
  String get paymentNetworkAfterRequest => 'يتم تحديدها بعد الطلب';

  @override
  String get paymentQuote => 'عرض السعر';

  @override
  String get paymentQuoteByBackend => 'يُنشأ بواسطة الخادم';

  @override
  String get paymentNetworkFee => 'رسوم الشبكة';

  @override
  String get paymentFeeByBackend => 'تُحسب بواسطة الخادم';

  @override
  String get paymentSettlement => 'التسوية';

  @override
  String get paymentPendingConfirmation => 'في انتظار التأكيد';

  @override
  String get paymentConfirmableTitle => 'إجراء مالي قابل للتأكيد';

  @override
  String get paymentConfirmableBody =>
      'أنت تُصرّح بعملية شراء BrickShares ممولة بالعملات المشفرة. قد تستغرق التسوية تأكيدات الشبكة.';

  @override
  String get paymentCreateRequest => 'إنشاء طلب إيداع';

  @override
  String get paymentSubmitProof => 'إرسال الإثبات للمراجعة';

  @override
  String get paymentIncreaseAmount => 'ارفع المبلغ إلى الحد الأدنى للفرصة.';

  @override
  String get paymentDepositCreated => 'تم إنشاء طلب الإيداع';

  @override
  String get paymentEnterHash => 'أدخل تجزئة المعاملة';

  @override
  String get paymentUploadProof => 'ارفع إثبات الدفع';

  @override
  String get paymentDepositInstructions => 'تعليمات الإيداع';

  @override
  String get paymentWalletAddress => 'عنوان المحفظة';

  @override
  String get paymentTransactionHash => 'تجزئة المعاملة';

  @override
  String get paymentHashHint => 'الصق تجزئة معاملة البلوكتشين';

  @override
  String get paymentReference => 'مرجع الدفع';

  @override
  String get paymentReferenceHint => 'أدخل معرّف التحويل أو المرجع';

  @override
  String get paymentStepQuote => 'عرض السعر';

  @override
  String get paymentStepSend => 'إرسال';

  @override
  String get paymentStepReview => 'مراجعة';

  @override
  String get paymentCopy => 'نسخ';

  @override
  String get paymentWalletCopied => 'تم نسخ عنوان المحفظة';

  @override
  String get supportNewRequest => 'طلب دعم جديد';

  @override
  String get supportNoRequestsTitle => 'لا توجد طلبات دعم بعد';

  @override
  String get supportNoRequestsBody =>
      'ابدأ محادثة مع فريق BrickClub عندما تحتاج إلى مساعدة بشأن الحساب أو KYC أو المحفظة أو الاستثمار.';

  @override
  String get supportSendRequest => 'إرسال الطلب';

  @override
  String get supportReplyTitle => 'الرد على الدعم';

  @override
  String get supportSendReply => 'إرسال الرد';

  @override
  String supportMessagesCount(int count) {
    return '$count رسالة';
  }

  @override
  String get supportRequestClosed => 'تم إغلاق الطلب';

  @override
  String get supportReply => 'رد';

  @override
  String get supportTalkDirectly => 'تحدث إلينا مباشرةً';

  @override
  String get supportTalkBody =>
      'تفضّل محادثة سريعة؟ تواصل مع فريق دعم BrickClub عبر WhatsApp أو Telegram للحصول على مساعدة أسرع.';

  @override
  String get supportNoMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get supportTeamName => 'دعم BrickClub';

  @override
  String get supportYou => 'أنت';

  @override
  String get supportSubject => 'الموضوع';

  @override
  String get supportSubjectHint => 'بماذا تحتاج المساعدة؟';

  @override
  String get supportMessage => 'الرسالة';

  @override
  String get supportMessageHint => 'اكتب رسالتك';

  @override
  String get supportEnterSubject => 'أدخل موضوعًا';

  @override
  String get supportEnterMessage => 'أدخل رسالة';

  @override
  String get supportMessageSent => 'تم إرسال الرسالة';

  @override
  String supportCouldNotOpen(String url) {
    return 'تعذّر فتح $url';
  }

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navMore => 'المزيد';

  @override
  String get notificationsNone => 'لا توجد إشعارات جديدة';

  @override
  String get profileInMore => 'الملف الشخصي موجود في «المزيد»';

  @override
  String get investmentCardCryptoFunding => 'تمويل مشفَّر';

  @override
  String get commonShowPassword => 'إظهار كلمة المرور';

  @override
  String get commonHidePassword => 'إخفاء كلمة المرور';

  @override
  String get errAuthEmulatorUnreachable =>
      'تعذّر على التطبيق الوصول إلى محاكي Firebase Auth. أعد بناء تطبيق التصحيح وتأكد من تشغيل محاكيات Firebase.';

  @override
  String get errInvalidEmail => 'أدخل عنوان بريد إلكتروني صالحًا.';

  @override
  String get errMissingEmail => 'أدخل عنوان بريدك الإلكتروني.';

  @override
  String get errMissingPassword => 'أدخل كلمة المرور.';

  @override
  String get errUserNotFound => 'لا يوجد حساب لهذا البريد الإلكتروني.';

  @override
  String get errWrongPassword => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errEmailInUse => 'يوجد حساب بالفعل لهذا البريد الإلكتروني.';

  @override
  String get errWeakPassword => 'استخدم كلمة مرور أقوى لا تقل عن 6 أحرف.';

  @override
  String get errOperationNotAllowed =>
      'تسجيل الدخول بالبريد الإلكتروني غير مُفعّل بعد. تواصل مع الدعم.';

  @override
  String get errUserDisabled => 'تم تعطيل هذا الحساب. تواصل مع الدعم للمساعدة.';

  @override
  String get errTooManyRequests =>
      'محاولات كثيرة جدًا. انتظر لحظة قبل المحاولة مرة أخرى.';

  @override
  String get errNetworkFailed =>
      'تعذّر الاتصال. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.';

  @override
  String get errRequiresRecentLogin =>
      'سجّل الدخول مرة أخرى قبل إجراء هذا التغيير.';

  @override
  String get errExpiredActionCode =>
      'انتهت صلاحية هذا الرابط. اطلب رابطًا جديدًا وحاول مرة أخرى.';

  @override
  String get errInvalidActionCode =>
      'لم يعد هذا الرابط صالحًا. اطلب رابطًا جديدًا وحاول مرة أخرى.';

  @override
  String get errAccountRequestFailed =>
      'تعذّر إكمال طلب الحساب هذا. يُرجى المحاولة مرة أخرى.';

  @override
  String get errResetUnavailable =>
      'بريد إعادة تعيين كلمة المرور غير متاح مؤقتًا. يُرجى المحاولة قريبًا.';

  @override
  String get errResetNotAvailable =>
      'إعادة تعيين كلمة المرور غير متاحة حاليًا.';

  @override
  String get errResetFailed =>
      'تعذّر إرسال بريد إعادة التعيين. يُرجى المحاولة مرة أخرى.';

  @override
  String get errSignInAgain => 'سجّل الدخول مرة أخرى للمتابعة.';

  @override
  String get errAdminNoPermission => 'حسابك لا يملك صلاحية القيام بذلك.';

  @override
  String get errEmailEnvUnavailable =>
      'إرسال البريد الإلكتروني غير متاح في هذه البيئة.';

  @override
  String get errAddEmailFirst => 'أضف عنوان بريد إلكتروني إلى حسابك أولًا.';

  @override
  String get errPermissionDenied => 'ليس لديك صلاحية القيام بذلك.';

  @override
  String get errGeneric => 'حدث خطأ ما. يُرجى المحاولة مرة أخرى.';

  @override
  String get errKycInvalidCode => 'أدخل رمز الرسالة النصية من المحاكي.';

  @override
  String get errKycCredentialInUse => 'رقم الهاتف هذا مرتبط بالفعل بحساب آخر.';

  @override
  String get errKycTooManyRequests => 'محاولات تحقق كثيرة جدًا. حاول لاحقًا.';

  @override
  String get errKycPhoneFailed =>
      'فشل التحقق من الهاتف. يُرجى المحاولة مرة أخرى.';

  @override
  String get errKycSignInAgain => 'سجّل الدخول مرة أخرى لمتابعة KYC.';

  @override
  String get errKycNoPermission => 'ليس لديك صلاحية تحديث ملف KYC هذا.';

  @override
  String get errKycUnavailable =>
      'خدمات KYC غير متاحة مؤقتًا. يُرجى المحاولة قريبًا.';

  @override
  String get errKycDeadline =>
      'استغرق الطلب وقتًا طويلًا. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get errKycStorageUnauthorized => 'ليس لديك صلاحية رفع هذا المستند.';

  @override
  String get errKycStorageCanceled => 'تم إلغاء رفع المستند.';

  @override
  String get errKycStorageRetry =>
      'استغرق الرفع وقتًا طويلًا. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get errKycStorageQuota =>
      'رفع المستندات غير متاح مؤقتًا. يُرجى المحاولة لاحقًا.';

  @override
  String get filterAll => 'الكل';

  @override
  String get enumAssetRealEstate => 'عقارات';

  @override
  String get enumAssetReit => 'REIT';

  @override
  String get enumAssetEtf => 'ETF';

  @override
  String get enumAssetIndex => 'صندوق مؤشر';

  @override
  String get enumAssetAlternative => 'بدائل';

  @override
  String get enumRiskConservative => 'متحفظ';

  @override
  String get enumRiskBalanced => 'متوازن';

  @override
  String get enumRiskGrowth => 'نمو';

  @override
  String get walletAddFundsTitle => 'Add funds to wallet';

  @override
  String get walletAddFundsSubtitle => 'Top up your spendable balance';

  @override
  String get investPlanTitle => 'Start an investment';

  @override
  String get investPlanNonePanel =>
      'No investment plans are available for this asset yet. Please check back soon.';

  @override
  String get investPlanAvailable => 'Available to invest';

  @override
  String get investPlanAmount => 'Amount to invest';

  @override
  String investPlanAmountHint(String min, String max) {
    return 'Between $min and $max';
  }

  @override
  String investPlanOutOfRange(String min, String max) {
    return 'Enter an amount between $min and $max.';
  }

  @override
  String get investPlanInsufficient =>
      'This is more than your wallet balance. Add funds first.';

  @override
  String investPlanBandApplied(String range) {
    return 'Plan tier: $range';
  }

  @override
  String get investPlanDuration => 'Lock duration';

  @override
  String get investPlanPrincipal => 'Principal';

  @override
  String get investPlanRate => 'Return rate';

  @override
  String get investPlanProfit => 'Projected profit';

  @override
  String get investPlanPayout => 'Total at maturity';

  @override
  String get investPlanMaturity => 'Matures on';

  @override
  String get investPlanDisclaimer =>
      'Profit is credited to your wallet as a lump sum when the plan matures.';

  @override
  String get investPlanConfirm => 'Confirm investment';

  @override
  String investPlanSuccess(String payout) {
    return 'Investment started. You will receive $payout at maturity.';
  }

  @override
  String portfolioExpectedProfit(String amount) {
    return 'Expected profit at maturity: $amount';
  }

  @override
  String get portfolioPlansTitle => 'Active investment plans';

  @override
  String portfolioPlanSummary(String rate, String duration, String date) {
    return '$rate for $duration · matures $date';
  }
}
