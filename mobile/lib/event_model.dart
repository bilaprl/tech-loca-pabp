class Event {
  int id;
  String title;
  String category;
  String eo;
  String date;
  String location;
  String venue;
  int quota;
  int max;
  String img;
  String desc;
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
    required this.img,
    required this.desc,
    this.isWishlisted = false,
  });
}

List<Event> mockEvents = [
  Event(
    id: 1,
    title: "Web Dev Bootcamp Unsil",
    category: "Web Dev",
    eo: "Informatika Unsil",
    date: "24 Mei 2026",
    location: "Tasikmalaya",
    venue: "Lab Komputer Terpadu Universitas Siliwangi",
    quota: 2, // Sisa dikit -> Akan muncul di Home
    max: 20,
    img:
        "https://images.unsplash.com/photo-1587620962725-abab7fe55159?q=80&w=600",
    desc:
        "Pelajari Next.js dan Tailwind CSS langsung di Lab Komputer Universitas Siliwangi.",
  ),
  Event(
    id: 2,
    title: "UI/UX Masterclass",
    category: "UI/UX",
    eo: "Tasik Design Hub",
    date: "02 Juni 2026",
    location: "Tasikmalaya",
    venue: "Tasik Creative Center",
    quota: 0, // Penuh -> Akan muncul di Home dengan label PENUH
    max: 50,
    img: "https://images.unsplash.com/photo-1561070791-2526d30994b5?q=80&w=600",
    desc: "Workshop intensif merancang antarmuka bento-box dan glassmorphism.",
  ),
  Event(
    id: 3,
    title: "Cyber Security Seminar",
    category: "Security",
    eo: "HIMA Informatika",
    date: "15 Juni 2026",
    location: "Online",
    venue: "Zoom Meeting",
    quota: 4, // Sisa dikit -> Akan muncul di Home
    max: 100,
    img: "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=600",
    desc: "Memahami dasar-dasar pertahanan jaringan dan etika hacking.",
  ),
  Event(
    id: 4,
    title: "AI & Machine Learning Expo",
    category: "Artificial Intelligence",
    eo: "Tech Community",
    date: "20 Juli 2026",
    location: "Bandung",
    venue: "Trans Convention Center",
    quota: 45, // Masih banyak -> Hanya muncul di Explore
    max: 500,
    img:
        "https://images.unsplash.com/photo-1677442136019-21780ecad995?q=80&w=600",
    desc: "Pameran teknologi AI terbaru dan implementasinya di industri.",
  ),
  Event(
    id: 5,
    title: "Mobile Dev Flutter Workshop",
    category: "Mobile",
    eo: "Google Dev Group",
    date: "10 Agustus 2026",
    location: "Jakarta",
    venue: "Google Office Indonesia",
    quota: 5, // Sisa dikit -> Akan muncul di Home
    max: 30,
    img:
        "https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?q=80&w=600",
    desc:
        "Membangun aplikasi multi-platform dengan satu basis kode menggunakan Flutter.",
  ),
];
