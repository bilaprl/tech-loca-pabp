import 'package:flutter/material.dart';
// 1. TAMBAHKAN IMPORT HIVE
import 'package:hive_flutter/hive_flutter.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      // 2. GUNAKAN ValueListenableBuilder UNTUK MEMBACA DATA DARI HIVE
      body: ValueListenableBuilder(
        valueListenable: Hive.box("notificationHistory").listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return _buildEmptyState();
          }

          // Mengambil data dari box dan membalik urutannya agar yang terbaru di atas
          final notifications = box.values.toList().reversed.toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              // Konversi data dari Hive ke Map agar bisa dibaca widget
              final item = Map<String, String>.from(notifications[index]);
              return _buildNotificationCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, String> item) {
    IconData icon;
    Color color;

    // Logika pemilihan ikon tetap sama agar UI konsisten
    switch (item['type']) {
      case 'cert':
        icon = Icons.card_membership_rounded;
        color = Colors.purple;
        break;
      case 'ticket':
        icon = Icons.confirmation_number_rounded;
        color = Colors.green;
        break;
      case 'event':
        icon = Icons.event_available_rounded;
        color = Colors.orange;
        break;
      default:
        icon = Icons.notifications_active_rounded;
        color = const Color(0xFF4F46E5);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.01),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? "Pemberitahuan",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['desc'] ?? "",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  item['time'] ?? "Baru saja",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada notifikasi",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
