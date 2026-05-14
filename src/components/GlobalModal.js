"use client";
import { useState, useEffect } from "react";
import { supabase } from "@/lib/supabaseClient";

export default function GlobalModal({ event, onClose, navigateTo }) {
  const [showMap, setShowMap] = useState(false);
  const [isBooking, setIsBooking] = useState(false);
  const [bookingSuccess, setBookingSuccess] = useState(false);
  const [isWishlisted, setIsWishlisted] = useState(false);
  const [user, setUser] = useState(null);

  useEffect(() => {
    const checkWishlistStatus = async () => {
      const {
        data: { user: currentUser },
      } = await supabase.auth.getUser();
      setUser(currentUser);

      if (currentUser && event) {
        const { data } = await supabase
          .from("wishlist")
          .select("id")
          .eq("user_id", currentUser.id)
          .eq("event_id", event.id)
          .single();

        if (data) setIsWishlisted(true);
      }
    };
    checkWishlistStatus();
  }, [event]);

  const toggleWishlist = async () => {
    if (!user) {
      alert("Silakan login terlebih dahulu untuk menyimpan wishlist.");
      return;
    }

    if (isWishlisted) {
      const { error } = await supabase
        .from("wishlist")
        .delete()
        .eq("user_id", user.id)
        .eq("event_id", event.id);

      if (!error) setIsWishlisted(false);
    } else {
      const { error } = await supabase
        .from("wishlist")
        .insert([{ user_id: user.id, event_id: event.id }]);

      if (!error) setIsWishlisted(true);
    }
  };

  const handleBooking = async () => {
    if (bookingSuccess) {
      onClose();
      return;
    }

    setIsBooking(true);

    try {
      const {
        data: { user },
        error: authError,
      } = await supabase.auth.getUser();

      if (authError || !user) {
        alert("Silakan Login terlebih dahulu untuk mendaftar acara.");
        setIsBooking(false);
        return;
      }

      const { error: insertError } = await supabase
        .from("transactions")
        .insert([
          {
            event_id: event.id,
            user_id: user.id,
            status: "pending",
          },
        ]);

      if (insertError) {
        console.error("Booking Error:", insertError);
        alert("Gagal melakukan pemesanan. Mungkin Anda sudah terdaftar.");
      } else {
        setBookingSuccess(true);
        if (
          typeof window !== "undefined" &&
          Notification.permission === "granted"
        ) {
          new Notification("Booking Berhasil!", {
            body: `Tiket untuk ${event.title} berstatus Pending.`,
            icon: "/logo.png",
          });
        }
      }
    } catch (err) {
      console.error(err);
      alert("Terjadi kesalahan jaringan.");
    }

    setIsBooking(false);
  };

  if (!event) return null;

  const isFull = event.quota === 0;

  const eventDateObj = new Date(event.date);
  const formattedDate = eventDateObj.toLocaleDateString("id-ID", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });
  const formattedTime =
    eventDateObj.toLocaleTimeString("id-ID", {
      hour: "2-digit",
      minute: "2-digit",
    }) + " WIB";

  const querySearch = encodeURIComponent(
    `${event.venue || ""} ${event.location || event.title}`,
  );
  const mapEmbedUrl = `https://maps.google.com/maps?q=${querySearch}&t=&z=15&ie=UTF8&iwloc=&output=embed`;

  return (
    <div className="fixed inset-0 z-[200] bg-dark/80 backdrop-blur-md flex items-center justify-center p-4 sm:p-6 animate-in fade-in duration-300">
      <div className="absolute inset-0" onClick={onClose}></div>

      <div className="bg-white w-full max-w-5xl max-h-[95vh] rounded-[2.5rem] shadow-2xl overflow-hidden flex flex-col md:flex-row relative z-10 animate-in zoom-in-95 duration-300">
        <button
          onClick={onClose}
          className="absolute top-4 right-4 z-20 w-10 h-10 bg-slate-100 hover:bg-slate-200 text-slate-500 hover:text-dark rounded-full transition-colors flex items-center justify-center"
        >
          <span className="material-icons-round">close</span>
        </button>

        <div className="md:w-[45%] h-64 md:h-auto bg-slate-200 relative overflow-hidden group">
          {!showMap ? (
            <>
              <img
                src={event.image_url || "/placeholder-event.jpg"}
                className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105"
                alt="Poster"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-dark/80 via-dark/20 to-transparent"></div>
            </>
          ) : (
            <div className="w-full h-full bg-slate-100 flex flex-col items-center justify-center relative">
              <iframe
                src={mapEmbedUrl}
                width="100%"
                height="100%"
                style={{ border: 0 }}
                allowFullScreen=""
                loading="lazy"
              ></iframe>
            </div>
          )}

          <div className="absolute top-6 left-6 bg-white/90 backdrop-blur-sm px-3 py-1.5 rounded-xl text-xs font-bold text-brand-600 shadow-sm uppercase tracking-wider">
            {event.eo || "TechLoca Event"}
          </div>

          <button
            onClick={() => setShowMap(!showMap)}
            className="absolute bottom-6 left-6 px-4 py-2.5 bg-white/20 hover:bg-white/30 border border-white/30 backdrop-blur-md text-white rounded-xl text-sm font-bold flex items-center gap-2 transition-all shadow-lg"
          >
            <span className="material-icons-round text-base">
              {showMap ? "image" : "map"}
            </span>
            {showMap ? "Lihat Poster" : "Lihat Lokasi Peta"}
          </button>
        </div>

        <div className="md:w-[55%] p-8 lg:p-10 flex flex-col bg-white overflow-y-auto">
          <div className="flex justify-between items-start gap-4 mb-4 mt-4 md:mt-0">
            <h2 className="font-heading text-3xl lg:text-4xl font-extrabold text-dark leading-tight">
              {event.title}
            </h2>

            <button
              onClick={toggleWishlist}
              className={`flex-shrink-0 w-12 h-12 rounded-2xl flex items-center justify-center transition-all duration-300 border 
                ${
                  isWishlisted
                    ? "bg-rose-50 border-rose-200 text-rose-500 shadow-inner"
                    : "bg-white border-slate-200 text-slate-400 hover:border-brand-500 hover:text-brand-500 hover:bg-brand-50 shadow-sm"
                }`}
            >
              <span className="material-icons-round text-2xl">
                {isWishlisted ? "favorite" : "favorite_border"}
              </span>
            </button>
          </div>

          <div className="flex items-center gap-3 mb-8 pb-6 border-b border-slate-100">
            <div className="w-12 h-12 rounded-full bg-brand-50 border border-brand-100 flex items-center justify-center text-brand-600">
              <span className="material-icons-round">verified</span>
            </div>
            <div>
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">
                Diselenggarakan Oleh
              </p>
              <p className="text-sm font-bold text-dark">
                {event.eo || "TechLoca Official Partner"}
              </p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4 mb-8">
            <div className="bg-slate-50 p-4 rounded-2xl border border-slate-100 flex gap-3 items-center">
              <span className="material-icons-round text-brand-500 bg-white p-2 rounded-xl shadow-sm">
                calendar_month
              </span>
              <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase">
                  Tanggal
                </p>
                <p className="text-sm font-bold text-dark">{formattedDate}</p>
              </div>
            </div>
            <div className="bg-slate-50 p-4 rounded-2xl border border-slate-100 flex gap-3 items-center">
              <span className="material-icons-round text-rose-500 bg-white p-2 rounded-xl shadow-sm">
                schedule
              </span>
              <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase">
                  Waktu
                </p>
                <p className="text-sm font-bold text-dark">{formattedTime}</p>
              </div>
            </div>
          </div>

          <div className="mb-10">
            <h3 className="text-sm font-bold text-dark mb-2 flex items-center gap-2">
              <span className="material-icons-round text-slate-400 text-sm">
                info
              </span>
              Tentang Acara
            </h3>
            <p className="text-slate-500 text-sm leading-relaxed">
              {event.description || "Informasi deskripsi belum tersedia."}
            </p>
          </div>

          <div className="mt-auto pt-6 border-t border-slate-100">
            <button
              disabled={isFull && !bookingSuccess}
              onClick={handleBooking}
              className={`w-full py-4 px-6 rounded-2xl font-bold transition-all duration-300 flex items-center justify-center gap-3 shadow-lg 
                ${
                  bookingSuccess
                    ? "bg-emerald-500 hover:bg-emerald-600 text-white"
                    : isFull
                      ? "bg-slate-100 text-slate-400"
                      : "bg-brand-600 hover:bg-brand-500 text-white shadow-brand-500/30"
                }`}
            >
              {isBooking
                ? "Memproses..."
                : bookingSuccess
                  ? "Lihat Status Tiket"
                  : isFull
                    ? "Kuota Penuh"
                    : "Amankan Slot Sekarang"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
