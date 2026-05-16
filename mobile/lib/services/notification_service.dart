import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _historyBox = "notificationHistory";

  static Future<void> init() async {
    // BUKA BOX HIVE SAAT INISIALISASI APLIKASI
    await Hive.openBox(_historyBox);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // 🌟 PERBAIKAN: Menambahkan named parameter 'settings:' yang diwajibkan oleh plugin
    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  // FUNGSI MEMICU POP-UP NOTIFIKASI HP & MENCATAT DATA BACKEND KE HIVE CACHE
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String type = 'info', // Membedakan ikon (cert, ticket, info, event)
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

    // Memunculkan banner pop-up notifikasi sistem di HP
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );

    final now = DateTime.now();

    // Format seragam dengan database: YYYY-MM-DD
    final String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // MENGAMBIL BOX NOTIFIKASI HIVE
    var box = Hive.box(_historyBox);

    // SINKRONISASI SKEMA DATA PAYLOAD SESUAI STRUKTUR REAL BACKEND
    final Map<String, dynamic> newNotif = {
      "title": title,
      "desc": body,
      "time": formattedDate, // Format seragam: YYYY-MM-DD
      "type": type,
      "timestamp": now.toIso8601String(),
    };

    // Simpan ke database lokal agar bisa dibaca ValueListenableBuilder halaman notifikasi
    await box.add(newNotif);
  }
}
