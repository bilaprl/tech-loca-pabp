import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // 🌟 TAMBAHAN: Untuk merender Google Maps interaktif
import '../event_model.dart';
import '../main.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailEventScreen extends StatefulWidget {
  final Event event;
  const DetailEventScreen({super.key, required this.event});

  @override
  State<DetailEventScreen> createState() => _DetailEventScreenState();
}

class _DetailEventScreenState extends State<DetailEventScreen> {
  late bool isWishlisted = widget.event.isWishlisted;
  // 🌟 PERBAIKAN 1 & 2: Buat variabel penampung agar tidak mengubah nilai 'final'
  late int currentQuota = widget.event.quota;

  bool isBooked = false;
  bool isLoadingWishlist = false;
  bool isProcessingTransaction = false;
  bool showLiveMap =
      false; // 🌟 TAMBAHAN: Variabel status untuk memicu pergantian Gambar/Peta

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  // 1. CEK STATUS AWAL (Apakah sudah wishlist/transaksi?)
  Future<void> _checkInitialStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // Tarik data kuota paling baru dari database!
      final liveEvent = await Supabase.instance.client
          .from('events')
          .select('quota')
          .eq('id', widget.event.id)
          .single();

      // Cek Wishlist
      final wishlist = await Supabase.instance.client
          .from('wishlist')
          .select()
          .eq('user_id', user.id)
          .eq('event_id', widget.event.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          // 🌟 PERBAIKAN 1 & 2: Gunakan variabel penampung 'currentQuota'
          currentQuota = liveEvent['quota'] ?? widget.event.quota;

          isWishlisted = wishlist != null;
          isBooked = false;
          isLoadingWishlist = false;
        });
      }
    } catch (e) {
      debugPrint("Error check status: $e");
      if (mounted) setState(() => isLoadingWishlist = false);
    }
  }

  // 2. FUNGSI TOGGLE WISHLIST (INSERT/DELETE)
  Future<void> _toggleWishlist() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => isLoadingWishlist = true);

    try {
      if (isWishlisted) {
        await Supabase.instance.client
            .from('wishlist')
            .delete()
            .eq('user_id', user.id)
            .eq('event_id', widget.event.id);
      } else {
        await Supabase.instance.client.from('wishlist').insert({
          'user_id': user.id,
          'event_id': widget.event.id,
        });
      }

      setState(() => isWishlisted = !isWishlisted);

      // 🌟 PERBAIKAN 4: Tambahkan mounted check sebelum memanggil SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isWishlisted
                  ? "Ditambahkan ke Wishlist"
                  : "Dihapus dari Wishlist",
            ),
            backgroundColor: isWishlisted
                ? const Color(0xFF4F46E5)
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Wishlist Error: $e");
    } finally {
      if (mounted) {
        setState(() => isLoadingWishlist = false);
      }
    }
  }

  // 3. FUNGSI AMANKAN SLOT (INSERT TRANSACTIONS)
  Future<void> _handleBooking() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => isProcessingTransaction = true);

    try {
      final String generatedQrString =
          "TCK-${user.id.substring(0, 5)}-${widget.event.id.toString().substring(0, 5)}-${DateTime.now().millisecondsSinceEpoch}";

      // 1. Pastikan dulu kuotanya masih ada sebelum di-insert (Gunakan currentQuota)
      if (currentQuota <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maaf, kuota event ini sudah habis terisi!'),
            ),
          );
        }
        return;
      }

      // 2. Insert transaksi baru ke Supabase
      await Supabase.instance.client.from('transactions').insert({
        'user_id': user.id,
        'event_id': widget.event.id,
        'status': 'pending',
        'is_checked_in': false,
        'qr_code_string':
            generatedQrString, // 🌟 PERBAIKAN 3: Masukkan variabel QR ke database!
      });

      // 3. Potong kuota event sebanyak 1 di database Supabase
      final int oldQuota = currentQuota;
      await Supabase.instance.client
          .from('events')
          .update({'quota': oldQuota - 1})
          .eq('id', widget.event.id);

      if (mounted) {
        setState(() {
          // 🌟 PERBAIKAN 1 & 2: Update variabel penampung layar
          currentQuota = oldQuota - 1;
          isBooked = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Slot berhasil diamankan! Silakan cek menu Tiket."),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      debugPrint("Transaction Error: $e");
    } finally {
      if (mounted) {
        setState(() => isProcessingTransaction = false);
      }
    }
  }

  Future<void> _launchMaps() async {
    if (widget.event.mapsUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link lokasi peta belum disediakan oleh EO"),
        ),
      );
      return;
    }

    // Bersihkan link dari modifikasi output=embed jika ada, kembalikan ke url asli
    final String cleanUrlString = widget.event.mapsUrl
        .replaceAll('&output=embed', '')
        .replaceAll('?output=embed', '')
        .trim();

    final Uri url = Uri.parse(cleanUrlString);

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak bisa membuka tautan peta")),
        );
      }
    } catch (e) {
      debugPrint("Error launching maps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 PERBAIKAN: Gunakan currentQuota untuk mengecek status sold out
    final bool isSoldOut = currentQuota <= 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _checkInitialStatus,
            color: const Color(0xFF4F46E5),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVisualHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 150),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryBadge(),
                        const SizedBox(height: 16),
                        Text(
                          widget.event.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildOrganizerInfo(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                Icons.calendar_today_rounded,
                                "TANGGAL",
                                widget.event.date.contains('T')
                                    ? widget.event.date.split('T')[0]
                                    : widget.event.date,
                                const Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                Icons.payments_rounded,
                                "HARGA",
                                widget.event.price == "0" ||
                                        widget.event.price.trim().isEmpty
                                    ? "Gratis"
                                    : "Rp ${widget.event.price}",
                                const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          Icons.location_on_rounded,
                          "LOKASI ACARA",
                          widget.event.venue.isEmpty
                              ? widget.event.location
                              : widget.event.venue,
                          const Color(0xFF10B981),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "Tentang Acara",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.event.desc,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.6,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TOMBOL STICKY DI BAWAH
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildQuotaIndicator(isSoldOut),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (isSoldOut || isProcessingTransaction)
                          ? null
                          : () {
                              if (!isBooked) {
                                _handleBooking();
                              } else {
                                mainNavKey.currentState?.changeTab(2);
                                Navigator.pop(context);
                              }
                            },
                      icon: isProcessingTransaction
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isSoldOut
                                  ? Icons.block
                                  : (isBooked
                                        ? Icons.confirmation_number_rounded
                                        : Icons.check_circle_outline),
                              color: Colors.white,
                              size: 18,
                            ),
                      label: Text(
                        isSoldOut
                            ? "Kuota Penuh"
                            : (isBooked
                                  ? "Lihat E-Ticket Saya"
                                  : "Amankan Slot Sekarang"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBooked
                            ? const Color(0xFF10B981)
                            : const Color(0xFF4F46E5),
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildVisualHeader() {
    return Stack(
      children: [
        widget.event.isBase64Image && widget.event.base64Bytes != null
            ? Image.memory(
                widget.event.base64Bytes!,
                height: 350,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 350,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              )
            : Image.network(
                widget.event.imageUrl,
                height: 350,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 350,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
        Positioned.fill(
          child: IgnorePointer(child: Container(color: Colors.black12)),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: isLoadingWishlist
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? Colors.red : Colors.grey,
                    ),
                    onPressed: _toggleWishlist,
                  ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: ElevatedButton.icon(
            onPressed: _launchMaps,
            // 🌟 PERBAIKAN: Ubah ikon dan teks tombol secara dinamis mengikuti status showLiveMap
            icon: Icon(
              showLiveMap ? Icons.image_outlined : Icons.map_outlined,
              size: 18,
            ),
            label: Text(
              showLiveMap ? "Lihat Gambar" : "Lihat Peta",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizerInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Color(0xFF4F46E5),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Diselenggarakan oleh",
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                Text(
                  widget.event.eo.isEmpty
                      ? "Penyelenggara IT"
                      : widget.event.eo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaIndicator(bool isSoldOut) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "KETERSEDIAAN TIKET",
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          // 🌟 PERBAIKAN: Gunakan currentQuota agar tidak error
          isSoldOut ? "HABIS TERJUAL" : "$currentQuota KURSI",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isSoldOut ? Colors.red : const Color(0xFF4F46E5),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.event.category.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF4F46E5),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
