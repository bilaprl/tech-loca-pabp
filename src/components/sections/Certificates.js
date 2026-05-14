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

    // ambil user login
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) return;

    // ambil data sertifikat + relasi event
    const { data, error } = await supabase
      .from("certificates")
      .select(`
        id,
        file_url,
        credential_id,
        tickets (
          id,
          status,
          events (
            id,
            title,
            date,
            eo,
            img
          )
        )
      `)
      .eq("tickets.user_id", user.id)
      .eq("tickets.status", "attended");

    if (error) {
      console.error(error);
    } else {
      setCertificates(data);
    }

    setLoading(false);
  };

  // DOWNLOAD PDF
  const handleDownload = (url) => {
    window.open(url, "_blank");
  };

  // SHARE LINKEDIN
  const handleShareLinkedIn = (title) => {
    const shareUrl = encodeURIComponent(window.location.href);
    const text = encodeURIComponent(`Saya telah menyelesaikan ${title} 🎉`);

    window.open(
      `https://www.linkedin.com/sharing/share-offsite/?url=${shareUrl}&summary=${text}`,
      "_blank"
    );
  };

  return (
    <div className="pt-32 pb-24 max-w-7xl mx-auto px-4 min-h-screen">
      <div className="mb-14">
        <h1 className="text-5xl font-extrabold mb-4">
          Kumpulan{" "}
          <span className="text-amber-500">Sertifikat</span>
        </h1>
        <p className="text-slate-500">
          Sertifikat dari event yang sudah kamu selesaikan.
        </p>
      </div>

      {loading ? (
        <p>Loading...</p>
      ) : certificates.length > 0 ? (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {certificates.map((cert) => {
            const ev = cert.tickets.events;

            return (
              <div
                key={cert.id}
                className="bg-white rounded-2xl p-6 border shadow-sm flex gap-6"
              >
                {/* IMAGE */}
                <img
                  src={ev.img}
                  className="w-40 h-40 object-cover rounded-xl"
                  alt={ev.title}
                />

                {/* CONTENT */}
                <div className="flex flex-col flex-1">
                  <h3 className="text-xl font-bold mb-2">
                    {ev.title}
                  </h3>

                  <p className="text-sm text-slate-500">
                    Penyelenggara: {ev.eo}
                  </p>

                  <p className="text-sm text-slate-500 mb-2">
                    Tanggal: {ev.date}
                  </p>

                  <p className="text-xs font-mono text-slate-400 mb-4">
                    ID: {cert.credential_id}
                  </p>

                  <div className="flex gap-3 mt-auto">
                    <button
                      onClick={() => handleDownload(cert.file_url)}
                      className="flex-1 bg-black text-white py-2 rounded-lg text-sm"
                    >
                      Unduh PDF
                    </button>

                    <button
                      onClick={() => handleShareLinkedIn(ev.title)}
                      className="px-4 bg-blue-600 text-white rounded-lg text-sm"
                    >
                      Share
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      ) : (
        <div className="text-center py-20">
          <h3 className="text-xl font-bold mb-2">
            Belum Ada Sertifikat
          </h3>
          <p className="text-slate-500">
            Selesaikan event dulu ya biar dapat sertifikat.
          </p>
        </div>
      )}
    </div>
  );
}