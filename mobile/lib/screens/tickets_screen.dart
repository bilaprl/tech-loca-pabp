import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../event_model.dart';
import 'detail_event_screen.dart';
import '../services/ticket_service.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> activeTickets = [];
  List<Map<String, dynamic>> historyTickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTicketsData();
  }

  Future<void> _fetchTicketsData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      final savedData = TicketService.getSavedTicket();
      if (savedData != null && savedData['offline_list'] != null) {
        final List<Map<String, dynamic>> offlineList = [];
        for (var cache in savedData['offline_list']) {
          offlineList.add({
            'transaction_id': cache['transaction_id'],
            'status': cache['status'],
            'qr_string': cache['qr_string'],
            'is_checked_in': cache['is_checked_in'],
            'created_at': cache['created_at'],
            'event': Event.fromJson(cache['event_data']),
          });
        }
        if (mounted) {
          setState(() {
            activeTickets = offlineList;
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('transactions')
          .select('*, events(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> activeList = [];
      final List<Map<String, dynamic>> historyList = [];

      for (var item in response as List) {
        if (item['events'] != null) {
          final eventObj = Event.fromJson(item['events']);
          final ticketMap = {
            'transaction_id': item['id'],
            'status': item['status'] ?? 'pending',
            'qr_string': item['qr_code_string'] ?? '',
            'is_checked_in': item['is_checked_in'] ?? false,
            'created_at': item['created_at'] ?? '',
            'event': eventObj,
            'event_data': item['events'],
          };

          if (item['status'] == 'cancelled' ||
              item['status'] == 'failed' ||
              item['is_checked_in'] == true) {
            historyList.add(ticketMap);
          } else {
            activeList.add(ticketMap);
          }
        }
      }

      if (activeList.isNotEmpty) {
        final List<Map<String, dynamic>> cacheReadyList = activeList.map((t) {
          return {
            'transaction_id': t['transaction_id'],
            'status': t['status'],
            'qr_string': t['qr_string'],
            'is_checked_in': t['is_checked_in'],
            'created_at': t['created_at'],
            'event_data': t['event_data'],
          };
        }).toList();

        await TicketService.saveTicket({'offline_list': cacheReadyList});
      }

      if (mounted) {
        setState(() {
          activeTickets = activeList;
          // 🌟 PERBAIKAN: Membalikkan list riwayat agar yang paling baru dipesan/dibatalkan berada paling atas
          historyTickets = historyList.reversed.toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch / Sinyal Offline: $e");
      final savedData = TicketService.getSavedTicket();
      if (savedData != null && savedData['offline_list'] != null) {
        final List<Map<String, dynamic>> offlineList = [];
        for (var cache in savedData['offline_list']) {
          offlineList.add({
            'transaction_id': cache['transaction_id'],
            'status': cache['status'],
            'qr_string': cache['qr_string'],
            'is_checked_in': cache['is_checked_in'],
            'created_at': cache['created_at'],
            'event': Event.fromJson(cache['event_data']),
          });
        }
        if (mounted) {
          setState(() {
            activeTickets = offlineList;
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  // Fungsi Pembatalan Tiket dan Pengembalian Slot Otomatis
  Future<void> _cancelTicket(String transactionId) async {
    try {
      // 1. Ambil data transaksi untuk mencari tahu event_id yang bersangkutan
      final transactionData = await Supabase.instance.client
          .from('transactions')
          .select('event_id')
          .eq('id', transactionId)
          .single();

      final String eventId = transactionData['event_id'];

      // 2. Tarik data kuota terbaru dari event tersebut
      final eventResponse = await Supabase.instance.client
          .from('events')
          .select('quota')
          .eq('id', eventId)
          .single();

      final int currentQuota = eventResponse['quota'] ?? 0;

      // 3. Ubah status transaksi tiket menjadi 'failed' (Sesuai dengan constraint check database kamu)
      await Supabase.instance.client
          .from('transactions')
          .update({'status': 'failed'})
          .eq('id', transactionId);

      // 4. Kembalikan 1 slot kursi ke event tersebut di tabel events
      await Supabase.instance.client
          .from('events')
          .update({'quota': currentQuota + 1})
          .eq('id', eventId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pesanan berhasil dibatalkan. Kuota telah dikembalikan!',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        // Refresh daftar tiket di layar
        _fetchTicketsData();
      }
    } catch (e) {
      debugPrint("Error cancel ticket: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membatalkan pesanan. Coba lagi.'),
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchTicketsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Tiket Saya",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4F46E5),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4F46E5),
          tabs: const [
            Tab(text: "Tiket Aktif"),
            Tab(text: "Riwayat"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: _handleRefresh,
            color: const Color(0xFF4F46E5),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : activeTickets.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                      const Center(
                        child: Text(
                          "Belum ada tiket aktif.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: activeTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = activeTickets[index];
                      // 🌟 PERBAIKAN 1: Berikan pelindung split agar aman dari out of bounds error
                      final String rawDate =
                          ticket['created_at']?.toString() ?? '';
                      final String parsedOrderDate = rawDate.contains('T')
                          ? rawDate.split('T')[0]
                          : (rawDate.isNotEmpty ? rawDate : '-');

                      return _buildTicketCard(
                        transactionId: ticket['transaction_id'],
                        event: ticket['event'],
                        status: ticket['status'],
                        // 🌟 PERBAIKAN: Trik Web - Gunakan ID Transaksi jika QR kosong
                        qrString: ticket['qr_string'].toString().isNotEmpty
                            ? ticket['qr_string']
                            : ticket['transaction_id'],
                        orderDate: parsedOrderDate,
                      );
                    },
                  ),
          ),
          RefreshIndicator(
            onRefresh: _handleRefresh,
            color: const Color(0xFF4F46E5),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : historyTickets.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                      const Center(
                        child: Text(
                          "Belum ada riwayat tiket.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: historyTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = historyTickets[index];
                      // 🌟 PERBAIKAN 2: Berikan pelindung split penangkal crash yang sama pada riwayat
                      final String rawDate =
                          ticket['created_at']?.toString() ?? '';
                      final String parsedOrderDate = rawDate.contains('T')
                          ? rawDate.split('T')[0]
                          : (rawDate.isNotEmpty ? rawDate : '-');

                      return _buildTicketCard(
                        transactionId: ticket['transaction_id'],
                        event: ticket['event'],
                        status: ticket['status'],
                        // 🌟 PERBAIKAN: Trik Web - Gunakan ID Transaksi jika QR kosong
                        qrString: ticket['qr_string'].toString().isNotEmpty
                            ? ticket['qr_string']
                            : ticket['transaction_id'],
                        orderDate: parsedOrderDate,
                        isHistory: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard({
    required String transactionId,
    required Event event,
    required String status,
    required String qrString,
    required String orderDate,
    bool isHistory = false,
  }) {
    bool isConfirmed = status.toLowerCase() == "confirmed";
    bool isCancelled =
        status.toLowerCase() == "cancelled" || status.toLowerCase() == "failed";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailEventScreen(event: event),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: event.isBase64Image && event.base64Bytes != null
                        // 🌟 JIKA GAMBAR DARI WEB (BASE64)
                        ? Image.memory(
                            event.base64Bytes!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                        // 🌟 JIKA GAMBAR DARI MOBILE (URL SUPABASE BIASA)
                        : Image.network(
                            event.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isConfirmed
                                ? const Color(0xFFDCFCE7)
                                : isCancelled
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isConfirmed
                                ? "CONFIRMED"
                                : isCancelled
                                ? "CANCELLED"
                                : "MENUNGGU VERIFIKASI",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isConfirmed
                                  ? const Color(0xFF166534)
                                  : isCancelled
                                  ? const Color(0xFF991B1B)
                                  : const Color(0xFF92400E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "ID: #${transactionId.substring(0, 8)}... • Dipesan $orderDate",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMiniDetail(
                  Icons.calendar_today_rounded,
                  // 🌟 PERBAIKAN 3: Amankan pemotongan string tanggal untuk file event di mini detail
                  event.date.contains('T')
                      ? event.date.split('T')[0]
                      : event.date,
                  const Color(0xFFEF4444),
                ),
                const SizedBox(height: 8),
                _buildMiniDetail(
                  Icons.access_time_filled_rounded,
                  "09:00 - 15:00 WIB",
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 8),
                _buildMiniDetail(
                  Icons.location_on_rounded,
                  event.venue.isEmpty ? event.location : event.venue,
                  const Color(0xFF10B981),
                ),
              ],
            ),
          ),
          if (!isHistory) ...[
            if (isConfirmed) ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Divider(height: 32, color: Color(0xFFF1F5F9)),
                    const Text(
                      "E-TICKET QR CODE",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _showFullQRCode(
                        context,
                        event.title,
                        transactionId,
                        qrString,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Hero(
                          tag: 'qr-$transactionId',
                          child: qrString.isEmpty
                              ? const Icon(
                                  Icons.qr_code_2_rounded,
                                  size: 120,
                                  color: Colors.grey,
                                )
                              : QrImageView(
                                  data: qrString,
                                  version: QrVersions.auto,
                                  size: 120.0,
                                  gapless: false,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Klik QR Code untuk memperbesar",
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showDownloadDialog(context),
                      icon: const Icon(
                        Icons.file_download_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        "Unduh PDF & Aturan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Divider(height: 32, color: Color(0xFFF1F5F9)),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFFD97706),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Selesaikan pembayaran atau unggah bukti transfer\ndi web agar admin dapat memverifikasi QR Code.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Menghubungi panitia acara..."),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.chat_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        "Hubungi Panitia (WA)",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          _showCancelConfirmation(context, transactionId),
                      child: const Text(
                        "Batalkan Pesanan",
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMiniDetail(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Aturan Acara TechLoca",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "1. Tunjukkan QR Code di pintu masuk.\n2. Datang 15 menit sebelum acara.\n3. Jangan bagikan E-Ticket ini.\n\nPDF Tiket berhasil diunduh ke folder internal.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Batalkan Pesanan?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Apakah kamu yakin ingin membatalkan pesanan tiket ini?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kembali", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelTicket(transactionId);
            },
            child: const Text(
              "Ya, Batalkan",
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullQRCode(
    BuildContext context,
    String title,
    String transactionId,
    String qrString,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Hero(
                  tag: 'qr-$transactionId',
                  child: qrString.isEmpty
                      ? const Icon(
                          Icons.qr_code_2_rounded,
                          size: 220,
                          color: Colors.grey,
                        )
                      : QrImageView(
                          data: qrString,
                          version: QrVersions.auto,
                          size: 220.0,
                          gapless: false,
                        ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Tunjukkan QR Code ini ke petugas meja registrasi",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "TUTUP",
                  style: TextStyle(
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
