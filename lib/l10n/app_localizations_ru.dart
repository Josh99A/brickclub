// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get languageScreenTitle => 'Язык';

  @override
  String get languageHeading => 'Язык интерфейса';

  @override
  String get languageDescription =>
      'Выберите язык, который BrickClub использует на этом устройстве.';

  @override
  String get languageSystemDefault => 'Системный язык';

  @override
  String get commonEmail => 'Электронная почта';

  @override
  String get commonEmailHint => 'you@example.com';

  @override
  String get commonPassword => 'Пароль';

  @override
  String get authConnecting => 'Подключение…';

  @override
  String get signInWelcomeTitle => 'С возвращением';

  @override
  String get signInAdminTitle => 'Вход для администратора';

  @override
  String get signInMemberSubtitle => 'Перейдите к своему портфелю BrickShares.';

  @override
  String get signInAdminSubtitle =>
      'Доступ к операциям с пользователями, активами и криптоплатежами.';

  @override
  String get signInPasswordHint => 'Введите пароль';

  @override
  String get signInForgotPassword => 'Забыли пароль?';

  @override
  String get signInProgress => 'Выполняется вход…';

  @override
  String get signInOpenAdminDashboard => 'Открыть панель администратора';

  @override
  String get signInSubmit => 'Безопасный вход';

  @override
  String get signInGoogleAdmin => 'Продолжить как администратор через Google';

  @override
  String get signInGoogle => 'Продолжить через Google';

  @override
  String get signInPhone => 'Продолжить по телефону';

  @override
  String get signInUseMember => 'Войти как участник';

  @override
  String get signInUseAdmin => 'Войти как администратор';

  @override
  String get signInCreateAccount => 'Создать аккаунт BrickClub';

  @override
  String get signInGoogleNoAdmin =>
      'У этого аккаунта Google нет прав администратора.';

  @override
  String get signInNoAdmin => 'У этого аккаунта нет прав администратора.';

  @override
  String get signInResetSent => 'Инструкции по сбросу пароля отправлены';

  @override
  String get signInStoryTitle => 'Владение стало\nдоступнее.';

  @override
  String get signInStoryBody =>
      'Изучайте проверенные возможности, проводите расчёты уверенно и держите каждый актив на виду.';

  @override
  String get signUpIntro =>
      'Создайте аккаунт BrickShares. Далее — проверка кошелька и KYC.';

  @override
  String get signUpCreateAccount => 'Создать аккаунт';

  @override
  String get signUpLegalNamesHint =>
      'Укажите официальные имена точно так, как в вашем документе.';

  @override
  String get signUpFirstName => 'Имя';

  @override
  String get signUpFirstNameHint => 'Официальное имя';

  @override
  String get signUpLastName => 'Фамилия';

  @override
  String get signUpLastNameHint => 'Официальная фамилия';

  @override
  String get signUpPasswordHint => 'Создайте пароль';

  @override
  String get signUpConfirmPassword => 'Подтвердите пароль';

  @override
  String get signUpConfirmPasswordHint => 'Подтвердите ваш пароль';

  @override
  String get signUpAgree =>
      'Я принимаю условия, раскрытие рисков и уведомления о подтверждении расчётов.';

  @override
  String get signUpProgress => 'Создание аккаунта…';

  @override
  String get signUpGoogle => 'Зарегистрироваться через Google';

  @override
  String get signUpDisclosure =>
      'Для финансовых операций после создания аккаунта требуются KYC и настройка проверенного кошелька.';

  @override
  String get signUpHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get phoneTitle => 'Вход по телефону';

  @override
  String get phoneOtpTitle => 'Введите код подтверждения';

  @override
  String get phoneSubtitle =>
      'Введите номер телефона с кодом страны (например, +1 415 555 2671).';

  @override
  String phoneOtpSubtitle(String phone) {
    return 'Мы отправили 6-значный код на $phone.';
  }

  @override
  String get phoneHint => '+1 415 555 2671';

  @override
  String get phoneCodeHint => '000000';

  @override
  String get phoneSendingCode => 'Отправка кода…';

  @override
  String get phoneSendCode => 'Отправить код подтверждения';

  @override
  String get phoneVerifying => 'Проверка…';

  @override
  String get phoneConfirmCode => 'Подтвердить код';

  @override
  String get phoneUseDifferentNumber => 'Использовать другой номер';

  @override
  String get installIosTitle => 'Установка на iPhone или iPad';

  @override
  String get installIosIntro =>
      'Добавьте BrickClub на главный экран прямо из Safari — без App Store.';

  @override
  String get installIosStep1 =>
      'Нажмите кнопку «Поделиться» на панели инструментов Safari.';

  @override
  String get installIosStep2 =>
      'Прокрутите вниз и выберите «На экран «Домой»».';

  @override
  String get installIosStep3 =>
      'Нажмите «Добавить» — BrickClub появится на главном экране.';

  @override
  String get installAndroidTitle => 'Установка на Android';

  @override
  String get installAndroidIntro =>
      'Добавьте BrickClub на устройство в пару нажатий из браузера.';

  @override
  String get installAndroidStep1 =>
      'Откройте меню браузера (⋮ в верхнем углу).';

  @override
  String get installAndroidStep2 =>
      'Нажмите «Установить приложение» или «Добавить на главный экран».';

  @override
  String get installAndroidStep3 =>
      'Подтвердите — BrickClub появится в списке приложений.';

  @override
  String get installDesktopTitle => 'Установка на компьютере';

  @override
  String get installDesktopIntro =>
      'Установите BrickClub как приложение из Chrome или Edge.';

  @override
  String get installDesktopStep1 =>
      'Нажмите значок установки в адресной строке или откройте меню браузера.';

  @override
  String get installDesktopStep2 =>
      'Выберите «Установить», чтобы открыть BrickClub в отдельном окне.';

  @override
  String get installGotIt => 'Понятно';

  @override
  String get installAlready => 'BrickClub уже установлен на этом устройстве.';

  @override
  String get installInstalling => 'Установка BrickClub на ваше устройство…';

  @override
  String get installDismissed =>
      'Установка отменена. Вы можете установить приложение в любое время.';

  @override
  String get navFeatures => 'Возможности';

  @override
  String get navHowItWorks => 'Как это работает';

  @override
  String get navTestimonials => 'Отзывы';

  @override
  String get landingSignIn => 'Войти';

  @override
  String get landingSignUp => 'Регистрация';

  @override
  String get landingJoin => 'Присоединиться';

  @override
  String get landingCreateAccount => 'Создать аккаунт';

  @override
  String get heroTitle => 'Владейте большим,\nчем мечта.';

  @override
  String get heroBody =>
      'Создавайте реальную собственность с помощью проверенных BrickShares, обеспеченных недвижимостью, с прозрачной доходностью и надёжными крипторасчётами в одном безопасном приложении.';

  @override
  String get heroInstall => 'Установить приложение';

  @override
  String get heroExplore => 'Изучить BrickShares';

  @override
  String get proofVerifiedAssets => 'Проверенные активы';

  @override
  String get proofTrustedSettlement => 'Надёжные расчёты';

  @override
  String get proofClearPerformance => 'Понятная доходность';

  @override
  String get previewPortfolioValue => 'Стоимость портфеля';

  @override
  String get previewMinimum => 'Минимум';

  @override
  String get previewTargetReturn => 'Целевая доходность';

  @override
  String get heroCardTargetReturn => 'Целевая годовая доходность';

  @override
  String get assetVerifiedBadge => 'ПРОВЕРЕННЫЙ АКТИВ';

  @override
  String get assetSampleDescription => 'Доходная жилая недвижимость';

  @override
  String get assetFunded => 'Профинансировано';

  @override
  String get trustDueDiligence => 'ПРОВЕРКА НЕДВИЖИМОСТИ';

  @override
  String get trustKycVerified => 'УЧАСТНИКИ С ПРОВЕРКОЙ KYC';

  @override
  String get trustUsdtSettlement => 'РАСЧЁТЫ В USDT';

  @override
  String get trustOwnershipRecords => 'ЧЁТКИЕ ЗАПИСИ О СОБСТВЕННОСТИ';

  @override
  String get statTargetReturn => 'Средняя целевая доходность';

  @override
  String get statMinimum => 'Минимум для старта';

  @override
  String get statSettlement => 'Расчёты в блокчейне';

  @override
  String get statVisibility => 'Прозрачность портфеля';

  @override
  String get howTitle => 'От регистрации к собственности.';

  @override
  String get howSubtitle =>
      'Понятный путь для инвесторов, которым нужна уверенность на каждом шаге.';

  @override
  String get howStep1Title => 'Создайте и подтвердите';

  @override
  String get howStep1Body =>
      'Откройте аккаунт, пройдите KYC и подключите проверенный кошелёк.';

  @override
  String get howStep2Title => 'Выберите BrickShares';

  @override
  String get howStep2Body =>
      'Изучите проверенные активы, целевую доходность, риски и условия собственности.';

  @override
  String get howStep3Title => 'Финансируйте и отслеживайте';

  @override
  String get howStep3Body =>
      'Проводите расчёты безопасно поддерживаемой криптовалютой и следите за портфелем.';

  @override
  String get featuresTitle => 'Создано ради ясности,\nа не спекуляций.';

  @override
  String get featuresBody =>
      'Каждая возможность сразу показывает важное: структуру собственности, проверку актива, целевую доходность, риски, сеть финансирования и статус расчётов.';

  @override
  String get feature1 => 'Проверенная документация по активам';

  @override
  String get feature2 => 'Прозрачные котировки крипты и комиссии сети';

  @override
  String get feature3 => 'Подтверждение перед каждым финансовым действием';

  @override
  String get testimonialsTitle => 'Построено на доверии инвесторов.';

  @override
  String get testimonialsSubtitle =>
      'Что больше всего ценят в работе первые участники BrickClub.';

  @override
  String get testimonial1Quote =>
      'BrickClub делает важные детали понятными. Я знаю, чем владею, как это работает и что происходит до финансирования.';

  @override
  String get testimonial1Role => 'Предприниматель, Лондон';

  @override
  String get testimonial2Quote =>
      'Процесс проверки и подтверждения вселил уверенность. Это похоже на серьёзную инвестиционную платформу, а не на очередной криптообходной путь.';

  @override
  String get testimonial2Role => 'Руководитель продукта, Сингапур';

  @override
  String get testimonial3Quote =>
      'Я могу начать с разумной суммы и при этом получить доступ к активам, за которыми обычно наблюдал бы только со стороны.';

  @override
  String get testimonial3Role => 'Консультант, Дубай';

  @override
  String get ctaBadge => 'НАЧНИТЕ ЗА НЕСКОЛЬКО МИНУТ';

  @override
  String get ctaTitle => 'Ваш следующий актив может начаться здесь.';

  @override
  String get ctaBody =>
      'Установите BrickClub, создайте аккаунт и изучите проверенные BrickShares, созданные для долгосрочной собственности.';

  @override
  String get ctaHaveAccount => 'У меня уже есть аккаунт';

  @override
  String get ctaSecureKyc => 'Безопасный KYC';

  @override
  String get ctaFreeToBrowse => 'Просмотр бесплатно';

  @override
  String get ctaVerifiedOnly => 'Только проверенные активы';

  @override
  String get footerCopyright => '© 2026 BrickClub';
}
