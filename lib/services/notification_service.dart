import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Manaus'));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      web: WebInitializationSettings(),
    );

    try {
      await _plugin.initialize(settings: settings);
      if (!kIsWeb) {
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
        await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
      _initialized = true;
    } catch (_) {
      // A indisponibilidade do plugin não pode impedir o app offline de abrir.
    }
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String petName,
    required DateTime dueDate,
  }) async {
    if (!_initialized || kIsWeb) return;

    final dayOf = _atHour(dueDate, 9);
    final dayBefore = dayOf.subtract(const Duration(days: 1));
    final now = tz.TZDateTime.now(tz.local);

    await _plugin.cancel(id: _dayOfId(id));
    await _plugin.cancel(id: _dayBeforeId(id));

    if (dayBefore.isAfter(now)) {
      await _plugin.zonedSchedule(
        id: _dayBeforeId(id),
        title: 'Amanhã tem cuidado no AuMiau',
        body: '$title · $petName',
        scheduledDate: dayBefore,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'reminder:$id',
      );
    }
    if (dayOf.isAfter(now)) {
      await _plugin.zonedSchedule(
        id: _dayOfId(id),
        title: 'Cuidado de hoje',
        body: '$title · $petName',
        scheduledDate: dayOf,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'reminder:$id',
      );
    }
  }

  Future<void> cancelReminder(int reminderId) async {
    if (!_initialized || kIsWeb) return;
    await _plugin.cancel(id: _dayOfId(reminderId));
    await _plugin.cancel(id: _dayBeforeId(reminderId));
  }

  Future<void> showUpdateAvailable({
    required String version,
    required String downloadUrl,
  }) async {
    if (kIsWeb) return;
    await initialize();
    if (!_initialized) return;
    await _plugin.show(
      id: 9001,
      title: 'Nova versão do AuMiau disponível',
      body: 'Versão $version pronta para baixar pelo GitHub.',
      notificationDetails: _updateDetails,
      payload: downloadUrl,
    );
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    await initialize();
    if (!_initialized) return false;
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? true;
  }

  Future<void> showTestNotification() async {
    if (kIsWeb) return;
    await initialize();
    if (!_initialized) return;
    await _plugin.show(
      id: 9101,
      title: 'Notificações do AuMiau ativas',
      body: 'Você receberá lembretes de cuidados e avisos importantes.',
      notificationDetails: _details,
      payload: 'notification-test',
    );
  }

  Future<void> scheduleFamilyExpiryWarning({
    required DateTime? validUntil,
  }) async {
    if (kIsWeb) return;
    await initialize();
    if (!_initialized) return;

    const notificationId = 9100;
    await _plugin.cancel(id: notificationId);
    if (validUntil == null) return;

    final expiry = validUntil.toLocal();
    final warning = _atHour(expiry.subtract(const Duration(days: 5)), 9);
    final now = tz.TZDateTime.now(tz.local);
    if (warning.isAfter(now)) {
      await _plugin.zonedSchedule(
        id: notificationId,
        title: 'Sua assinatura Family está perto do vencimento',
        body:
            'Faltam 5 dias para o vencimento. Renove para continuar usando todos os recursos.',
        scheduledDate: warning,
        notificationDetails: _subscriptionDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'family-expiry',
      );
      return;
    }

    if (expiry.isAfter(DateTime.now())) {
      final daysLeft = expiry.difference(DateTime.now()).inDays.clamp(1, 5);
      await _plugin.show(
        id: notificationId,
        title: 'Sua assinatura Family está perto do vencimento',
        body:
            'Faltam $daysLeft dias para o vencimento. Renove para continuar usando todos os recursos.',
        notificationDetails: _subscriptionDetails,
        payload: 'family-expiry',
      );
    }
  }

  tz.TZDateTime _atHour(DateTime date, int hour) =>
      tz.TZDateTime(tz.local, date.year, date.month, date.day, hour);

  int _dayOfId(int reminderId) => reminderId * 10;

  int _dayBeforeId(int reminderId) => reminderId * 10 + 1;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'aumiau_cuidados',
      'Cuidados dos pets',
      channelDescription: 'Lembretes de vacinas, medicamentos e rotinas.',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
    macOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  static const _updateDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'aumiau_atualizacoes',
      'Atualizações do AuMiau',
      channelDescription: 'Avisos de novas versões do aplicativo.',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
    macOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  static const _subscriptionDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'aumiau_assinatura',
      'Assinatura AuMiau Family',
      channelDescription: 'Avisos sobre o vencimento da assinatura Family.',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
    macOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );
}
