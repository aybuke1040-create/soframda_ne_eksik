import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Login",
  robots: {
    index: false,
    follow: false
  }
};

export default function LoginPage() {
  return (
    <div className="section-shell py-20">
      <div className="glass-card mx-auto max-w-3xl rounded-4xl p-8 text-center">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">İkinci Faz</p>
        <h1 className="mt-3 text-4xl font-black text-ink">Giriş deneyimi yakında</h1>
        <p className="mt-4 text-base leading-7 text-slate-600">
          `/login` sayfası ikinci faz için ayrıldı. Gerektiğinde mevcut marka diliyle güçlü bir web giriş deneyimine dönüştürebiliriz.
        </p>
      </div>
    </div>
  );
}
