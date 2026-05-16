import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Import untuk akses file
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/services/notification_service.dart';

class MenuCertificateAdmin extends StatefulWidget {
  const MenuCertificateAdmin({super.key});

  @override
  State<MenuCertificateAdmin> createState() => _MenuCertificateAdminState();
}

class _MenuCertificateAdminState extends State<MenuCertificateAdmin> {
  String selectedCategory = "SEMUA";
  String? selectedFileName; // Menyimpan nama file yang dipilih

  PlatformFile? pickedFile; // Menyimpan data file mentah untuk diupload
  List<Map<String, dynamic>> pesertaSertif = [];
  List<String> filterCategories = ["SEMUA"];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCertificateData();
  }

  // ==================== AMBIL DATA REAL DARI BACKEND ====================
  Future<void> _fetchCertificateData() async {
    try {
      final supabase = Supabase.instance.client;

      // Ambil transaksi confirmed beserta profil, event, dan join tabel certificates
      final response = await supabase
          .from('transactions')
          .select('*, profiles(*), events(*), certificates(id, file_url)')
          .eq('status', 'confirmed')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> loadedPeserta = [];
      final Set<String> eventTitles = {"SEMUA"};

      for (var item in response as List) {
        final profile = item['profiles'];
        final event = item['events'];
        final certs = item['certificates'] as List?;

        if (profile != null && event != null) {
          final String eventTitle = event['title'] ?? 'Event';
          eventTitles.add(eventTitle.toUpperCase());

          // Jika record di tabel certificates ada, maka status sudah TERKIRIM
          bool hasCert = certs != null && certs.isNotEmpty;

          loadedPeserta.add({
            "transaction_id": item['id'],
            "nama": profile['full_name'] ?? 'Anonim',
            "event": eventTitle.toUpperCase(),
            "status": hasCert ? "TERKIRIM" : "MENUNGGU",
            "email": profile['email'] ?? '-',
          });
        }
      }

      if (mounted) {
        setState(() {
          pesertaSertif = loadedPeserta;
          filterCategories = eventTitles.toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Certificate Admin: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ==================== PROSES PICK FILE DARI DEVICE ====================
  Future<void> _pickCertificateFile(StateSetter setModalState) async {
    try {
      // 🌟 PERBAIKAN 1: Menghapus '.platform' agar mutlak sinkron dengan FilePicker v11.0.2
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
        allowMultiple: false,
      );

      if (result != null) {
        setModalState(() {
          pickedFile = result.files.single;
          selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      debugPrint("Error saat memilih file: $e");
    }
  }

  // ==================== UPLOAD TO STORAGE & INSERT DATABASE ====================
  Future<void> _uploadAndSendCertificate(
    Map<String, dynamic> peserta,
    StateSetter setModalState,
  ) async {
    if (pickedFile == null) return;

    try {
      final supabase = Supabase.instance.client;
      final transId = peserta['transaction_id'];

      // 1. Upload file ke Supabase Storage Bucket 'certificates'
      final fileBytes = pickedFile!.bytes;
      final fileName =
          "${transId}_${DateTime.now().millisecondsSinceEpoch}.${pickedFile!.extension}";

      if (fileBytes != null) {
        await supabase.storage
            .from('certificates')
            .uploadBinary(fileName, fileBytes);
      } else if (pickedFile!.path != null) {
        final ioFile = File(pickedFile!.path!);
        final bytes = await ioFile.readAsBytes();
        await supabase.storage
            .from('certificates')
            .uploadBinary(fileName, bytes);
      }

      // 2. Dapatkan Public URL File yang diunggah
      final String fileUrl = supabase.storage
          .from('certificates')
          .getPublicUrl(fileName);

      // 3. Masukkan data ke tabel certificates backend
      await supabase.from('certificates').insert({
        'transaction_id': transId,
        'file_url': fileUrl,
      });

      // 4. Update status lokal & trigger Notifikasi Sistem
      setState(() => peserta['status'] = "TERKIRIM");

      await NotificationService.showNotification(
        id: transId.hashCode,
        title: "Sertifikat Terbit! 🎓",
        body: "Sertifikat untuk ${peserta['nama']} telah dikirim ke email.",
        type: "cert",
      );

      _fetchCertificateData(); // Refresh data live
    } catch (e) {
      debugPrint("Error Upload Certificate: $e");
    }
  }

  // ==================== PULL-TO-REFRESH LOGIC ====================
  Future<void> _handleRefresh() async {
    await _fetchCertificateData();
  }

  void _showUploadDialog(BuildContext context, Map<String, dynamic> peserta) {
    selectedFileName = null;
    pickedFile = null;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Kirim Sertifikat",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Pilih file sertifikat untuk dikirim ke ${peserta['email']}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 32),

              // Area Drop Zone / Click to Upload
              GestureDetector(
                onTap: isUploading
                    ? null
                    : () => _pickCertificateFile(setModalState),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.attachment_rounded,
                        size: 40,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        selectedFileName ?? "Klik untuk pilih file (PDF/JPG)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedFileName != null
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: isUploading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: (selectedFileName == null || isUploading)
                          ? null
                          : () async {
                              setModalState(() => isUploading = true);
                              await _uploadAndSendCertificate(
                                peserta,
                                setModalState,
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                                _showTopSnackBar(
                                  context,
                                  "🚀 Sertifikat berhasil dikirim!",
                                );
                              }
                            },
                      child: isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Kirim Sekarang",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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
    List<Map<String, dynamic>> filteredList = selectedCategory == "SEMUA"
        ? pesertaSertif
        : pesertaSertif.where((p) => p['event'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Penerbitan Sertifikat",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF4F46E5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Kategori Horizontal Dinamis
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: filterCategories
                    .map(
                      (cat) => _buildFilterBtn(
                        cat,
                        cat == "SEMUA"
                            ? Icons.grid_view_rounded
                            : Icons.star_outline_rounded,
                      ),
                    )
                    .toList(),
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        const Center(
                          child: Text(
                            "Belum ada peserta terverifikasi.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final p = filteredList[index];
                        bool isSent = p['status'] == "TERKIRIM";

                        // 🌟 PERBAIKAN 2: Berikan pengaman substring karakter pertama nama agar kebal Crash RangeError
                        final String namaPesertaRaw =
                            p['nama']?.toString().trim() ?? 'A';
                        final String initialChar = namaPesertaRaw.isNotEmpty
                            ? namaPesertaRaw[0].toUpperCase()
                            : 'A';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFF1F5F9),
                                child: Text(
                                  initialChar, // Pakai inisial yang aman
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p['nama'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      p['event'],
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSent
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      p['status'],
                                      style: TextStyle(
                                        color: isSent
                                            ? Colors.green
                                            : Colors.grey,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  IconButton(
                                    onPressed: isSent
                                        ? null
                                        : () => _showUploadDialog(context, p),
                                    icon: Icon(
                                      Icons.cloud_upload_rounded,
                                      color: isSent
                                          ? Colors.grey
                                          : const Color(0xFF6366F1),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBtn(String label, IconData icon) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
