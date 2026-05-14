"use client";
import { registerUser, loginUser } from "@/lib/auth";
import { useState, useEffect } from "react";
import { supabase } from "@/lib/supabaseClient";

export default function AuthPage({ loginAs, onClose }) {
  const [isLogin, setIsLogin] = useState(true);
  const [name, setName] = useState("");
  const [location, setLocation] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  // ✅ AUTO DETECT SESSION
  useEffect(() => {
    const checkUser = async () => {
      const { data: { session } } = await supabase.auth.getSession();
      if (session?.user) {
        const role = session.user.email === "admin@techloca.com" ? "eo" : "peserta";
        loginAs(role);
        onClose();
      }
    };
    checkUser();
  }, [loginAs, onClose]);

  // ✅ GOOGLE LOGIN (DIOPTIMALKAN)
  const handleGoogleLogin = async () => {
    setLoading(true);
    try {
      const { error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: window.location.origin,
          queryParams: {
            access_type: 'offline',
            prompt: 'consent',
          },
        },
      });
      if (error) throw error;
    } catch (error) {
      alert("Google Auth Error: " + error.message);
      setLoading(false);
    }
  };

  // ✅ FORM SUBMIT (LOGIN & REGISTER)
  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (isLogin) {
        // --- PROSES LOGIN ---
        const { data, error } = await loginUser(email, password);
        if (error) throw error;

        if (data?.user) {
          const role = data.user.email === "admin@techloca.com" ? "eo" : "peserta";
          loginAs(role);
          onClose();
        }
      } else {
        // --- PROSES REGISTER (DENGAN UPSERT AGAR TIDAK DUPLIKAT) ---
        const { data, error } = await registerUser(email, password);
        if (error) throw error;

        if (data?.user) {
          // Gunakan upsert alih-alih insert untuk menghindari error "User Already Exists" di tabel profil
          // Hanya masukkan kolom yang PASTI ada di database
          const { error: profileError } = await supabase
            .from("profiles")
            .upsert({
              id: data.user.id,
              full_name: name,
              location: location,
              email: email,
              role: "Member",
              updated_at: new Date().toISOString(),
            });

          if (profileError) {
            console.error("Database Sync Error:", profileError.message);
            // Tetap lanjut meskipun profil gagal, karena user auth sudah berhasil dibuat
          }
          
          alert("Registrasi Berhasil! Silakan masuk.");
          setIsLogin(true);
        }
      }
    } catch (err) {
      alert(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-[300] bg-white flex flex-col md:flex-row overflow-hidden animate-in fade-in duration-500">
      {/* SEKSI KIRI: Visual Branding */}
      <div className="hidden md:flex md:w-5/12 lg:w-1/2 bg-dark relative items-center justify-center p-12 overflow-hidden">
        <div className="absolute top-[-10%] right-[-10%] w-[500px] h-[500px] bg-brand-600/20 rounded-full blur-[120px] animate-pulse"></div>
        <div className="absolute bottom-[-10%] left-[-10%] w-[400px] h-[400px] bg-indigo-500/10 rounded-full blur-[100px] animate-pulse delay-1000"></div>

        <div
          className="absolute inset-0 opacity-15"
          style={{
            backgroundImage: `radial-gradient(#4f46e5 0.5px, transparent 0.5px)`,
            backgroundSize: "24px 24px",
          }}
        ></div>

        <div className="relative z-10 max-w-md">
          <div className="w-20 h-20 bg-brand-600 rounded-3xl flex items-center justify-center mb-8 shadow-2xl shadow-brand-500/40 -rotate-3">
            <img src="/logo.png" alt="Logo" className="w-20 h-20 object-contain rounded-2xl" />
          </div>

          <h2 className="font-heading text-5xl font-extrabold text-white mb-6 leading-[1.1]">
            Build the <span className="text-brand-500 italic">Next Generation</span> of Tech.
          </h2>
          <p className="text-slate-400 text-lg leading-relaxed mb-10">
            Platform ekosistem digital untuk menghubungkan talenta IT, mahasiswa, dan profesional.
          </p>
        </div>
      </div>

      {/* SEKSI KANAN: Form */}
      <div className="flex-1 flex flex-col h-full bg-slate-50/50 relative overflow-hidden">
        <button
          onClick={onClose}
          className="absolute top-6 right-6 z-[350] w-10 h-10 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center text-slate-400 hover:text-dark hover:rotate-90 transition-all duration-300"
        >
          <span className="material-icons-round">close</span>
        </button>

        <div className="flex-1 overflow-y-auto px-6 py-12 md:px-12 flex justify-center items-start">
          <div className="w-full max-w-[400px] my-auto">
            <div className="mb-8">
              <h3 className="font-heading text-3xl font-extrabold text-dark mb-2 tracking-tight">
                {isLogin ? "Welcome Back!" : "Get Started"}
              </h3>
              <p className="text-slate-400 text-sm font-medium">
                {isLogin ? "Akses dashboard Anda sekarang." : "Gabung dan temukan peluang teknologi."}
              </p>
            </div>

            {/* Switch Tab */}
            <div className="flex bg-slate-200/60 p-1.5 rounded-2xl mb-8">
              <button
                type="button"
                onClick={() => setIsLogin(true)}
                className={`flex-1 py-2.5 rounded-xl text-[10px] font-extrabold tracking-widest transition-all ${isLogin ? "bg-white text-brand-600 shadow-md" : "text-slate-500"}`}
              >
                LOG IN
              </button>
              <button
                type="button"
                onClick={() => setIsLogin(false)}
                className={`flex-1 py-2.5 rounded-xl text-[10px] font-extrabold tracking-widest transition-all ${!isLogin ? "bg-white text-brand-600 shadow-md" : "text-slate-500"}`}
              >
                SIGN UP
              </button>
            </div>

            <form className="space-y-4" onSubmit={handleSubmit}>
              {!isLogin && (
                <>
                  <div className="space-y-1.5">
                    <label className="text-[10px] font-bold text-slate-400 uppercase ml-4 tracking-wider">Full Name</label>
                    <div className="relative">
                      <span className="material-icons-round absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 text-sm">person_outline</span>
                      <input
                        type="text"
                        required
                        className="w-full pl-11 pr-4 py-3.5 rounded-2xl border border-slate-200 bg-white focus:border-brand-500 focus:outline-none text-sm font-medium"
                        value={name}
                        onChange={(e) => setName(e.target.value)}
                      />
                    </div>
                  </div>
                  <div className="space-y-1.5">
                    <label className="text-[10px] font-bold text-slate-400 uppercase ml-4 tracking-wider">Location</label>
                    <div className="relative">
                      <span className="material-icons-round absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 text-sm">location_on</span>
                      <input
                        type="text"
                        required
                        className="w-full pl-11 pr-4 py-3.5 rounded-2xl border border-slate-200 bg-white focus:border-brand-500 focus:outline-none text-sm font-medium"
                        value={location}
                        onChange={(e) => setLocation(e.target.value)}
                      />
                    </div>
                  </div>
                </>
              )}

              <div className="space-y-1.5">
                <label className="text-[10px] font-bold text-slate-400 uppercase ml-4 tracking-wider">Email Address</label>
                <div className="relative">
                  <span className="material-icons-round absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 text-sm">alternate_email</span>
                  <input
                    type="email"
                    required
                    className="w-full pl-11 pr-4 py-3.5 rounded-2xl border border-slate-200 bg-white focus:border-brand-500 focus:outline-none text-sm font-medium"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-[10px] font-bold text-slate-400 uppercase ml-4 tracking-wider">Password</label>
                <div className="relative">
                  <span className="material-icons-round absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 text-sm">lock_open</span>
                  <input
                    type="password"
                    required
                    className="w-full pl-11 pr-4 py-3.5 rounded-2xl border border-slate-200 bg-white focus:border-brand-500 focus:outline-none text-sm font-medium"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full py-4 bg-brand-600 hover:bg-brand-500 text-white font-bold rounded-2xl shadow-xl shadow-brand-500/20 active:scale-[0.98] mt-4 text-sm transition-all disabled:opacity-50"
              >
                {loading ? "Memproses..." : isLogin ? "Masuk ke Platform" : "Daftar Sekarang"}
              </button>
            </form>

            <div className="relative my-8">
              <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-slate-200"></div></div>
              <div className="relative flex justify-center text-[9px] uppercase font-black text-slate-400">
                <span className="bg-slate-50/50 px-4 tracking-[0.2em]">Social Connect</span>
              </div>
            </div>

            <button
              type="button"
              onClick={handleGoogleLogin}
              disabled={loading}
              className="w-full py-3.5 border border-slate-200 bg-white hover:bg-slate-50 text-dark font-bold rounded-2xl transition-all flex items-center justify-center gap-3 text-sm shadow-sm disabled:opacity-50"
            >
              <img src="https://www.svgrepo.com/show/475656/google-color.svg" className="w-5 h-5" alt="Google" />
              Lanjutkan dengan Google
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}