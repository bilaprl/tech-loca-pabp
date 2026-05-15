import 'package:flutter/material.dart';

class MenuIkhtisar extends StatelessWidget {
  const MenuIkhtisar({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "IKHTISAR SISTEM",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 16),

          // Statistik Cards dengan warna yang lebih tegas (Solid)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildWebCard(
                "TOTAL MEMBER",
                "1,284",
                "↑ 12% minggu ini",
                const Color(0xFF4F46E5),
                const Color(0xFFEEF2FF),
              ),
              _buildWebCard(
                "TICKET CONFIRMED",
                "842",
                "Siap check-in",
                const Color(0xFF059669),
                const Color(0xFFECFDF5),
              ),
              _buildWebCard(
                "PENDING PAYMENT",
                "43",
                "Perlu verifikasi",
                const Color(0xFFD97706),
                const Color(0xFFFFFBEB),
              ),
              _buildWebCard(
                "PLATFORM STATUS",
                "LIVE",
                "Region: Jakarta",
                const Color(0xFF1E293B),
                const Color(0xFFF1F5F9),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Text(
            "TRAFIK PENDAFTARAN (7 HARI TERAKHIR)",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 16),

          // Grafik Trafik dengan Sumbu X (Info Hari)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _webBoxDecoration(),
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBar(40, "Sen"),
                      _buildBar(70, "Sel"),
                      _buildBar(50, "Rab"),
                      _buildBar(90, "Kam"),
                      _buildBar(60, "Jum"),
                      _buildBar(100, "Sab"),
                      _buildBar(80, "Min"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Text(
            "LOG AKTIVITAS PESERTA",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: _webBoxDecoration(),
            child: Column(
              children: [
                _buildWebLog(
                  "Muthia Anggraeni",
                  "Mendaftar di Workshop UI/UX",
                  "Baru saja",
                  Icons.person_add_rounded,
                  const Color(0xFF4F46E5),
                ),
                const Divider(height: 1, indent: 60),
                _buildWebLog(
                  "Budi Santoso",
                  "Melakukan upload bukti bayar",
                  "10 mnt lalu",
                  Icons.payments_rounded,
                  const Color(0xFF10B981),
                ),
                const Divider(height: 1, indent: 60),
                _buildWebLog(
                  "Siti Aminah",
                  "Berhasil check-in (Gate A)",
                  "25 mnt lalu",
                  Icons.qr_code_scanner_rounded,
                  const Color(0xFF6366F1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebCard(
    String label,
    String value,
    String sub,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor, // Warna background card yang lebih cerah tapi tegas
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: textColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, String day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 25,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildWebLog(
    String user,
    String act,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        user,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        act,
        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
      ),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  BoxDecoration _webBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
