import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data FAQ dari web yang kamu berikan
    final List<Map<String, dynamic>> faqData = [
      {
        "id": 1,
        "q": "Bagaimana cara mencetak atau mengunduh E-Ticket?",
        "a":
            "E-Ticket dapat diunduh di menu 'Tiket Saya' setelah kamu menyelesaikan proses registrasi. Tiket akan berbentuk file PDF yang berisi QR Code eksklusif milikmu.",
      },
      {
        "id": 2,
        "q": "Apakah saya bisa membatalkan tiket yang sudah diamankan?",
        "a":
            "Pembatalan hanya dapat dilakukan jika status tiket masih 'Menunggu Pembayaran'. Jika tiket sudah terkonfirmasi (Confirmed), tiket tidak dapat dibatalkan sesuai kebijakan sistem kami.",
      },
      {
        "id": 3,
        "q": "Bagaimana sistem absensi / check-in di lokasi acara?",
        "a":
            "Sangat mudah! Cukup tunjukkan QR Code E-Ticket kamu melalui layar HP. Tim TechLoca di lokasi akan men-scan kode tersebut untuk memverifikasi kehadiranmu dengan cepat.",
      },
      {
        "id": 4,
        "q": "Kapan sertifikat digital akan saya dapatkan?",
        "a":
            "Sertifikat akan otomatis diterbitkan ke halaman 'Kumpulan Sertifikat' dalam waktu maksimal 2x24 jam setelah acara selesai, dengan syarat kamu telah di-scan hadir oleh panitia di lokasi.",
      },
      {
        "id": 5,
        "q":
            "Apakah institusi/komunitas saya bisa berkolaborasi mengadakan event?",
        "a":
            "Tentu saja! TechLoca dikelola secara eksklusif oleh tim internal kami, namun kami sangat terbuka untuk partnership. Jika kamu punya event IT dan ingin bekerjasama agar tayang di platform kami, silakan hubungi tim kami via WhatsApp.",
      },
    ];

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
      body: ListView.builder(
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
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ExpansionTile(
              shape: const Border(), // Menghilangkan garis border bawaan
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
    );
  }
}
