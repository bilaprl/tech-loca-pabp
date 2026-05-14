"use client";
import { useState } from "react";

const faqData = [
  {
    id: 1,
    q: "Bagaimana cara mencetak atau mengunduh E-Ticket?",
    a: "E-Ticket dapat diunduh di menu 'Tiket Saya' setelah kamu menyelesaikan proses registrasi. Tiket akan berbentuk file PDF yang berisi QR Code eksklusif milikmu.",
  },
  {
    id: 2,
    q: "Apakah saya bisa membatalkan tiket yang sudah diamankan?",
    a: "Pembatalan hanya dapat dilakukan jika status tiket masih 'Menunggu Pembayaran'. Jika tiket sudah terkonfirmasi (Confirmed), tiket tidak dapat dibatalkan sesuai kebijakan sistem kami.",
  },
  {
    id: 3,
    q: "Bagaimana sistem absensi / check-in di lokasi acara?",
    a: "Sangat mudah! Cukup tunjukkan QR Code E-Ticket kamu melalui layar HP. Tim TechLoca di lokasi akan men-scan kode tersebut untuk memverifikasi kehadiranmu dengan cepat.",
  },
  {
    id: 4,
    q: "Kapan sertifikat digital akan saya dapatkan?",
    a: "Sertifikat akan otomatis diterbitkan ke halaman 'Kumpulan Sertifikat' dalam waktu maksimal 2x24 jam setelah acara selesai, dengan syarat kamu telah di-scan hadir oleh panitia di lokasi.",
  },
  {
    id: 5,
    q: "Apakah institusi/komunitas saya bisa berkolaborasi mengadakan event?",
    a: "Tentu saja! TechLoca dikelola secara eksklusif oleh tim internal kami, namun kami sangat terbuka untuk partnership. Jika kamu punya event IT dan ingin bekerjasama agar tayang di platform kami, silakan hubungi tim kami via WhatsApp.",
  },
];

export default function FAQ() {
  const [openId, setOpenId] = useState(1); // Set item pertama terbuka secara default

  const toggleFAQ = (id) => {
    setOpenId(openId === id ? null : id);
  };

  const handlePartnership = () => {
    const adminWA = "6281234567890"; // Ganti dengan nomor WA TechLoca
    const text = encodeURIComponent(
      "Halo Tim TechLoca, saya ingin berdiskusi mengenai peluang kolaborasi/partnership untuk event IT komunitas kami.",
    );
    window.open(`https://wa.me/${adminWA}?text=${text}`, "_blank");
  };

  return (
    <div className="pt-32 pb-24 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 min-h-screen">
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-16 items-start">
        {/* --- KOLOM KIRI: Judul & CTA Box (Sticky) --- */}
        <div className="lg:col-span-5 lg:sticky lg:top-32 space-y-8">
          <div>
            <div className="inline-flex items-center gap-2 px-3 py-1 bg-brand-50 border border-brand-100 rounded-lg mb-6 shadow-sm">
              <span className="material-icons-round text-brand-500 text-sm">
                support_agent
              </span>
              <span className="text-[10px] font-black text-brand-600 uppercase tracking-widest">
                Support & Info
              </span>
            </div>
            <h1 className="font-heading text-4xl lg:text-5xl font-extrabold text-dark leading-[1.1] tracking-tight mb-4">
              Pusat <br className="hidden lg:block" />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-brand-600 to-brand-400">
                Bantuan
              </span>
            </h1>
            <p className="text-slate-500 font-medium text-lg leading-relaxed max-w-md">
              Temukan jawaban cepat untuk pertanyaan seputar penggunaan
              platform, tiket, hingga peluang kolaborasi.
            </p>
          </div>

          {/* Kolaborasi / Partnership Bento Box */}
          <div className="bg-gradient-to-br from-slate-900 to-slate-950 rounded-[2rem] p-8 text-white relative overflow-hidden group shadow-2xl">
            {/* Dekorasi Glow */}
            <div className="absolute top-0 right-0 w-64 h-64 bg-brand-500/20 rounded-full blur-[80px] group-hover:bg-brand-500/30 transition-colors duration-700 pointer-events-none"></div>

            <div className="relative z-10">
              <div className="w-12 h-12 bg-white/10 backdrop-blur-md rounded-xl flex items-center justify-center border border-white/10 mb-6 group-hover:scale-110 transition-transform duration-500">
                <span className="material-icons-round text-2xl text-brand-300">
                  handshake
                </span>
              </div>
              <h3 className="font-heading text-2xl font-bold mb-2">
                Ingin Berkolaborasi?
              </h3>
              <p className="text-slate-400 text-sm font-medium leading-relaxed mb-8">
                Punya event IT yang ingin diselenggarakan bersama TechLoca?
                Hubungi kami untuk membahas sistem partnership.
              </p>

              <button
                onClick={handlePartnership}
                className="w-full px-6 py-4 bg-white text-dark font-bold rounded-xl hover:bg-brand-600 hover:text-white transition-all duration-300 flex items-center justify-center gap-2 group/btn"
              >
                Chat via WhatsApp
                <span className="material-icons-round text-sm group-hover/btn:translate-x-1 transition-transform">
                  arrow_forward
                </span>
              </button>
            </div>
          </div>
        </div>

        {/* --- KOLOM KANAN: Daftar FAQ Accordion --- */}
        <div className="lg:col-span-7 flex flex-col gap-4">
          {faqData.map((item) => {
            const isOpen = openId === item.id;
            return (
              <div
                key={item.id}
                className={`bg-white rounded-[1.5rem] border transition-all duration-500 overflow-hidden cursor-pointer
                  ${
                    isOpen
                      ? "border-brand-300 shadow-[0_10px_40px_-10px_rgba(99,102,241,0.15)] ring-4 ring-brand-50"
                      : "border-slate-200 hover:border-slate-300 hover:shadow-md"
                  }`}
                onClick={() => toggleFAQ(item.id)}
              >
                {/* Header Pertanyaan */}
                <div className="p-6 md:p-8 flex items-center justify-between gap-6 select-none">
                  <h3
                    className={`font-bold text-[1.1rem] md:text-lg leading-snug transition-colors duration-300 ${isOpen ? "text-brand-600" : "text-dark"}`}
                  >
                    {item.q}
                  </h3>
                  <div
                    className={`w-10 h-10 rounded-full flex items-center justify-center shrink-0 transition-all duration-500 
                    ${isOpen ? "bg-brand-600 text-white rotate-180 shadow-md" : "bg-slate-50 text-slate-400"}`}
                  >
                    <span className="material-icons-round">
                      keyboard_arrow_down
                    </span>
                  </div>
                </div>

                {/* Isi Jawaban (Accordion effect dengan Grid Template) */}
                <div
                  className={`grid transition-all duration-500 ease-in-out ${isOpen ? "grid-rows-[1fr] opacity-100" : "grid-rows-[0fr] opacity-0"}`}
                >
                  <div className="overflow-hidden">
                    <p className="px-6 md:px-8 pb-8 text-slate-500 font-medium leading-relaxed">
                      {item.a}
                    </p>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
