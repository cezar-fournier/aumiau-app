class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'AUMIAU_API_BASE_URL',
    defaultValue: 'https://aumiau.app.br/',
  );

  static Uri get apiBaseUri => Uri.parse(apiBaseUrl);
}
