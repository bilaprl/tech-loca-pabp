"use client";
import { useState, useEffect } from "react";
import { supabase } from "@/lib/supabaseClient";

export default function Explore({ onOpenModal, navigateTo }) {
  const [events, setEvents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [activeLocation, setActiveLocation] = useState("Semua Lokasi");
  const [wishlist, setWishlist] = useState([]);
  const [user, setUser] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);

      const {
        data: { user: currentUser },
      } = await supabase.auth.getUser();
      setUser(currentUser);

      const { data: eventsData, error: eventsError } = await supabase
        .from("events")
        .select("*")
        .order("date", { ascending: true });

      if (!eventsError && eventsData) {
        setEvents(eventsData);
      }

      if (currentUser) {
        const { data: wishlistData } = await supabase
          .from("wishlist")
          .select("event_id")
          .eq("user_id", currentUser.id);

        if (wishlistData) {
          setWishlist(wishlistData.map((item) => item.event_id));
        }
      }

      setLoading(false);
    };

    fetchData();
  }, []);

  const locations = [
    "Semua Lokasi",
    ...new Set(events.map((ev) => ev.location || "Online")),
  ];

  const filteredEvents = events.filter((ev) => {
    const evLoc = ev.location || "Online";
    const matchLocation =
      activeLocation === "Semua Lokasi" || evLoc === activeLocation;
    const matchSearch = ev.title
      .toLowerCase()
      .includes(searchQuery.toLowerCase());
    return matchLocation && matchSearch;
  });

  const toggleWishlist = async (e, eventId) => {
    e.stopPropagation();

    if (!user) {
      alert("Silakan login terlebih dahulu!");
      return;
    }

    const isAlreadyWishlisted = wishlist.includes(eventId);

    if (isAlreadyWishlisted) {
      const { error } = await supabase
        .from("wishlist")
        .delete()
        .eq("user_id", user.id)
        .eq("event_id", eventId);

      if (!error) {
        setWishlist((prev) => prev.filter((id) => id !== eventId));
      }
    } else {
      const { error } = await supabase
        .from("wishlist")
        .insert([{ user_id: user.id, event_id: eventId }]);

      if (!error) {
        setWishlist((prev) => [...prev, eventId]);
      }
    }
  };

  if (loading) {
    return (
      <div className="pt-32 pb-20 flex justify-center items-center min-h-screen bg-[#FBFBFE]">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-brand-600"></div>
      </div>
    );
  }

  return (
    <div className="pt-32 pb-20 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 min-h-screen bg-[#FBFBFE]">
      <div className="mb-12 text-center md:text-left">
        <h1 className="font-heading text-4xl lg:text-5xl font-extrabold text-dark mb-4 tracking-tight">
          Eksplorasi{" "}
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-brand-600 to-brand-400">
            Workshop IT
          </span>
        </h1>
        <p className="text-slate-500 text-lg mb-8 max-w-2xl font-medium">
          Temukan acara teknologi terbaik untuk karir profesionalmu.
        </p>

        <div className="flex flex-col gap-4 bg-white p-4 rounded-[2.5rem] border border-slate-100 shadow-sm">
          <div className="flex flex-col md:flex-row gap-4">
            <div className="relative flex-grow group">
              <span className="material-icons-round absolute left-5 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-brand-500">
                search
              </span>
              <input
                type="text"
                placeholder="Cari acara..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full bg-slate-50 border border-transparent text-dark text-sm rounded-full pl-14 pr-6 py-4 focus:bg-white focus:outline-none focus:ring-4 focus:ring-brand-500/5 focus:border-brand-500 transition-all font-medium"
              />
            </div>

            <div className="relative min-w-[220px]">
              <select
                value={activeLocation}
                onChange={(e) => setActiveLocation(e.target.value)}
                className="w-full appearance-none bg-slate-50 border border-transparent text-dark text-sm rounded-full px-8 py-4 focus:bg-white focus:outline-none focus:ring-4 focus:ring-brand-500/5 font-black cursor-pointer"
              >
                {locations.map((loc) => (
                  <option key={loc} value={loc}>
                    {loc}
                  </option>
                ))}
              </select>
              <span className="material-icons-round absolute right-6 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none">
                expand_more
              </span>
            </div>
          </div>
        </div>
      </div>

      {filteredEvents.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {filteredEvents.map((ev) => {
            const isFull = ev.quota <= 0;
            const isExpired = new Date(ev.date) < new Date();
            const isWishlisted = wishlist.includes(ev.id);

            return (
              <div
                key={ev.id}
                onClick={() => onOpenModal(ev)}
                className={`bg-white rounded-[2.5rem] p-3 shadow-sm border border-slate-50 hover:shadow-2xl hover:shadow-brand-500/10 hover:-translate-y-2 transition-all duration-500 group cursor-pointer flex flex-col ${isExpired ? "opacity-75 grayscale-[0.5]" : ""}`}
              >
                <div className="h-60 rounded-[2rem] overflow-hidden relative mb-5">
                  <img
                    src={ev.image_url || "/placeholder-event.jpg"}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-1000"
                    alt={ev.title}
                  />

                  <button
                    onClick={(e) => toggleWishlist(e, ev.id)}
                    className="absolute top-5 right-5 w-11 h-11 rounded-2xl bg-white/40 backdrop-blur-md border border-white/40 flex items-center justify-center hover:bg-white hover:scale-110 transition-all z-10 shadow-lg"
                  >
                    <span
                      className={`material-icons-round text-2xl ${isWishlisted ? "text-rose-500" : "text-white group-hover:text-slate-300"}`}
                    >
                      {isWishlisted ? "favorite" : "favorite_border"}
                    </span>
                  </button>

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
                          {new Date(ev.date).toLocaleDateString("id-ID", {
                            day: "numeric",
                            month: "short",
                          })}
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
                          ? "Sudah Terlewat"
                          : isFull
                            ? "Full Booked"
                            : `${ev.quota} Slot Tersisa`}
                      </span>
                    </div>
                    <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
                      <div
                        className={`h-full rounded-full transition-all duration-1000 ${isExpired ? "bg-slate-300" : isFull ? "bg-rose-500" : "bg-brand-500"}`}
                        style={{
                          width: `${isExpired ? 100 : isFull ? 100 : Math.min(100, (ev.quota / 50) * 100)}%`,
                        }}
                      ></div>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      ) : (
        <div className="w-full py-24 flex flex-col items-center justify-center text-center bg-white rounded-[3.5rem] border-2 border-dashed border-slate-100">
          <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mb-6">
            <span className="material-icons-round text-4xl text-slate-200">
              search_off
            </span>
          </div>
          <h3 className="text-2xl font-black text-dark mb-2">
            Hasil Tidak Ditemukan
          </h3>
          <p className="text-slate-400 text-sm mb-8 font-medium">
            Coba gunakan kata kunci lain.
          </p>
          <button
            onClick={() => {
              setSearchQuery("");
              setActiveLocation("Semua Lokasi");
            }}
            className="px-10 py-4 bg-dark text-white font-black text-[10px] uppercase tracking-widest rounded-2xl hover:bg-brand-600 transition-all shadow-xl shadow-dark/10"
          >
            Reset Filter
          </button>
        </div>
      )}
    </div>
  );
}
