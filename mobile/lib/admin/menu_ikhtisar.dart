import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../event_model.dart';

class MenuIkhtisar extends StatefulWidget {
  const MenuIkhtisar({super.key});

  @override
  State<MenuIkhtisar> createState() => _MenuIkhtisarState();
}

class _MenuIkhtisarState extends State<MenuIkhtisar> {
  int totalMembers = 0;
  int confirmedTickets = 0;
  int pendingPayments = 0;
  List<Map<String, dynamic>> activityLogs = [];
  bool isLoading = true;

  Map<int, int> trafficData = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
  List<String> dayLabels = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];
  int maxTrafficCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchSummaryData();
  }

  // AMBIL DATA AGREGASI & LOG AKTIVITAS DARI SUPABASE (VERSI PALING AMAN & KOMPATIBEL)
  Future<void> _fetchSummaryData() async {
    try {
      final supabase = Supabase.instance.client;

      // 1. Hitung Total Member (Role Peserta/User)
      final membersCountRes = await supabase
          .from('profiles')
          .select('id')
          .eq('role', 'user');
      final int membersCount = (membersCountRes as List).length;

      // 2. Hitung Tiket Confirmed
      final confirmedCountRes = await supabase
          .from('transactions')
          .select('id')
          .eq('status', 'confirmed');
      final int confirmedCount = (confirmedCountRes as List).length;

      // 3. Hitung Pending Payment
      final pendingCountRes = await supabase
          .from('transactions')
          .select('id')
          .eq('status', 'pending');
      final int pendingCount = (pendingCountRes as List).length;

      // 4. Hitung Trafik Pendaftaran 7 Hari Terakhir untuk Grafik (Rolling 7 Days)
      final DateTime now = DateTime.now();
      final DateTime midnightToday = DateTime(now.year, now.month, now.day);
      final DateTime startDate = midnightToday.subtract(
        const Duration(days: 6),
      );

      final trafficResponse = await supabase
          .from('transactions')
          .select('created_at')
          .gte('created_at', startDate.toIso8601String());

      final Map<int, int> localTraffic = {
        0: 0,
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
        6: 0,
      };

      final List<String> localDayLabels = List.filled(7, "");
      final List<String> weekdaysName = [
        "Sen",
        "Sel",
        "Rab",
        "Kam",
        "Jum",
        "Sab",
        "Min",
      ];

      for (int i = 0; i < 7; i++) {
        DateTime targetDate = startDate.add(Duration(days: i));
        localDayLabels[i] = weekdaysName[targetDate.weekday - 1];
      }

      for (var trans in trafficResponse as List) {
        if (trans['created_at'] != null) {
          final DateTime transDate = DateTime.parse(
            trans['created_at'],
          ).toLocal();

          // 🌟 PERBAIKAN UTAMA: Pastikan pembuatan instansi tanggal dicatat dalam basis zona waktu lokal perangkat (.local)
          // agar kalkulasi perbandingan .difference() lurus dan tidak meleset akibat bias offset UTC database.
          final DateTime transDay = DateTime(
            transDate.year,
            transDate.month,
            transDate.day,
          );
          final int differenceInDays = transDay.difference(startDate).inDays;

          if (differenceInDays >= 0 && differenceInDays < 7) {
            localTraffic[differenceInDays] =
                (localTraffic[differenceInDays] ?? 0) + 1;
          }
        }
      }

      int maxVal = 0;
      localTraffic.forEach((key, val) {
        if (val > maxVal) maxVal = val;
      });

      // 5. Ambil Log Transaksi Terbaru (Join dengan Profiles dan Events)
      final logsResponse = await supabase
          .from('transactions')
          .select(
            'id, status, created_at, is_checked_in, profiles(full_name), events(title)',
          )
          .order('created_at', ascending: false)
          .limit(5);

      final List<Map<String, dynamic>> parsedLogs = [];
      for (var log in logsResponse as List) {
        final profile = log['profiles'];
        final event = log['events'];
        if (profile != null && event != null) {
          String actionText = "Mendaftar di event ${event['title']}";
          IconData icon = Icons.person_add_rounded;
          Color color = const Color(0xFF4F46E5);

          if (log['is_checked_in'] == true) {
            actionText = "Berhasil check-in di ${event['title']}";
            icon = Icons.qr_code_scanner_rounded;
            color = const Color(0xFF6366F1);
          } else if (log['status'] == 'confirmed') {
            actionText = "Pembayaran dikonfirmasi untuk ${event['title']}";
            icon = Icons.payments_rounded;
            color = const Color(0xFF10B981);
          }

          // Ambil waktu jam & menit secara lokal
          final DateTime parsedDate = DateTime.parse(
            log['created_at'],
          ).toLocal();
          final String timeString =
              "${parsedDate.day}/${parsedDate.month} • ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}";

          parsedLogs.add({
            'name': profile['full_name'] ?? 'Anonim',
            'action': actionText,
            'time': timeString,
            'icon': icon,
            'color': color,
          });
        }
      }

      if (mounted) {
        setState(() {
          totalMembers = membersCount;
          confirmedTickets = confirmedCount;
          pendingPayments = pendingCount;
          trafficData = localTraffic;
          dayLabels = localDayLabels;
          maxTrafficCount = maxVal;
          activityLogs = parsedLogs;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Following Summary Dashboard: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  double _calculateBarHeight(int count) {
    if (maxTrafficCount == 0 || count == 0) {
      return 10.0; // Tinggi minimal jika kosong biar estetik
    }
    // Maksimal tinggi bar di dalam kontainer adalah 110px agar teks hari tidak terdorong keluar
    return (count / maxTrafficCount) * 110.0;
  }

  // FITUR PULL-TO-REFRESH
  Future<void> _handleRefresh() async {
    await _fetchSummaryData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFF4F46E5),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "IKHTISAR SISTEM LIVE",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 16),

            // Statistik Cards dengan Data Asli Backend
            isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _buildWebCard(
                        "TOTAL MEMBER",
                        totalMembers.toString(),
                        "Pengguna terdaftar",
                        const Color(0xFF4F46E5),
                        const Color(0xFFEEF2FF),
                      ),
                      _buildWebCard(
                        "TICKET CONFIRMED",
                        confirmedTickets.toString(),
                        "Siap check-in",
                        const Color(0xFF059669),
                        const Color(0xFFECFDF5),
                      ),
                      _buildWebCard(
                        "PENDING PAYMENT",
                        pendingPayments.toString(),
                        "Perlu verifikasi",
                        const Color(0xFFD97706),
                        const Color(0xFFFFFBEB),
                      ),
                      _buildWebCard(
                        "PLATFORM STATUS",
                        "LIVE",
                        "Region Tasikmalaya",
                        const Color(0xFF1E293B),
                        const Color(0xFFF1F5F9),
                      ),
                    ],
                  ),

            const SizedBox(height: 32),
            const Text(
              "TRAFIK PENDAFTARAN (7 HARI TERAKHIR)",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 16),

            // GRAFIK TRAFIK KINI 100% DINAMIS BERDASARKAN DATABASE LIVE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _webBoxDecoration(),
              child: SizedBox(
                height: 150,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(7, (index) {
                          return _buildBar(
                            _calculateBarHeight(trafficData[index] ?? 0),
                            dayLabels[index],
                            trafficData[index] ?? 0,
                          );
                        }),
                      ),
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              "LOG AKTIVITAS PESERTA REAL-TIME",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 16),

            // Daftar Aktivitas Riil dari Database
            Container(
              decoration: _webBoxDecoration(),
              child: isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : activityLogs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          "Belum ada aktivitas pendaftaran.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      children: activityLogs.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var log = entry.value;
                        return Column(
                          children: [
                            _buildWebLog(
                              log['name'],
                              log['action'],
                              log['time'],
                              log['icon'],
                              log['color'],
                            ),
                            if (idx < activityLogs.length - 1)
                              const Divider(height: 1, indent: 60),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebCard(
    String label,
    String value,
    String sub,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: textColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, String day, int totalCount) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (totalCount > 0)
          Text(
            "$totalCount",
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4F46E5),
            ),
          ),
        const SizedBox(height: 2),
        Container(
          width: 25,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildWebLog(
    String user,
    String act,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        user,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        act,
        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
      ),
      trailing: Text(
        time,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  BoxDecoration _webBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
