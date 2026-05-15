import 'package:flutter/material.dart';
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

  Map<dynamic, dynamic>? offlineTicket;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initOfflineData();
  }

  void _initOfflineData() {
    final savedData = TicketService.getSavedTicket();
    if (savedData != null) {
      setState(() {
        offlineTicket = savedData;
      });
    } else {
      // Jika pertama kali buka, simpan data tiket pertama ke cache
      if (mockEvents.isNotEmpty) {
        final dummyToCache = {
          "title": mockEvents[0].title,
          "id": mockEvents[0].id,
          "date": mockEvents[0].date,
          "venue": mockEvents[0].venue,
          "orderId": "TL-88291029",
        };
        TicketService.saveTicket(dummyToCache);
        setState(() {
          offlineTicket = dummyToCache;
        });
      }
    }
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
          // Ganti isi ListView di Tab 1 dengan ini:
          ListView(
            padding: const EdgeInsets.all(20),
            children: mockEvents.asMap().entries.map((entry) {
              int index = entry.key; // Ini adalah 'index' yang dicari Flutter
              var event = entry.value;

              return _buildTicketCard(
                event: event,
                status: index == 0 ? "confirmed" : "pending",
                orderId: offlineTicket != null && index == 0
                    ? offlineTicket!['orderId']
                    : "TL-882910${29 + index}",
                orderDate: "12 Mei 2026",
                index: index,
              );
            }).toList(),
          ),
          const Center(
            child: Text(
              "Belum ada riwayat tiket.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard({
    required Event event,
    required String status,
    required String orderId,
    required String orderDate,
    required int index,
  }) {
    bool isConfirmed = status == "confirmed";

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
                    child: Image.network(
                      event.img,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      // TAMBAHKAN INI: Supaya kalau offline tidak muncul kotak kuning-hitam
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        );
                      },
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
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isConfirmed ? "CONFIRMED" : "MENUNGGU PEMBAYARAN",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isConfirmed
                                  ? const Color(0xFF166534)
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
                        // INFO ORDER ID & TANGGAL PESAN (BARU)
                        Text(
                          "ID: #$orderId • Dipesan $orderDate",
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
                  event.date,
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
                  event.venue,
                  const Color(0xFF10B981),
                ),
              ],
            ),
          ),

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
                    onTap: () => _showFullQRCode(context, event),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Hero(
                        tag: 'qr-${event.id}',
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          size: 120,
                          color: Color(0xFF0F172A),
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
            // BAGIAN MENUNGGU PEMBAYARAN (PENDING)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Divider(height: 32, color: Color(0xFFF1F5F9)),

                  // ICON DOMPET KECIL (Sesuai Mockup Web)
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
                    "Selesaikan pembayaran untuk\nmendapatkan QR Code.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // TOMBOL LANJUT KE WA (WARNA UNGU INDIGO)
                  ElevatedButton.icon(
                    onPressed: () {
                      // Simulasi buka WhatsApp
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Membuka WhatsApp Admin..."),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.chat_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      "Lanjut ke WA",
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

                  // TOMBOL BATALKAN PESANAN (WARNA MERAH)
                  TextButton(
                    onPressed: () => _showCancelConfirmation(context, index),
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
          "1. Tunjukkan QR Code di pintu masuk.\n2. Datang 15 menit sebelum acara.\n3. Jangan bagikan E-Ticket ini.\n\nPDF sedang diproses...",
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

  // FUNGSI POP-UP KONFIRMASI BATAL
  void _showCancelConfirmation(BuildContext context, int index) {
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
              // PROSES MENGHAPUS TIKET DARI LIST
              setState(() {
                mockEvents.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Pesanan berhasil dibatalkan"),
                  backgroundColor: Colors.red,
                ),
              );
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

  void _showFullQRCode(BuildContext context, Event event) {
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
                event.title,
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
                  tag: 'qr-${event.id}',
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    size: 220,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Tunjukkan QR Code ini ke petugas",
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
