"use client";
import { useEffect, useState } from "react";
import { supabase } from "@/lib/supabaseClient";

export default function Certificates() {
  const [certificates, setCertificates] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchCertificates();
  }, []);

  const fetchCertificates = async () => {
    setLoading(true);
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return;

      const { data, error } = await supabase
        .from("certificates")
        .select(
          `
          id, file_url, created_at,
          transactions!inner ( id, events ( title, date, eo, image_url ) )
        `,
        )
        .eq("transactions.user_id", user.id);

      if (error) throw error;
      setCertificates(data || []);
    } catch (err) {
      console.error(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleDownload = (url) => {
    if (!url) return alert("File sertifikat tidak tersedia.");
    window.open(url, "_blank");
  };

  const handleShareLinkedIn = () => {
    const shareUrl = encodeURIComponent(window.location.href);
    window.open(
      `https://www.linkedin.com/sharing/share-offsite/?url=${shareUrl}`,
      "_blank",
    );
  };

  return (
    <div className="pt-32 pb-24 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 min-h-screen relative">
      <div className="absolute top-40 left-0 w-96 h-96 bg-amber-500/5 rounded-full blur-[100px] pointer-events-none -z-10"></div>

      <div className="mb-14">
        <h1 className="font-heading text-4xl md:text-5xl lg:text-6xl font-extrabold text-slate-900 mb-5 tracking-tight leading-[1.1]">
          Kumpulan{" "}
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-amber-500 via-orange-400 to-amber-600">
            Sertifikat
          </span>
        </h1>
        <p className="text-slate-500 font-medium text-lg max-w-2xl leading-relaxed">
          Apresiasi atas dedikasi dan partisipasimu. Unduh sertifikat digital
          dengan Credential ID resmi dari setiap acara TechLoca yang telah kamu
          selesaikan.
        </p>
      </div>

      {loading ? (
        <div className="flex flex-col items-center py-20">
          <div className="animate-spin rounded-full h-12 w-12 border-t-4 border-amber-500 border-slate-200"></div>
        </div>
      ) : certificates.length > 0 ? (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {certificates.map((cert) => {
            const ev = cert.transactions?.events;
            const credentialId = `TL-C2026-${cert.id.split("-")[0].toUpperCase()}`;

            return (
              <div
                key={cert.id}
                className="group bg-gradient-to-br from-white to-amber-50/30 rounded-[2rem] p-5 shadow-[0_4px_20px_rgba(0,0,0,0.03)] border border-amber-100/50 hover:shadow-2xl hover:shadow-amber-500/10 hover:border-amber-300 transition-all duration-500 flex flex-col sm:flex-row gap-6 relative overflow-hidden"
              >
                <div className="absolute -right-8 -top-8 text-amber-500/5 group-hover:text-amber-500/10 group-hover:rotate-12 transition-all duration-700 pointer-events-none z-0">
                  <span className="material-icons-round text-[16rem]">
                    workspace_premium
                  </span>
                </div>

                <div className="w-full sm:w-44 h-48 sm:h-auto rounded-[1.5rem] overflow-hidden shrink-0 relative z-10 shadow-inner">
                  <img
                    src={ev?.image_url || "/placeholder-event.png"}
                    alt={ev?.title}
                    className="w-full h-full object-cover grayscale-[20%] group-hover:grayscale-0 group-hover:scale-110 transition-all duration-700"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent"></div>
                  <div className="absolute bottom-3 right-3 w-10 h-10 bg-gradient-to-br from-amber-300 to-amber-600 rounded-full flex items-center justify-center shadow-lg border-2 border-white/80">
                    <span className="material-icons-round text-white text-lg">
                      star
                    </span>
                  </div>
                </div>

                <div className="flex flex-col justify-center flex-grow z-10 py-2">
                  <div className="flex items-start justify-between gap-2 mb-3">
                    <div className="inline-flex items-center gap-1.5 px-3 py-1 bg-gradient-to-r from-amber-100 to-amber-50 text-amber-700 rounded-lg text-[10px] font-black uppercase tracking-widest border border-amber-200/60 shadow-sm">
                      <span className="material-icons-round text-[14px]">
                        verified
                      </span>
                      Verified
                    </div>
                  </div>

                  <h3 className="font-heading text-xl md:text-2xl font-extrabold text-slate-900 mb-2 leading-tight group-hover:text-amber-600 transition-colors">
                    {ev?.title}
                  </h3>

                  <div className="space-y-1 mb-6">
                    <p className="text-xs font-bold text-slate-500 flex items-center gap-1.5">
                      <span className="material-icons-round text-[14px] text-slate-400">
                        business
                      </span>
                      Penyelenggara:{" "}
                      <span className="text-slate-900">{ev?.eo}</span>
                    </p>
                    <p className="text-xs font-bold text-slate-500 flex items-center gap-1.5">
                      <span className="material-icons-round text-[14px] text-slate-400">
                        calendar_today
                      </span>
                      Diterbitkan:{" "}
                      <span className="text-slate-900">{ev?.date}</span>
                    </p>
                    <p className="text-[10px] font-mono font-bold text-slate-400 mt-2 bg-slate-50 px-2 py-1 rounded inline-block border border-slate-100">
                      ID: {credentialId}
                    </p>
                  </div>

                  <div className="mt-auto flex items-center gap-3 pt-4 border-t border-slate-100/80">
                    <button
                      onClick={() => handleDownload(cert.file_url)}
                      className="flex-1 bg-slate-900 hover:bg-black text-white text-xs font-bold py-3.5 rounded-xl transition-all shadow-lg hover:shadow-xl flex items-center justify-center gap-2 group/btn"
                    >
                      <span className="material-icons-round text-sm group-hover/btn:-translate-y-0.5 transition-transform">
                        picture_as_pdf
                      </span>
                      Unduh PDF
                    </button>
                    <button
                      onClick={handleShareLinkedIn}
                      className="w-12 h-[44px] bg-slate-50 hover:bg-[#0A66C2] text-slate-400 hover:text-white border border-slate-200 hover:border-[#0A66C2] rounded-xl flex items-center justify-center transition-all duration-300 shadow-sm"
                    >
                      <span className="material-icons-round">share</span>
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      ) : (
        <div className="py-24 text-center bg-gradient-to-b from-slate-50 to-white rounded-[3rem] border border-dashed border-slate-200 flex flex-col items-center shadow-sm">
          <div className="w-28 h-28 bg-white rounded-full flex items-center justify-center shadow-md mb-6 text-amber-200 border-4 border-amber-50">
            <span className="material-icons-round text-6xl">
              workspace_premium
            </span>
          </div>
          <h3 className="font-heading text-2xl font-bold text-slate-900 mb-3">
            Koleksi Sertifikat Kosong
          </h3>
        </div>
      )}
    </div>
  );
}
