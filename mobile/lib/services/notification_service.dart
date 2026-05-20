import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';

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

    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  // FUNGSI MEMICU POP-UP NOTIFIKASI HP & MENCATAT DATA BACKEND KE HIVE CACHE
  static Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String type = 'info',
    bool saveToHive = false, // Membedakan ikon (cert, ticket, info, event)
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'tech_loca_channel',
          'TechLoca Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher', // Memastikan ikon aplikasi muncul
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    final int notifId = id == 0 ? Random().nextInt(100000) : id;

    // Memunculkan banner pop-up notifikasi sistem di HP
    await _notificationsPlugin.show(
      id: notifId,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );

    if (saveToHive) {
      final now = DateTime.now();
      final String formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour}:${now.minute}";

      var box = Hive.box(_historyBox);

      final Map<String, dynamic> newNotif = {
        "id": "local-$notifId",
        "type": type,
        "title": title,
        "desc": body,
        "time": formattedDate,
        "timestamp": now.toIso8601String(),
        "isRead": false,
      };

      // Simpan ke database lokal agar bisa dibaca ValueListenableBuilder halaman notifikasi
      await box.add(newNotif);
    }
  }
}
