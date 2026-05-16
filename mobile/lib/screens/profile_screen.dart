import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'certificates_screen.dart';
import 'wishlist_screen.dart';
import 'edit_profile_screen.dart';
import 'faq_screen.dart';
import 'about_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 1. DATA PENAMPUNG (State)
  String currentName = "Memuat...";
  String currentEmail = "Memuat...";
  String currentAvatarUrl = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData(); // Panggil fungsi saat layar dibuka
  }

  // 2. FUNGSI MENARIK DATA PROFIL DARI SUPABASE
  Future<void> _fetchProfileData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle(); // Ambil 1 baris data milik user ini

      if (mounted) {
        setState(() {
          if (data != null) {
            // 🌟 PERBAIKAN: Gunakan toString() aman untuk mengantisipasi nilai null dari database
            currentName = data['full_name']?.toString() ?? 'Tanpa Nama';
            currentEmail = data['email']?.toString() ?? user.email ?? '-';
            currentAvatarUrl = data['avatar_url']?.toString() ?? '';
          } else {
            currentName = 'Tanpa Nama';
            currentEmail = user.email ?? '-';
            currentAvatarUrl = '';
          }
          isLoading =
              false; // ✅ PERBAIKAN: Pastikan loading dimatikan baik data ada maupun tidak
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // FITUR PULL-TO-REFRESH
  Future<void> _handleRefresh() async {
    await _fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // MEMBUNGKUS DENGAN REFRESH INDICATOR
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF4F46E5),
        child: SingleChildScrollView(
          // Physics AlwaysScrollable agar bisa ditarik meski konten pendek
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 80),
              // FOTO PROFIL
              Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: const Color(0xFF4F46E5),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      currentAvatarUrl.isNotEmpty
                          ? currentAvatarUrl
                          : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(currentName)}&background=4F46E5&color=fff",
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. TAMPILKAN NAMA DINAMIS
              if (isLoading)
                const CircularProgressIndicator()
              else ...[
                Text(
                  currentName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  currentEmail, // Diganti jadi Email karena tabel database tidak pakai username
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 32),

              _buildProfileMenu(
                Icons.military_tech_rounded,
                "Sertifikat Saya",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CertificatesScreen(),
                    ),
                  );
                },
              ),
              _buildProfileMenu(
                Icons.favorite_border_rounded,
                "Wishlist Saya",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WishlistScreen(),
                    ),
                  );
                },
              ),

              // 3. LOGIKA UPDATE SAAT BALIK DARI EDIT PROFIL
              _buildProfileMenu(
                Icons.edit_outlined,
                "Edit Profil",
                onTap: () async {
                  // Menunggu data balik dari halaman Edit
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );

                  // Jika user klik 'Simpan' dan ada data baru
                  if (result == true) {
                    setState(() => isLoading = true);
                    _fetchProfileData();
                  }
                },
              ),

              _buildProfileMenu(
                Icons.notifications_none_rounded,
                "Notifikasi",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Divider(color: Color(0xFFE2E8F0)),
              ),

              _buildProfileMenu(
                Icons.help_outline_rounded,
                "FAQ & Bantuan",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FaqScreen()),
                  );
                },
              ),
              _buildProfileMenu(
                Icons.info_outline_rounded,
                "Tentang TechLoca",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Divider(color: Color(0xFFE2E8F0)),
              ),

              // TOMBOL LOGOUT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListTile(
                  onTap: () async {
                    // 3. LOGIKA LOGOUT DATABASE
                    await Supabase.instance.client.auth.signOut();

                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.logout_rounded, color: Colors.red),
                  ),
                  title: const Text(
                    "Keluar",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 🌟 PERBAIKAN UTAMA: Memasukkan kembali method pembangun menu ke dalam block kurung siku State yang benar
  Widget _buildProfileMenu(IconData icon, String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: ListTile(
        onTap: onTap ?? () {},
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF4F46E5)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }
}
