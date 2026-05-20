import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../event_model.dart';
import 'dart:convert';
import 'dart:typed_data';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  List<Map<String, dynamic>> certificates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
  }

  // FUNGSI AMBIL DATA SERTIFIKAT DENGAN JOIN MULTI-TABEL
  Future<void> _fetchCertificates() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // Join Query: certificates -> transactions -> events
      final response = await Supabase.instance.client
          .from('certificates')
          .select('*, transactions!inner(*, events(*))')
          .eq('transactions.user_id', user.id)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> loadedCertificates = [];

      for (var item in response as List) {
        final transaction = item['transactions'];
        if (transaction != null && transaction['events'] != null) {
          final eventObj = Event.fromJson(transaction['events']);

          // 🌟 PERBAIKAN 1: Amankan pemotongan string UUID sertifikat agar kebal dari null data crash
          final String rawCertId = item['id']?.toString() ?? '';
          final String safeCertId = rawCertId.length >= 8
              ? rawCertId.substring(0, 8).toUpperCase()
              : 'UNKNOWN';

          // 🌟 PERBAIKAN 2: Amankan pemotongan format tanggal ISO murni dari database
          final String rawCreatedAt = item['created_at']?.toString() ?? '';
          final String parsedDate = rawCreatedAt.contains('T')
              ? rawCreatedAt.split('T')[0]
              : (rawCreatedAt.isNotEmpty ? rawCreatedAt : '-');

          loadedCertificates.add({
            'id': safeCertId, // Credential ID aman
            'file_url': item['file_url'] ?? '',
            'date': parsedDate,
            'event': eventObj,
          });
        }
      }

      if (mounted) {
        setState(() {
          certificates = loadedCertificates;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Certificates: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // FUNGSI BUKA URL PDF SERTIFIKAT
  Future<void> _downloadCertificate(String urlString) async {
    if (urlString.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File URL sertifikat belum tersedia")),
      );
      return;
    }

    final Uri url = Uri.parse(urlString.trim());
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka file sertifikat")),
        );
      }
    }
  }

  // FUNGSI PULL-TO-REFRESH
  Future<void> _handleRefresh() async {
    await _fetchCertificates();
  }

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
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF4F46E5),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : certificates.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  const Center(
                    child: Text(
                      "Belum ada sertifikat yang diterbitkan.\nSelesaikan event kamu terlebih dahulu!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, height: 1.5),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: certificates.length,
                itemBuilder: (context, index) {
                  final cert = certificates[index];
                  final Event event = cert['event'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildCertificateCard(
                      title: event.title,
                      organizer: event.eo,
                      date: cert['date'],
                      id: "TL-CERT-${cert['id']}",
                      img: event
                          .imageUrl, // 🌟 PERBAIKAN: Kembalikan menjadi 'img'
                      fileUrl: cert['file_url'],
                    ),
                  );
                },
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
    required String fileUrl,
  }) {
    // 🌟 PERBAIKAN: Proteksi Null agar aplikasi tidak crash kalau gambarnya kosong
    final String safeImg = img.trim().isEmpty ? '' : img;
    bool isBase64 = safeImg.startsWith('data:image');
    Uint8List? bytes;

    if (isBase64) {
      try {
        bytes = base64Decode(safeImg.split(',').last);
      } catch (e) {
        isBase64 = false;
      }
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.shade200, width: 1.5),
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
          // Bagian Kiri: Gambar Cover Event
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: isBase64 && bytes != null
                    // 🌟 JIKA GAMBAR DARI WEB (BASE64)
                    ? Image.memory(
                        bytes,
                        width: 100,
                        height:
                            120, // 🌟 PERBAIKAN: Beri tinggi yang pasti (misal 120) agar layout tidak crash
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 120,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    // 🌟 JIKA GAMBAR DARI MOBILE (URL)
                    : Image.network(
                        safeImg, // Gunakan safeImg yang sudah diproteksi dari null
                        width: 100,
                        height:
                            120, // 🌟 PERBAIKAN: Beri tinggi yang pasti (misal 120)
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 120,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
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

          // Bagian Kanan: Detail Informasi Sertifikat
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
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
                        organizer.isEmpty ? "Penyelenggara" : "EO: $organizer",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    id,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadCertificate(fileUrl),
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
                          backgroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
                        onPressed: () {
                          if (fileUrl.trim().isEmpty) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Link sertifikat disalin!"),
                            ),
                          );
                        },
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
