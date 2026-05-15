import 'package:flutter/material.dart';
import '../screens/explore_screen.dart'; // Import halaman explore yang sudah ada
import 'menu_ikhtisar.dart';
import 'menu_event.dart';
import 'menu_verifikasi.dart';
import 'menu_checkin.dart';
import 'menu_certificate.dart';
import '../screens/explore_screen.dart';
import '../screens/login_screen.dart';
import 'package:mobile/admin/menu_verifikasi.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  // Daftar menu yang akan kita buat
  final List<Widget> _menuPages = [
    const MenuIkhtisar(),
    const MenuEventAdmin(),
    const MenuVerifikasiAdmin(),
    const MenuCheckInAdmin(),
    const MenuCertificateAdmin(),
    const ExploreScreen(), // Halaman explorasi yang sama dengan peserta
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.red),
          onPressed: () {
            // Mengarahkan langsung ke halaman Login dan menghapus histori halaman sebelumnya
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) =>
                  false, // Menghapus semua tumpukan halaman agar tidak bisa 'back' ke admin
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
      ),
      body: _menuPages[_selectedIndex],
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
