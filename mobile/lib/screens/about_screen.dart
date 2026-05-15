import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tentang TechLoca",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LOGO & VERSI
            const Icon(Icons.code, size: 80, color: Color(0xFF4F46E5)),
            const SizedBox(height: 16),
            const Text(
              "TechLoca",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const Text("Versi 1.0.0", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            // DESKRIPSI (Sesuai Web)
            const Text(
              "TechLoca adalah platform manajemen event IT yang dirancang khusus untuk memfasilitasi mahasiswa dan komunitas teknologi dalam menemukan, mendaftar, dan mengelola sertifikat acara secara digital.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 32),

            // VISI & MISI (Sesuai Web)
            _buildInfoCard(
              "Visi Kami",
              "Menjadi pusat ekosistem kolaborasi IT terbesar yang menghubungkan talenta digital dengan kesempatan belajar yang inklusif.",
              Icons.auto_awesome_outlined,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              "Misi Kami",
              "Menyediakan akses pendaftaran event yang mudah, sistem absensi QR-Code yang cepat, dan distribusi sertifikat digital yang aman.",
              Icons.rocket_launch_outlined,
            ),

            const SizedBox(height: 40),
            const Text(
              "© 2026 TechLoca Team. All rights reserved.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
