import 'package:hive_flutter/hive_flutter.dart';

class TicketService {
  static const String _boxName = "ticketBox";

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  // FUNGSI MENYIMPAN TIKET AKTIF DARI BACKEND KE CACHE LOKAL HIVE
  static Future<void> saveTicket(Map<String, dynamic> ticketData) async {
    var box = Hive.box(_boxName);
    await box.put('my_ticket', ticketData);
  }

  // FUNGSI MENGAMBIL TIKET YANG SUDAH TERCACHED SAAT OFFLINE
  static Map<String, dynamic>? getSavedTicket() {
    var box = Hive.box(_boxName);
    final rawData = box.get('my_ticket');

    if (rawData == null) return null;

    // 🌟 PERBAIKAN UTAMA: Menggunakan helper rekursif untuk mengonversi seluruh nested map internal Hive
    // agar kebal dari TypeError saat parsing objek Event.fromJson secara offline.
    return _deepConvertMap(rawData);
  }

  // Helper Rekursif untuk membersihkan tipe data _Map bawaan lokal Hive
  static Map<String, dynamic>? _deepConvertMap(dynamic map) {
    if (map == null) return null;

    final Map<String, dynamic> converted = {};

    map.forEach((key, value) {
      if (value is Map) {
        converted[key.toString()] = _deepConvertMap(value);
      } else if (value is List) {
        converted[key.toString()] = value.map((item) {
          if (item is Map) {
            return _deepConvertMap(item);
          }
          return item;
        }).toList();
      } else {
        converted[key.toString()] = value;
      }
    });

    return converted;
  }
}
