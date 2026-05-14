"use client";
import { useState, useEffect } from "react";
import { supabase } from "@/lib/supabaseClient";
import Navbar from "@/components/Navbar";
import AuthModal from "@/components/AuthModal";
import LandingPage from "@/components/sections/LandingPage";
import Explore from "@/components/sections/Explore";
import Dashboard from "@/components/sections/Dashboard";
import GlobalModal from "@/components/GlobalModal";
import Wishlist from "@/components/sections/Wishlist";
import MyTickets from "@/components/sections/MyTickets";
import Footer from "@/components/Footer";

import Certificates from "@/components/sections/Certificates";
import Profile from "@/components/sections/Profile";
import FAQ from "@/components/sections/FAQ";

export default function Page() {
  const [currentPage, setCurrentPage] = useState("home");
  const [role, setRole] = useState(null);
  const [userData, setUserData] = useState(null);
  const [isAuthOpen, setIsAuthOpen] = useState(false);
  const [selectedEvent, setSelectedEvent] = useState(null);

  const syncUserRole = (user) => {
    if (user) {
      setUserData(user);
      const userRole = user.email === "admin@techloca.com" ? "eo" : "peserta";
      setRole(userRole);
      localStorage.setItem("tech_role", userRole);

      if (currentPage === "home") {
        setCurrentPage(userRole === "eo" ? "dashboard" : "explore");
      }
    } else {
      setUserData(null);
      setRole(null);
      localStorage.removeItem("tech_role");
      setCurrentPage("home");
    }
  };

  useEffect(() => {
    const initAuth = async () => {
      const {
        data: { session },
      } = await supabase.auth.getSession();
      if (session?.user) {
        syncUserRole(session.user);
      }
    };
    initAuth();

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((event, session) => {
      if (event === "SIGNED_IN" && session) {
        syncUserRole(session.user);
        setIsAuthOpen(false);
      } else if (event === "SIGNED_OUT") {
        syncUserRole(null);
      }
    });

    if (
      typeof window !== "undefined" &&
      Notification.permission !== "granted"
    ) {
      Notification.requestPermission();
    }

    return () => {
      subscription.unsubscribe();
    };
  }, [currentPage]);

  const loginAs = (userRole) => {
    const normalizedRole = userRole.toLowerCase();
    setRole(normalizedRole);
    localStorage.setItem("tech_role", normalizedRole);
    setIsAuthOpen(false);
    setCurrentPage(normalizedRole === "eo" ? "dashboard" : "explore");
  };

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
          <Explore onOpenModal={setSelectedEvent} navigateTo={setCurrentPage} />
        )}

        {currentPage === "dashboard" && (
          <Dashboard navigateTo={setCurrentPage} />
        )}

        {currentPage === "wishlist" && (
          <Wishlist
            onOpenModal={setSelectedEvent}
            navigateTo={setCurrentPage}
            user={userData}
          />
        )}

        {currentPage === "tickets" && (
          <MyTickets onOpenModal={setSelectedEvent} />
        )}

        {currentPage === "certificates" && <Certificates />}
        {currentPage === "profile" && <Profile />}
        {currentPage === "faq" && <FAQ />}
      </main>

      {currentPage !== "dashboard" && <Footer navigateTo={setCurrentPage} />}

      {isAuthOpen && (
        <AuthModal loginAs={loginAs} onClose={() => setIsAuthOpen(false)} />
      )}

      {selectedEvent && (
        <GlobalModal
          event={selectedEvent}
          onClose={() => setSelectedEvent(null)}
          navigateTo={setCurrentPage}
        />
      )}
    </>
  );
}
