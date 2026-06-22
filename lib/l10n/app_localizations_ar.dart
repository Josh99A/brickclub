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
}
