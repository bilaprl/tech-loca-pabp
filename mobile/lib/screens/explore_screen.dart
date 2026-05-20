import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../event_model.dart';
import 'detail_event_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String searchQuery = "";
  String selectedLocation = "Semua Lokasi";

  List<Event> allEvents = [];
  List<String> locations = ["Semua Lokasi"];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  // AMBIL DATA DARI SUPABASE
  Future<void> _fetchEvents() async {
    try {
      final response = await Supabase.instance.client
          .from('events')
          .select()
          .order('created_at', ascending: false);

      // 🌟 PERBAIKAN 1: Ambil data wishlist milik user saat ini
      final user = Supabase.instance.client.auth.currentUser;
      List<String> userWishlistIds = [];
      if (user != null) {
        final wishlistData = await Supabase.instance.client
            .from('wishlist')
            .select('event_id')
            .eq('user_id', user.id);
        userWishlistIds = (wishlistData as List)
            .map((w) => w['event_id'].toString())
            .toList();
      }

      final List<Event> loadedEvents = (response as List).map((json) {
        final event = Event.fromJson(json);
        // Warnai merah jika ID event ada di tabel wishlist user
        if (userWishlistIds.contains(event.id.toString())) {
          event.isWishlisted = true;
        }
        return event;
      }).toList();

      final uniqueLocations = loadedEvents
          .map((e) => e.location.trim())
          .where((loc) => loc.isNotEmpty)
          .toSet()
          .toList();
      uniqueLocations.sort();

      if (mounted) {
        setState(() {
          allEvents = loadedEvents;
          locations = ["Semua Lokasi", ...uniqueLocations];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching explore events: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // 🌟 PERBAIKAN 2: Fungsi untuk Insert/Delete ke database Supabase
  Future<void> _toggleWishlist(Event event) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    setState(() {
      event.isWishlisted = !event.isWishlisted;
    });

    try {
      if (event.isWishlisted) {
        await Supabase.instance.client.from('wishlist').insert({
          'user_id': user.id,
          'event_id': event.id,
        });
      } else {
        await Supabase.instance.client
            .from('wishlist')
            .delete()
            .eq('user_id', user.id)
            .eq('event_id', event.id);
      }
    } catch (e) {
      setState(() {
        event.isWishlisted = !event.isWishlisted;
      });
      debugPrint("Error toggle wishlist: $e");
    }
  }

  // FUNGSI PULL TO REFRESH
  Future<void> _onRefresh() async {
    await _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = allEvents.where((event) {
      final matchesSearch = event.title.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      // 🌟 PERBAIKAN 2: Penyetaraan toleransi perbandingan filter jika teks memiliki spasi berlebih
      final matchesLocation =
          selectedLocation == "Semua Lokasi" ||
          event.location.trim() == selectedLocation.trim();
      return matchesSearch && matchesLocation;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Katalog Event",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF4F46E5),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  // SEARCH FIELD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: "Cari event teknologi...",
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // DROPDOWN LOKASI (DINAMIS DARI DB)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedLocation,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF4F46E5),
                          ),
                          items: locations.map((String loc) {
                            return DropdownMenuItem(
                              value: loc,
                              child: Text(
                                loc,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedLocation = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // LIST VIEW DENGAN PHYSICS ALWAYS SCROLLABLE AGAR BISA REFRESH SAAT KOSONG
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEvents.isEmpty
                  ? const Center(child: Text("Event tidak ditemukan..."))
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        return _buildEventCard(context, event);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailEventScreen(event: event),
          ),
        ).then((_) {
          _fetchEvents();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // 🌟 PERBAIKAN 2: Mengganti withOpacity menjadi withValues
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child: event.isBase64Image && event.base64Bytes != null
                      ? Image.memory(
                          event.base64Bytes!,
                          width: 120,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 120,
                                height: 140,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported),
                              ),
                        )
                      : Image.network(
                          event.imageUrl,
                          width: 120,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 120,
                                height: 140,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported),
                              ),
                        ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () => _toggleWishlist(event),
                    child: CircleAvatar(
                      radius: 14,
                      // 🌟 PERBAIKAN 3: Mengganti withOpacity menjadi withValues
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: Icon(
                        event.isWishlisted
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: event.isWishlisted ? Colors.red : Colors.grey,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.category,
                        style: const TextStyle(
                          color: Color(0xFF4F46E5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.date.contains('T')
                              ? event.date.split('T')[0]
                              : event.date,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.confirmation_number_outlined,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.price == '0' || event.price.isEmpty
                              ? "Gratis"
                              : "Rp ${event.price}",
                          style: const TextStyle(
                            color: Color(0xFF059669),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
