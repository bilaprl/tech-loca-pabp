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
  });

  // FUNGSI UTK KONVERSI DARI JSON SUPABASE KE OBJECT EVENT (Sesuai Kolom Database Saklek)
  factory Event.fromJson(Map<String, dynamic> json) {
    // Fallback gambar default jika kolom image_url di database bernilai null/kosong
    final String rawImg = json['image_url']?.toString() ?? '';
    final String safeImg = rawImg.trim().isEmpty
        ? 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=1000'
        : rawImg;

    return Event(
      id: json['id'], // uuid NOT NULL
      title: json['title']?.toString() ?? '', // text NOT NULL
      category:
          json['category']?.toString() ??
          'Workshop IT', // text DEFAULT 'Workshop IT'
      eo: json['eo']?.toString() ?? '', // text
      date:
          json['date']?.toString() ??
          DateTime.now().toIso8601String(), // timestamp with time zone
      location: json['location']?.toString() ?? '', // text
      venue: json['venue']?.toString() ?? '', // text
      // Di database: quota integer. Di model properti: int.
      quota: int.tryParse(json['quota']?.toString() ?? '0') ?? 0,
      max:
          int.tryParse(json['quota']?.toString() ?? '0') ??
          0, // Diisi dari nilai quota database sebagai limit awal mobile
      // 🌟 PERBAIKAN DI SINI: Sesuaikan nama parameter dengan deklarasi di constructor
      imageUrl: safeImg,

      // Nama parameternya 'desc' sesuai constructor kelas, tapi key JSON dari kolom 'description'
      desc: json['description']?.toString() ?? '',

      // Di database: price integer. Di model properti: String. Kita konversi ke String aman.
      price: json['price']?.toString() ?? '0',

      mapsUrl: json['maps_url']?.toString() ?? '', // text
      createdAt:
          json['created_at']?.toString() ??
          DateTime.now().toIso8601String(), // timestamp with time zone
    );
  }
}
