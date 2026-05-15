import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import Screens
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/tickets_screen.dart';
import 'screens/profile_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'package:mobile/services/notification_service.dart';
import 'services/ticket_service.dart';

void main() async {
  // 1. WAJIB: Pastikan sistem Flutter siap sebelum inisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi sistem penyimpanan lokal (Hive)
  await Hive.initFlutter();

  // 3. Inisialisasi Service Notifikasi dan Tiket
  await NotificationService.init();
  await TicketService.init();

  // 4. Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://cgyhcgneljqmmcwsravj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNneWhjZ25lbGpxbW1jd3NyYXZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0NDMxNTUsImV4cCI6MjA5NDAxOTE1NX0.zgs6DROpp5brUe_4YIqpUn6DqmfIVLRE2S11LUZ_ITw',
  );

  // 5. HANYA PANGGIL runApp SATU KALI DI PALING AKHIR
  runApp(const TechLocaApp());
}

// REMOTE CONTROL UNTUK PINDAH TAB
final GlobalKey<MainNavigationState> mainNavKey =
    GlobalKey<MainNavigationState>();

class TechLocaApp extends StatelessWidget {
  const TechLocaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechLoca',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
        fontFamily: 'Montserrat',
      ),
      // CARA GANTI HALAMAN UNTUK TESTING:
      // Jika ingin melihat halaman Peserta, gunakan: const SplashScreen()
      // Jika ingin melihat halaman Admin, gunakan: const AdminDashboardScreen()
      //home: const SplashScreen(),
      home: const AdminDashboardScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  static MainNavigationState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainNavigationState>();
  }

  MainNavigation({Key? key}) : super(key: key ?? mainNavKey);

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(),
          ExploreScreen(),
          TicketsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          changeTab(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: "Tickets",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
