import 'dart:convert';
import 'dart:typed_data';

class Event {
  final dynamic id;
  final String title;
  final String category;
  final String eo;
  final String date;
  final String location;
  final String venue;
  final int quota;
  final int max;
  final String imageUrl;
  final String desc;
  final String price;
  final String mapsUrl;
  final String createdAt;

  bool isWishlisted;

  final bool isBase64Image;
  final Uint8List? base64Bytes;

  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.eo,
    required this.date,
    required this.location,
    required this.venue,
    required this.quota,
    required this.max,
    required this.imageUrl,
    required this.desc,
    required this.price,
    required this.mapsUrl,
    required this.createdAt,
    this.isWishlisted = false,
    this.isBase64Image = false,
    this.base64Bytes,
  });

  // FUNGSI UTK KONVERSI DARI JSON SUPABASE KE OBJECT EVENT (Sesuai Kolom Database Saklek)
  factory Event.fromJson(Map<String, dynamic> json) {
    // Fallback gambar default jika kolom image_url di database bernilai null/kosong
    final String rawImg = json['image_url']?.toString() ?? '';
    final String safeImg = rawImg.trim().isEmpty
        ? 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=1000'
        : rawImg;

    bool base64Check = safeImg.startsWith('data:image');
    Uint8List? bytes;

    if (base64Check) {
      try {
        // Membuang teks "data:image/...;base64," dan menyisakan kode aslinya
        String base64Str = safeImg.split(',').last;
        bytes = base64Decode(base64Str);
      } catch (e) {
        base64Check = false;
      }
    }

    return Event(
      id: json['id'],
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Workshop IT',
      eo: json['eo']?.toString() ?? '',
      date: json['date']?.toString() ?? DateTime.now().toIso8601String(),
      location: json['location']?.toString() ?? '',
      venue: json['venue']?.toString() ?? '',
      quota: int.tryParse(json['quota']?.toString() ?? '0') ?? 0,
      max: int.tryParse(json['quota']?.toString() ?? '0') ?? 0,
      imageUrl: safeImg,
      desc: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      mapsUrl: json['maps_url']?.toString() ?? '',
      createdAt:
          json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      isBase64Image: base64Check,
      base64Bytes: bytes,
    );
  }
}
