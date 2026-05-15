"use client";
import { useState, useEffect } from "react";
import { supabase } from "@/lib/supabaseClient";

export default function LandingPage({ navigateTo, openAuth, onOpenModal }) {
  const [currentSlide, setCurrentSlide] = useState(0);
  const [urgentEvents, setUrgentEvents] = useState([]);
  const [loading, setLoading] = useState(true);

  const slides = [
    "https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=2000",
    "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=2000",
  ];

  // --- FUNGSI FETCH DATA DARI SUPABASE (SINKRON DENGAN EXPLORE) ---
  const fetchTrendingEvents = async () => {
    try {
      setLoading(true);
      const today = new Date().toISOString();

      // Mencegah "0 terus": Ambil event yang BELUM expired dan slotnya MASIH ADA (> 0)
      const { data, error } = await supabase
        .from("events_with_slots")
        .select("*")
        .gte("date", today)
        .gt("sisa_slot", 0)
        .order("sisa_slot", { ascending: true })
        .limit(3);

      if (error) throw error;

      // Fallback: Jika semua event sudah penuh/0 slot, tampilkan event terbaru saja
      if (!data || data.length === 0) {
        const { data: fallbackData } = await supabase
          .from("events_with_slots")
          .select("*")
          .gte("date", today)
          .order("date", { ascending: true })
          .limit(3);
        setUrgentEvents(fallbackData || []);
      } else {
        setUrgentEvents(data);
      }
    } catch (error) {
      console.error("Error fetching trending events:", error.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTrendingEvents();

    const timer = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % slides.length);
    }, 5000);
    return () => clearInterval(timer);
  }, []);

  return (
    <div className="flex flex-col w-full bg-white">
      {/* --- 1. HERO SECTION --- */}
      <section className="relative h-[100vh] bg-dark flex items-center overflow-hidden">
        {slides.map((src, idx) => (
          <div
            key={idx}
            className={`absolute inset-0 transition-opacity duration-1000 ${
              idx === currentSlide ? "opacity-30 z-10" : "opacity-0 z-0"
            }`}
          >
            <img
              src={src}
              className="w-full h-full object-cover scale-105 animate-slow-zoom"
              alt="Background"
            />
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_right,_var(--tw-gradient-from)_0%,_transparent_50%)] from-brand-600/20"></div>
            <div className="absolute inset-0 bg-gradient-to-r from-dark via-dark/80 to-transparent"></div>
          </div>
        ))}

        <div className="absolute top-1/4 right-10 w-64 h-64 bg-brand-600/20 rounded-full blur-[100px] animate-pulse"></div>
        <div className="absolute bottom-1/4 right-1/4 w-32 h-32 bg-indigo-500/20 rounded-full blur-[80px] animate-bounce duration-[5000ms]"></div>

        <div className="relative z-20 max-w-7xl mx-auto px-6 w-full pt-20">
          <div className="flex flex-col lg:flex-row items-center justify-between gap-12">
            <div className="w-full lg:w-2/3">
              <div className="inline-flex items-center gap-3 bg-white/5 backdrop-blur-xl border border-white/10 px-5 py-2 rounded-2xl mb-8 animate-in slide-in-from-left duration-700">
                <div className="flex -space-x-2">
                  {[1, 2, 3].map((i) => (
                    <div
                      key={i}
                      className="w-6 h-6 rounded-full border-2 border-dark bg-slate-400 overflow-hidden"
                    >
                      <img
                        src={`https://i.pravatar.cc/50?u=${i + 10}`}
                        alt="avatar"
                      />
                    </div>
                  ))}
                </div>
                <span className="text-brand-500 text-[10px] font-black uppercase tracking-[0.2em] border-l border-white/10 pl-3">
                  Trusted by 10k+ Developers
                </span>
              </div>

              <h1 className="font-heading text-6xl md:text-8xl lg:text-[100px] text-white font-black mb-8 leading-[0.95] tracking-tighter">
                Build the <br />
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-brand-400 to-brand-600 italic">
                  Future
                </span>{" "}
                of Tech.
              </h1>

              <p className="text-slate-400 text-lg md:text-xl max-w-xl mb-12 leading-relaxed font-medium">
                Akses eksklusif ke berbagai workshop dan seminar IT terdekat.
                Hubungkan potensimu dengan ekosistem teknologi terbaik sekarang.
              </p>

              <div className="flex flex-col sm:flex-row gap-5">
                <button
                  onClick={() => navigateTo("explore")}
                  className="group px-10 py-5 bg-brand-600 hover:bg-brand-500 text-white font-bold rounded-[2rem] shadow-2xl shadow-brand-600/40 transition-all flex items-center justify-center gap-3 transform hover:-translate-y-1 hover:scale-105"
                >
                  Mulai Eksplorasi
                  <span className="material-icons-round group-hover:rotate-45 transition-transform">
                    rocket_launch
                  </span>
                </button>
                <button
                  onClick={openAuth}
                  className="px-10 py-5 bg-white/5 backdrop-blur-md border border-white/10 text-white font-bold rounded-[2rem] hover:bg-white/10 transition-all flex items-center justify-center gap-2 hover:border-brand-500/50"
                >
                  Dapatkan Akses Penuh
                  <span className="material-icons-round text-brand-500">
                    verified_user
                  </span>
                </button>
              </div>
            </div>

            <div className="hidden lg:block w-1/3 relative animate-in zoom-in duration-1000">
              <div className="relative z-10 bg-white/5 backdrop-blur-2xl border border-white/10 p-8 rounded-[3rem] shadow-2xl rotate-3 hover:rotate-0 transition-transform duration-500">
                <div className="space-y-8">
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 bg-brand-500/20 rounded-2xl flex items-center justify-center text-brand-500 font-bold">
                      <span className="material-icons-round">public</span>
                    </div>
                    <div>
                      <p className="text-white font-bold text-sm leading-none">
                        Global Tech Hub
                      </p>
                      <p className="text-slate-500 text-[10px] uppercase font-bold mt-1 tracking-widest">
                        Connected Network
                      </p>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div className="bg-white/5 p-4 rounded-2xl border border-white/5">
                      <p className="text-2xl font-black text-white">150+</p>
                      <p className="text-slate-500 text-[9px] uppercase font-bold tracking-tighter">
                        Total Events
                      </p>
                    </div>
                    <div className="bg-white/5 p-4 rounded-2xl border border-white/5">
                      <p className="text-2xl font-black text-brand-500">12+</p>
                      <p className="text-slate-500 text-[9px] uppercase font-bold tracking-tighter">
                        Cities Covered
                      </p>
                    </div>
                  </div>

                  <div className="pt-4 border-t border-white/5">
                    <div className="flex justify-between items-center text-[10px] font-bold text-slate-400 uppercase mb-3">
                      <span className="flex items-center gap-1">
                        <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-pulse"></span>
                        Live Participants
                      </span>
                      <span className="text-white">10.2k</span>
                    </div>
                    <div className="w-full h-1.5 bg-white/5 rounded-full overflow-hidden">
                      <div className="w-[92%] h-full bg-gradient-to-r from-brand-600 to-indigo-400 rounded-full"></div>
                    </div>
                    <p className="text-[9px] text-slate-500 mt-3 italic font-medium leading-relaxed">
                      *Bergabunglah dengan ribuan talenta digital lainnya hari
                      ini.
                    </p>
                  </div>
                </div>
              </div>
              <div className="absolute -top-10 -left-10 w-24 h-24 bg-brand-600 rounded-full mix-blend-screen filter blur-xl opacity-50 animate-pulse"></div>
            </div>
          </div>
        </div>
      </section>

      {/* --- 2. SUGGESTION & BENEFIT SECTION --- */}
      <section className="py-24 relative">
        <div className="absolute top-1/2 left-0 w-96 h-96 bg-brand-500/5 rounded-full blur-[100px] -translate-y-1/2 -translate-x-1/2 pointer-events-none"></div>

        <div className="max-w-7xl mx-auto px-6 relative z-10">
          <div className="mb-14 text-center md:text-left flex flex-col md:flex-row md:items-end justify-between gap-6">
            <div className="max-w-2xl">
              <h2 className="font-heading text-4xl md:text-5xl lg:text-6xl font-extrabold text-dark tracking-tight leading-[1.1]">
                Kenapa Memilih{" "}
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-brand-600 to-brand-400">
                  TechLoca?
                </span>
              </h2>
              <p className="text-slate-500 mt-5 text-lg font-medium">
                Manfaat nyata berdasarkan lokasi dan kebutuhan karir
                teknologimu.
              </p>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-12 gap-6 auto-rows-[minmax(0,1fr)]">
            {/* Box 1 */}
            <div className="md:col-span-7 bg-gradient-to-br from-white to-slate-50/80 rounded-[2.5rem] p-10 md:p-12 relative overflow-hidden group border border-slate-200/60 shadow-[0_4px_20px_rgba(0,0,0,0.02)] hover:shadow-[0_20px_40px_-15px_rgba(99,102,241,0.15)] hover:border-brand-200 transition-all duration-500">
              <div className="relative z-10 flex flex-col h-full">
                <div className="relative w-16 h-16 mb-8">
                  <div className="absolute inset-0 bg-brand-200 rounded-2xl animate-ping opacity-20 group-hover:opacity-40 transition-opacity"></div>
                  <div className="relative w-full h-full bg-white border border-slate-100 rounded-2xl flex items-center justify-center shadow-sm text-brand-600 group-hover:scale-110 group-hover:bg-brand-50 transition-all duration-500 z-10">
                    <span className="material-icons-round text-3xl">
                      location_on
                    </span>
                  </div>
                </div>

                <h3 className="text-3xl lg:text-4xl font-heading font-extrabold text-dark mb-4 leading-tight group-hover:text-brand-600 transition-colors duration-300">
                  Event IT Terdekat di Lokasimu.
                </h3>
                <p className="text-slate-500 max-w-md font-medium leading-relaxed mb-8 flex-grow">
                  Sesuai namanya, <strong>TechLoca</strong> memprioritaskan
                  kemudahan akses lokasi. Temukan workshop dan seminar IT yang
                  diselenggarakan di sekitarmu, meminimalkan waktu perjalanan
                  dan memaksimalkan waktu belajarmu.
                </p>

                <div className="mt-auto flex items-center gap-4">
                  <button
                    onClick={() => navigateTo("explore")}
                    className="group/btn flex items-center gap-2 text-sm font-black uppercase tracking-widest text-brand-600 hover:text-brand-700 transition-all"
                  >
                    Cek Lokasi Event
                    <span className="material-icons-round group-hover/btn:translate-x-2 transition-transform duration-300">
                      arrow_right_alt
                    </span>
                  </button>
                </div>
              </div>
              <span className="material-icons-round absolute -right-12 -bottom-16 text-[20rem] lg:text-[24rem] text-slate-100/50 pointer-events-none group-hover:text-brand-50 transition-all duration-700 group-hover:-rotate-12 group-hover:scale-110">
                explore
              </span>
            </div>

            {/* Box 2 */}
            <div className="md:col-span-5 bg-gradient-to-br from-brand-600 to-brand-800 rounded-[2.5rem] p-10 md:p-12 text-white relative overflow-hidden group shadow-xl shadow-brand-600/20 hover:shadow-2xl hover:shadow-brand-600/40 hover:-translate-y-1 transition-all duration-500">
              <div className="absolute -top-24 -right-24 w-64 h-64 bg-white/10 rounded-full blur-3xl group-hover:bg-white/20 transition-all duration-700"></div>
              <div className="relative z-10 flex flex-col h-full justify-between">
                <div>
                  <div className="w-14 h-14 bg-white/10 backdrop-blur-md rounded-2xl flex items-center justify-center border border-white/20 mb-8 group-hover:scale-110 transition-transform duration-500">
                    <span className="material-icons-round text-3xl text-white">
                      hub
                    </span>
                  </div>
                  <h4 className="text-2xl lg:text-3xl font-heading font-extrabold mb-4 leading-tight">
                    Terhubung dengan Ekosistem Lokal.
                  </h4>
                  <p className="text-brand-100 text-sm font-medium leading-relaxed">
                    Bertemu langsung dengan sesama mahasiswa dan profesional IT
                    di kotamu. Bangun relasi yang berharga untuk masa depan
                    karirmu.
                  </p>
                </div>
                <div className="pt-10 flex -space-x-4 overflow-hidden group-hover:translate-x-2 transition-transform duration-500">
                  {[1, 2, 3, 4, 5].map((i) => (
                    <img
                      key={i}
                      src={`https://i.pravatar.cc/100?u=${i + 40}`}
                      className="w-12 h-12 rounded-full border-2 border-brand-600 shadow-lg relative transition-transform duration-300 hover:-translate-y-2 hover:z-20 cursor-pointer"
                      style={{ zIndex: 10 - i }}
                      alt="Avatar"
                    />
                  ))}
                  <div className="w-12 h-12 rounded-full border-2 border-brand-600 bg-brand-500 flex items-center justify-center text-xs font-bold shadow-lg relative z-0">
                    +99
                  </div>
                </div>
              </div>
            </div>

            {/* Box 3 */}
            <div className="md:col-span-5 bg-slate-900 rounded-[2.5rem] p-10 md:p-12 text-white group overflow-hidden relative border border-slate-800 hover:border-brand-500/50 hover:shadow-[0_0_40px_rgba(99,102,241,0.15)] transition-all duration-500">
              <div className="absolute top-0 right-0 w-32 h-32 bg-brand-500/20 rounded-full blur-[50px] group-hover:bg-brand-500/40 transition-colors duration-700"></div>
              <div className="relative z-10 flex flex-col h-full justify-center">
                <h4 className="text-2xl font-heading font-bold mb-4 flex items-center gap-3">
                  Fokus pada Skill Spesifik{" "}
                  <span className="material-icons-round text-brand-400">
                    psychology
                  </span>
                </h4>
                <p className="text-slate-400 text-sm font-medium leading-relaxed mb-8">
                  Pilih workshop berdasarkan minatmu: Frontend, UI/UX, AI,
                  hingga Cyber Security. Belajar apa yang benar-benar kamu
                  butuhkan.
                </p>
                <div className="flex flex-wrap gap-2.5">
                  {["Next.js", "Figma", "Python", "React", "Node.js"].map(
                    (tag) => (
                      <span
                        key={tag}
                        className="px-4 py-1.5 bg-white/5 border border-white/10 rounded-xl text-[10px] font-bold text-slate-300 uppercase tracking-widest hover:bg-brand-500/20 hover:text-brand-300 hover:border-brand-500/30 transition-all duration-300 cursor-default"
                      >
                        {tag}
                      </span>
                    ),
                  )}
                </div>
              </div>
            </div>

            {/* Box 4 */}
            <div className="md:col-span-7 bg-gradient-to-tr from-slate-950 to-slate-900 rounded-[2.5rem] p-10 md:p-12 text-white flex flex-col md:flex-row items-center justify-between gap-8 relative overflow-hidden group border border-slate-800 shadow-2xl hover:shadow-[0_20px_50px_rgba(0,0,0,0.3)] transition-all duration-500">
              <div
                className="absolute inset-0 opacity-20 pointer-events-none transition-opacity duration-700 group-hover:opacity-30"
                style={{
                  backgroundImage:
                    "linear-gradient(#4f46e5 1px, transparent 1px), linear-gradient(90deg, #4f46e5 1px, transparent 1px)",
                  backgroundSize: "32px 32px",
                  maskImage:
                    "radial-gradient(ellipse at center, black 0%, transparent 80%)",
                  WebkitMaskImage:
                    "radial-gradient(ellipse at center, black 0%, transparent 80%)",
                }}
              ></div>
              <div className="relative z-10 w-full md:w-auto text-center md:text-left">
                <span className="inline-block px-3 py-1 bg-brand-500/20 border border-brand-500/30 text-brand-400 rounded-lg font-black text-[10px] uppercase tracking-[0.2em] mb-5">
                  Quick Discovery
                </span>
                <h4 className="text-3xl lg:text-4xl font-heading font-extrabold mb-4 leading-tight">
                  Temukan Event yang <br className="hidden md:block" /> Sesuai
                  Jadwalmu.
                </h4>
                <p className="text-slate-400 text-sm max-w-sm mx-auto md:mx-0 font-medium leading-relaxed">
                  Gunakan filter canggih untuk menemukan workshop yang paling
                  dekat waktunya agar tidak ketinggalan slot.
                </p>
              </div>
              <button
                onClick={() => navigateTo("explore")}
                className="relative z-10 w-full md:w-auto px-8 py-4 bg-white text-dark font-black rounded-2xl hover:bg-brand-600 hover:text-white transition-all duration-300 shadow-xl shadow-white/5 hover:shadow-brand-600/40 flex items-center justify-center gap-2 group/btn shrink-0"
              >
                Buka Katalog
                <span className="material-icons-round text-brand-600 group-hover/btn:text-white transition-colors">
                  launch
                </span>
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* --- 3. MINI KATALOG: THE HOT LIST (SINKRON DENGAN EXPLORE & MODAL) --- */}
      <section className="py-32 bg-slate-50 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-gradient-to-br from-brand-500/10 to-rose-500/5 rounded-full blur-[120px] -translate-y-1/2 translate-x-1/3"></div>
        <div className="absolute bottom-0 left-0 w-[600px] h-[600px] bg-brand-400/5 rounded-full blur-[100px] translate-y-1/3 -translate-x-1/4"></div>

        <div className="max-w-7xl mx-auto px-6 relative z-10">
          <div className="flex flex-col md:flex-row justify-between items-end mb-16 gap-6 border-b border-slate-200/60 pb-8">
            <div className="max-w-xl">
              <div className="inline-flex items-center gap-2 px-3 py-1.5 bg-rose-50 border border-rose-100 rounded-full mb-6 shadow-sm">
                <span className="flex h-2.5 w-2.5 relative">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-rose-400 opacity-75"></span>
                  <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-rose-500"></span>
                </span>
                <span className="text-[10px] font-black text-rose-600 uppercase tracking-[0.15em]">
                  Akan Berakhir
                </span>
              </div>
              <h2 className="font-heading text-4xl md:text-5xl lg:text-6xl font-extrabold text-dark leading-[1.1]">
                Amankan{" "}
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-brand-600 to-brand-400">
                  Slot
                </span>{" "}
                Sebelum Penuh.
              </h2>
            </div>
            <button
              onClick={() => navigateTo("explore")}
              className="group relative overflow-hidden flex items-center gap-3 px-8 py-4 bg-white border border-slate-200 rounded-2xl font-bold text-dark hover:text-brand-600 hover:border-brand-200 hover:shadow-[0_8px_30px_rgba(99,102,241,0.1)] transition-all duration-300"
            >
              <span className="relative z-10">Lihat Semua Katalog</span>
              <span className="material-icons-round text-brand-500 group-hover:translate-x-1 transition-transform relative z-10">
                arrow_forward
              </span>
              <div className="absolute inset-0 h-full w-0 bg-brand-50/50 group-hover:w-full transition-all duration-300 ease-out"></div>
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {loading
              ? [1, 2, 3].map((i) => (
                  <div
                    key={i}
                    className="bg-white rounded-[2.5rem] p-3 shadow-sm border border-slate-50 animate-pulse"
                  >
                    <div className="h-60 bg-slate-200 rounded-[2rem] mb-5"></div>
                    <div className="px-3 pb-4">
                      <div className="h-6 bg-slate-200 rounded mb-4 w-3/4"></div>
                      <div className="grid grid-cols-2 gap-3 mb-6">
                        <div className="h-16 bg-slate-200 rounded-2xl"></div>
                        <div className="h-16 bg-slate-200 rounded-2xl"></div>
                      </div>
                      <div className="h-8 bg-slate-200 rounded-full w-full"></div>
                    </div>
                  </div>
                ))
              : urgentEvents.map((ev) => {
                  const isFull = ev.sisa_slot <= 0;
                  const isExpired = new Date(ev.date) < new Date();

                  return (
                    <div
                      key={ev.id}
                      onClick={() => onOpenModal && onOpenModal(ev)}
                      className={`bg-white rounded-[2.5rem] p-3 shadow-sm border border-slate-50 hover:shadow-2xl hover:shadow-brand-500/10 hover:-translate-y-2 transition-all duration-500 group cursor-pointer flex flex-col ${isExpired ? "opacity-75 grayscale-[0.5]" : ""}`}
                    >
                      <div className="h-60 rounded-[2rem] overflow-hidden relative mb-5">
                        <img
                          src={ev.image_url || "/placeholder-event.jpg"}
                          className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-1000"
                          alt={ev.title}
                        />

                        <div className="absolute bottom-4 left-4 flex gap-2">
                          <span className="px-4 py-2 bg-brand-500 text-white text-[9px] font-black uppercase tracking-widest rounded-full shadow-lg">
                            {ev.location || "Online"}
                          </span>
                          {isExpired && (
                            <span className="px-4 py-2 bg-rose-500 text-white text-[9px] font-black uppercase tracking-widest rounded-full shadow-lg">
                              Selesai
                            </span>
                          )}
                        </div>
                      </div>

                      <div className="px-3 pb-4 flex-grow flex flex-col">
                        <h3 className="font-heading text-xl font-black text-dark leading-tight mb-4 group-hover:text-brand-600 transition-colors line-clamp-2">
                          {ev.title}
                        </h3>

                        <div className="grid grid-cols-2 gap-3 mb-6">
                          <div className="bg-slate-50 rounded-2xl p-3 border border-slate-100">
                            <span className="text-[9px] text-slate-400 font-black uppercase tracking-tighter block mb-1">
                              Jadwal
                            </span>
                            <div className="flex items-center gap-1.5">
                              <span
                                className={`material-icons-round text-sm ${isExpired ? "text-slate-400" : "text-brand-500"}`}
                              >
                                calendar_today
                              </span>
                              <span
                                className={`text-[11px] font-black ${isExpired ? "text-slate-400" : "text-dark"}`}
                              >
                                {ev.date
                                  ? new Date(ev.date).toLocaleDateString(
                                      "id-ID",
                                      {
                                        day: "numeric",
                                        month: "short",
                                      },
                                    )
                                  : "-"}
                              </span>
                            </div>
                          </div>
                          <div className="bg-slate-50 rounded-2xl p-3 border border-slate-100">
                            <span className="text-[9px] text-slate-400 font-black uppercase tracking-tighter block mb-1">
                              Investasi
                            </span>
                            <div className="flex items-center gap-1.5">
                              <span className="material-icons-round text-emerald-500 text-sm">
                                payments
                              </span>
                              <span className="text-[11px] font-black text-dark truncate">
                                {ev.price
                                  ? `Rp ${ev.price.toLocaleString()}`
                                  : "Gratis"}
                              </span>
                            </div>
                          </div>
                        </div>

                        <div className="mt-auto pt-5 border-t border-slate-50">
                          <div className="flex justify-between items-center mb-2">
                            <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest">
                              Status Acara
                            </span>
                            <span
                              className={`text-[10px] font-black px-3 py-1 rounded-full ${isExpired ? "bg-slate-100 text-slate-500" : isFull ? "bg-rose-100 text-rose-600" : "bg-brand-50 text-brand-600"}`}
                            >
                              {isExpired
                                ? "Pendaftaran Ditutup"
                                : isFull
                                  ? "Kuota Habis"
                                  : `${ev.sisa_slot} Slot Tersisa`}
                            </span>
                          </div>
                          <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
                            <div
                              className={`h-full rounded-full transition-all duration-1000 ${isExpired ? "bg-slate-300" : isFull ? "bg-rose-500" : "bg-brand-500"}`}
                              style={{
                                width:
                                  isExpired || isFull
                                    ? "100%"
                                    : `${Math.min(100, (ev.sisa_slot / (ev.quota || 1)) * 100)}%`,
                              }}
                            ></div>
                          </div>
                        </div>
                      </div>
                    </div>
                  );
                })}
          </div>
        </div>
      </section>
    </div>
  );
}
