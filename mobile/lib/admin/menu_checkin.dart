import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MenuCheckInAdmin extends StatefulWidget {
  const MenuCheckInAdmin({super.key});

  @override
  State<MenuCheckInAdmin> createState() => _MenuCheckInAdminState();
}

class _MenuCheckInAdminState extends State<MenuCheckInAdmin> {
  String selectedEvent = "";
  String selectedEventId = "";

  List<Map<String, dynamic>> rawEventsList = [];
  bool isLoading = true;
  bool isScanningActive = false; // Mencegah double scan berturut-turut

  @override
  void initState() {
    super.initState();
    _fetchActiveEvents();
  }

  // ==================== AMBIL DATA FILTER EVENT DARI SUPABASE ====================
  Future<void> _fetchActiveEvents() async {
    try {
      final response = await Supabase.instance.client
          .from('events')
          .select('id, title')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> loadedEvents = [];
      for (var item in response as List) {
        loadedEvents.add({
          'id': item['id'].toString(),
          'title': item['title'] ?? 'Event Tanpa Nama',
        });
      }

      if (mounted) {
        setState(() {
          rawEventsList = loadedEvents;
          if (loadedEvents.isNotEmpty) {
            // Set default pilihan pertama jika belum ada yang dipilih
            selectedEvent = loadedEvents.first['title'];
            selectedEventId = loadedEvents.first['id'];
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Events Dropdown: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ==================== PROSES VALIDASI CHECK-IN DI DATABASE ====================
  Future<void> _processCheckIn(String qrCodePayload) async {
    if (selectedEventId.isEmpty) return;

    try {
      final supabase = Supabase.instance.client;

      // 1. Cari tiket berdasarkan string QR Code dari database
      final transaction = await supabase
          .from('transactions')
          .select('id, event_id, status, is_checked_in, profiles(full_name)')
          .eq('qr_code_string', qrCodePayload)
          .maybeSingle();

      if (transaction == null) {
        _showStatusSnackBar(
          context,
          "❌ Gagal: QR Code Tidak Terdaftar!",
          Colors.redAccent,
        );
        return;
      }

      final String transId = transaction['id'];
      final String eventIdInTicket = transaction['event_id'].toString();
      final String status = transaction['status'] ?? 'pending';
      final bool isAlreadyCheckedIn = transaction['is_checked_in'] ?? false;
      final String namaPeserta =
          transaction['profiles']?['full_name'] ?? 'Peserta';

      // 2. Validasi kesesuaian Event Gate
      if (eventIdInTicket != selectedEventId) {
        _showStatusSnackBar(
          context,
          "⚠️ Salah Gate! Tiket ini untuk event lain.",
          Colors.orangeAccent,
        );
        return;
      }

      // 3. Validasi Status Pembayaran
      if (status.toLowerCase() != 'confirmed') {
        _showStatusSnackBar(
          context,
          "❌ Gagal: Pembayaran belum diverifikasi admin!",
          Colors.red,
        );
        return;
      }

      // 4. Validasi jika sudah pernah melakukan check-in sebelumnya
      if (isAlreadyCheckedIn) {
        _showStatusSnackBar(
          context,
          "⚠️ Perhatian: $namaPeserta sudah masuk sebelumnya!",
          Colors.amber.shade700,
        );
        return;
      }

      // 5. Sukses lolos validasi, update status is_checked_in ke database
      await supabase
          .from('transactions')
          .update({'is_checked_in': true})
          .eq('id', transId);

      _showStatusSnackBar(
        context,
        "✅ Berhasil Check-In: $namaPeserta siap masuk!",
        Colors.green,
      );
    } catch (e) {
      debugPrint("Error Processing CheckIn backend: $e");
      _showStatusSnackBar(context, "❌ Error sistem verifikasi", Colors.red);
    }
  }

  // --- FITUR PULL-TO-REFRESH ---
  Future<void> _handleRefresh() async {
    await _fetchActiveEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF4F46E5),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KARTU HITAM: EVENT TERPILIH
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "EVENT TERPILIH",
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedEvent.isEmpty
                                ? "Belum Ada Acara Aktif"
                                : selectedEvent,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // KARTU KONFIGURASI GATE
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.event_available_rounded,
                                  color: Color(0xFF6366F1),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Konfigurasi Gate",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    "Pilih event aktif",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // DROPDOWN DINAMIS
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedEventId.isEmpty
                                    ? null
                                    : selectedEventId,
                                isExpanded: true,
                                hint: const Text("Pilih Event Aktif"),
                                items: rawEventsList
                                    .map(
                                      (item) => DropdownMenuItem<String>(
                                        value: item['id'],
                                        child: Text(
                                          item['title'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  final match = rawEventsList.firstWhere(
                                    (e) => e['id'] == val,
                                  );
                                  setState(() {
                                    selectedEventId = val!;
                                    selectedEvent = match['title'];
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // TOMBOL BUKA GERBANG SCAN
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: rawEventsList.isEmpty
                                  ? null
                                  : () => _openScanner(context),
                              icon: const Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: const Text(
                                "BUKA GERBANG SCAN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ==================== LEMBAR SCANNER KAMERA LIVE ====================
  void _openScanner(BuildContext context) {
    setState(() => isScanningActive = true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Stack(
          children: [
            MobileScanner(
              onDetect: (capture) {
                if (!isScanningActive)
                  return; // Mengunci scanner agar tidak spamming data masuk

                final barcode = capture.barcodes.first;
                if (barcode.rawValue != null) {
                  // 🌟 PERBAIKAN UTAMA: Setel status pemindai menjadi false SEBELUM menutup navigasi,
                  // agar siklus data pendeteksian kamera kembali murni dan tidak mengunci tombol.
                  isScanningActive = false;
                  Navigator.pop(context);
                  _processCheckIn(
                    barcode.rawValue!,
                  ); // Eksekusi validasi data database rill
                }
              },
            ),
            // Scanner Overlay Frame
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF6366F1), width: 3),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            // Indikator teks petunjuk di dalam kamera
            const Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Posisikan QR Code Tiket di Dalam Kotak",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // 🌟 PENGAMAT LIFECYCLE SHEET: Jika admin menutup lembar kamera secara manual tanpa scan,
      // paksa status penunjuk kembali ke false agar tombol tidak mogok di pemakaian berikutnya.
      if (mounted && isScanningActive) {
        setState(() => isScanningActive = false);
      }
    });
  }

  void _showStatusSnackBar(
    BuildContext context,
    String message,
    Color bgColor,
  ) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
