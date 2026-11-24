import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz; // BARU
import 'package:timezone/timezone.dart' as tz;        // BARU

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static int _nextId = 0;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'tugas_channel',
    'Notifikasi Tugas',
    channelDescription: 'Notifikasi dan pengingat daftar tugas kuliah',
    importance: Importance.high,
    priority: Priority.high,
  );

  static Future<void> init() async {
    // BARU: siapkan database zona waktu, lalu set ke WIB
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notifikasi ditekan, payload: ${response.payload}');
      },
    );
  }

  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ───────────── Notif instan (Bagian 1) ─────────────
  static Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      id: _nextId++,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: _androidDetails),
      payload: payload,
    );
  }

  // ───────────── Notif terjadwal (Bagian 2) ─────────────

  // BARU: pasang pengingat untuk satu tugas di jam tertentu
  // Mengembalikan true kalau pengingatnya tepat waktu, false kalau bisa telat
  static Future<bool> scheduleReminder({
    required String taskId,
    required String taskTitle,
    required int hour,
    required int minute,
  }) async {
    // 1. Susun waktu tujuan: hari ini di jam yang dipilih
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );

    // 2. Kalau jamnya udah lewat, pindahkan ke besok
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 3. Cek izin alarm tepat waktu, pilih mode yang sesuai
    final exact = await _ensureExactAlarmPermission();

    // 4. Titip jadwalnya ke Android
    await _plugin.zonedSchedule(
      id: _reminderId(taskId),
      title: 'Jangan lupa ⏰',
      body: taskTitle,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(android: _androidDetails),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'reminder',
    );

    return exact;
  }

  // BARU: batalkan pengingat milik satu tugas
  static Future<void> cancelReminder(String taskId) async {
    await _plugin.cancel(id: _reminderId(taskId));
  }

  // BARU: cek izin alarm tepat, kalau belum ada minta ke user
  static Future<bool> _ensureExactAlarmPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;

    final alreadyAllowed = await android.canScheduleExactNotifications() ?? false;
    if (alreadyAllowed) return true;

    // Buka halaman Settings "Alarm & pengingat" buat aplikasi ini
    return await android.requestExactAlarmsPermission() ?? false;
  }

  // BARU: ubah ID tugas (teks) jadi nomor notifikasi (angka) yang selalu sama
  static int _reminderId(String taskId) {
    var hash = 0;
    for (final code in taskId.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash;
  }
}