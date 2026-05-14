import { useState, useEffect } from "react";

export default function Hero({ navigateTo }) {
  const [currentSlide, setCurrentSlide] = useState(0);
  const slides = [
    "https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=2000",
    "https://images.unsplash.com/photo-1531482615713-2afd69097998?q=80&w=2000"
  ];

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % slides.length);
    }, 5000);
    return () => clearInterval(timer);
  }, []);

  return (
    <section className="relative h-[90vh] bg-dark flex items-center overflow-hidden">
      {slides.map((src, idx) => (
        <div key={idx} className={`absolute inset-0 transition-opacity duration-1000 ${idx === currentSlide ? 'opacity-40 z-10' : 'opacity-0 z-0'}`}>
          <img src={src} className="w-full h-full object-cover" alt="Hero background" />
          <div className="absolute inset-0 bg-gradient-to-r from-dark via-dark/40 to-transparent"></div>
        </div>
      ))}
      
      <div className="relative z-20 max-w-7xl mx-auto px-6 w-full">
        <span className="bg-brand-500 text-white px-4 py-1.5 rounded-full text-xs font-extrabold uppercase tracking-widest mb-6 inline-block">Tasikmalaya Tech Ecosystem</span>
        <h2 className="font-heading text-5xl md:text-7xl text-white font-extrabold mb-6 leading-[1.1]">Temukan Masa Depan<br/>Teknologimu di Sini.</h2>
        <p className="text-slate-300 text-lg max-w-xl mb-10 leading-relaxed">Hub pendaftaran workshop, bootcamp, dan seminar IT terbesar di Priangan Timur.</p>
        <button onClick={() => navigateTo('explore')} className="px-8 py-4 bg-brand-600 hover:bg-brand-500 text-white font-bold rounded-2xl shadow-xl shadow-brand-500/20 transition-all flex items-center gap-2 w-fit">
          Mulai Eksplorasi <span className="material-icons-round">arrow_forward</span>
        </button>
      </div>
    </section>
  );
}