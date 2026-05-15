import 'package:flutter/material.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Kumpulan ",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              "Sertifikat",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFFF59E0B),
              ),
            ), // Warna oranye
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Apresiasi atas dedikasi dan partisipasimu. Unduh sertifikat digital dengan Credential ID resmi dari setiap acara TechLoca yang telah kamu selesaikan.",
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Kartu Sertifikat 1
            _buildCertificateCard(
              title: "Web Dev Bootcamp Unsil",
              organizer: "Informatika Unsil",
              date: "24 Mei 2026",
              id: "TL-C2026-0001X",
              img:
                  "https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=800",
            ),
            const SizedBox(height: 20),

            // Kartu Sertifikat 2
            _buildCertificateCard(
              title: "UI/UX Masterclass",
              organizer: "Tasik Design Hub",
              date: "02 Juni 2026",
              id: "TL-C2026-0002X",
              img:
                  "https://images.unsplash.com/photo-1561070791-2526d30994b5?q=80&w=600",
            ),
          ],
        ),
      ),
    );
  }

  // Desain Kartu Sertifikat menyesuaikan UI Web
  Widget _buildCertificateCard({
    required String title,
    required String organizer,
    required String date,
    required String id,
    required String img,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.amber.shade200,
          width: 1.5,
        ), // Border kuning halus
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Kiri: Gambar
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  img,
                  width: 100,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Bagian Kanan: Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge Verified
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.amber.shade700,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "VERIFIED",
                        style: TextStyle(
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Info Penyelenggara & Tanggal
                Row(
                  children: [
                    const Icon(
                      Icons.business_rounded,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Penyelenggara: $organizer",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Diterbitkan: $date",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Credential ID
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "ID: $id",
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tombol Unduh & Share
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Unduh PDF",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF0F172A,
                          ), // Warna gelap seperti web
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.share_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onPressed: () {},
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
