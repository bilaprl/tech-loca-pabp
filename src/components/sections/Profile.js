"use client";
import { useState, useEffect } from "react";
import { supabase } from "@/lib/supabaseClient";

export default function Profile() {
  const [loading, setLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  const [userData, setUserData] = useState({
    id: "",
    full_name: "",
    email: "",
    whatsapp: "",
    institution: "",
    location: "",
    avatar_url: "",
    role: "Member",
    created_at: "",
  });

  useEffect(() => {
    const getProfile = async () => {
      setLoading(true);
      try {
        const {
          data: { user },
          error: authError,
        } = await supabase.auth.getUser();
        if (authError || !user) return;

        let { data: profile, error: profileError } = await supabase
          .from("profiles")
          .select("*")
          .eq("id", user.id)
          .single();

        if (!profile) {
          const newProfile = {
            id: user.id,
            full_name: user.user_metadata?.full_name || "User TechLoca",
            email: user.email,
            avatar_url:
              user.user_metadata?.avatar_url ||
              `https://ui-avatars.com/api/?name=${user.email}`,
            role: "Member",
          };
          const { data: inserted } = await supabase
            .from("profiles")
            .insert(newProfile)
            .select()
            .single();
          profile = inserted;
        }

        setUserData({
          id: user.id,
          full_name: profile?.full_name || "",
          email: user.email || "",
          whatsapp: profile?.whatsapp || "",
          institution: profile?.institution || "",
          location: profile?.location || "",
          avatar_url: profile?.avatar_url || "",
          role: profile?.role || "Member",
          created_at: profile?.created_at || new Date().toISOString(),
        });
      } catch (err) {
        console.error("Load error:", err.message);
      } finally {
        setLoading(false);
      }
    };
    getProfile();
  }, []);

  const handleSave = async (e) => {
    e.preventDefault();
    setIsSaving(true);
    try {
      const { error } = await supabase.from("profiles").upsert({
        id: userData.id,
        full_name: userData.full_name,
        whatsapp: userData.whatsapp,
        institution: userData.institution,
        location: userData.location,
        avatar_url: userData.avatar_url,
        updated_at: new Date().toISOString(),
      });

      if (error) throw error;

      setIsSuccess(true);
      window.dispatchEvent(new CustomEvent("profileUpdated"));
      setTimeout(() => setIsSuccess(false), 2500);
    } catch (err) {
      alert("Gagal menyimpan: " + err.message);
    } finally {
      setIsSaving(false);
    }
  };

  if (loading)
    return (
      <div className="pt-40 flex flex-col items-center justify-center gap-4">
        <div className="w-12 h-12 border-4 border-indigo-600 border-t-transparent rounded-full animate-spin"></div>
        <p className="font-bold text-slate-500 animate-pulse">
          Menyiapkan profilmu...
        </p>
      </div>
    );

  const joinDate = new Date(userData.created_at).toLocaleDateString("id-ID", {
    month: "long",
    year: "numeric",
  });

  return (
    <div className="pt-32 pb-24 max-w-6xl mx-auto px-4 min-h-screen">
      <div className="mb-10 text-center lg:text-left">
        <h1 className="text-4xl font-extrabold text-slate-800 tracking-tight">
          Pengaturan <span className="text-indigo-600">Profil</span>
        </h1>
        <p className="text-slate-500 mt-2">
          Kelola identitas digital dan informasi instansimu.
        </p>
      </div>

      <div className="grid lg:grid-cols-12 gap-8 items-start">
        {/* PREVIEW CARD */}
        <div className="lg:col-span-4">
          <div className="bg-white rounded-[2.5rem] shadow-xl shadow-slate-200/50 overflow-hidden border border-slate-100 sticky top-32">
            <div className="h-32 bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500"></div>
            <div className="px-6 pb-8 -mt-16 text-center">
              <div className="relative inline-block group">
                <img
                  src={
                    userData.avatar_url ||
                    `https://ui-avatars.com/api/?name=${userData.full_name}`
                  }
                  className="w-32 h-32 rounded-3xl border-4 border-white object-cover shadow-2xl transition-transform group-hover:scale-105"
                  alt="Avatar"
                  onError={(e) => {
                    e.target.src = "https://ui-avatars.com/api/?name=User";
                  }}
                />
              </div>
              <h2 className="mt-4 text-2xl font-black text-slate-800 truncate px-4">
                {userData.full_name || "Nama Belum Diatur"}
              </h2>
              <div className="flex flex-wrap justify-center gap-2 mt-3">
                <span className="px-3 py-1 bg-indigo-50 text-indigo-600 text-[10px] font-black uppercase rounded-lg border border-indigo-100">
                  {userData.role}
                </span>
                <span className="px-3 py-1 bg-slate-50 text-slate-400 text-[10px] font-black uppercase rounded-lg border border-slate-100">
                  TECH ENTHUSIAST
                </span>
              </div>
              <div className="mt-8 pt-8 border-t border-slate-50 text-left space-y-4 px-2">
                <div className="flex items-center gap-3 text-slate-500 font-bold">
                  <span className="material-icons-round text-indigo-400">
                    school
                  </span>
                  <span className="text-xs truncate">
                    {userData.institution || "Belum ada institusi"}
                  </span>
                </div>
                <div className="flex items-center gap-3 text-slate-500 font-bold">
                  <span className="material-icons-round text-indigo-400">
                    location_on
                  </span>
                  <span className="text-xs truncate">
                    {userData.location || "Lokasi belum diset"}
                  </span>
                </div>
                <div className="flex items-center gap-3 text-slate-400 font-bold">
                  <span className="material-icons-round text-indigo-300">
                    calendar_today
                  </span>
                  <span className="text-xs italic">Bergabung {joinDate}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* FORM SECTION */}
        <div className="lg:col-span-8 bg-white rounded-[2.5rem] p-8 lg:p-12 shadow-xl shadow-slate-200/50 border border-slate-100">
          <form onSubmit={handleSave} className="space-y-10">
            <section>
              <div className="flex items-center gap-3 mb-8">
                <div className="w-10 h-10 bg-indigo-50 rounded-xl flex items-center justify-center">
                  <span className="material-icons-round text-indigo-600">
                    image
                  </span>
                </div>
                <h3 className="text-xl font-black text-slate-800">
                  Visual Identitas
                </h3>
              </div>
              <div className="space-y-2">
                <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 ml-1">
                  Avatar Image URL
                </label>
                <div className="relative group">
                  <span className="material-icons-round absolute left-4 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-indigo-600 transition-colors">
                    link
                  </span>
                  <input
                    type="text"
                    placeholder="https://images.unsplash.com/photo-..."
                    value={userData.avatar_url}
                    onChange={(e) =>
                      setUserData({ ...userData, avatar_url: e.target.value })
                    }
                    className="w-full pl-12 pr-5 py-4 bg-slate-50/50 border border-slate-100 rounded-2xl focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all font-bold text-slate-700 text-sm"
                  />
                </div>
                <p className="text-[10px] text-slate-400 font-medium ml-1">
                  Gunakan link gambar (Unsplash/Imgur) atau URL API Gravatar.
                </p>
              </div>
            </section>

            <section>
              <div className="flex items-center gap-3 mb-8">
                <div className="w-10 h-10 bg-indigo-50 rounded-xl flex items-center justify-center">
                  <span className="material-icons-round text-indigo-600">
                    badge
                  </span>
                </div>
                <h3 className="text-xl font-black text-slate-800">
                  Informasi Personal
                </h3>
              </div>

              <div className="grid md:grid-cols-2 gap-6">
                <div className="space-y-2 md:col-span-2">
                  <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 ml-1">
                    Nama Lengkap
                  </label>
                  <input
                    type="text"
                    required
                    value={userData.full_name}
                    onChange={(e) =>
                      setUserData({ ...userData, full_name: e.target.value })
                    }
                    className="w-full px-6 py-4 bg-slate-50/50 border border-slate-100 rounded-2xl focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all font-bold text-slate-700"
                  />
                </div>

                <div className="space-y-2 md:col-span-2 opacity-60">
                  <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 ml-1">
                    Email Terverifikasi (Terkunci)
                  </label>
                  <input
                    type="email"
                    value={userData.email}
                    disabled
                    className="w-full px-6 py-4 bg-slate-100 border border-slate-200 rounded-2xl cursor-not-allowed font-bold text-slate-500"
                  />
                </div>

                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 ml-1">
                    WhatsApp
                  </label>
                  <input
                    type="text"
                    value={userData.whatsapp}
                    onChange={(e) =>
                      setUserData({ ...userData, whatsapp: e.target.value })
                    }
                    placeholder="Contoh: 0812345..."
                    className="w-full px-6 py-4 bg-slate-50/50 border border-slate-100 rounded-2xl focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all font-bold text-slate-700"
                  />
                </div>

                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 ml-1">
                    Instansi / Kampus
                  </label>
                  <input
                    type="text"
                    value={userData.institution}
                    placeholder="Contoh: Universitas Siliwangi"
                    onChange={(e) =>
                      setUserData({ ...userData, institution: e.target.value })
                    }
                    className="w-full px-6 py-4 bg-slate-50/50 border border-slate-100 rounded-2xl focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all font-bold text-slate-700"
                  />
                </div>

                <div className="space-y-2 md:col-span-2">
                  <label className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400 ml-1">
                    Lokasi Domisili
                  </label>
                  <input
                    type="text"
                    value={userData.location}
                    placeholder="Contoh: Tasikmalaya, Jawa Barat"
                    onChange={(e) =>
                      setUserData({ ...userData, location: e.target.value })
                    }
                    className="w-full px-6 py-4 bg-slate-50/50 border border-slate-100 rounded-2xl focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all font-bold text-slate-700"
                  />
                </div>
              </div>
            </section>

            <div className="flex items-center justify-end gap-4 pt-10 border-t border-slate-50">
              <button
                type="submit"
                disabled={isSaving}
                className="group relative px-10 py-4 bg-indigo-600 text-white font-black rounded-2xl hover:bg-indigo-700 transition-all shadow-xl shadow-indigo-200 disabled:opacity-50 overflow-hidden"
              >
                <div className="flex items-center gap-2">
                  <span className="material-icons-round text-sm">
                    {isSaving ? "sync" : isSuccess ? "done_all" : "save"}
                  </span>
                  <span>
                    {isSaving
                      ? "Menyimpan..."
                      : isSuccess
                        ? "Berhasil!"
                        : "Simpan Perubahan"}
                  </span>
                </div>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
