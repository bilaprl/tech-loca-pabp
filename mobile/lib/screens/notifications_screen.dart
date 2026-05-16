import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _syncNotificationsWithBackend();
  }

  // SINKRONISASI DATA SUPABASE KE HIVE BOX NOTIFIKASI
  Future<void> _syncNotificationsWithBackend() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    if (mounted) setState(() => _isRefreshing = true);

    try {
      final box = Hive.box("notificationHistory");

      // 1. Tarik data Transaksi Tiket
      final transResponse = await Supabase.instance.client
          .from('transactions')
          .select('*, events(title)')
          .eq('user_id', user.id);

      // 2. Tarik data Sertifikat
      final certResponse = await Supabase.instance.client
          .from('certificates')
          .select('*, transactions!inner(user_id, events(title))')
          .eq('transactions.user_id', user.id);

      // Bersihkan box lokal terlebih dahulu agar sinkron dengan yang terbaru
      await box.clear();

      // Masukkan Notifikasi Berbasis Transaksi Tiket
      for (var trans in transResponse as List) {
        final eventTitle = trans['events']?['title'] ?? 'Event';
        final status = trans['status'] ?? 'pending';

        String title = "Pemesanan Tiket";
        String desc =
            "Tiket untuk event '$eventTitle' sedang menunggu verifikasi pembayaran.";
        String type = "event";

        if (status == 'confirmed') {
          title = "Tiket Terkonfirmasi!";
          desc =
              "Selamat! Pembayaran event '$eventTitle' diverifikasi. QR Code e-ticket kamu sudah aktif.";
          type = "ticket";
        } else if (status == 'cancelled') {
          title = "Pesanan Dibatalkan";
          desc = "Pesanan tiket untuk event '$eventTitle' telah dibatalkan.";
          type = "default";
        }

        // 🌟 PERBAIKAN 1: Proteksi pemotongan string tanggal created_at transaksi
        final String rawTransTime = trans['created_at']?.toString() ?? '';
        final String parsedTransTime = rawTransTime.contains('T')
            ? rawTransTime.split('T')[0]
            : (rawTransTime.isNotEmpty ? rawTransTime : 'Baru saja');

        await box.add({
          'id': trans['id'].toString(),
          'title': title,
          'desc': desc,
          'type': type,
          'time': parsedTransTime,
        });
      }

      // Masukkan Notifikasi Berbasis Penerbitan Sertifikat
      for (var cert in certResponse as List) {
        final eventTitle = cert['transactions']?['events']?['title'] ?? 'Event';

        // 🌟 PERBAIKAN 2: Proteksi pemotongan string tanggal created_at sertifikat
        final String rawCertTime = cert['created_at']?.toString() ?? '';
        final String parsedCertTime = rawCertTime.contains('T')
            ? rawCertTime.split('T')[0]
            : (rawCertTime.isNotEmpty ? rawCertTime : 'Baru saja');

        await box.add({
          'id': cert['id'].toString(),
          'title': "Sertifikat Baru Terbit!",
          'desc':
              "Selamat! Sertifikat digital kamu untuk event '$eventTitle' telah diterbitkan. Silakan unduh.",
          'type': "cert",
          'time': parsedCertTime,
        });
      }
    } catch (e) {
      debugPrint("Error Sync Notifications: $e");
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  // FUNGSI PULL-TO-REFRESH
  Future<void> _handleRefresh() async {
    await _syncNotificationsWithBackend();
  }

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
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF4F46E5),
        child: ValueListenableBuilder(
          valueListenable: Hive.box("notificationHistory").listenable(),
          builder: (context, Box box, _) {
            if (box.isEmpty && _isRefreshing) {
              return const Center(child: CircularProgressIndicator());
            }

            if (box.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  _buildEmptyState(),
                ],
              );
            }

            final notifications = box.values.toList().reversed.toList();

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = Map<String, dynamic>.from(notifications[index]);

                final Map<String, String> cardData = {
                  'title': item['title']?.toString() ?? '',
                  'desc': item['desc']?.toString() ?? '',
                  'type': item['type']?.toString() ?? '',
                  'time': item['time']?.toString() ?? '',
                };

                return _buildNotificationCard(cardData);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, String> item) {
    IconData icon;
    Color color;

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
              color: color.withValues(alpha: 0.05),
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
            "Belum ada notifikasi baru",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
