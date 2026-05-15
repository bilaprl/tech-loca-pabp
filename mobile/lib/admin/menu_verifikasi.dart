import 'package:flutter/material.dart';
import 'package:mobile/services/notification_service.dart';

class MenuVerifikasiAdmin extends StatefulWidget {
  const MenuVerifikasiAdmin({super.key});

  @override
  State<MenuVerifikasiAdmin> createState() => _MenuVerifikasiAdminState();
}

class _MenuVerifikasiAdminState extends State<MenuVerifikasiAdmin> {
  List<Map<String, dynamic>> pesertaList = [
    {
      "nama": "Muthia Anggraeni",
      "event": "Workshop Flutter Basic",
      "status": "Pending",
      "tanggal": "14 Mei 2026",
      "no_tiket": "TCK-029-2026",
      "bukti":
          "https://raw.githubusercontent.com/muthiaanggraeni/flutter-assets/main/bukti-transfer-bca-dummy.png",
    },
    {
      "nama": "Budi Santoso",
      "event": "UI/UX Design Masterclass",
      "status": "Berhasil",
      "tanggal": "12 Mei 2026",
      "no_tiket": "TCK-112-2026",
      "bukti":
          "https://raw.githubusercontent.com/muthiaanggraeni/flutter-assets/main/bukti-transfer-bca-dummy.png",
    },
  ];

  String selectedCategory = "SEMUA ACARA";

  void _showDetailVerifikasi(BuildContext context, int index) {
    final peserta = pesertaList[index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Verifikasi Pembayaran",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      "Order ID: #${peserta['no_tiket'].split('-')[1]}",
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.cancel,
                    color: Color(0xFFF1F5F9),
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          "https://ui-avatars.com/api/?name=${peserta['nama']}&background=random",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF94A3B8),
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            peserta['nama'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const Text(
                            "UNIVERSITAS SILIWANGI",
                            style: TextStyle(
                              color: Color(0xFF4F46E5),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),
                  _buildIconInfo(
                    Icons.alternate_email_rounded,
                    "${peserta['nama'].toLowerCase().replaceAll(' ', '.')}@student.unsil.ac.id",
                  ),
                  const SizedBox(height: 12),
                  _buildIconInfo(Icons.smartphone_rounded, "081234567890"),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "WORKSHOP YANG DIPILIH",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peserta['event'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${peserta['tanggal'].toUpperCase()} • GEDUNG REKTORAT LT. 2",
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              "No. Tiket",
              peserta['no_tiket'],
            ), // Memanggil fungsi agar tidak unused
            const SizedBox(height: 24),
            const Text(
              "Pastikan bukti transfer di WhatsApp sudah sesuai sebelum konfirmasi.",
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      foregroundColor: const Color(0xFF94A3B8),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "TUTUP",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (peserta['status'] == "Pending")
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        setState(() => peserta['status'] = "Berhasil");
                        Navigator.pop(context);

                        // TRIGGER NOTIFIKASI LOKAL
                        NotificationService.showNotification(
                          id: 1,
                          title: "Pembayaran Berhasil! ✅",
                          body:
                              "Tiket untuk ${peserta['nama']} telah diverifikasi.",
                        );

                        _showTopSnackBar(
                          context,
                          "✅ Pembayaran Berhasil Dikonfirmasi!",
                        );
                      },
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text(
                        "KONFIRMASI",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildIconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF475569)),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showTopSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4F46E5),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredList = selectedCategory == "SEMUA ACARA"
        ? pesertaList
        : pesertaList
              .where((p) => p['event'].toUpperCase() == selectedCategory)
              .toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Verifikasi Tiket",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: Color(0xFF6366F1)),
                SizedBox(width: 8),
                Text(
                  "PILIH ACARA UNTUK VERIFIKASI",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterCard(
                  "SEMUA ACARA",
                  Icons.all_inclusive_rounded,
                  "",
                ),
                _buildFilterCard(
                  "WORKSHOP FLUTTER BASIC",
                  Icons.confirmation_number_rounded,
                  "1 Pending",
                ),
                _buildFilterCard(
                  "UI/UX DESIGN MASTERCLASS",
                  Icons.confirmation_number_rounded,
                  "1 Pending",
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final p = filteredList[index];
                bool isSuccess = p['status'] == "Berhasil";
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF1F5F9),
                      backgroundImage: NetworkImage(
                        "https://ui-avatars.com/api/?name=${p['nama']}&background=random",
                      ),
                    ),
                    title: Text(
                      p['nama'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      p['event'],
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF9C3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p['status'].toUpperCase(),
                        style: TextStyle(
                          color: isSuccess
                              ? const Color(0xFF166534)
                              : const Color(0xFF854D0E),
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    onTap: () =>
                        _showDetailVerifikasi(context, pesertaList.indexOf(p)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(String title, IconData icon, String subtitle) {
    bool isSelected = selectedCategory == title;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = title),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEEF2FF)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
