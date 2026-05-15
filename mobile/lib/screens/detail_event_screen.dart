import 'package:flutter/material.dart';
import '../event_model.dart';
import '../main.dart';

class DetailEventScreen extends StatefulWidget {
  final Event event;
  const DetailEventScreen({super.key, required this.event});

  @override
  State<DetailEventScreen> createState() => _DetailEventScreenState();
}

class _DetailEventScreenState extends State<DetailEventScreen> {
  late bool isWishlisted = widget.event.isWishlisted;
  bool isMapVisible = false;
  bool isBooked = false;

  @override
  void initState() {
    super.initState();
    // Mengambil status asli dari data event yang dikirim
    isWishlisted = widget.event.isWishlisted;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSoldOut = widget.event.quota <= 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVisualHeader(),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryBadge(),
                      const SizedBox(height: 16),
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildOrganizerInfo(),

                      const SizedBox(height: 24),

                      // --- PERBAIKAN DI SINI: MENAMBAHKAN WARNA WARNI PADA IKON ---
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              Icons.calendar_today_rounded,
                              "TANGGAL",
                              widget.event.date,
                              const Color(0xFFEF4444), // MERAH untuk Tanggal
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              Icons.access_time_filled_rounded,
                              "WAKTU",
                              "09:00 WIB",
                              const Color(
                                0xFFF59E0B,
                              ), // KUNING/ORANGE untuk Waktu
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        Icons.location_on_rounded,
                        "LOKASI ACARA",
                        widget.event.venue,
                        const Color(0xFF10B981), // HIJAU untuk Lokasi
                      ),

                      const SizedBox(height: 32),
                      const Text(
                        "Tentang Acara",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.event.desc,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.6,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TOMBOL STICKY DI BAWAH (Kode tetap sama)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildQuotaIndicator(isSoldOut),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isSoldOut
                          ? null
                          : () {
                              if (!isBooked) {
                                setState(() => isBooked = true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Slot berhasil diamankan!"),
                                    backgroundColor: Color(0xFF10B981),
                                  ),
                                );
                              } else {
                                mainNavKey.currentState?.changeTab(2);
                                Navigator.pop(context);
                              }
                            },
                      icon: Icon(
                        isSoldOut
                            ? Icons.block
                            : (isBooked
                                  ? Icons.confirmation_number_rounded
                                  : Icons.check_circle_outline),
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        isSoldOut
                            ? "Kuota Penuh"
                            : (isBooked
                                  ? "Lihat E-Ticket Saya"
                                  : "Amankan Slot Sekarang"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBooked
                            ? const Color(0xFF10B981)
                            : const Color(0xFF4F46E5),
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildOrganizerInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Color(0xFF4F46E5),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Diselenggarakan oleh",
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              Text(
                widget.event.eo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // PERBAIKAN: Menambahkan parameter iconColor
  Widget _buildInfoCard(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // IKON SEKARANG MENGIKUTI WARNA DARI PARAMETER
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualHeader() {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: isMapVisible
              ? Container(
                  key: const ValueKey(1),
                  height: 350,
                  width: double.infinity,
                  color: const Color(0xFFE2E8F0),
                  child: Center(
                    child: Text(
                      "Simulasi Peta: ${widget.event.venue}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : Image.network(
                  key: const ValueKey(2),
                  widget.event.img,
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  isWishlisted = !isWishlisted;
                  // UPDATE DATA PUSAT DI SINI:
                  widget.event.isWishlisted = isWishlisted;
                });

                // Tambahkan Snackback agar user tahu statusnya
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isWishlisted
                          ? "Ditambahkan ke Wishlist"
                          : "Dihapus dari Wishlist",
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: isWishlisted
                        ? const Color(0xFF4F46E5)
                        : Colors.red,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => isMapVisible = !isMapVisible),
            icon: Icon(
              isMapVisible ? Icons.image : Icons.map_outlined,
              size: 18,
            ),
            label: Text(
              isMapVisible ? "Lihat Foto" : "Lihat Peta",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuotaIndicator(bool isSoldOut) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "KETERSEDIAAN TIKET",
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          isSoldOut ? "HABIS TERJUAL" : "${widget.event.quota} KURSI",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isSoldOut ? Colors.red : const Color(0xFF4F46E5),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.event.category.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF4F46E5),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
