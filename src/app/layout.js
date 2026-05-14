"use client"; // Wajib agar useEffect dan state bisa berjalan

import "./globals.css";
import { useEffect, useState } from "react";
import { supabase } from "@/lib/supabaseClient";

// Catatan: Metadata dipindah ke file terpisah (misal layout.metadata.js) 
// atau biarkan di sini jika Next.js versi terbaru mendukung mixed mode, 
// namun amannya kita fokus pada fungsionalitas Auth.

export default function RootLayout({ children }) {
  const [user, setUser] = useState(null);
  const [role, setRole] = useState(null);

  useEffect(() => {
    // 1. Cek sesi saat halaman pertama kali dimuat (Initial Load)
    const getInitialSession = async () => {
      const { data: { session } } = await supabase.auth.getSession();
      if (session) {
        syncUserSession(session);
      }
    };

    getInitialSession();

    // 2. LISTEN Perubahan Auth (Kunci agar Login Google otomatis terdeteksi)
    const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
      console.log("Auth Event:", event); // Untuk debugging
      if (session) {
        syncUserSession(session);
      } else {
        setUser(null);
        setRole(null);
      }
    });

    return () => {
      subscription?.unsubscribe();
    };
  }, []);

  // Fungsi pembantu untuk sinkronisasi data user dan role
  const syncUserSession = (session) => {
    setUser(session.user);
    // Logika penentuan role admin vs peserta
    const userRole = session.user.email === "admin@techloca.com" ? "eo" : "peserta";
    setRole(userRole);
  };

  return (
    <html lang="id" className="scroll-smooth">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link 
          href="https://fonts.googleapis.com/css2?family=Montserrat:wght@700;800&family=Open+Sans:wght@400;600;700&display=swap" 
          rel="stylesheet" 
        />
        <link 
          href="https://fonts.googleapis.com/icon?family=Material+Icons+Round" 
          rel="stylesheet" 
        />
      </head>
      <body className="antialiased selection:bg-brand-500/30">
        <div className="min-h-screen flex flex-col">
          {/* Pastikan children menerima user/role jika diperlukan, 
              atau gunakan Context Provider jika project semakin besar */}
          {children}
        </div>
      </body>
    </html>
  );
}