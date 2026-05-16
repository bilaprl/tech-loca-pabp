import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/explore_screen.dart'; // Import halaman explore yang sudah ada
import '../screens/login_screen.dart';
import 'menu_ikhtisar.dart';
import 'menu_event.dart';
import 'menu_verifikasi.dart';
import 'menu_checkin.dart';
import 'menu_certificate.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  // 🌟 PERBAIKAN UTAMA: Tambahkan variabel pemicu UniqueKey agar sub-menu admin
  // dipaksa melakukan initState ulang secara bersih tanpa merusak UI atau menyangkutkan loading
  Key _refreshKey = UniqueKey();

  // FUNGSI LOGOUT SEKALIGUS CLEAR SESSION SUPABASE
  Future<void> _handleLogout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Logout Error: $e");
    }
  }

  // LOGIKA UTAMA REFRESH UNTUK DASHBOARD ADMIN
  Future<void> _handleGlobalRefresh() async {
    if (mounted) {
      setState(() {
        // 🌟 Perbarui kunci untuk memaksa penghancuran instansi menu lama & re-fetch live DB
        _refreshKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Daftar menu diinisialisasi di dalam build dengan menyertakan _refreshKey pembantu
    final List<Widget> menuPages = [
      MenuIkhtisar(key: _refreshKey),
      MenuEventAdmin(key: _refreshKey),
      MenuVerifikasiAdmin(key: _refreshKey),
      MenuCheckInAdmin(key: _refreshKey),
      MenuCertificateAdmin(key: _refreshKey),
      ExploreScreen(key: _refreshKey),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.red),
          onPressed: () {
            // Tampilkan dialog konfirmasi logout demi keamanan data admin
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  "Keluar Admin Panel?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  "Apakah kamu yakin ingin keluar dari sesi admin panel TechLoca?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleLogout();
                    },
                    child: const Text(
                      "Keluar",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        title: const Text(
          "Admin Panel TechLoca",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Indikator visual pembantu refresh di appbar admin
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4F46E5)),
            onPressed: _handleGlobalRefresh,
          ),
        ],
      ),
      // Membungkus halaman aktif dengan RefreshIndicator global yang responsif terhadap scrollable child
      body: RefreshIndicator(
        onRefresh: _handleGlobalRefresh,
        color: const Color(0xFF4F46E5),
        child: ScrollConfiguration(
          // Memastikan efek overscroll tetap bekerja di platform manapun saat ditarik
          behavior: const ScrollBehavior().copyWith(overscroll: true),
          child: menuPages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Ikhtisar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_rounded),
            label: 'Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_rounded),
            label: 'Verifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: 'Check-in',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership_rounded),
            label: 'Sertifikat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
        ],
      ),
    );
  }
}
