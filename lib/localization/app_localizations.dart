import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      const AppLocalizations(Locale('pt', 'BR'));

  String text(String key) {
    final language = _catalogs.containsKey(locale.languageCode)
        ? locale.languageCode
        : 'pt';
    return _catalogs[language]?[key] ?? _catalogs['pt']?[key] ?? key;
  }

  String confirmationSent(String email) =>
      text('auth.confirmationSent').replaceFirst('{email}', email);

  String get languageName => switch (locale.languageCode) {
    'en' => 'English',
    'es' => 'Español',
    _ => 'Português',
  };
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const {'pt', 'en', 'es'}.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

const _catalogs = <String, Map<String, String>>{
  'pt': {
    'language.title': 'Idioma',
    'language.subtitle': 'Escolha o idioma do aplicativo',
    'language.choose': 'Escolher idioma',
    'language.portuguese': 'Português',
    'language.english': 'English',
    'language.spanish': 'Español',
    'common.close': 'Fechar',
    'common.understood': 'Entendi',
    'common.email': 'E-mail',
    'common.password': 'Senha',
    'auth.tagline': 'CUIDADO COM CARINHO',
    'auth.hero': 'Cuide de quem ama',
    'auth.subtitle': 'Rotina, saúde e carinho para seus pets em um só lugar.',
    'auth.login': 'Entrar',
    'auth.createAccount': 'Criar conta',
    'auth.offline': 'Usar aplicativo offline',
    'auth.offlineNotice':
        'AuMiau Free Offline: seus dados ficam somente neste aparelho.',
    'auth.betaSemantics': 'Versão beta para testes',
    'auth.welcome': 'Bem-vindo(a)! 👋',
    'auth.loginSubtitle': 'Entre para acompanhar a rotina dos seus pets.',
    'auth.invalidCredentials': 'Informe um e-mail e uma senha válida.',
    'auth.forgotPassword': 'Esqueci minha senha?',
    'auth.noAccount': 'Ainda não tem conta? ',
    'auth.hasAccount': 'Já tem conta? ',
    'auth.registerSubtitle': 'Vamos começar!',
    'auth.fullName': 'Nome completo',
    'auth.phone': 'Telefone/WhatsApp',
    'auth.passwordHint': 'Senha (mínimo de 8 caracteres)',
    'auth.confirmPassword': 'Confirmar senha',
    'auth.birthDate': 'Data de nascimento (opcional)',
    'auth.acceptTerms':
        'Li e aceito os Termos de Uso e a Política de Privacidade.',
    'auth.reviewRegistration':
        'Revise os dados e aceite os termos para continuar.',
    'auth.confirmEmail': 'Confirme seu e-mail',
    'auth.confirmationSent': 'Enviamos um token de confirmação para {email}.',
    'auth.confirmationToken': 'Token de confirmação',
    'auth.confirmAndLogin': 'Confirmar e entrar',
    'auth.incompleteToken': 'Informe o token completo enviado por e-mail.',
    'trust.title': 'Confiança e transparência',
    'trust.dataProtected': 'Dados protegidos',
    'trust.payment': 'Pagamentos processados pelo Mercado Pago',
    'trust.developedBy': 'Desenvolvido por',
    'trust.connection':
        'Seus dados são transmitidos por conexão segura e tratados conforme a finalidade dos recursos do AuMiau.',
    'trust.paymentDetails':
        'Os pagamentos do AuMiau Family são processados pelo Mercado Pago via Pix. O AuMiau não armazena dados bancários do usuário.',
    'trust.company': 'Desenvolvido por Cezar Fournier',
    'trust.semantics':
        'Dados protegidos. Pagamentos processados pelo Mercado Pago. Desenvolvido por Cezar Fournier. Toque para saber mais.',
    'trust.logoSemantics':
        'Selo de identificação do desenvolvedor Cezar Fournier',
  },
  'en': {
    'language.title': 'Language',
    'language.subtitle': 'Choose the app language',
    'language.choose': 'Choose language',
    'language.portuguese': 'Português',
    'language.english': 'English',
    'language.spanish': 'Español',
    'common.close': 'Close',
    'common.understood': 'Got it',
    'common.email': 'Email',
    'common.password': 'Password',
    'auth.tagline': 'CARE WITH LOVE',
    'auth.hero': 'Care for those you love',
    'auth.subtitle':
        'Routine, health and affection for your pets in one place.',
    'auth.login': 'Sign in',
    'auth.createAccount': 'Create account',
    'auth.offline': 'Use app offline',
    'auth.offlineNotice':
        'AuMiau Free Offline: your data stays only on this device.',
    'auth.betaSemantics': 'Beta version for testing',
    'auth.welcome': 'Welcome! 👋',
    'auth.loginSubtitle': 'Sign in to follow your pets’ routine.',
    'auth.invalidCredentials': 'Enter a valid email and password.',
    'auth.forgotPassword': 'Forgot your password?',
    'auth.noAccount': 'Don’t have an account yet? ',
    'auth.hasAccount': 'Already have an account? ',
    'auth.registerSubtitle': 'Let’s get started!',
    'auth.fullName': 'Full name',
    'auth.phone': 'Phone/WhatsApp',
    'auth.passwordHint': 'Password (at least 8 characters)',
    'auth.confirmPassword': 'Confirm password',
    'auth.birthDate': 'Date of birth (optional)',
    'auth.acceptTerms': 'I accept the Terms of Use and Privacy Policy.',
    'auth.reviewRegistration':
        'Review your information and accept the terms to continue.',
    'auth.confirmEmail': 'Confirm your email',
    'auth.confirmationSent': 'We sent a confirmation token to {email}.',
    'auth.confirmationToken': 'Confirmation token',
    'auth.confirmAndLogin': 'Confirm and sign in',
    'auth.incompleteToken': 'Enter the complete token sent by email.',
    'trust.title': 'Trust and transparency',
    'trust.dataProtected': 'Protected data',
    'trust.payment': 'Payments processed by Mercado Pago',
    'trust.developedBy': 'Developed by',
    'trust.connection':
        'Your data is transmitted through a secure connection and handled according to the purpose of AuMiau features.',
    'trust.paymentDetails':
        'AuMiau Family payments are processed by Mercado Pago via Pix. AuMiau does not store your banking data.',
    'trust.company': 'Developed by Cezar Fournier',
    'trust.semantics':
        'Protected data. Payments processed by Mercado Pago. Developed by Cezar Fournier. Tap to learn more.',
    'trust.logoSemantics': 'Developer identification badge: Cezar Fournier',
  },
  'es': {
    'language.title': 'Idioma',
    'language.subtitle': 'Elige el idioma de la aplicación',
    'language.choose': 'Elegir idioma',
    'language.portuguese': 'Português',
    'language.english': 'English',
    'language.spanish': 'Español',
    'common.close': 'Cerrar',
    'common.understood': 'Entendido',
    'common.email': 'Correo electrónico',
    'common.password': 'Contraseña',
    'auth.tagline': 'CUIDADO CON CARIÑO',
    'auth.hero': 'Cuida a quienes amas',
    'auth.subtitle':
        'Rutina, salud y cariño para tus mascotas en un solo lugar.',
    'auth.login': 'Ingresar',
    'auth.createAccount': 'Crear cuenta',
    'auth.offline': 'Usar la aplicación sin conexión',
    'auth.offlineNotice':
        'AuMiau Free Offline: tus datos permanecen solo en este dispositivo.',
    'auth.betaSemantics': 'Versión beta para pruebas',
    'auth.welcome': '¡Bienvenido(a)! 👋',
    'auth.loginSubtitle': 'Ingresa para acompañar la rutina de tus mascotas.',
    'auth.invalidCredentials': 'Ingresa un correo y una contraseña válidos.',
    'auth.forgotPassword': '¿Olvidaste tu contraseña?',
    'auth.noAccount': '¿Aún no tienes una cuenta? ',
    'auth.hasAccount': '¿Ya tienes una cuenta? ',
    'auth.registerSubtitle': '¡Comencemos!',
    'auth.fullName': 'Nombre completo',
    'auth.phone': 'Teléfono/WhatsApp',
    'auth.passwordHint': 'Contraseña (mínimo 8 caracteres)',
    'auth.confirmPassword': 'Confirmar contraseña',
    'auth.birthDate': 'Fecha de nacimiento (opcional)',
    'auth.acceptTerms':
        'Acepto los Términos de Uso y la Política de Privacidad.',
    'auth.reviewRegistration':
        'Revisa tus datos y acepta los términos para continuar.',
    'auth.confirmEmail': 'Confirma tu correo electrónico',
    'auth.confirmationSent': 'Enviamos un token de confirmación a {email}.',
    'auth.confirmationToken': 'Token de confirmación',
    'auth.confirmAndLogin': 'Confirmar e ingresar',
    'auth.incompleteToken':
        'Ingresa el token completo enviado por correo electrónico.',
    'trust.title': 'Confianza y transparencia',
    'trust.dataProtected': 'Datos protegidos',
    'trust.payment': 'Pagos procesados por Mercado Pago',
    'trust.developedBy': 'Desarrollado por',
    'trust.connection':
        'Tus datos se transmiten mediante una conexión segura y se tratan según la finalidad de las funciones de AuMiau.',
    'trust.paymentDetails':
        'Los pagos de AuMiau Family se procesan por Mercado Pago mediante Pix. AuMiau no almacena tus datos bancarios.',
    'trust.company': 'Desarrollado por Cezar Fournier',
    'trust.semantics':
        'Datos protegidos. Pagos procesados por Mercado Pago. Desarrollado por Cezar Fournier. Toca para saber más.',
    'trust.logoSemantics':
        'Sello de identificación del desarrollador Cezar Fournier',
  },
};
