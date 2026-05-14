"use client";
import { useState, useMemo, useEffect } from "react";
import { supabase } from "@/lib/supabaseClient";
import { QRCodeSVG } from "qrcode.react";
import { toPng } from "html-to-image";
import jsPDF from "jspdf";

export default function MyTickets({ onOpenModal }) {
  const [myTickets, setMyTickets] = useState([]);
  const [user, setUser] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  const [activeTab, setActiveTab] = useState("active");
  const [activeFilter, setActiveFilter] = useState("all"); // 'all', 'pending', 'confirmed'

  // ================= GET USER & DATA =================
  useEffect(() => {
    getUserAndTickets();
  }, []);

  const getUserAndTickets = async () => {
    setIsLoading(true);
    try {
      const {
        data: { user },
        error: authError,
      } = await supabase.auth.getUser();
      if (authError || !user) {
        setIsLoading(false);
        return;
      }
      setUser(user);
      await fetchTickets(user.id);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  // ================= FETCH TICKETS DARI SUPABASE =================
  const fetchTickets = async (userId) => {
    // FIX: Menggunakan constraint name spesifik karena ada redundansi FK di DB
    const { data, error } = await supabase
      .from("transactions")
      .select(
        `
        *,
        events!transactions_event_id_fkey (
          id,
          title,
          date,
          location,
          venue,
          image_url,
          eo,
          category
        )
      `,
      )
      .eq("user_id", userId)
      .order("created_at", { ascending: false });

    if (error) {
      console.error(
        "Gagal mengambil tiket. Pesan error:",
        error.message || error,
      );
      return;
    }

    // Mapping Data Supabase ke Format UI
    const mapped = data.map((t) => {
      const ev = t.events || {};

      // Tentukan status UI
      let uiStatus = "pending";
      if (t.is_checked_in) {
        uiStatus = "attended";
      } else if (t.status === "confirmed" || t.status === "success") {
        uiStatus = "confirmed";
      }

      // Cek apakah event sudah lewat hari ini
      const eventDateObj = new Date(ev.date);
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const isPast = eventDateObj < today;

      return {
        id: t.id,
        eventId: ev.id,
        status: uiStatus, // 'pending', 'confirmed', 'attended'
        bookingDate: new Date(t.created_at).toLocaleDateString("id-ID", {
          day: "numeric",
          month: "long",
          year: "numeric",
        }),
        isPast: isPast,
        qrData: `TL-TICKET-${t.id}-${userId.substring(0, 5)}`,
        event: {
          title: ev.title || "Unknown Event",
          date: new Date(ev.date).toLocaleDateString("id-ID", {
            day: "numeric",
            month: "long",
            year: "numeric",
          }),
          time:
            new Date(ev.date).toLocaleTimeString("id-ID", {
              hour: "2-digit",
              minute: "2-digit",
            }) + " WIB",
          location: ev.location || "Tasikmalaya",
          venue: ev.venue || "-",
          category: ev.category || "Workshop IT",
          img: ev.image_url || "/placeholder-event.jpg",
          eo: ev.eo || "TechLoca",
        },
      };
    });

    setMyTickets(mapped);
  };

  // ================= ACTION CRUD =================

  // 1. DELETE: Batalkan pesanan
  const handleCancelTicket = async (e, ticketId) => {
    e.stopPropagation();
    if (!confirm("Yakin ingin membatalkan pesanan tiket ini?")) return;

    const { error } = await supabase
      .from("transactions")
      .delete()
      .eq("id", ticketId);
    if (error) {
      alert("Gagal membatalkan tiket.");
    } else {
      setMyTickets((prev) => prev.filter((t) => t.id !== ticketId));
    }
  };

  // 2. LANJUT KE WA (KIRIM BUKTI)
  const handleContinuePayment = async (e, eventTitle, ticketId) => {
    e.stopPropagation();

    try {
      const adminWA = "6281234567890";
      const text = encodeURIComponent(
        `Halo Admin TechLoca, saya ingin mengkonfirmasi pembayaran tiket untuk acara: *${eventTitle}* dengan Order ID: #${ticketId}. Berikut bukti pembayarannya:`,
      );
      window.open(`https://wa.me/${adminWA}?text=${text}`, "_blank");
    } catch (err) {
      console.error("Gagal membuka WA:", err);
      alert("Terjadi kesalahan saat mencoba membuka WhatsApp.");
    }
  };

  // 3. UPDATE: Simulasi Check-in oleh EO
  const handleSimulateEOScan = async (e, ticketId) => {
    e.stopPropagation();

    const { error } = await supabase
      .from("transactions")
      .update({ is_checked_in: true })
      .eq("id", ticketId);

    if (error) {
      alert("Gagal melakukan scan tiket.");
      return;
    }

    alert("BIP! Tiket berhasil di-scan oleh EO. Selamat mengikuti acara!");
    setMyTickets((prev) =>
      prev.map((t) => (t.id === ticketId ? { ...t, status: "attended" } : t)),
    );
  };

  // 4. Unduh PDF
  const handleDownloadPDF = async (e, eventTitle, ticketId) => {
    e.stopPropagation();
    const ticketElement = document.getElementById(`ticket-card-${ticketId}`);
    if (!ticketElement) return;

    try {
      const btn = e.currentTarget;
      const originalText = btn.innerHTML;
      btn.innerHTML = `<span class="material-icons-round text-sm animate-spin">sync</span> Memproses...`;

      const width = ticketElement.offsetWidth;
      const height = ticketElement.offsetHeight;

      const dataUrl = await toPng(ticketElement, {
        cacheBust: true,
        useCORS: true,
        backgroundColor: "#ffffff",
        pixelRatio: 2,
        fontEmbedCSS: "",
      });

      const pdf = new jsPDF({
        orientation: "landscape",
        unit: "px",
        format: [width, height],
      });

      pdf.addImage(dataUrl, "PNG", 0, 0, width, height);
      pdf.save(`E-Ticket_TechLoca_${eventTitle.replace(/\s+/g, "_")}.pdf`);

      btn.innerHTML = originalText;
    } catch (error) {
      console.error("Gagal membuat PDF:", error);
      alert(
        "Maaf, terjadi kendala teknis saat merender PDF. Pastikan koneksi stabil.",
      );
    }
  };

  // ================= LOGIKA FILTER =================
  const { activeTickets, historyTickets } = useMemo(() => {
    const active = [];
    const history = [];

    myTickets.forEach((ticket) => {
      if (ticket.isPast || ticket.status === "attended") {
        history.push(ticket);
      } else {
        active.push(ticket);
      }
    });

    return { activeTickets: active, historyTickets: history };
  }, [myTickets]);

  let displayedTickets =
    activeTab === "active" ? activeTickets : historyTickets;

  if (activeTab === "active" && activeFilter !== "all") {
    displayedTickets = displayedTickets.filter(
      (ticket) => ticket.status === activeFilter,
    );
  }

  // ================= UI RENDER =================
  if (isLoading) {
    return (
      <div className="pt-32 pb-20 flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-brand-600"></div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="pt-32 pb-20 max-w-7xl mx-auto px-4 text-center min-h-[70vh] flex flex-col items-center justify-center">
        <span className="material-icons-round text-6xl text-slate-300 mb-4">
          lock
        </span>
        <h2 className="text-2xl font-bold text-dark mb-2">
          Silakan Login Terlebih Dahulu
        </h2>
        <p className="text-slate-500 mb-6">
          Kamu perlu masuk ke akunmu untuk melihat dan mengelola tiket.
        </p>
      </div>
    );
  }

  return (
    <div className="pt-32 pb-20 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 min-h-screen">
      <div className="mb-10">
        <h1 className="font-heading text-4xl md:text-5xl font-extrabold text-dark mb-4 tracking-tight">
          E-Ticket{" "}
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-brand-600 to-brand-400">
            Saya
          </span>
        </h1>
        <p className="text-slate-500 font-medium">
          Kelola tiket acaramu, tunggu verifikasi, dan tunjukkan QR Code saat di
          lokasi.
        </p>
      </div>

      <div className="flex items-center gap-2 mb-6 border-b border-slate-200 pb-px overflow-x-auto no-scrollbar">
        <button
          onClick={() => {
            setActiveTab("active");
            setActiveFilter("all");
          }}
          className={`relative px-6 py-3 text-sm font-bold transition-colors whitespace-nowrap ${
            activeTab === "active"
              ? "text-brand-600"
              : "text-slate-400 hover:text-slate-600"
          }`}
        >
          Tiket Aktif ({activeTickets.length})
          {activeTab === "active" && (
            <span className="absolute bottom-0 left-0 w-full h-0.5 bg-[#4F46E5] rounded-t-full"></span>
          )}
        </button>
        <button
          onClick={() => setActiveTab("history")}
          className={`relative px-6 py-3 text-sm font-bold transition-colors whitespace-nowrap ${
            activeTab === "history"
              ? "text-slate-800"
              : "text-slate-400 hover:text-slate-600"
          }`}
        >
          Riwayat ({historyTickets.length})
          {activeTab === "history" && (
            <span className="absolute bottom-0 left-0 w-full h-0.5 bg-slate-800 rounded-t-full"></span>
          )}
        </button>
      </div>

      {activeTab === "active" && activeTickets.length > 0 && (
        <div className="flex flex-wrap gap-3 mb-8 animate-in fade-in slide-in-from-top-2 duration-300">
          <button
            onClick={() => setActiveFilter("all")}
            className={`px-4 py-2 rounded-xl text-[11px] font-black tracking-widest uppercase transition-all ${
              activeFilter === "all"
                ? "bg-[#4F46E5] text-white shadow-md shadow-brand-600/20"
                : "bg-slate-100 text-slate-500 hover:bg-slate-200"
            }`}
          >
            Semua
          </button>
          <button
            onClick={() => setActiveFilter("pending")}
            className={`px-4 py-2 rounded-xl text-[11px] font-black tracking-widest uppercase transition-all flex items-center gap-1.5 ${
              activeFilter === "pending"
                ? "bg-amber-500 text-white shadow-md shadow-amber-500/20"
                : "bg-amber-50 text-amber-600 hover:bg-amber-100"
            }`}
          >
            <span className="w-2 h-2 rounded-full bg-current opacity-70"></span>
            Menunggu Verifikasi
          </button>
          <button
            onClick={() => setActiveFilter("confirmed")}
            className={`px-4 py-2 rounded-xl text-[11px] font-black tracking-widest uppercase transition-all flex items-center gap-1.5 ${
              activeFilter === "confirmed"
                ? "bg-emerald-500 text-white shadow-md shadow-emerald-500/20"
                : "bg-emerald-50 text-emerald-600 hover:bg-emerald-100"
            }`}
          >
            <span className="w-2 h-2 rounded-full bg-current opacity-70"></span>
            Lunas
          </button>
        </div>
      )}

      {displayedTickets.length > 0 ? (
        <div className="flex flex-col gap-8">
          {displayedTickets.map((ticket) => {
            const ev = ticket.event;
            const isPending = ticket.status === "pending";
            const isAttended = ticket.status === "attended";
            const isExpired = ticket.isPast && ticket.status !== "attended";

            return (
              <div
                key={ticket.id}
                id={`ticket-card-${ticket.id}`}
                onClick={() => onOpenModal(ev)}
                className={`bg-white rounded-[2rem] border border-slate-200 flex flex-col lg:flex-row overflow-hidden transition-all duration-300 cursor-pointer relative group
                  ${activeTab === "active" ? "hover:shadow-2xl hover:-translate-y-1 hover:border-brand-200" : "opacity-80 grayscale-[20%]"}`}
              >
                <div className="lg:w-1/3 h-48 lg:h-auto relative overflow-hidden">
                  <img
                    src={ev.img}
                    alt={ev.title}
                    crossOrigin="anonymous"
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                  />
                  <div className="absolute inset-0 bg-dark/20"></div>

                  <div
                    className={`absolute top-4 left-4 text-[10px] font-black px-3 py-1.5 rounded-xl uppercase tracking-wider shadow-sm backdrop-blur-md
                    ${
                      isPending
                        ? "bg-amber-500 text-white"
                        : isAttended
                          ? "bg-slate-700 text-white"
                          : isExpired
                            ? "bg-rose-500 text-white"
                            : "bg-emerald-500 text-white"
                    }`}
                  >
                    {isPending
                      ? "MENUNGGU VERIFIKASI"
                      : isAttended
                        ? "TELAH HADIR"
                        : isExpired
                          ? "KADALUARSA"
                          : "LUNAS"}
                  </div>

                  <div className="absolute bottom-4 left-4 bg-white/90 backdrop-blur-md text-dark text-[10px] font-bold px-2.5 py-1 rounded-lg">
                    Order ID: #{ticket.id}
                  </div>
                </div>

                <div className="hidden lg:flex flex-col items-center justify-between relative bg-white w-6 shrink-0">
                  <div className="w-8 h-8 rounded-full bg-slate-50 absolute -top-4 border-b border-slate-200 shadow-inner"></div>
                  <div className="h-full border-r-2 border-dashed border-slate-200 my-6"></div>
                  <div className="w-8 h-8 rounded-full bg-slate-50 absolute -bottom-4 border-t border-slate-200 shadow-inner"></div>
                </div>

                <div className="p-6 lg:p-8 flex-grow flex flex-col justify-center">
                  <div className="flex items-center gap-2 mb-3">
                    <span className="text-[10px] font-bold text-brand-600 bg-brand-50 px-2.5 py-1 rounded-lg uppercase tracking-widest truncate max-w-[150px]">
                      {ev.category}
                    </span>
                    <span className="text-[10px] font-bold text-slate-400">
                      Dipesan pada {ticket.bookingDate}
                    </span>
                  </div>

                  <h3 className="font-heading text-2xl md:text-3xl font-extrabold text-dark mb-6 leading-tight group-hover:text-brand-600 transition-colors line-clamp-2">
                    {ev.title}
                  </h3>

                  <div className="grid grid-cols-2 gap-4 bg-slate-50 rounded-2xl p-4 border border-slate-100">
                    <div>
                      <p className="flex items-center gap-1 text-[10px] font-bold text-slate-400 uppercase mb-1">
                        <span className="material-icons-round text-sm text-brand-500">
                          schedule
                        </span>{" "}
                        Waktu
                      </p>
                      <p className="text-sm font-bold text-dark">{ev.date}</p>
                      <p className="text-xs font-semibold text-slate-500">
                        {ev.time}
                      </p>
                    </div>
                    <div>
                      <p className="flex items-center gap-1 text-[10px] font-bold text-slate-400 uppercase mb-1">
                        <span className="material-icons-round text-sm text-emerald-500">
                          location_on
                        </span>{" "}
                        Lokasi
                      </p>
                      <p className="text-sm font-bold text-dark truncate">
                        {ev.venue}
                      </p>
                      <p className="text-xs font-semibold text-slate-500 truncate">
                        {ev.location}
                      </p>
                    </div>
                  </div>
                </div>

                <div className="bg-slate-50 p-6 lg:p-8 lg:w-64 shrink-0 flex flex-col items-center justify-center border-t lg:border-t-0 lg:border-l border-slate-200 border-dashed relative z-10">
                  {isPending ? (
                    <div className="text-center w-full">
                      <div className="w-16 h-16 bg-amber-100 text-amber-500 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-inner">
                        <span className="material-icons-round text-3xl">
                          hourglass_empty
                        </span>
                      </div>
                      <p className="text-[11px] font-bold text-dark mb-4 leading-relaxed">
                        Menunggu verifikasi Admin. Hubungi kami via WA untuk
                        mempercepat.
                      </p>
                      <button
                        onClick={(e) =>
                          handleContinuePayment(e, ev.title, ticket.id)
                        }
                        className="w-full bg-[#25D366] hover:bg-[#1ebd5a] text-white text-xs font-bold py-3 rounded-xl transition-all shadow-md flex items-center justify-center gap-2 mb-3"
                      >
                        <span className="material-icons-round text-sm">
                          chat
                        </span>{" "}
                        Kirim Bukti via WA
                      </button>
                      <button
                        onClick={(e) => handleCancelTicket(e, ticket.id)}
                        className="text-[11px] font-bold text-rose-500 hover:text-rose-600 hover:underline"
                      >
                        Batalkan Pesanan
                      </button>
                    </div>
                  ) : activeTab === "history" ? (
                    <div className="text-center w-full">
                      <div className="w-20 h-20 border-4 border-slate-200 rounded-full flex items-center justify-center mx-auto mb-4 rotate-12 opacity-50">
                        <span className="font-heading font-black text-slate-300 text-xl tracking-widest uppercase">
                          {isAttended ? "USED" : "EXPIRED"}
                        </span>
                      </div>
                      <p className="text-xs font-bold text-slate-400">
                        {isAttended
                          ? "Kamu telah mengikuti acara ini."
                          : "Waktu acara telah terlewat."}
                      </p>
                    </div>
                  ) : (
                    <div className="text-center w-full">
                      <div className="bg-white p-3 rounded-2xl shadow-sm border border-slate-100 mb-3 inline-block">
                        <QRCodeSVG
                          value={ticket.qrData}
                          size={96}
                          bgColor={"#ffffff"}
                          fgColor={"#0F172A"}
                          level={"H"}
                        />
                      </div>
                      <p className="text-[10px] font-bold text-brand-600 uppercase tracking-widest text-center mb-4">
                        Scan Masuk Area
                      </p>
                      <button
                        onClick={(e) =>
                          handleDownloadPDF(e, ev.title, ticket.id)
                        }
                        className="w-full bg-dark hover:bg-slate-800 text-white text-xs font-bold py-3 rounded-xl transition-colors flex items-center justify-center gap-2 mb-2 shadow-lg"
                      >
                        <span className="material-icons-round text-sm">
                          download
                        </span>{" "}
                        Unduh PDF
                      </button>

                      <button
                        onClick={(e) => handleSimulateEOScan(e, ticket.id)}
                        className="text-[9px] font-bold text-slate-400 hover:text-brand-500 transition-colors uppercase tracking-widest"
                      >
                        [Simulasi Scan EO]
                      </button>
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      ) : (
        <div className="py-24 text-center bg-slate-50 rounded-[3rem] border border-dashed border-slate-200 flex flex-col items-center">
          <div className="w-24 h-24 bg-white rounded-full flex items-center justify-center shadow-sm mb-6 text-slate-300">
            <span className="material-icons-round text-5xl">
              {activeTab === "active" ? "local_activity" : "history"}
            </span>
          </div>
          <h3 className="font-heading text-2xl font-bold text-dark mb-2">
            {activeTab === "active"
              ? activeFilter !== "all"
                ? `Tidak ada tiket yang ${activeFilter === "pending" ? "menunggu verifikasi" : "lunas"}`
                : "Belum Ada Tiket Aktif"
              : "Riwayat Masih Kosong"}
          </h3>
          <p className="text-slate-500 text-sm max-w-sm">
            {activeTab === "active"
              ? activeFilter !== "all"
                ? "Saat ini kamu tidak memiliki tiket dengan status tersebut."
                : "Kamu belum mengamankan slot untuk acara apapun. Yuk cari event menarik sekarang!"
              : "Tiket acara yang sudah kamu ikuti atau tanggalnya terlewat akan muncul di sini."}
          </p>
        </div>
      )}
    </div>
  );
}
