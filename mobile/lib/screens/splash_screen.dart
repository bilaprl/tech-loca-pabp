import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import '../main.dart'; // Import MainNavigation
import '../admin/admin_dashboard_screen.dart'; // Import AdminDashboard

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  // FUNGSI CEK SESI LOGIN AKTIF
  Future<void> _checkSession() async {
    // Memberi waktu animasi splash tampil (3 detik)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // 1. Ambil session saat ini dari Supabase
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      // Jika TIDAK ADA sesi -> Ke halaman Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // Jika ADA sesi -> Cek Role di tabel profiles
      try {
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', session.user.id)
            .maybeSingle();

        // Amankan pembacaan string JSON dari nilai null database
        final String userRole = (profileData?['role']?.toString() ?? 'user')
            .trim()
            .toLowerCase();

        if (!mounted) return;

        // 2. Arahkan berdasarkan role
        if (userRole == 'admin' || userRole == 'eo') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainNavigation()),
          );
        }
      } catch (e) {
        debugPrint("Error sync role inside splash session: $e");

        // Bersihkan token sesi login auth Supabase secara total terlebih dahulu
        // agar tidak terjadi bentrok session saat user mendarat di LoginScreen.
        try {
          await Supabase.instance.client.auth.signOut();
        } catch (_) {}

        if (!mounted) return;

        // Paksa login ulang dengan state token yang sudah bersih murni
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F46E5), // Warna brand TechLoca
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Utama
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Image.asset(
                'assets/logo.png',
                height: 80,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "TechLoca",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Event Companion App",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
