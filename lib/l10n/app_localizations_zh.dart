// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => '语言';

  @override
  String get languageScreenTitle => '语言';

  @override
  String get languageHeading => '显示语言';

  @override
  String get languageDescription => '选择 BrickClub 在此设备上使用的语言。';

  @override
  String get languageSystemDefault => '系统默认';

  @override
  String get commonEmail => '电子邮箱';

  @override
  String get commonEmailHint => 'you@example.com';

  @override
  String get commonPassword => '密码';

  @override
  String get authConnecting => '连接中…';

  @override
  String get signInWelcomeTitle => '欢迎回来';

  @override
  String get signInAdminTitle => '管理员登录';

  @override
  String get signInMemberSubtitle => '继续查看您的 BrickShares 投资组合。';

  @override
  String get signInAdminSubtitle => '访问用户、资产和加密支付操作。';

  @override
  String get signInPasswordHint => '请输入您的密码';

  @override
  String get signInForgotPassword => '忘记密码？';

  @override
  String get signInProgress => '正在登录…';

  @override
  String get signInOpenAdminDashboard => '打开管理后台';

  @override
  String get signInSubmit => '安全登录';

  @override
  String get signInGoogleAdmin => '以管理员身份使用 Google 继续';

  @override
  String get signInGoogle => '使用 Google 继续';

  @override
  String get signInPhone => '使用手机号继续';

  @override
  String get signInUseMember => '使用会员登录';

  @override
  String get signInUseAdmin => '以管理员身份登录';

  @override
  String get signInCreateAccount => '创建 BrickClub 账户';

  @override
  String get signInGoogleNoAdmin => '该 Google 账户没有管理员权限。';

  @override
  String get signInNoAdmin => '该账户没有管理员权限。';

  @override
  String get signInResetSent => '已发送密码重置说明';

  @override
  String get signInStoryTitle => '让拥有，\n更触手可及。';

  @override
  String get signInStoryBody => '查看经过验证的机会，安心完成结算，并随时掌握每一项资产。';

  @override
  String get signUpIntro => '创建您的 BrickShares 账户。接下来需要完成钱包验证和 KYC。';

  @override
  String get signUpCreateAccount => '创建账户';

  @override
  String get signUpLegalNamesHint => '请使用与您证件上完全一致的法定姓名。';

  @override
  String get signUpFirstName => '名字';

  @override
  String get signUpFirstNameHint => '法定名字';

  @override
  String get signUpLastName => '姓氏';

  @override
  String get signUpLastNameHint => '法定姓氏';

  @override
  String get signUpPasswordHint => '创建密码';

  @override
  String get signUpConfirmPassword => '确认密码';

  @override
  String get signUpConfirmPasswordHint => '请确认您的密码';

  @override
  String get signUpAgree => '我同意条款、风险披露和结算确认通知。';

  @override
  String get signUpProgress => '正在创建账户…';

  @override
  String get signUpGoogle => '使用 Google 注册';

  @override
  String get signUpDisclosure => '创建账户后，进行金融操作需完成 KYC 和已验证的钱包设置。';

  @override
  String get signUpHaveAccount => '已有账户？登录';

  @override
  String get phoneTitle => '使用手机号登录';

  @override
  String get phoneOtpTitle => '输入验证码';

  @override
  String get phoneSubtitle => '请输入带国家/地区代码的手机号（例如 +1 415 555 2671）。';

  @override
  String phoneOtpSubtitle(String phone) {
    return '我们已向 $phone 发送了 6 位验证码。';
  }

  @override
  String get phoneHint => '+1 415 555 2671';

  @override
  String get phoneCodeHint => '000000';

  @override
  String get phoneSendingCode => '正在发送验证码…';

  @override
  String get phoneSendCode => '发送验证码';

  @override
  String get phoneVerifying => '正在验证…';

  @override
  String get phoneConfirmCode => '确认验证码';

  @override
  String get phoneUseDifferentNumber => '使用其他号码';

  @override
  String get installIosTitle => '在 iPhone 或 iPad 上安装';

  @override
  String get installIosIntro => '直接从 Safari 将 BrickClub 添加到主屏幕——无需 App Store。';

  @override
  String get installIosStep1 => '点按 Safari 工具栏中的“分享”按钮。';

  @override
  String get installIosStep2 => '向下滚动并选择“添加到主屏幕”。';

  @override
  String get installIosStep3 => '点按“添加”——BrickClub 即会出现在主屏幕上。';

  @override
  String get installAndroidTitle => '在 Android 上安装';

  @override
  String get installAndroidIntro => '在浏览器中只需轻点几下即可将 BrickClub 添加到设备。';

  @override
  String get installAndroidStep1 => '打开浏览器菜单（右上角的 ⋮）。';

  @override
  String get installAndroidStep2 => '点按“安装应用”或“添加到主屏幕”。';

  @override
  String get installAndroidStep3 => '确认——BrickClub 即会出现在应用抽屉中。';

  @override
  String get installDesktopTitle => '在桌面上安装';

  @override
  String get installDesktopIntro => '从 Chrome 或 Edge 将 BrickClub 安装为应用。';

  @override
  String get installDesktopStep1 => '点击地址栏中的安装图标，或打开浏览器菜单。';

  @override
  String get installDesktopStep2 => '选择“安装”，在独立窗口中启动 BrickClub。';

  @override
  String get installGotIt => '知道了';

  @override
  String get installAlready => 'BrickClub 已安装在此设备上。';

  @override
  String get installInstalling => '正在将 BrickClub 安装到您的设备…';

  @override
  String get installDismissed => '已取消安装。您可以随时安装。';

  @override
  String get navFeatures => '功能';

  @override
  String get navHowItWorks => '工作原理';

  @override
  String get navTestimonials => '用户评价';

  @override
  String get landingSignIn => '登录';

  @override
  String get landingSignUp => '注册';

  @override
  String get landingJoin => '加入';

  @override
  String get landingCreateAccount => '创建账户';

  @override
  String get heroTitle => '拥有的，\n不止是梦想。';

  @override
  String get heroBody =>
      '通过经过验证的房产支持型 BrickShares 建立真正的所有权，在一个安全的应用中享受透明的业绩和可信的加密结算。';

  @override
  String get heroInstall => '安装应用';

  @override
  String get heroExplore => '探索 BrickShares';

  @override
  String get proofVerifiedAssets => '已验证资产';

  @override
  String get proofTrustedSettlement => '可信结算';

  @override
  String get proofClearPerformance => '清晰的业绩';

  @override
  String get previewPortfolioValue => '投资组合价值';

  @override
  String get previewMinimum => '最低投资';

  @override
  String get previewTargetReturn => '目标回报';

  @override
  String get heroCardTargetReturn => '目标年化回报';

  @override
  String get assetVerifiedBadge => '已验证资产';

  @override
  String get assetSampleDescription => '可产生收入的住宅物业';

  @override
  String get assetFunded => '已募集';

  @override
  String get trustDueDiligence => '房产尽职调查';

  @override
  String get trustKycVerified => 'KYC 已验证会员';

  @override
  String get trustUsdtSettlement => 'USDT 结算';

  @override
  String get trustOwnershipRecords => '清晰的所有权记录';

  @override
  String get statTargetReturn => '平均目标回报';

  @override
  String get statMinimum => '起投金额';

  @override
  String get statSettlement => '链上结算';

  @override
  String get statVisibility => '投资组合可见性';

  @override
  String get howTitle => '从注册到拥有。';

  @override
  String get howSubtitle => '为希望在每一步都充满信心的投资者设计的清晰路径。';

  @override
  String get howStep1Title => '创建并验证';

  @override
  String get howStep1Body => '开设账户，完成 KYC，并连接已验证的钱包。';

  @override
  String get howStep2Title => '选择 BrickShares';

  @override
  String get howStep2Body => '查看已验证资产、目标回报、风险和所有权条款。';

  @override
  String get howStep3Title => '出资并跟踪';

  @override
  String get howStep3Body => '使用支持的加密货币安全结算，并监控您的投资组合。';

  @override
  String get featuresTitle => '为清晰而建，\n而非投机。';

  @override
  String get featuresBody => '每个机会都会突出重要信息：所有权结构、资产验证、目标回报、风险、出资网络和结算状态。';

  @override
  String get feature1 => '已验证的资产文件';

  @override
  String get feature2 => '透明的加密报价和网络手续费';

  @override
  String get feature3 => '每次金融操作前都需确认';

  @override
  String get testimonialsTitle => '建立在投资者信任之上。';

  @override
  String get testimonialsSubtitle => '早期 BrickClub 会员最看重的体验。';

  @override
  String get testimonial1Quote =>
      'BrickClub 让重要细节一目了然。我清楚自己拥有什么、表现如何，以及出资前会发生什么。';

  @override
  String get testimonial1Role => '企业家，伦敦';

  @override
  String get testimonial2Quote => '验证和确认流程让我很有信心。它感觉像是一个严肃的投资平台，而不是又一个加密捷径。';

  @override
  String get testimonial2Role => '产品负责人，新加坡';

  @override
  String get testimonial3Quote => '我可以从一个切实可行的金额起步，同时还能接触到通常只能旁观的资产。';

  @override
  String get testimonial3Role => '顾问，迪拜';

  @override
  String get ctaBadge => '几分钟即可开始';

  @override
  String get ctaTitle => '您的下一项资产可以从这里开始。';

  @override
  String get ctaBody => '安装 BrickClub，创建账户，探索为长期持有而打造的经过验证的 BrickShares。';

  @override
  String get ctaHaveAccount => '我已有账户';

  @override
  String get ctaSecureKyc => '安全的 KYC';

  @override
  String get ctaFreeToBrowse => '免费浏览';

  @override
  String get ctaVerifiedOnly => '仅限已验证资产';

  @override
  String get footerCopyright => '© 2026 BrickClub';
}
