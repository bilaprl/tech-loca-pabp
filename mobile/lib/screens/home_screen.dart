import 'package:flutter/material.dart';
import '../event_model.dart';
import '../main.dart';
import 'detail_event_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  // <--- Ganti jadi StatefulWidget
  const HomeScreen({super.key}); // Tambahkan 'const' di depan constructor

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final trendingEvents = mockEvents.where((e) => e.quota <= 5).toList();

    return CustomScrollView(
      slivers: [
        // NAVBAR
        SliverAppBar(
          floating: true,
          pinned: true,
          backgroundColor: Colors.white.withValues(alpha: 0.95),
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 28,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.code, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 10),
              const Text(
                'TechLoca',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded, // Logo lonceng di pojok kanan
                color: Colors.black,
              ),
              onPressed: () {
                // PERBAIKAN: Tambahkan navigasi ini
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 8), // Biasanya ada sedikit spasi di pinggir
          ],
        ),

        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HERO SECTION
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E1B4B),
                      Color(0xFF4F46E5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "TRUSTED BY 10K+ DEVELOPERS",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Build the\nFuture of Tech.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Akses eksklusif ke berbagai workshop dan seminar IT terdekat di sekitarmu.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. BAGIAN TRENDING
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF43F5E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "TRENDING & SEGERA HADIR",
                            style: TextStyle(
                              color: Color(0xFFF43F5E),
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Amankan Slot\nSebelum Penuh.",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        MainNavigation.of(context)?.changeTab(1);
                      },
                      icon: const Text(
                        "Lihat Semua Katalog",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      label: const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Color(0xFF0F172A),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. DAFTAR EVENT (BAGIAN YANG DIPERBAIKI)
        // 3. DAFTAR EVENT (VERSI PERBAIKAN TOTAL)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final event = trendingEvents[index];
              bool isFull = event.quota == 0;
              bool isAlmostFull = event.quota > 0 && event.quota <= 5;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailEventScreen(event: event),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- BAGIAN GAMBAR ---
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                            child: Image.network(
                              event.img, // Pastikan ini .img bukan .image
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              // Penanganan jika gambar gagal muat
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),

                          // Ikon Wishlist di Kiri Atas
                          Positioned(
                            top: 15,
                            left: 15,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  event.isWishlisted = !event.isWishlisted;
                                });
                              },
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.9,
                                ),
                                child: Icon(
                                  event.isWishlisted
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: event.isWishlisted
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),

                          // Badge Kuota di Kanan Atas
                          if (isAlmostFull || isFull)
                            Positioned(
                              top: 15,
                              right: 15,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isFull ? Colors.red : Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isFull
                                      ? "PENUH"
                                      : "${event.quota} SLOT TERSISA",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // --- BAGIAN TEKS (YANG TADI HILANG) ---
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cari bagian Row kategori dan ganti dengan ini:
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Bungkus dengan Flexible/Expanded agar tidak overflow ke kanan
                                Flexible(
                                  child: Text(
                                    event.category.toUpperCase(),
                                    overflow: TextOverflow
                                        .ellipsis, // Jika kepanjangan jadi titik-titik
                                    style: const TextStyle(
                                      color: Color(0xFF4F46E5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ), // Kasih jarak sedikit
                                Text(
                                  event.date,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Cari bagian Row venue dan ganti dengan ini:
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                // WAJIB PAKAI EXPANDED DISINI:
                                Expanded(
                                  child: Text(
                                    event.venue,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
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
            }, childCount: trendingEvents.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 50)),
      ],
    );
  }
}
