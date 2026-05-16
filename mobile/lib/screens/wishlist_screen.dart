import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../event_model.dart';
import 'detail_event_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List<Event> wishlistedEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchWishlistData();
  }

  // FUNGSI TARIK DATA LIVE DARI JOIN TABEL SUPABASE
  Future<void> _fetchWishlistData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // Melakukan Select Join: Ambil data dari wishlist yang memiliki relasi ke tabel events
      final response = await Supabase.instance.client
          .from('wishlist')
          .select('*, events(*)')
          .eq('user_id', user.id);

      final List<Event> loadedEvents = [];
      for (var item in response as List) {
        if (item['events'] != null) {
          final eventObj = Event.fromJson(item['events']);
          eventObj.isWishlisted = true; // Kunci status ter-wishlist
          loadedEvents.add(eventObj);
        }
      }

      if (mounted) {
        setState(() {
          wishlistedEvents = loadedEvents;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Wishlist: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // FUNGSI HAPUS ITEM DARI WISHLIST LIVE ACARA
  Future<void> _removeFromWishlist(Event event) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client
          .from('wishlist')
          .delete()
          .eq('user_id', user.id)
          .eq('event_id', event.id);

      if (mounted) {
        setState(() {
          wishlistedEvents.removeWhere((e) => e.id == event.id);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Dihapus dari Wishlist"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint("Error remove wishlist: $e");
    }
  }

  // LOGIKA UTAMA PULL-TO-REFRESH
  Future<void> _handleRefresh() async {
    await _fetchWishlistData();
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 PERBAIKAN 1: Bagi data secara otomatis & dinamis berdasarkan perbandingan tanggal hari ini
    final now = DateTime.now();

    final upcomingWishlist = wishlistedEvents.where((e) {
      final eventDate = DateTime.tryParse(e.date) ?? now;
      return eventDate.isAfter(now) || eventDate.isAtSameMomentAs(now);
    }).toList();

    final pastWishlist = wishlistedEvents.where((e) {
      final eventDate = DateTime.tryParse(e.date) ?? now;
      return eventDate.isBefore(now);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Wishlist",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER SEPERTI DI WEB
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Wishlist Tersimpan",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Kelola acara yang telah kamu tandai.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text("Cari Event"),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    backgroundColor: const Color(0xFFEEF2FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TAB BAR (Akan Datang / Telah Terlewat)
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF4F46E5),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF4F46E5),
            indicatorWeight: 3,
            tabs: [
              const Tab(text: "Akan Datang"),
              // 🌟 PERBAIKAN 2: Tampilkan jumlah total data terlewat secara dinamis dari database
              Tab(text: "Telah Terlewat (${pastWishlist.length})"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: LIST EVENT WISHLIST AKAN DATANG
                RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: const Color(0xFF4F46E5),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : upcomingWishlist.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.15,
                            ),
                            _buildEmptyState(),
                          ],
                        )
                      : GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisExtent: 280,
                                mainAxisSpacing: 20,
                              ),
                          itemCount: upcomingWishlist.length,
                          itemBuilder: (context, index) {
                            return _buildWishlistCard(upcomingWishlist[index]);
                          },
                        ),
                ),

                // TAB 2: LIST EVENT WISHLIST TELAH TERLEWAT
                RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: const Color(0xFF4F46E5),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : pastWishlist.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2,
                            ),
                            const Center(
                              child: Text("Riwayat wishlist kosong."),
                            ),
                          ],
                        )
                      : GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisExtent: 280,
                                mainAxisSpacing: 20,
                              ),
                          itemCount: pastWishlist.length,
                          itemBuilder: (context, index) {
                            return _buildWishlistCard(
                              pastWishlist[index],
                              isPast: true,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(Event event, {bool isPast = false}) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailEventScreen(event: event),
            ),
          ).then(
            (_) => _fetchWishlistData(),
          ), // Ambil ulang data jika status berubah dari halaman detail
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Image.network(
                    event.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 160,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPast ? Colors.grey.shade300 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPast ? "SELESAI" : "SEGERA HADIR",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isPast
                            ? Colors.grey.shade700
                            : const Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => _removeFromWishlist(event),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        // 🌟 PERBAIKAN 3: Memotong stamp jam ISO agar format tanggal bersih (YYYY-MM-DD)
                        event.date.contains('T')
                            ? event.date.split('T')[0]
                            : event.date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.venue.isEmpty ? event.location : event.venue,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada wishlist",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
