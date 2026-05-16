import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controller untuk data profil
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _univController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Ambil data awal dari database
  }

  // FUNGSI MENARIK DATA AWAL DARI SUPABASE
  Future<void> _fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          if (data != null) {
            _nameController.text = data['full_name']?.toString() ?? '';
            _avatarUrlController.text = data['avatar_url']?.toString() ?? '';
            _emailController.text =
                data['email']?.toString() ?? user.email ?? '';
            _phoneController.text = data['whatsapp']?.toString() ?? '';
            _univController.text = data['institution']?.toString() ?? '';
            _locationController.text = data['location']?.toString() ?? '';
          } else {
            // Jika baris data profile belum ada di database, set fallback dari Auth
            _emailController.text = user.email ?? '';
          }
          _isLoading =
              false; // ✅ PERBAIKAN: Loading dipastikan mati baik data null maupun tidak
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // FUNGSI PULL-TO-REFRESH
  Future<void> _handleRefresh() async {
    await _fetchUserData();
  }

  // FUNGSI UPDATE DATA KE SUPABASE
  Future<void> _updateProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      // Menggunakan query upsert agar jika baris profil belum terbuat, otomatis membuat baris data baru
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id, // Kunci utama UUID pengguna
        'full_name': _nameController.text.trim(),
        'avatar_url': _avatarUrlController.text.trim(),
        'whatsapp': _phoneController.text.trim(),
        'institution': _univController.text.trim(),
        'location': _locationController.text.trim(),
        'email': _emailController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      // Balik ke halaman profil dan beritahu bahwa data berhasil diupdate
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil Berhasil Diperbarui"),
          backgroundColor: Color(0xFF4F46E5),
        ),
      );
    } catch (e) {
      debugPrint("Error Update: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memperbarui profil"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profil",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF4F46E5),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Wajib agar bisa di-refresh
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FOTO PROFIL
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFEEF2FF),
                        backgroundImage: _avatarUrlController.text.isNotEmpty
                            ? NetworkImage(_avatarUrlController.text)
                            : null,
                        child: _avatarUrlController.text.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Color(0xFF4F46E5),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // FORM DATA DIRI
                    _buildInputField(
                      "Nama Lengkap",
                      _nameController,
                      Icons.person_outline,
                    ),
                    _buildInputField(
                      "Avatar Image URL",
                      _avatarUrlController,
                      Icons.image_outlined,
                    ),
                    _buildInputField(
                      "Email",
                      _emailController,
                      Icons.mail_outline,
                      isReadOnly: true,
                    ),
                    _buildInputField(
                      "Nomor Telepon",
                      _phoneController,
                      Icons.phone_android_outlined,
                    ),
                    _buildInputField(
                      "Institusi / Universitas",
                      _univController,
                      Icons.school_outlined,
                    ),
                    _buildInputField(
                      "Lokasi / Domisili",
                      _locationController,
                      Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 30),

                    // TOMBOL SIMPAN
                    ElevatedButton(
                      onPressed: _isSaving ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Simpan Perubahan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // 🌟 PERBAIKAN UTAMA: Memasukkan kembali fungsi pembangun input text ke dalam penutup block State yang benar
  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    bool isReadOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: isPassword,
            readOnly: isReadOnly,
            onChanged: (val) {
              // Jika yang diubah adalah avatar URL, trigger refresh preview gambar
              if (label == "Avatar Image URL") setState(() {});
            },
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              filled: true,
              fillColor: isReadOnly
                  ? Colors.grey[100]
                  : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
