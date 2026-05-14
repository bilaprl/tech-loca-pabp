"use client";

export default function Footer({ navigateTo }) {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="mt-20 pb-10 px-6">
      <div className="max-w-7xl mx-auto">
        {/* MAIN FOOTER CARD */}
        <div className="bg-white border border-slate-100 rounded-[3rem] p-10 md:p-16 shadow-sm overflow-hidden relative">
          {/* Subtle Background Ornament */}
          <div className="absolute top-0 right-0 w-64 h-64 bg-brand-50 rounded-full -mr-32 -mt-32 blur-3xl opacity-50"></div>

          <div className="relative z-10 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12">
            {/* COLUMN 1: LOGO & ABOUT */}
            <div className="space-y-6">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-brand-600 rounded-xl flex items-center justify-center shadow-lg shadow-brand-500/20">
                  <img
                    src="/logo.png"
                    alt="TechLoca"
                    className="w-10 h-10 object-contain rounded-2xl"
                  />
                </div>
                <span className="font-heading font-black text-2xl tracking-tighter text-dark uppercase">
                  TechLoca
                </span>
              </div>
              <p className="text-sm font-medium text-slate-400 leading-relaxed">
                The Ultimate Tech & Dev Event Hub in Tasikmalaya. Wadah
                kolaborasi para developer dan antusias teknologi untuk
                berkembang bersama.
              </p>
              <div className="flex gap-4">
                {[
                  {
                    id: "facebook",
                    url: "https://facebook.com/techloca",
                    path: "M22 12c0-5.52-4.48-10-10-10S2 6.48 2 12c0 4.84 3.44 8.87 8 9.8V15H8v-3h2V9.5C10 7.57 11.57 6 13.5 6H16v3h-2c-.55 0-1 .45-1 1V12h3l-.5 3h-2.5v6.8c4.56-.93 8-4.96 8-9.8z",
                  },
                  {
                    id: "instagram",
                    url: "https://instagram.com/techloca",
                    path: "M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4s1.791-4 4-4 4 1.791 4 4-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z",
                  },
                  {
                    id: "twitter",
                    url: "https://twitter.com/techloca",
                    path: "M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.84 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z",
                  },
                  {
                    id: "github",
                    url: "https://github.com/bilaprl/tech-loca",
                    path: "M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12",
                  },
                ].map((social) => (
                  <button
                    key={social.id}
                    className="w-10 h-10 rounded-full bg-slate-50 flex items-center justify-center text-slate-400 hover:bg-brand-600 hover:text-white transition-all duration-300 shadow-sm"
                  >
                    <svg
                      className="w-5 h-5 fill-current"
                      viewBox="0 0 24 24"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path d={social.path} />
                    </svg>
                  </button>
                ))}
              </div>
            </div>

            {/* COLUMN 2: QUICK LINKS */}
            <div className="space-y-6 md:pl-10">
              <h4 className="text-[10px] font-black text-dark uppercase tracking-[0.2em]">
                Navigasi
              </h4>
              <ul className="space-y-4">
                {["Home", "Explore", "FAQ"].map((link) => (
                  <li key={link}>
                    <button
                      onClick={() => navigateTo(link.toLowerCase())}
                      className="text-sm font-bold text-slate-400 hover:text-brand-600 transition-colors"
                    >
                      {link}
                    </button>
                  </li>
                ))}
              </ul>
            </div>

            {/* COLUMN 3: ACCOUNT & SUPPORT */}
            <div className="space-y-6">
              <h4 className="text-[10px] font-black text-dark uppercase tracking-[0.2em]">
                Akun & Bantuan
              </h4>
              <ul className="space-y-4">
                {["Wishlist", "Tiket Saya", "Profil", "Sertifikat"].map(
                  (link) => {
                    const id =
                      link === "Tiket Saya" ? "tickets" : link.toLowerCase();
                    return (
                      <li key={link}>
                        <button
                          onClick={() => navigateTo(id)}
                          className="text-sm font-bold text-slate-400 hover:text-brand-600 transition-colors"
                        >
                          {link}
                        </button>
                      </li>
                    );
                  },
                )}
              </ul>
            </div>

            {/* COLUMN 4: CONTACT INFO */}
            <div className="space-y-6">
              <h4 className="text-[10px] font-black text-dark uppercase tracking-[0.2em]">
                Lokasi Kami
              </h4>
              <div className="space-y-4">
                <div className="flex items-start gap-3">
                  <span className="material-icons-round text-brand-600 text-lg">
                    location_on
                  </span>
                  <p className="text-sm font-bold text-slate-500 leading-snug">
                    Jl. Siliwangi No. 24, Tasikmalaya
                    <br />
                    Jawa Barat, Indonesia
                  </p>
                </div>
                <div className="flex items-center gap-3">
                  <span className="material-icons-round text-brand-600 text-lg">
                    phone
                  </span>
                  <p className="text-sm font-bold text-slate-500">
                    (0265) 123 4567
                  </p>
                </div>
                <div className="flex items-center gap-3">
                  <span className="material-icons-round text-brand-600 text-lg">
                    mail
                  </span>
                  <p className="text-sm font-bold text-slate-500">
                    hello@techloca.com
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* BOTTOM BAR */}
          <div className="mt-16 pt-8 border-t border-slate-50 flex flex-col md:flex-row justify-between items-center gap-4">
            <p className="text-[10px] font-black text-slate-300 uppercase tracking-widest">
              © {currentYear} TechLoca Tasikmalaya • Designed for Excellence
            </p>
            <div className="flex gap-6">
              <button className="text-[10px] font-black text-slate-300 uppercase tracking-widest hover:text-brand-600 transition-colors">
                Privacy Policy
              </button>
              <button className="text-[10px] font-black text-slate-300 uppercase tracking-widest hover:text-brand-600 transition-colors">
                Terms of Service
              </button>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}
