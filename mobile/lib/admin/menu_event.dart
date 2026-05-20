import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../event_model.dart';
import 'package:file_picker/file_picker.dart';

class MenuEventAdmin extends StatefulWidget {
  const MenuEventAdmin({super.key});

  @override
  State<MenuEventAdmin> createState() => _MenuEventAdminState();
}

class _MenuEventAdminState extends State<MenuEventAdmin> {
  List<Event> eventsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  // ==================== AMBIL DATA (READ) ====================
  Future<void> _fetchEvents() async {
    try {
      final response = await Supabase.instance.client
          .from('events')
          .select()
          .order('created_at', ascending: false);

      final List<Event> loadedEvents = [];
      for (var item in response as List) {
        loadedEvents.add(Event.fromJson(item));
      }

      if (mounted) {
        setState(() {
          eventsList = loadedEvents;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Events Admin: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ==================== SIMPAN / UPDATE DATA (CRUD) ====================
  Future<bool> _saveEvent({
    String? id,
    required String title,
    required String eo,
    required String date,
    required String quota,
    required String location,
    required String venue,
    required String mapsUrl,
    required String price,
    required String description,
    required String imageUrl,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      final String numericPriceStr = price.replaceAll(RegExp(r'[^0-9]'), '');
      final String numericQuotaStr = quota.replaceAll(RegExp(r'[^0-9]'), '');

      String sanitize(String input) => input.replaceAll('\u0000', '').trim();

      final eventData = {
        'title': title,
        'eo': eo,
        'date': date,
        'quota': int.tryParse(numericQuotaStr) ?? 0,
        'location': location,
        'venue': venue,
        'maps_url': mapsUrl,
        'price': int.tryParse(numericPriceStr) ?? 0,
        'description': description.trim().isEmpty
            ? 'Workshop Event: $title'
            : description,
        'category': 'Workshop IT',
        'image_url': imageUrl,
      };

      if (id == null) {
        eventData['created_at'] = DateTime.now().toIso8601String();
        await supabase.from('events').insert(eventData);
      } else {
        await supabase.from('events').update(eventData).eq('id', id);
      }

      await _fetchEvents();
      return true;
    } catch (e) {
      debugPrint("Error Saving Event: $e");
      return false;
    }
  }

  // ==================== HAPUS DATA (DELETE) ====================
  Future<void> _deleteEvent(dynamic id) async {
    try {
      await Supabase.instance.client.from('events').delete().eq('id', id);
      _fetchEvents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Event berhasil dihapus!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error Delete Event: $e");
    }
  }

  // --- FITUR PULL-TO-REFRESH ---
  Future<void> _handleRefresh() async {
    await _fetchEvents();
  }

  // --- FUNGSI TAMPILKAN FORM (UNTUK TAMBAH & EDIT) ---
  void _showEventForm(BuildContext context, {Event? existingEvent}) {
    final titleController = TextEditingController(
      text: existingEvent?.title ?? "",
    );
    final eoController = TextEditingController(text: existingEvent?.eo ?? "");

    String selectedIsoDate = existingEvent != null ? existingEvent.date : "";

    final String initialDateRaw = existingEvent?.date ?? '';
    final dateController = TextEditingController(
      text: initialDateRaw.contains('T')
          ? initialDateRaw.split('T')[0]
          : initialDateRaw,
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
    final mapsController = TextEditingController(
      text: existingEvent?.mapsUrl ?? "",
    );
    final priceController = TextEditingController(
      text: existingEvent?.price.toString() ?? "",
    );
    final descController = TextEditingController(
      text: existingEvent?.desc ?? "",
    );

    String uploadedImageUrl = existingEvent?.imageUrl ?? "";
    String? localFileName;

    bool isUploading = false;
    bool isSubmitting = false;

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
        child: StatefulBuilder(
          builder: (modalContext, setModalState) => SingleChildScrollView(
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
                            selectedIsoDate = pickedDate.toIso8601String();
                            dateController.text =
                                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
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
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: _webInputStyle(
                    "Harga Tiket (Isi 0 jika gratis)",
                    Icons.payments_rounded,
                  ),
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
                TextField(
                  controller: mapsController,
                  decoration: _webInputStyle(
                    "Link Google Maps (URL)",
                    Icons.near_me_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: _webInputStyle(
                    "Deskripsi Lengkap Tentang Acara...",
                    Icons.description_rounded,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "   POSTER EVENT",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: isUploading
                      ? null
                      : () async {
                          try {
                            // 🌟 PERBAIKAN UNTUK v11.0.2: Menghapus '.platform' karena sudah deprecated/dihapus
                            FilePickerResult? result =
                                await FilePicker.pickFiles(
                                  type: FileType.image,
                                  allowMultiple: false,
                                );

                            if (result != null) {
                              setModalState(() {
                                isUploading = true;
                                localFileName = result.files.single.name;
                              });

                              final supabase = Supabase.instance.client;
                              final fileSingle = result.files.single;
                              final String storagePathName =
                                  "${DateTime.now().millisecondsSinceEpoch}_${fileSingle.name}";

                              if (fileSingle.bytes != null) {
                                await supabase.storage
                                    .from('events')
                                    .uploadBinary(
                                      storagePathName,
                                      fileSingle.bytes!,
                                    );
                              } else if (fileSingle.path != null) {
                                final bytes = await File(
                                  fileSingle.path!,
                                ).readAsBytes();
                                await supabase.storage
                                    .from('events')
                                    .uploadBinary(storagePathName, bytes);
                              }

                              final String publicUrl = supabase.storage
                                  .from('events')
                                  .getPublicUrl(storagePathName);

                              setModalState(() {
                                uploadedImageUrl = publicUrl;
                                isUploading = false;
                              });
                            }
                          } catch (e) {
                            debugPrint("Error picking/uploading poster: $e");
                            setModalState(() => isUploading = false);
                          }
                        },
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      image: uploadedImageUrl.isNotEmpty && !isUploading
                          ? DecorationImage(
                              image: NetworkImage(uploadedImageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : uploadedImageUrl.isEmpty
                        ? Column(
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
                          )
                        : Container(
                            color: Colors.black45,
                            child: Center(
                              child: Text(
                                localFileName ??
                                    "Poster Terpilih (Klik untuk mengganti)",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
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
                    onPressed: (isUploading || isSubmitting)
                        ? null
                        : () async {
                            if (titleController.text.trim().isEmpty ||
                                eoController.text.trim().isEmpty ||
                                dateController.text.trim().isEmpty ||
                                cityController.text.trim().isEmpty ||
                                quotaController.text.trim().isEmpty ||
                                venueController.text.trim().isEmpty ||
                                priceController.text.trim().isEmpty ||
                                descController.text.trim().isEmpty ||
                                uploadedImageUrl.isEmpty ||
                                mapsController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "⚠️ Mohon lengkapi seluruh isian dan unggah poster!",
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            setModalState(() => isSubmitting = true);

                            bool isSuccess = await _saveEvent(
                              id: existingEvent?.id?.toString(),
                              title: titleController.text,
                              eo: eoController.text,
                              date: selectedIsoDate.isEmpty
                                  ? DateTime.now().toIso8601String()
                                  : selectedIsoDate,
                              quota: quotaController.text,
                              location: cityController.text,
                              venue: venueController.text,
                              mapsUrl: mapsController.text,
                              price: priceController.text,
                              description: descController.text,
                              imageUrl: uploadedImageUrl,
                            );

                            if (context.mounted) {
                              setModalState(() => isSubmitting = false);

                              if (isSuccess) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      existingEvent == null
                                          ? "✅ Event Berhasil Dipublikasikan!"
                                          : "✅ Perubahan Berhasil Disimpan!",
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "❌ Gagal menyimpan event! Periksa koneksi internet.",
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
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
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF4F46E5),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : eventsList.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Text(
                      "Belum ada event di katalog.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: eventsList.length,
                itemBuilder: (context, index) {
                  final event = eventsList[index];
                  return _buildKatalogItem(context, event);
                },
              ),
      ),
    );
  }

  Widget _buildKatalogItem(BuildContext context, Event event) {
    final String listDateRaw = event.date;
    final String parsedListDate = listDateRaw.contains('T')
        ? listDateRaw.split('T')[0]
        : listDateRaw;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        // 🌟 PERBAIKAN UTAMA: Mendukung render gambar Base64 dari Web & URL dari Mobile
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: event.isBase64Image && event.base64Bytes != null
              ? Image.memory(
                  event.base64Bytes!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Image.network(
                  event.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("$parsedListDate • ${event.location}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: () => _showEventForm(context, existingEvent: event),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Hapus Event?"),
                    content: const Text(
                      "Aksi ini akan menghapus event permanen dari database.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteEvent(event.id);
                        },
                        child: const Text(
                          "Hapus",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
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
