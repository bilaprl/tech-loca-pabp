"use client";
import { useState, useEffect } from "react";
// Import supabase client Anda (sesuaikan path-nya)
import { supabase } from "@/lib/supabaseClient"; 

export default function LandingPage({ navigateTo, openAuth, onOpenModal }) {
  const [currentSlide, setCurrentSlide] = useState(0);
  const [urgentEvents, setUrgentEvents] = useState([]);
  const [loading, setLoading] = useState(true);

  const slides = [
    "https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=2000",
    "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=2000",
  ];

  // 1. Fungsi untuk mengambil data dari Supabase
  const fetchTrendingEvents = async () => {
    try {
      setLoading(true);
      // Mengambil 3 event yang slotnya paling sedikit (urgent) 
      // atau bisa disesuaikan logic-nya
      const { data, error } = await supabase
        .from("events")
        .select("*")
        .order("quota", { ascending: true }) // Menampilkan yang sisa kuotanya paling sedikit
        .limit(3);

      if (error) throw error;
      setUrgentEvents(data || []);
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
      {/* --- 1. HERO SECTION (TIDAK BERUBAH) --- */}
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
                    <div key={i} className="w-6 h-6 rounded-full border-2 border-dark bg-slate-400 overflow-hidden">
                      <img src={`https://i.pravatar.cc/50?u=${i + 10}`} alt="avatar" />
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
                  <span className="material-icons-round group-hover:rotate-45 transition-transform">rocket_launch</span>
                </button>
                <button
                  onClick={openAuth}
                  className="px-10 py-5 bg-white/5 backdrop-blur-md border border-white/10 text-white font-bold rounded-[2rem] hover:bg-white/10 transition-all flex items-center justify-center gap-2 hover:border-brand-500/50"
                >
                  Dapatkan Akses Penuh
                  <span className="material-icons-round text-brand-500">verified_user</span>
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
                      <p className="text-white font-bold text-sm leading-none">Global Tech Hub</p>
                      <p className="text-slate-500 text-[10px] uppercase font-bold mt-1 tracking-widest">Connected Network</p>
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="bg-white/5 p-4 rounded-2xl border border-white/5">
                      <p className="text-2xl font-black text-white">150+</p>
                      <p className="text-slate-500 text-[9px] uppercase font-bold tracking-tighter">Total Events</p>
                    </div>
                    <div className="bg-white/5 p-4 rounded-2xl border border-white/5">
                      <p className="text-2xl font-black text-brand-500">12+</p>
                      <p className="text-slate-500 text-[9px] uppercase font-bold tracking-tighter">Cities Covered</p>
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
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* --- 2. SUGGESTION & BENEFIT SECTION (TIDAK BERUBAH) --- */}
      <section className="py-24 relative">
        <div className="absolute top-1/2 left-0 w-96 h-96 bg-brand-500/5 rounded-full blur-[100px] -translate-y-1/2 -translate-x-1/2 pointer-events-none"></div>
        <div className="max-w-7xl mx-auto px-6 relative z-10">
          <div className="mb-14 text-center md:text-left flex flex-col md:flex-row md:items-end justify-between gap-6">
            <div className="max-w-2xl">
              <h2 className="font-heading text-4xl md:text-5xl lg:text-6xl font-extrabold text-dark tracking-tight leading-[1.1]">
                Kenapa Memilih{" "}
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-brand-600 to-brand-400">TechLoca?</span>
              </h2>
              <p className="text-slate-500 mt-5 text-lg font-medium">Manfaat nyata berdasarkan lokasi dan kebutuhan karir teknologimu.</p>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-12 gap-6 auto-rows-[minmax(0,1fr)]">
             {/* Bento Content Placeholder - Tetap sesuai kode awal Anda */}
             <div className="md:col-span-7 bg-gradient-to-br from-white to-slate-50/80 rounded-[2.5rem] p-10 md:p-12 relative overflow-hidden group border border-slate-200/60 transition-all duration-500 shadow-sm">
                {/* ... Isi Bento 1 ... */}
                <h3 className="text-3xl lg:text-4xl font-heading font-extrabold text-dark mb-4">Event IT Terdekat di Lokasimu.</h3>
                <p className="text-slate-500 mb-8">Sesuai namanya, TechLoca memprioritaskan kemudahan akses lokasi.</p>
                <button onClick={() => navigateTo("explore")} className="text-brand-600 font-black uppercase tracking-widest flex items-center gap-2">Cek Lokasi Event <span className="material-icons-round">arrow_right_alt</span></button>
             </div>
             {/* ... Bento lainnya ... */}
             <div className="md:col-span-5 bg-gradient-to-br from-brand-600 to-brand-800 rounded-[2.5rem] p-10 text-white relative overflow-hidden">
                <h4 className="text-2xl font-heading font-extrabold mb-4">Terhubung dengan Ekosistem Lokal.</h4>
                <p className="text-brand-100 text-sm">Bangun relasi yang berharga untuk masa depan karirmu.</p>
             </div>
          </div>
        </div>
      </section>

      {/* --- 3. MINI KATALOG: THE HOT LIST (INTEGRASI SUPABASE) --- */}
      <section className="py-32 bg-slate-50 relative overflow-hidden">
        <div className="max-w-7xl mx-auto px-6 relative z-10">
          <div className="flex flex-col md:flex-row justify-between items-end mb-16 gap-6 border-b border-slate-200/60 pb-8">
            <div className="max-w-xl">
              <div className="inline-flex items-center gap-2 px-3 py-1.5 bg-rose-50 border border-rose-100 rounded-full mb-6">
                <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-rose-500"></span>
                <span className="text-[10px] font-black text-rose-600 uppercase tracking-[0.15em]">Trending & Segera Hadir</span>
              </div>
              <h2 className="font-heading text-4xl md:text-5xl lg:text-6xl font-extrabold text-dark leading-[1.1]">
                Amankan <span className="text-transparent bg-clip-text bg-gradient-to-r from-brand-600 to-brand-400">Slot</span> Sebelum Penuh.
              </h2>
            </div>
            <button
              onClick={() => navigateTo("explore")}
              className="group flex items-center gap-3 px-8 py-4 bg-white border border-slate-200 rounded-2xl font-bold text-dark hover:text-brand-600 transition-all duration-300"
            >
              Lihat Semua Katalog
              <span className="material-icons-round text-brand-500 group-hover:translate-x-1 transition-transform">arrow_forward</span>
            </button>
          </div>

          {/* Grid Katalog Mini */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {loading ? (
              // Skeleton Loading Simple
              [1, 2, 3].map((i) => (
                <div key={i} className="h-[400px] bg-slate-200 animate-pulse rounded-[2rem]"></div>
              ))
            ) : (
              urgentEvents.map((ev) => {
                const isFull = ev.quota === 0;
                // Pastikan kolom max_quota ada di tabel Supabase Anda
                const quotaPercentage = ((ev.max_quota - ev.quota) / ev.max_quota) * 100;

                return (
                  <div
                    key={ev.id}
                    className="group relative bg-white rounded-[2rem] p-3 shadow-sm border border-slate-100 hover:shadow-2xl hover:-translate-y-2 transition-all duration-500 cursor-pointer flex flex-col"
                    onClick={() => onOpenModal && onOpenModal(ev)}
                  >
                    {/* Image Container */}
                    <div className="relative h-60 rounded-[1.5rem] overflow-hidden mb-4">
                      <img
                        src={ev.image_url || "https://images.unsplash.com/photo-1587620962725-abab7fe55159?q=80&w=600"}
                        alt={ev.title}
                        className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-dark/80 via-dark/10 to-transparent opacity-70"></div>
                      <div className="absolute top-4 left-4 right-4 flex justify-between items-start z-10">
                        <div className="bg-white/90 backdrop-blur-md px-3 py-1 rounded-lg text-[10px] font-bold text-brand-700 uppercase">{ev.category}</div>
                        <div className={`px-3 py-1 rounded-lg text-[10px] font-black uppercase tracking-wider text-white ${isFull ? "bg-rose-500" : "bg-brand-500"}`}>
                          {isFull ? "Penuh" : `${ev.quota} Slot Tersisa`}
                        </div>
                      </div>
                      <div className="absolute bottom-4 left-4 right-4 flex items-center gap-2 z-10">
                        <span className="text-white font-bold text-sm truncate drop-shadow-md">{ev.eo_name || "Organizer"}</span>
                      </div>
                    </div>

                    {/* Content Section */}
                    <div className="px-2 pb-2 flex-grow flex flex-col">
                      <h3 className="text-xl font-heading font-extrabold text-dark leading-tight mb-4 group-hover:text-brand-600 transition-colors line-clamp-2">
                        {ev.title}
                      </h3>
                      <div className="grid grid-cols-2 gap-3 mb-5">
                        <div className="bg-slate-50 rounded-xl p-2.5 border border-slate-100 flex items-center gap-2">
                          <span className="material-icons-round text-brand-500 text-base">calendar_month</span>
                          <span className="text-xs font-bold text-dark truncate">{new Date(ev.date).toLocaleDateString("id-ID")}</span>
                        </div>
                        <div className="bg-slate-50 rounded-xl p-2.5 border border-slate-100 flex items-center gap-2">
                          <span className="material-icons-round text-emerald-500 text-base">location_on</span>
                          <span className="text-xs font-bold text-dark truncate">{ev.location}</span>
                        </div>
                      </div>

                      {/* Quota Progress Bar */}
                      <div className="mt-auto pt-4 border-t border-slate-100">
                        <div className="w-full h-1.5 bg-slate-100 rounded-full overflow-hidden">
                          <div
                            className={`h-full rounded-full transition-all duration-1000 ${isFull ? "bg-rose-500" : "bg-brand-500"}`}
                            style={{ width: `${quotaPercentage}%` }}
                          ></div>
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </div>
      </section>
    </div>
  );
}