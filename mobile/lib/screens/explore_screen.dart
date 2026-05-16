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

      final List<Event> loadedEvents = (response as List)
          .map((json) => Event.fromJson(json))
          .toList();

      // 🌟 PERBAIKAN 1: Proteksi penyaringan lokasi agar string kosong/null tidak merusak fungsi dropdown sorting
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
      debugPrint("Error fetch: $e");
      if (mounted) setState(() => isLoading = false);
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailEventScreen(event: event),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(24),
              ),
              child: Image.network(
                event.imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 110,
                  height: 110,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          // 🌟 PERBAIKAN 3: Memotong teks penanda jam ISO dari database agar tampilan tanggal bersih murni YYYY-MM-DD
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
