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
  String get heroDownloadAndroid => 'Download for Android';

  @override
  String get heroDownloadIos => 'Download for iOS';

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
  String get footerCopyright => '© 1996–2026 BrickClub';

  @override
  String get commonViewAll => '查看全部';

  @override
  String get commonCancel => '取消';

  @override
  String get navInvest => '投资';

  @override
  String get navWallet => '钱包';

  @override
  String get navPortfolio => '投资组合';

  @override
  String get navProfile => '我的';

  @override
  String get kycGateTitle => '请先完成 KYC';

  @override
  String kycGateBody(String status) {
    return '状态：$status。审核通过后，购买、提现、钱包变更和加密结算将解锁。';
  }

  @override
  String get kycGateViewStatus => '查看 KYC 状态';

  @override
  String get kycGateComplete => '完成 KYC';

  @override
  String get homeFeaturedOpportunity => '精选机会';

  @override
  String get homeNoLiveTitle => '暂无在线 BrickShares';

  @override
  String get homeNoLiveBody => '已发布的已验证资产将显示在此处。';

  @override
  String get homeViewInvest => '查看投资';

  @override
  String get homeYourHoldings => '您的持仓';

  @override
  String get homeRecentActivity => '近期活动';

  @override
  String get holdingsEmptyTitle => '暂无持仓';

  @override
  String get holdingsEmptyHome => '已验证的存款将以 BrickShares 形式显示在此处。';

  @override
  String get activityEmptyTitle => '暂无活动';

  @override
  String get activityEmptyBody => '存款请求和结算更新将显示在此处。';

  @override
  String get dashboardErrorTitle => '无法加载账户数据';

  @override
  String get dashboardErrorBody => '请检查后端连接后重试。';

  @override
  String get investSubtitle => '探索经过验证的多资产 BrickShares';

  @override
  String get investSearchHint => '按名称、地点或资产类别搜索';

  @override
  String investAvailable(int count) {
    return '可用 $count';
  }

  @override
  String get investFilteredIncome => '筛选的收益型\nBrickShares';

  @override
  String investOpportunitiesCount(int count) {
    return '$count 个机会';
  }

  @override
  String get investLoadingOpportunities => '正在加载机会';

  @override
  String get investFiltersAction => '筛选';

  @override
  String get investNoMatchTitle => '没有匹配的 BrickShares';

  @override
  String get investNoMatchEmpty => '管理员发布的已验证资产将显示在此处。';

  @override
  String investNoMatchSearch(String query) {
    return '没有与“$query”匹配的 BrickShares。请尝试其他搜索或调整筛选条件。';
  }

  @override
  String get investNoMatchFilters => '请尝试其他资产类别、风险等级或支付方式。';

  @override
  String get investResetFilters => '重置筛选';

  @override
  String get walletCryptoActivity => '加密订单活动';

  @override
  String get walletFundingTitle => '出资准备';

  @override
  String get walletFundingBody => '在汇款前添加已验证的钱包。确认前会显示网络、手续费、报价有效期和结算状态。';

  @override
  String get walletAddWallet => '添加已验证钱包';

  @override
  String get walletVerificationStarted => '钱包验证已开始';

  @override
  String get walletSettlementTitle => '需要结算确认';

  @override
  String get walletSettlementBody => '购买、提现和钱包变更需要最终确认。';

  @override
  String get walletVerifiedBalance => '已验证钱包余额';

  @override
  String get portfolioCurrentValue => '当前投资组合价值';

  @override
  String get portfolioInvested => '已投资';

  @override
  String get portfolioProfitLoss => '盈亏';

  @override
  String get portfolioReturn => '回报';

  @override
  String portfolioDividends(String amount) {
    return '已收到股息：$amount';
  }

  @override
  String get portfolioHoldings => '持仓';

  @override
  String get portfolioHoldingsEmptyBody => '已批准的投资将自动显示在此处。';

  @override
  String get portfolioAllocation => '资产配置';

  @override
  String get portfolioAllocationEmptyTitle => '暂无配置';

  @override
  String get portfolioAllocationEmptyBody => '您的资产组合将在存款验证后显示。';

  @override
  String portfolioInvestedOwnership(String invested, String ownership) {
    return '已投资 $invested · 持有 $ownership';
  }

  @override
  String get profileSettings => '设置';

  @override
  String profileThemeSubtitle(String mode) {
    return '$mode主题';
  }

  @override
  String get profileSecurityTitle => '安全与隐私';

  @override
  String get profileSecuritySubtitle => '已验证钱包和生物识别';

  @override
  String get profileDocumentsTitle => '文件';

  @override
  String get profileDocumentsSubtitle => '对账单、风险披露';

  @override
  String profileRowOpened(String title) {
    return '已打开$title';
  }

  @override
  String get profileSupport => '支持';

  @override
  String get profileSupportSubtitle => '联系 BrickClub 团队';

  @override
  String get profileLogout => '退出登录';

  @override
  String get profileLogoutConfirmTitle => '退出登录？';

  @override
  String get profileLogoutConfirmBody => '您需要重新登录才能访问您的账户。';

  @override
  String get profileDefaultName => 'BrickClub 会员';

  @override
  String get profileDefaultSubtitle => '您的账户和 BrickShares 详情';

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
  String get themeScreenTitle => '主题';

  @override
  String get themeAppearance => '外观';

  @override
  String get themeAppearanceDescription => '选择 BrickClub 在此设备上的外观。';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystemDescription => '自动跟随此设备。';

  @override
  String get themeLightDescription => '使用明亮界面和深色文字。';

  @override
  String get themeDarkDescription => '使用经典的 BrickClub 深色界面。';

  @override
  String get commonSending => '发送中…';

  @override
  String get commonSubmitting => '提交中…';

  @override
  String get filtersAssetClass => '资产类别';

  @override
  String get filtersRiskLevel => '风险等级';

  @override
  String get filtersPaymentMethod => '支付方式';

  @override
  String get filtersReset => '重置';

  @override
  String filtersShow(int count) {
    return '显示 $count';
  }

  @override
  String get successTitle => '凭证已提交';

  @override
  String get successBody => '您的付款凭证正在等待管理员核实。审核后我们会通知您。';

  @override
  String get successSettlementStatus => '结算状态';

  @override
  String get successViewPortfolio => '查看投资组合';

  @override
  String get detailVerifiedDocs => '已验证文件';

  @override
  String detailAssetLine(String assetClass, String location) {
    return '$assetClass BrickShares | $location';
  }

  @override
  String get detailLiquidity => '流动性';

  @override
  String get detailFundingStatus => '募集状态';

  @override
  String detailFundedPercent(String percent) {
    return '已募集 $percent%';
  }

  @override
  String get detailFundingNote => '支持的付款方式和报价有效期将在结算确认前显示。';

  @override
  String get detailDocuments => '文件';

  @override
  String get detailInvestButton => '使用加密货币出资投资';

  @override
  String get kycStatusApproved => '金融操作已解锁。';

  @override
  String get kycStatusSubmitted => '您的文件正在审核中。';

  @override
  String get kycStatusRejectedDefault => '请检查申请并重新提交。';

  @override
  String get kycStatusDefault => '购买和钱包变更前必须完成。';

  @override
  String get kycChipPhone => '电话';

  @override
  String get kycChipIdentity => '身份';

  @override
  String get kycChipOk => '完成';

  @override
  String get kycChipNeeded => '待办';

  @override
  String get kycViewDetails => '查看 KYC 详情';

  @override
  String get kycVerifyIdentity => '验证身份';

  @override
  String get kycFullName => '法定全名';

  @override
  String get kycFullNameHint => '与您证件上完全一致的姓名';

  @override
  String get kycDob => '出生日期';

  @override
  String get kycSelectDate => '选择日期';

  @override
  String get kycGovId => '政府身份证件或护照';

  @override
  String get kycUploadId => '上传身份证件';

  @override
  String get kycSelfie => '自拍 / 人脸验证';

  @override
  String get kycCaptureSelfie => '拍摄自拍';

  @override
  String get kycAddressProof => '实际地址证明';

  @override
  String get kycUploadAddress => '上传水电费账单或租约';

  @override
  String get kycPhoneVerification => '电话验证';

  @override
  String get kycSendCode => '发送验证码';

  @override
  String get kycVerificationCodeHint => '验证码';

  @override
  String get kycEmailVerification => '电子邮箱验证';

  @override
  String get kycEmailVerified => '电子邮箱已验证';

  @override
  String get kycEmailNotVerified => '电子邮箱未验证';

  @override
  String get kycSendEmail => '发送邮件';

  @override
  String get kycSubmitForReview => '提交审核';

  @override
  String get kycEmulatorNote =>
      '电话验证码会显示在 Firebase Auth 模拟器中。开发邮件会显示在 Mailpit 中。';

  @override
  String get kycEmailSent => '验证邮件已发送';

  @override
  String get kycEnterPhoneFirst => '请先输入您的电话号码';

  @override
  String get kycCodeSent => '验证码已发送。请查看 Firebase Auth 模拟器。';

  @override
  String get kycSubmitted => 'KYC 已提交进行自动检查';

  @override
  String get kycMissingName => '请输入您的法定姓名';

  @override
  String get kycMissingDob => '请选择您的出生日期';

  @override
  String get kycMissingId => '请上传您的身份证件或护照';

  @override
  String get kycMissingSelfie => '请拍摄自拍';

  @override
  String get kycMissingAddress => '请上传地址证明';

  @override
  String get kycMissingPhone => '请输入您的电话号码';

  @override
  String get kycInvalidPhone => '请以国际格式输入您的电话号码，例如 +12025550190。';

  @override
  String get kycMissingCode => '请输入电话验证码';

  @override
  String get kycUpdateFailed => '无法更新您的 KYC 信息。请重试。';

  @override
  String get paymentConfirmFunding => '确认出资';

  @override
  String get paymentSetup => '出资设置';

  @override
  String get paymentStatusDraft => '草稿';

  @override
  String get paymentStatusActive => '进行中';

  @override
  String get paymentRail => '支付通道';

  @override
  String get paymentAmount => '投资金额';

  @override
  String get paymentAmountHint => '金额（美元）';

  @override
  String paymentBelowMinimum(String minimum) {
    return '此机会的最低金额为 $minimum。';
  }

  @override
  String get paymentDemoAmount => '创建存款请求前可调整演示金额。';

  @override
  String get paymentQuotePaymentAsset => '支付资产';

  @override
  String get paymentQuoteAmount => '金额';

  @override
  String get paymentQuoteNetwork => '网络';

  @override
  String get paymentNetworkAfterRequest => '请求后选择';

  @override
  String get paymentQuote => '报价';

  @override
  String get paymentQuoteByBackend => '由后端创建';

  @override
  String get paymentNetworkFee => '网络手续费';

  @override
  String get paymentFeeByBackend => '由后端计算';

  @override
  String get paymentSettlement => '结算';

  @override
  String get paymentPendingConfirmation => '等待确认';

  @override
  String get paymentConfirmableTitle => '可确认的金融操作';

  @override
  String get paymentConfirmableBody =>
      '您正在授权一笔加密货币出资的 BrickShares 购买。结算可能需要网络确认。';

  @override
  String get paymentCreateRequest => '创建存款请求';

  @override
  String get paymentSubmitProof => '提交凭证以供审核';

  @override
  String get paymentIncreaseAmount => '请将金额增加到机会的最低金额。';

  @override
  String get paymentDepositCreated => '存款请求已创建';

  @override
  String get paymentEnterHash => '请输入交易哈希';

  @override
  String get paymentUploadProof => '上传付款凭证';

  @override
  String get paymentDepositInstructions => '存款说明';

  @override
  String get paymentWalletAddress => '钱包地址';

  @override
  String get paymentTransactionHash => '交易哈希';

  @override
  String get paymentHashHint => '粘贴区块链交易哈希';

  @override
  String get paymentReference => '付款参考编号';

  @override
  String get paymentReferenceHint => '输入转账 ID 或参考编号';

  @override
  String get paymentStepQuote => '报价';

  @override
  String get paymentStepSend => '发送';

  @override
  String get paymentStepReview => '审核';

  @override
  String get paymentCopy => '复制';

  @override
  String get paymentWalletCopied => '钱包地址已复制';

  @override
  String get supportNewRequest => '新建支持请求';

  @override
  String get supportNoRequestsTitle => '暂无支持请求';

  @override
  String get supportNoRequestsBody =>
      '当您需要账户、KYC、钱包或投资方面的帮助时，请与 BrickClub 团队开始对话。';

  @override
  String get supportSendRequest => '发送请求';

  @override
  String get supportReplyTitle => '回复支持';

  @override
  String get supportSendReply => '发送回复';

  @override
  String supportMessagesCount(int count) {
    return '$count 条消息';
  }

  @override
  String get supportRequestClosed => '请求已关闭';

  @override
  String get supportReply => '回复';

  @override
  String get supportTalkDirectly => '直接联系我们';

  @override
  String get supportTalkBody =>
      '想快速聊聊？通过 WhatsApp 或 Telegram 联系 BrickClub 支持团队以获得更快帮助。';

  @override
  String get supportNoMessagesYet => '暂无消息';

  @override
  String get supportTeamName => 'BrickClub 支持';

  @override
  String get supportYou => '您';

  @override
  String get supportSubject => '主题';

  @override
  String get supportSubjectHint => '您需要什么帮助？';

  @override
  String get supportMessage => '消息';

  @override
  String get supportMessageHint => '输入您的消息';

  @override
  String get supportEnterSubject => '请输入主题';

  @override
  String get supportEnterMessage => '请输入消息';

  @override
  String get supportMessageSent => '消息已发送';

  @override
  String supportCouldNotOpen(String url) {
    return '无法打开 $url';
  }

  @override
  String get navHome => '首页';

  @override
  String get navMore => '更多';

  @override
  String get notificationsNone => '暂无新通知';

  @override
  String get profileInMore => '个人资料在“更多”中';

  @override
  String get investmentCardCryptoFunding => '出资';

  @override
  String get commonShowPassword => '显示密码';

  @override
  String get commonHidePassword => '隐藏密码';

  @override
  String get errAuthEmulatorUnreachable =>
      '应用无法连接 Firebase Auth 模拟器。请重新构建调试应用并确保 Firebase 模拟器正在运行。';

  @override
  String get errInvalidEmail => '请输入有效的电子邮箱地址。';

  @override
  String get errMissingEmail => '请输入您的电子邮箱地址。';

  @override
  String get errMissingPassword => '请输入您的密码。';

  @override
  String get errUserNotFound => '该邮箱没有对应的账户。';

  @override
  String get errWrongPassword => '邮箱或密码不正确。';

  @override
  String get errEmailInUse => '该邮箱已存在账户。';

  @override
  String get errWeakPassword => '请使用至少 6 个字符的更强密码。';

  @override
  String get errOperationNotAllowed => '电子邮箱登录尚未启用。请联系支持。';

  @override
  String get errUserDisabled => '此账户已被停用。请联系支持寻求帮助。';

  @override
  String get errTooManyRequests => '尝试次数过多。请稍候片刻再试。';

  @override
  String get errNetworkFailed => '无法连接。请检查您的网络后重试。';

  @override
  String get errRequiresRecentLogin => '进行此更改前请重新登录。';

  @override
  String get errExpiredActionCode => '此链接已过期。请重新申请后再试。';

  @override
  String get errInvalidActionCode => '此链接已失效。请重新申请后再试。';

  @override
  String get errAccountRequestFailed => '我们无法完成该账户请求。请重试。';

  @override
  String get errResetUnavailable => '密码重置邮件暂时不可用。请稍后再试。';

  @override
  String get errResetNotAvailable => '目前无法重置密码。';

  @override
  String get errResetFailed => '我们无法发送重置邮件。请重试。';

  @override
  String get errSignInAgain => '请重新登录以继续。';

  @override
  String get errAdminNoPermission => '您的账户没有权限执行此操作。';

  @override
  String get errEmailEnvUnavailable => '此环境中无法发送邮件。';

  @override
  String get errAddEmailFirst => '请先为您的账户添加电子邮箱地址。';

  @override
  String get errPermissionDenied => '您没有权限执行此操作。';

  @override
  String get errGeneric => '出错了。请重试。';

  @override
  String get errKycInvalidCode => '请输入模拟器中的短信验证码。';

  @override
  String get errKycCredentialInUse => '该电话号码已关联到另一个账户。';

  @override
  String get errKycTooManyRequests => '验证尝试次数过多。请稍后再试。';

  @override
  String get errKycPhoneFailed => '电话验证失败。请重试。';

  @override
  String get errKycSignInAgain => '请重新登录以继续 KYC。';

  @override
  String get errKycNoPermission => '您没有权限更新此 KYC 资料。';

  @override
  String get errKycUnavailable => 'KYC 服务暂时不可用。请稍后再试。';

  @override
  String get errKycDeadline => '请求耗时过长。请检查您的网络后重试。';

  @override
  String get errKycStorageUnauthorized => '您没有权限上传此文件。';

  @override
  String get errKycStorageCanceled => '文件上传已取消。';

  @override
  String get errKycStorageRetry => '上传耗时过长。请检查您的网络后重试。';

  @override
  String get errKycStorageQuota => '文件上传暂时不可用。请稍后再试。';

  @override
  String get filterAll => '全部';

  @override
  String get enumAssetRealEstate => '房地产';

  @override
  String get enumAssetReit => 'REIT';

  @override
  String get enumAssetEtf => 'ETF';

  @override
  String get enumAssetIndex => '指数基金';

  @override
  String get enumAssetAlternative => '另类投资';

  @override
  String get enumRiskConservative => '保守型';

  @override
  String get enumRiskBalanced => '平衡型';

  @override
  String get enumRiskGrowth => '成长型';

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

  @override
  String portfolioPlanMatures(String payout, String date) {
    return 'Pays $payout at maturity on $date';
  }
}
