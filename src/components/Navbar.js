"use client";
import { useState, useEffect, useCallback } from "react";
import { supabase } from "@/lib/supabaseClient";

export default function Navbar({
  role,
  navigateTo,
  logout,
  activePage,
  openAuth,
}) {
  const [isScrolled, setIsScrolled] = useState(false);
  const [profile, setProfile] = useState({
    name: "",
    avatar: "",
  });

  // Fungsi fetch dipisah agar bisa dipanggil berulang kali
  const fetchProfile = useCallback(async () => {
    const { data: { user } } = await supabase.auth.getUser();
    
    if (user) {
      const { data, error } = await supabase
        .from("profiles")
        .select("full_name, avatar_url")
        .eq("id", user.id)
        .single();

      if (data) {
        setProfile({
          name: data.full_name,
          avatar: data.avatar_url,
        });
      }
    }
  }, []);

  useEffect(() => {
    fetchProfile();

    // 1. Listen perubahan Auth
    const { data: { subscription } } = supabase.auth.onAuthStateChange(() => {
      fetchProfile();
    });

    // 2. LISTEN EVENT KHUSUS (Penting agar Navbar update saat Profil disimpan)
    window.addEventListener("profileUpdated", fetchProfile);

    return () => {
      subscription.unsubscribe();
      window.removeEventListener("profileUpdated", fetchProfile);
    };
  }, [fetchProfile]);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const currentRole = role ? String(role).toLowerCase().trim() : null;
  const isAdmin = currentRole === "eo";
  const isUser = currentRole && currentRole !== "eo";
  const isLoggedIn = Boolean(currentRole);

  const navItems = [
    ...(isAdmin ? [{ id: "dashboard", label: "Dashboard Admin", icon: "admin_panel_settings" }] : []),
    { id: "explore", label: "Eksplorasi", icon: "explore" },
    ...(isUser ? [
      { id: "wishlist", label: "Wishlist", icon: "favorite" },
      { id: "tickets", label: "Tiket Saya", icon: "local_activity" },
    ] : []),
    ...(!isAdmin ? [{ id: "faq", label: "FAQ", icon: "live_help" }] : []),
  ];

  return (
    <header className={`fixed top-0 left-0 w-full z-[100] transition-all duration-500 ${isScrolled ? "pt-4" : "pt-0"}`}>
      <nav className={`mx-auto transition-all duration-500 flex items-center ${
          isScrolled
            ? "max-w-5xl bg-white/80 backdrop-blur-xl shadow-[0_8px_32px_rgba(0,0,0,0.05)] border border-white/20 rounded-3xl h-16 px-8"
            : "max-w-full bg-white border-b border-slate-100 h-20 px-10"
        }`}>
        <div className="w-full flex justify-between items-center">
          
          {/* LOGO AREA */}
          <div className="flex items-center gap-3 cursor-pointer group" onClick={() => navigateTo(isAdmin ? "dashboard" : "home")}>
            <div className={`w-10 h-10 rounded-xl flex items-center justify-center transition-transform group-hover:rotate-12 duration-300 shadow-lg ${isAdmin ? "bg-slate-900 shadow-slate-900/30" : "bg-indigo-600 shadow-indigo-500/30"}`}>
              <img src="/logo.png" alt="Logo" className="w-10 h-10 object-contain rounded-2xl" />
            </div>
            <div className="flex flex-col text-left">
              <span className="font-bold text-xl tracking-tighter text-slate-900 uppercase leading-none">TechLoca</span>
              <span className={`text-[9px] font-black tracking-[0.2em] uppercase ${isAdmin ? "text-rose-500" : "text-indigo-500"}`}>
                {isAdmin ? "TechLoca Admin" : "Ecosystem"}
              </span>
            </div>
          </div>

          {/* NAV LINKS */}
          <div className="hidden md:flex items-center bg-slate-100/50 p-1.5 rounded-2xl gap-1">
            {navItems.map((item) => (
              <button
                key={item.id}
                onClick={() => navigateTo(item.id)}
                className={`flex items-center gap-2 px-5 py-2 rounded-xl text-xs font-extrabold transition-all duration-300 ${
                  activePage === item.id ? "bg-white text-indigo-600 shadow-sm" : "text-slate-500 hover:text-slate-900 hover:bg-white/40"
                }`}
              >
                <span className={`material-icons-round text-lg ${activePage === item.id ? "text-indigo-600" : "text-slate-400"}`}>
                  {item.icon}
                </span>
                {item.label}
              </button>
            ))}
          </div>

          {/* ACTION BUTTONS */}
          <div className="flex items-center gap-4">
            {isLoggedIn ? (
              <div className="flex items-center gap-3 pl-4 border-l border-slate-200">
                <div className="hidden lg:flex flex-col items-end mr-1 text-right">
                  <span className="text-[11px] font-black text-slate-900 leading-none">
                    {isAdmin ? "TechLoca Admin" : (profile.name || "User TechLoca")}
                  </span>
                  <span className={`text-[9px] font-bold uppercase tracking-widest mt-1 px-1.5 py-0.5 rounded ${isAdmin ? "bg-rose-100 text-rose-600" : "bg-slate-100 text-slate-400"}`}>
                    {isAdmin ? "Event Organizer" : "Member"}
                  </span>
                </div>

                <div className="relative group cursor-pointer py-2">
                  <div className={`w-10 h-10 rounded-full border-2 p-0.5 transition-transform group-hover:scale-105 ${isAdmin ? "border-slate-900" : "border-indigo-500"}`}>
                    <img
                      src={profile.avatar || `https://ui-avatars.com/api/?name=${profile.name || 'User'}`}
                      className="w-full h-full rounded-full object-cover"
                      alt="Profile"
                    />
                  </div>

                  <div className="absolute top-full right-0 mt-1 w-48 bg-white rounded-2xl shadow-xl border border-slate-100 p-2 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-300 transform origin-top-right group-hover:translate-y-0 translate-y-2 z-50">
                    {isUser && (
                      <>
                        <button onClick={() => navigateTo("profile")} className="w-full px-4 py-2.5 text-left text-slate-600 hover:bg-slate-50 hover:text-indigo-600 rounded-xl text-xs font-bold flex items-center gap-3 transition-colors">
                          <span className="material-icons-round text-lg">account_circle</span> Profil
                        </button>
                        <button onClick={() => navigateTo("certificates")} className="w-full px-4 py-2.5 text-left text-slate-600 hover:bg-slate-50 hover:text-amber-500 rounded-xl text-xs font-bold flex items-center gap-3 transition-colors">
                          <span className="material-icons-round text-lg">workspace_premium</span> Sertifikat
                        </button>
                        <div className="my-1 border-t border-slate-100"></div>
                      </>
                    )}
                    <button onClick={logout} className="w-full px-4 py-2.5 text-left text-rose-500 hover:bg-rose-50 rounded-xl text-xs font-bold flex items-center gap-3 transition-colors">
                      <span className="material-icons-round text-lg">logout</span> Keluar
                    </button>
                  </div>
                </div>
              </div>
            ) : (
              <button onClick={openAuth} className="px-7 py-2.5 rounded-xl bg-slate-900 text-white font-bold text-sm shadow-md flex items-center gap-2 hover:bg-indigo-700 transition-colors">
                Masuk <span className="material-icons-round text-sm">login</span>
              </button>
            )}
          </div>
        </div>
      </nav>
    </header>
  );
}