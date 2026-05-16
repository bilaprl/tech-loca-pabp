import 'package:flutter/material.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // Data FAQ disesuaikan dengan fitur riel dari tabel database backend
  final List<Map<String, dynamic>> faqData = [
    {
      "id": 1,
      "q": "Bagaimana cara mencetak atau mengunduh E-Ticket?",
      "a":
          "E-Ticket dapat diakses langsung di menu 'Tiket Saya' segera setelah kamu melakukan pendaftaran slot. Tiket dilengkapi dengan QR Code enkreditasi unik untuk proses registrasi masuk.",
    },
    {
      "id": 2,
      "q": "Apakah saya bisa membatalkan tiket yang sudah diamankan?",
      "a":
          "Pembatalan pesanan secara mandiri hanya dapat dilakukan jika status transaksi kamu masih dalam tahap verifikasi admin web. Jika status sudah 'CONFIRMED', tombol pembatalan otomatis dinonaktifkan.",
    },
    {
      "id": 3,
      "q": "Bagaimana sistem absensi / check-in di lokasi acara?",
      "a":
          "Sangat praktis! Kamu hanya perlu menunjukkan QR Code yang ada pada kartu menu 'Tiket Saya' lewat layar HP. Panitia acara di meja registrasi akan memindai kode tersebut untuk mengubah status kehadiranmu menjadi Check-In secara real-time.",
    },
    {
      "id": 4,
      "q": "Kapan sertifikat digital akan saya dapatkan?",
      "a":
          "Sertifikat digital akan otomatis terbit dan masuk ke menu 'Kumpulan Sertifikat' setelah status pesanan kamu ditandai sudah melakukan check-in oleh sistem administrasi pasca acara selesai.",
    },
    {
      "id": 5,
      "q":
          "Apakah institusi/komunitas saya bisa berkolaborasi mengadakan event?",
      "a":
          "Tentu saja! Platform TechLoca sangat terbuka untuk partnership publikasi event IT. Kamu bisa menghubungi nomor administrasi WhatsApp yang tercantum di menu Profile untuk pengajuan integrasi database event baru.",
    },
  ];

  // FUNGSI PULL-TO-REFRESH (Pusat bantuan langsung merespon refresh instan)
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        // Logika refresh lokal untuk membersihkan cache rendering komponen UI
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pusat Bantuan (FAQ)",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // INTEGRASI FITUR PULL-TO-REFRESH
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF4F46E5),
        child: ListView.builder(
          physics:
              const AlwaysScrollableScrollPhysics(), // Menjamin area layar selalu responsif ditarik
          padding: const EdgeInsets.all(20),
          itemCount: faqData.length,
          itemBuilder: (context, index) {
            final faq = faqData[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.04,
                    ), // 🌟 PERBAIKAN: Dari 0.5 menjadi 0.04 agar bayangan halus/estetik
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ExpansionTile(
                shape: const Border(),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: Text(
                    "${faq['id']}",
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  faq['q'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      faq['a'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
