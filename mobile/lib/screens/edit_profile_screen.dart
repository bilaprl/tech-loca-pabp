import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controller untuk data profil
  final TextEditingController _nameController = TextEditingController(
    text: "Muthia Anggraeni",
  );
  final TextEditingController _usernameController = TextEditingController(
    text: "muthia_ang",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "muthia.rukmawan@student.unsil.ac.id",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "081234567890",
  );
  final TextEditingController _univController = TextEditingController(
    text: "Universitas Siliwangi",
  );
  final TextEditingController _locationController = TextEditingController(
    text: "Tasikmalaya, Jawa Barat",
  );

  // Controller untuk ganti password
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO PROFIL
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      "https://ui-avatars.com/api/?name=Muthia+Anggraeni&background=4F46E5&color=fff",
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
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
              "Username",
              _usernameController,
              Icons.alternate_email,
            ),
            _buildInputField("Email", _emailController, Icons.mail_outline),
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

            const Divider(height: 40),

            // FORM GANTI PASSWORD (Sesuai Web)
            const Text(
              "Ganti Password",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 15),
            _buildInputField(
              "Password Lama",
              _oldPassController,
              Icons.lock_outline,
              isPassword: true,
            ),
            _buildInputField(
              "Password Baru",
              _newPassController,
              Icons.lock_reset_outlined,
              isPassword: true,
            ),

            const SizedBox(height: 30),

            // TOMBOL SIMPAN
            ElevatedButton(
              onPressed: () {
                // Kirim data balik ke halaman Profil Utama agar tampilan berubah
                Navigator.pop(context, {
                  'name': _nameController.text,
                  'username': _usernameController.text,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profil Berhasil Diperbarui"),
                    backgroundColor: Color(0xFF4F46E5),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
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
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
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
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
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
