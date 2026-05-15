import 'package:flutter/material.dart';
import '../event_model.dart';
import 'package:file_picker/file_picker.dart';

class MenuEventAdmin extends StatefulWidget {
  const MenuEventAdmin({super.key});

  @override
  State<MenuEventAdmin> createState() => _MenuEventAdminState();
}

class _MenuEventAdminState extends State<MenuEventAdmin> {
  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    return months[month - 1];
  }

  // --- FUNGSI TAMPILKAN FORM (UNTUK TAMBAH & EDIT) ---
  void _showEventForm(BuildContext context, {Event? existingEvent}) {
    final titleController = TextEditingController(
      text: existingEvent?.title ?? "",
    );
    final eoController = TextEditingController(text: existingEvent?.eo ?? "");
    final dateController = TextEditingController(
      text: existingEvent?.date ?? "",
    );
    final quotaController = TextEditingController(
      text: existingEvent?.quota.toString() ?? "",
    );
    final cityController = TextEditingController(
      text: existingEvent?.location ?? "",
    );
    final venueController = TextEditingController(
      text: existingEvent?.venue ?? "",
    );
    // Kolom tambahan yang tadi terlewat
    final mapsController = TextEditingController(text: "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  Text(
                    existingEvent == null ? "Buat Event Baru" : "Edit Event",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: _webInputStyle(
                  "Nama Workshop / Event",
                  Icons.title,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: eoController,
                decoration: _webInputStyle(
                  "Nama Penyelenggara",
                  Icons.business,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dateController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(
                            () => dateController.text =
                                "${pickedDate.day} ${_getMonthName(pickedDate.month)} ${pickedDate.year}",
                          );
                        }
                      },
                      decoration: _webInputStyle(
                        "Pilih Tanggal",
                        Icons.calendar_month,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: quotaController,
                      keyboardType: TextInputType.number,
                      decoration: _webInputStyle("Kuota", Icons.people),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cityController,
                decoration: _webInputStyle("Kota / Lokasi", Icons.apartment),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: venueController,
                decoration: _webInputStyle("Nama Venue", Icons.location_on),
              ),
              const SizedBox(height: 16),

              // ISIAN LINK MAPS
              TextField(
                controller: mapsController,
                decoration: _webInputStyle(
                  "Link Google Maps (URL)",
                  Icons.near_me_outlined,
                ),
              ),
              const SizedBox(height: 24),

              // AREA UPLOAD POSTER
              const Text(
                "  POSTER EVENT",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  try {
                    // PERBAIKAN FINAL: Langsung panggil FilePicker.pickFiles
                    // Pastikan import di paling atas adalah: import 'package:file_picker/file_picker.dart';
                    FilePickerResult? result = await FilePicker.pickFiles(
                      type: FileType.image,
                      allowMultiple: false,
                    );

                    // Cek apakah file dipilih dan widget masih terpasang (mounted)
                    if (result != null && context.mounted) {
                      // Notifikasi muncul di posisi atas layar agar tidak tertutup form
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("📸 Gambar berhasil dipilih!"),
                          backgroundColor: const Color(
                            0xFF4F46E5,
                          ), // Warna Indigo tema kamu
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).size.height -
                                150, // Muncul di atas
                            left: 20,
                            right: 20,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    // Jika error tetap muncul di konsol, kita bisa lacak di sini
                    debugPrint("Error picking file: $e");
                  }
                },
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: Colors.grey.shade400,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "KLIK UNTUK MEMBUKA PENYIMPANAN PERANGKAT",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // TOMBOL PUBLIKASIKAN DENGAN VALIDASI KETAT
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // VALIDASI KETAT
                    if (titleController.text.trim().isEmpty ||
                        eoController.text.trim().isEmpty ||
                        dateController.text.trim().isEmpty ||
                        cityController.text.trim().isEmpty ||
                        quotaController.text.trim().isEmpty ||
                        venueController.text.trim().isEmpty ||
                        mapsController.text.trim().isEmpty) {
                      // PERBAIKAN: SnackBar muncul di ATAS (Top)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.white),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "⚠️ Mohon lengkapi seluruh isian!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior
                              .floating, // WAJIB floating agar margin bekerja
                          dismissDirection: DismissDirection
                              .up, // Bisa di-swipe ke atas untuk hapus
                          margin: EdgeInsets.only(
                            // Menaruhnya di bagian paling atas layar
                            bottom: MediaQuery.of(context).size.height - 120,
                            left: 20,
                            right: 20,
                          ),
                          duration: const Duration(seconds: 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      if (existingEvent == null) {
                        mockEvents.insert(
                          0,
                          Event(
                            id: DateTime.now().millisecondsSinceEpoch,
                            title: titleController.text,
                            eo: eoController.text,
                            date: dateController.text,
                            location: cityController.text,
                            venue: venueController.text,
                            quota: int.tryParse(quotaController.text) ?? 0,
                            max: int.tryParse(quotaController.text) ?? 50,
                            desc: "Event baru dari Admin Panel.",
                            img:
                                "https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=1000",
                            category: "Workshop",
                            isWishlisted: false,
                          ),
                        );
                      } else {
                        existingEvent.title = titleController.text;
                        existingEvent.eo = eoController.text;
                        existingEvent.date = dateController.text;
                        existingEvent.location = cityController.text;
                        existingEvent.venue = venueController.text;
                        existingEvent.quota =
                            int.tryParse(quotaController.text) ?? 0;
                      }
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          existingEvent == null
                              ? "✅ Event Berhasil Dipublikasikan!"
                              : "✅ Perubahan Berhasil Disimpan!",
                        ),
                      ),
                    );
                  },
                  child: Text(
                    existingEvent == null
                        ? "Publikasikan ke Katalog"
                        : "Simpan Perubahan",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEventForm(context),
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Buat Event Baru",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockEvents.length,
        itemBuilder: (context, index) {
          final event = mockEvents[index];
          return _buildKatalogItem(context, event);
        },
      ),
    );
  }

  Widget _buildKatalogItem(BuildContext context, Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${event.date} • ${event.location}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TOMBOL EDIT KEMBALI MUNCUL
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: () => _showEventForm(context, existingEvent: event),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                setState(() => mockEvents.remove(event));
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _webInputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
