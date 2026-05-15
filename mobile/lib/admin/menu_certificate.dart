import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Import untuk akses file
import 'package:mobile/services/notification_service.dart';

class MenuCertificateAdmin extends StatefulWidget {
  const MenuCertificateAdmin({super.key});

  @override
  State<MenuCertificateAdmin> createState() => _MenuCertificateAdminState();
}

class _MenuCertificateAdminState extends State<MenuCertificateAdmin> {
  String selectedCategory = "SEMUA";
  String? selectedFileName; // Menyimpan nama file yang dipilih

  // Data dummy peserta sertifikat
  List<Map<String, dynamic>> pesertaSertif = [
    {
      "nama": "Budi Santoso",
      "event": "UI/UX MASTERCLASS",
      "status": "MENUNGGU",
      "email": "budi.santoso@student.unsil.ac.id",
    },
    {
      "nama": "Siti Aminah",
      "event": "WEB DEV UNSIL",
      "status": "TERKIRIM",
      "email": "siti.aminah@gmail.com",
    },
  ];

  // Fungsi untuk memilih file dari HP/Laptop
  Future<void> _pickCertificateFile(StateSetter setModalState) async {
    try {
      // Menggunakan cara yang sama dengan form event: langsung .pickFiles
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
        allowMultiple: false,
      );

      if (result != null) {
        setModalState(() {
          selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      debugPrint("Error saat memilih file: $e");
    }
  }

  void _showUploadDialog(BuildContext context, int index) {
    selectedFileName = null; // Reset nama file setiap buka dialog
    final p = pesertaSertif[index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        // Agar modal bisa update tampilan saat file terpilih
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
                "Pilih file sertifikat untuk dikirim ke ${p['email']}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 32),

              // Area Drop Zone / Click to Upload
              GestureDetector(
                onTap: () => _pickCertificateFile(setModalState),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      style: BorderStyle.solid,
                    ),
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
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: selectedFileName == null
                          ? null
                          : () {
                              setState(() => p['status'] = "TERKIRIM");
                              Navigator.pop(context);

                              // --- TAMBAHKAN BARIS INI (TRIGGER NOTIFIKASI LOKAL) ---
                              NotificationService.showNotification(
                                id: 2,
                                title: "Sertifikat Terbit! 🎓",
                                body:
                                    "Sertifikat untuk ${p['nama']} telah dikirim ke email.",
                                type: "cert",
                              );
                              // -----------------------------------------------------

                              _showTopSnackBar(
                                context,
                                "🚀 Sertifikat berhasil dikirim!",
                              );
                            },
                      child: const Text(
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Kategori (Opsi Menu seperti di Web)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildFilterBtn("SEMUA", Icons.grid_view_rounded),
                _buildFilterBtn(
                  "UI/UX MASTERCLASS",
                  Icons.star_outline_rounded,
                ),
                _buildFilterBtn("WEB DEV UNSIL", Icons.star_outline_rounded),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final p = filteredList[index];
                bool isSent = p['status'] == "TERKIRIM";

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
                          p['nama'][0],
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
                                color: isSent ? Colors.green : Colors.grey,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          IconButton(
                            onPressed: () => _showUploadDialog(
                              context,
                              pesertaSertif.indexOf(p),
                            ),
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
