import 'package:hive_flutter/hive_flutter.dart';

class TicketService {
  static const String _boxName = "ticketBox";

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  // Fungsi menyimpan tiket (saat pertama kali daftar/beli)
  static Future<void> saveTicket(Map<String, dynamic> ticketData) async {
    var box = Hive.box(_boxName);
    await box.put('my_ticket', ticketData);
  }

  // Fungsi mengambil tiket (meskipun offline)
  static Map<dynamic, dynamic>? getSavedTicket() {
    var box = Hive.box(_boxName);
    return box.get('my_ticket');
  }
}
