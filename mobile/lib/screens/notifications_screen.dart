import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/notification_service.dart';

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

  // SINKRONISASI DATA SUPABASE KE HIVE BOX & MUNCULKAN NOTIFIKASI LOKAL
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

      final List<Map<dynamic, dynamic>> existingNotifs = box.values
          .cast<Map<dynamic, dynamic>>()
          .toList();

      bool hasNew = false;

      // 🌟 PROSES TRANSAKSI (Menangkap semua status + Check in)
      for (var trans in transResponse as List) {
        final status = trans['status'];
        final eventTitle = trans['events'] != null
            ? trans['events']['title']
            : 'Event';
        final transDate =
            trans['updated_at'] != null || trans['created_at'] != null
            ? DateTime.parse(trans['updated_at'] ?? trans['created_at'])
            : DateTime.now();

        String title = '';
        String desc = '';
        bool isValidStatus = false;

        // Cek Status Transaksi
        if (status == 'success' || status == 'confirmed') {
          title = 'Tiket Dikonfirmasi! 🎉';
          desc = 'Pembayaran tiketmu untuk $eventTitle berhasil diverifikasi.';
          isValidStatus = true;
        } else if (status == 'waiting') {
          title = 'Menunggu Verifikasi ⏳';
          desc =
              'Pembayaran tiket $eventTitle sedang kami proses. Mohon tunggu.';
          isValidStatus = true;
        } else if (status == 'failed') {
          title = 'Transaksi Gagal ❌';
          desc = 'Maaf, pembayaran tiket $eventTitle gagal atau ditolak admin.';
          isValidStatus = true;
        }

        // Simpan & Munculkan Notif Status Transaksi
        if (isValidStatus) {
          final notifId = 'trans-${trans['id']}-$status';
          if (!existingNotifs.any((n) => n['id'] == notifId)) {
            final newNotif = {
              'id': notifId,
              'type': 'ticket',
              'title': title,
              'desc': desc,
              'time':
                  '${transDate.day}-${transDate.month}-${transDate.year} ${transDate.hour}:${transDate.minute}',
              'timestamp': transDate.toIso8601String(),
              'isRead': false,
            };
            await box.add(newNotif);
            hasNew = true;
            // PANGGIL POP-UP HP
            NotificationService.showNotification(title: title, body: desc);
          }
        }

        // Cek Status Check-In (Jika petugas sudah scan QR di lokasi)
        if (trans['is_checked_in'] == true) {
          final checkinId = 'checkin-${trans['id']}';
          if (!existingNotifs.any((n) => n['id'] == checkinId)) {
            final newNotif = {
              'id': checkinId,
              'type': 'ticket',
              'title': 'Berhasil Check-In! ✅',
              'desc': 'Selamat datang di $eventTitle! Selamat mengikuti acara.',
              'time':
                  '${transDate.day}-${transDate.month}-${transDate.year} ${transDate.hour}:${transDate.minute}',
              'timestamp': transDate.toIso8601String(),
              'isRead': false,
            };
            await box.add(newNotif);
            hasNew = true;
            // PANGGIL POP-UP HP
            NotificationService.showNotification(
              title: newNotif['title'] as String,
              body: newNotif['desc'] as String,
            );
          }
        }
      }

      // 🌟 PROSES SERTIFIKAT
      for (var cert in certResponse as List) {
        final certId = cert['id'];
        final transData = cert['transactions'];
        final eventTitle = transData != null && transData['events'] != null
            ? transData['events']['title']
            : 'Event';
        final certDate = cert['created_at'] != null
            ? DateTime.parse(cert['created_at'])
            : DateTime.now();

        final notifId = 'cert-$certId';

        if (!existingNotifs.any((n) => n['id'] == notifId)) {
          final newNotif = {
            'id': notifId,
            'type': 'certificate',
            'title': 'Sertifikat Tersedia! 🎓',
            'desc':
                'Sertifikat untuk event $eventTitle sudah bisa diunduh sekarang.',
            'time':
                '${certDate.day}-${certDate.month}-${certDate.year} ${certDate.hour}:${certDate.minute}',
            'timestamp': certDate.toIso8601String(),
            'isRead': false,
          };
          await box.add(newNotif);
          hasNew = true;

          // PANGGIL POP-UP HP
          NotificationService.showNotification(
            title: newNotif['title'] as String,
            body: newNotif['desc'] as String,
          );
        }
      }

      if (mounted) {
        setState(() => _isRefreshing = false);
        // Kalau tidak ada yang baru, tidak usah tampilkan snackbar kosong
      }
    } catch (e) {
      debugPrint("Error sync notifications: $e");
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
