"use client";
import { useState, useEffect, useMemo } from "react";
import { eventsData } from "@/data/events";
import { supabase } from "@/lib/supabaseClient"; // Pastikan path ini sesuai config supabase kamu

// Helper untuk mengubah string tanggal Indonesia menjadi Object Date Javascript
const parseIndonesianDate = (dateStr) => {
  const months = {
    Januari: 0, Februari: 1, Maret: 2, April: 3, Mei: 4, Juni: 5,
    Juli: 6, Agustus: 7, September: 8, Oktober: 9, November: 10, Desember: 11,
  };
  const parts = dateStr.split(" ");
  if (parts.length === 3) {
    return new Date(parts[2], months[parts[1]], parts[0]);
  }
  return new Date();
};

export default function Wishlist({ onOpenModal, navigateTo, user }) {
  const [savedItemIds, setSavedItemIds] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState("upcoming");

  // ✅ 1. AMBIL DATA DARI SUPABASE SAAT PAGE LOAD
  useEffect(() => {
    const fetchWishlist = async () => {
      if (!user) {
        setLoading(false);
        return;
      }
      
      try {
        const { data, error } = await supabase
          .from("wishlist")
          .select("event_id")
          .eq("user_id", user.id);

        if (error) throw error;
        
        // Simpan hanya array ID: [1, 4, 10]
        setSavedItemIds(data.map((item) => item.event_id));
      } catch (err) {
        console.error("Error fetching wishlist:", err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchWishlist();
  }, [user]);

  // ✅ 2. HAPUS DARI WISHLIST (DATABASE)
  const handleRemoveWishlist = async (e, id) => {
    e.stopPropagation();
    if (!user) return;

    try {
      // Hapus di database
      const { error } = await supabase
        .from("wishlist")
        .delete()
        .eq("user_id", user.id)
        .eq("event_id", id);

      if (error) throw error;
      
      // Update state lokal (UI langsung berubah)
      setSavedItemIds((prev) => prev.filter((itemId) => itemId !== id));
    } catch (err) {
      alert("Gagal menghapus: " + err.message);
    }
  };

  // ✅ 3. LOGIKA FILTER (UPCOMING VS PAST)
  const { upcomingEvents, pastEvents } = useMemo(() => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Filter data mentah berdasarkan ID yang ada di database wishlist
    const userWishlist = eventsData.filter((ev) => savedItemIds.includes(ev.id));

    const upcoming = [];
    const past = [];

    userWishlist.forEach((ev) => {
      const eventDate = parseIndonesianDate(ev.date);
      if (eventDate >= today) {
        upcoming.push(ev);
      } else {
        past.push(ev);
      }
    });

    return { upcomingEvents: upcoming, pastEvents: past };
  }, [savedItemIds]);

  const displayedEvents = activeTab === "upcoming" ? upcomingEvents : pastEvents;

  if (loading) {
    return (
      <div className="pt-40 text-center min-h-screen">
        <div className="animate-spin inline-block w-8 h-8 border-4 border-brand-500 border-t-transparent rounded-full mb-4"></div>
        <p className="text-slate-500 font-bold">Sinkronisasi Wishlist...</p>
      </div>
    );
  }

  return (
    <div className="pt-32 pb-20 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 min-h-screen">
      {/* HEADER SECTION */}
      <div className="mb-10 flex flex-col md:flex-row md:items-end justify-between gap-6">
        <div>
          <h1 className="font-heading text-4xl md:text-5xl font-extrabold text-slate-900 mb-3 tracking-tight">
            Wishlist{" "}
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-brand-500 to-indigo-600">
              Tersimpan
            </span>
          </h1>
          <p className="text-slate-500 font-medium">
            Kelola acara-acara yang telah kamu tandai untuk diikuti.
          </p>
        </div>
        <button
          onClick={() => navigateTo("explore")}
          className="group flex items-center gap-2 px-6 py-3 bg-brand-50 text-brand-600 rounded-xl font-bold hover:bg-brand-600 hover:text-white transition-all shadow-sm"
        >
          Cari Event Lain
          <span className="material-icons-round text-sm group-hover:translate-x-1 transition-transform">
            arrow_forward
          </span>
        </button>
      </div>

      {/* TAB NAVIGATION */}
      <div className="flex items-center gap-2 mb-8 border-b border-slate-200 pb-px">
        <button
          onClick={() => setActiveTab("upcoming")}
          className={`relative px-6 py-3 text-sm font-bold transition-colors ${
            activeTab === "upcoming" ? "text-brand-600" : "text-slate-400 hover:text-slate-600"
          }`}
        >
          Akan Datang ({upcomingEvents.length})
          {activeTab === "upcoming" && (
            <span className="absolute bottom-0 left-0 w-full h-0.5 bg-brand-600 rounded-t-full"></span>
          )}
        </button>
        <button
          onClick={() => setActiveTab("past")}
          className={`relative px-6 py-3 text-sm font-bold transition-colors ${
            activeTab === "past" ? "text-slate-800" : "text-slate-400 hover:text-slate-600"
          }`}
        >
          Telah Terlewat ({pastEvents.length})
          {activeTab === "past" && (
            <span className="absolute bottom-0 left-0 w-full h-0.5 bg-slate-800 rounded-t-full"></span>
          )}
        </button>
      </div>

      {/* GRID CONTENT */}
      {displayedEvents.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {displayedEvents.map((ev) => (
            <div
              key={ev.id}
              onClick={() => activeTab === "upcoming" ? onOpenModal(ev) : null}
              className={`relative bg-white rounded-[2rem] p-3 shadow-[0_4px_20px_rgba(0,0,0,0.03)] border border-slate-100 transition-all duration-300 flex flex-col group
                ${activeTab === "upcoming" ? "hover:shadow-xl hover:-translate-y-1 cursor-pointer" : "opacity-80 grayscale-[30%] cursor-default"}`}
            >
              <div className="h-52 rounded-[1.5rem] overflow-hidden relative mb-4">
                <img src={ev.img} className={`w-full h-full object-cover transition-transform duration-700 ${activeTab === "upcoming" && "group-hover:scale-110"}`} alt={ev.title} />
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-80"></div>

                {/* Tombol Hapus */}
                <button
                  onClick={(e) => handleRemoveWishlist(e, ev.id)}
                  className="absolute top-4 right-4 w-10 h-10 rounded-full bg-white/90 backdrop-blur border border-rose-100 flex items-center justify-center shadow-sm z-10 hover:bg-rose-50 hover:scale-110 transition-all group/btn"
                >
                  <span className="material-icons-round text-xl text-rose-500">heart_broken</span>
                </button>

                <div className="absolute top-4 left-4 bg-white/90 backdrop-blur px-3 py-1 rounded-lg text-[10px] font-black uppercase tracking-wider">
                  {activeTab === "upcoming" ? <span className="text-brand-600">Segera Hadir</span> : <span className="text-slate-500">Selesai</span>}
                </div>
              </div>

              <div className="px-3 pb-3 flex-grow flex flex-col">
                <h3 className={`font-heading text-xl font-extrabold text-slate-900 leading-tight mb-4 line-clamp-2 ${activeTab === "upcoming" && "group-hover:text-brand-600"}`}>
                  {ev.title}
                </h3>
                <div className="mt-auto space-y-2">
                  <div className="flex items-center gap-2 text-slate-500">
                    <span className="material-icons-round text-sm">event</span>
                    <span className="text-xs font-bold">{ev.date}</span>
                  </div>
                  <div className="flex items-center gap-2 text-slate-500">
                    <span className="material-icons-round text-sm">location_on</span>
                    <span className="text-xs font-bold truncate">{ev.venue}</span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="py-24 text-center bg-slate-50 rounded-[3rem] border border-dashed border-slate-200 flex flex-col items-center">
          <div className="w-24 h-24 bg-white rounded-full flex items-center justify-center shadow-sm mb-6 text-slate-300">
            <span className="material-icons-round text-5xl">{activeTab === "upcoming" ? "favorite_border" : "history"}</span>
          </div>
          <h3 className="font-heading text-2xl font-bold text-slate-900 mb-2">
            {activeTab === "upcoming" ? "Wishlist Masih Kosong" : "Belum Ada Acara Terlewat"}
          </h3>
          <p className="text-slate-500 text-sm max-w-sm">
            {activeTab === "upcoming" ? "Temukan workshop menarik di halaman eksplorasi." : "Acara yang sudah lewat akan otomatis masuk ke sini."}
          </p>
        </div>
      )}
    </div>
  );
}