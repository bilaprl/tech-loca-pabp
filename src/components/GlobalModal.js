"use client";
import { useState } from "react";
import { supabase } from "@/lib/supabaseClient";

export default function GlobalModal({ event, onClose }) {
  const [showMap, setShowMap] = useState(false);
  const [isBooking, setIsBooking] = useState(false);
  const [bookingSuccess, setBookingSuccess] = useState(false);
  const [isWishlisted, setIsWishlisted] = useState(false);

  const handleBooking = async () => {
    if (bookingSuccess) {
      onClose();
      return;
    }

    setIsBooking(true);

    try {
      // 1. Ambil Data User yang sedang Login
      const {
        data: { user },
        error: authError,
      } = await supabase.auth.getUser();

      if (authError || !user) {
        alert("Silakan Login terlebih dahulu untuk mendaftar acara.");
        setIsBooking(false);
        return;
      }

      // 2. Insert ke tabel transactions
      const { error: insertError } = await supabase
        .from("transactions")
        .insert([
          {
            event_id: event.id,
            user_id: user.id,
            status: "pending", // Default status
          },
        ]);

      if (insertError) {
        console.error("Booking Error:", insertError);
        alert(
          "Gagal melakukan pemesanan. Mungkin Anda sudah terdaftar atau terjadi kesalahan server.",
        );
      } else {
        setBookingSuccess(true);
        // Native Notification Logic
        if (
          typeof window !== "undefined" &&
          Notification.permission === "granted"
        ) {
          new Notification("Booking Berhasil!", {
            body: `Tiket untuk ${event.title} berstatus Pending. Silakan cek dashboard.`,
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

  const toggleWishlist = () => {
    setIsWishlisted(!isWishlisted);
  };

  if (!event) return null;

  const isFull = event.quota === 0;

  // Format Waktu & Tanggal
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

  // Embed Google Maps gratis (tanpa API key embed) berdasarkan parameter alamat teks dari kolom venue/kota
  const querySearch = encodeURIComponent(
    `${event.venue || ""} ${event.location || event.title}`,
  );
  const mapEmbedUrl = `https://maps.google.com/maps?q=${querySearch}&t=&z=15&ie=UTF8&iwloc=&output=embed`;

  return (
    <div className="fixed inset-0 z-[200] bg-dark/80 backdrop-blur-md flex items-center justify-center p-4 sm:p-6 animate-in fade-in duration-300">
      {/* Overlay klik luar untuk tutup */}
      <div className="absolute inset-0" onClick={onClose}></div>

      <div className="bg-white w-full max-w-5xl max-h-[95vh] rounded-[2.5rem] shadow-2xl overflow-hidden flex flex-col md:flex-row relative z-10 animate-in zoom-in-95 duration-300">
        {/* Tombol Close */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 z-20 w-10 h-10 bg-slate-100 hover:bg-slate-200 text-slate-500 hover:text-dark rounded-full transition-colors flex items-center justify-center"
        >
          <span className="material-icons-round">close</span>
        </button>

        {/* --- Media Side (Gambar / Peta) --- */}
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
                referrerPolicy="no-referrer-when-downgrade"
              ></iframe>
              {event.maps_url && (
                <a
                  href={event.maps_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="absolute bottom-20 px-4 py-2 bg-brand-600 text-white rounded-xl text-xs font-bold shadow-lg hover:bg-brand-700 transition-colors flex items-center gap-2"
                >
                  <span className="material-icons-round text-sm">
                    open_in_new
                  </span>{" "}
                  Buka di App Gmaps
                </a>
              )}
            </div>
          )}

          {/* Badge Kiri Atas */}
          <div className="absolute top-6 left-6 bg-white/90 backdrop-blur-sm px-3 py-1.5 rounded-xl text-xs font-bold text-brand-600 shadow-sm uppercase tracking-wider">
            {event.eo || "TechLoca Event"}
          </div>

          {/* Tombol Toggle Peta Kiri Bawah */}
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

        {/* --- Content Side --- */}
        <div className="md:w-[55%] p-8 lg:p-10 flex flex-col bg-white overflow-y-auto">
          {/* Header Info: Title & Wishlist */}
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
              title={
                isWishlisted ? "Hapus dari Wishlist" : "Simpan ke Wishlist"
              }
            >
              <span className="material-icons-round text-2xl">
                {isWishlisted ? "favorite" : "favorite_border"}
              </span>
            </button>
          </div>

          {/* Penyelenggara (EO) */}
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

          {/* Info Grid (Bento Box Style) */}
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
            <div className="col-span-2 bg-slate-50 p-4 rounded-2xl border border-slate-100 flex gap-3 items-center">
              <span className="material-icons-round text-emerald-500 bg-white p-2 rounded-xl shadow-sm">
                location_on
              </span>
              <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase">
                  Lokasi Acara
                </p>
                <p className="text-sm font-bold text-dark">
                  {event.venue
                    ? `${event.venue}, ${event.location}`
                    : event.location}
                </p>
              </div>
            </div>
          </div>

          {/* Deskripsi */}
          <div className="mb-10">
            <h3 className="text-sm font-bold text-dark mb-2 flex items-center gap-2">
              <span className="material-icons-round text-slate-400 text-sm">
                info
              </span>{" "}
              Tentang Acara
            </h3>
            <p className="text-slate-500 text-sm leading-relaxed">
              {event.description ||
                "Informasi deskripsi belum tersedia untuk acara ini."}
            </p>
          </div>

          {/* --- Action Bar (Bottom) --- */}
          <div className="mt-auto pt-6 border-t border-slate-100">
            <div className="flex justify-between items-center mb-4">
              <span className="text-xs font-bold text-slate-400 uppercase tracking-widest">
                Ketersediaan Tiket
              </span>
              <span
                className={`px-3 py-1 rounded-full text-[10px] font-extrabold uppercase tracking-wider 
                ${isFull ? "bg-rose-100 text-rose-600" : "bg-brand-100 text-brand-600"}`}
              >
                {isFull ? "Habis Terjual" : `${event.quota} Kursi Tersedia`}
              </span>
            </div>

            <button
              disabled={isFull && !bookingSuccess}
              onClick={handleBooking}
              className={`w-full py-4 px-6 rounded-2xl font-bold transition-all duration-300 flex items-center justify-center gap-3 shadow-lg 
                ${
                  bookingSuccess
                    ? "bg-emerald-500 hover:bg-emerald-600 text-white shadow-emerald-500/30"
                    : isFull
                      ? "bg-slate-100 text-slate-400 cursor-not-allowed shadow-none"
                      : "bg-brand-600 hover:bg-brand-500 text-white shadow-brand-500/30"
                }`}
            >
              {isBooking ? (
                <>
                  <span className="material-icons-round animate-spin">
                    sync
                  </span>{" "}
                  Memproses...
                </>
              ) : bookingSuccess ? (
                <>
                  <span className="material-icons-round">local_activity</span>{" "}
                  Lihat Status Tiket
                </>
              ) : isFull ? (
                <>
                  <span className="material-icons-round">block</span> Kuota
                  Penuh
                </>
              ) : (
                <>
                  <span className="material-icons-round">
                    check_circle_outline
                  </span>{" "}
                  Amankan Slot Sekarang
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
