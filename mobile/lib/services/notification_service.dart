import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// 1. TAMBAH IMPORT HIVE
import 'package:hive_flutter/hive_flutter.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 2. TAMBAH VARIABEL NAMA BOX UNTUK INBOX
  static const String _historyBox = "notificationHistory";

  static Future<void> init() async {
    // 3. BUKA BOX HIVE SAAT INISIALISASI APLIKASI
    await Hive.openBox(_historyBox);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  // 4. TAMBAHKAN PARAMETER 'type' DENGAN NILAI DEFAULT
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String type =
        'info', // Tambahan: agar bisa membedakan ikon (cert, ticket, info)
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'tech_loca_channel',
          'TechLoca Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // PERBAIKAN: Wajib pakai id:, title:, body:, dan notificationDetails:
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );

    final now = DateTime.now();
    final timeString =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB";

    // 5. TAMBAHAN LOGIKA BARU: SIMPAN NOTIFIKASI KE LOCAL CACHE (HIVE)
    var box = Hive.box(_historyBox);
    final newNotif = {
      "title": title,
      "desc": body,
      "time": timeString, // Sekarang pakai waktu asli dari sistem
      "type": type,
      "timestamp": now.toString(),
    };
    await box.add(newNotif);
  }
}
