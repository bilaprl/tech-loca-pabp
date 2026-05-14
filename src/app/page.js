"use client";
import { useState, useEffect } from "react";
import { supabase } from "@/lib/supabaseClient"; // Pastikan import ini sudah benar
import Navbar from "@/components/Navbar";
import AuthModal from "@/components/AuthModal";
import LandingPage from "@/components/sections/LandingPage";
import Explore from "@/components/sections/Explore";
import Dashboard from "@/components/sections/Dashboard";
import GlobalModal from "@/components/GlobalModal";
import Wishlist from "@/components/sections/Wishlist";
import MyTickets from "@/components/sections/MyTickets";
import Footer from "@/components/Footer";

// --- KOMPONEN BARU ---
import Certificates from "@/components/sections/Certificates";
import Profile from "@/components/sections/Profile";
import FAQ from "@/components/sections/FAQ";

export default function Page() {
  const [currentPage, setCurrentPage] = useState("home");
  const [role, setRole] = useState(null);
  const [isAuthOpen, setIsAuthOpen] = useState(false);
  const [selectedEvent, setSelectedEvent] = useState(null);

  // 1. FUNGSI SINKRONISASI ROLE
  const syncUserRole = (user) => {
    if (user) {
      const userRole = user.email === "admin@techloca.com" ? "eo" : "peserta";
      setRole(userRole);
      localStorage.setItem("tech_role", userRole);
      
      // Jika user baru login dan masih di home, arahkan ke halaman yang sesuai
      if (currentPage === "home") {
        setCurrentPage(userRole === "eo" ? "dashboard" : "explore");
      }
    } else {
      setRole(null);
      localStorage.removeItem("tech_role");
      setCurrentPage("home");
    }
  };

  useEffect(() => {
    // 2. CEK SESSION SAAT INI (Saat pertama kali load)
    const initAuth = async () => {
      const { data: { session } } = await supabase.auth.getSession();
      if (session?.user) {
        syncUserRole(session.user);
      }
    };
    initAuth();

    // 3. LISTEN PERUBAHAN AUTH SECARA REAL-TIME (PENTING UNTUK GOOGLE LOGIN)
    const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
      if (event === "SIGNED_IN" && session) {
        syncUserRole(session.user);
        setIsAuthOpen(false);
      } else if (event === "SIGNED_OUT") {
        syncUserRole(null);
      }
    });

    // Request permission notifikasi
    if (typeof window !== "undefined" && Notification.permission !== "granted") {
      Notification.requestPermission();
    }

    return () => {
      subscription.unsubscribe();
    };
  }, [currentPage]); // Re-run jika currentPage berubah untuk validasi redirect

  // Fungsi Login Manual (untuk AuthModal)
  const loginAs = (userRole) => {
    const normalizedRole = userRole.toLowerCase();
    setRole(normalizedRole);
    localStorage.setItem("tech_role", normalizedRole);
    setIsAuthOpen(false);
    setCurrentPage(normalizedRole === "eo" ? "dashboard" : "explore");
  };

  // Fungsi Logout Terintegrasi Supabase
  const logout = async () => {
    await supabase.auth.signOut();
    syncUserRole(null);
  };

  return (
    <>
      <Navbar
        role={role}
        navigateTo={setCurrentPage}
        logout={logout}
        activePage={currentPage}
        openAuth={() => setIsAuthOpen(true)}
      />

      <main className="page-fade">
        {currentPage === "home" && (
          <LandingPage
            navigateTo={setCurrentPage}
            openAuth={() => setIsAuthOpen(true)}
            onOpenModal={setSelectedEvent}
          />
        )}

        {currentPage === "explore" && (
          <Explore onOpenModal={setSelectedEvent} />
        )}

        {currentPage === "dashboard" && (
          <Dashboard navigateTo={setCurrentPage} />
        )}

        {currentPage === "wishlist" && (
          <Wishlist
            onOpenModal={setSelectedEvent}
            navigateTo={setCurrentPage}
          />
        )}

        {currentPage === "tickets" && (
          <MyTickets onOpenModal={setSelectedEvent} />
        )}

        {currentPage === "certificates" && <Certificates />}
        {currentPage === "profile" && <Profile />}
        {currentPage === "faq" && <FAQ />}
      </main>

      {/* Footer disembunyikan jika di dashboard agar lebih rapi */}
      {currentPage !== "dashboard" && <Footer navigateTo={setCurrentPage} />}

      {/* MODAL SISTEM */}
      {isAuthOpen && (
        <AuthModal loginAs={loginAs} onClose={() => setIsAuthOpen(false)} />
      )}

      {selectedEvent && (
        <GlobalModal
          event={selectedEvent}
          onClose={() => setSelectedEvent(null)}
        />
      )}
    </>
  );
}