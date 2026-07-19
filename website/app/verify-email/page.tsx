import Link from "next/link";
import type { Metadata } from "next";
import { siteConfig } from "@/components/site-config";

export const metadata: Metadata = {
  title: "E-posta Doğrulama",
  robots: { index: false, follow: false },
};

export default function VerifyEmailPage() {
  return (
    <div className="section-shell py-16 sm:py-20">
      <div className="mx-auto max-w-2xl rounded-[32px] border border-plum-100 bg-white p-6 shadow-sm sm:p-10">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">
          E-posta Doğrulama
        </p>
        <h1 className="mt-3 text-3xl font-black tracking-tight text-ink sm:text-4xl">
          E-posta adresini güvenle doğrula
        </h1>
        <p className="mt-4 text-base leading-8 text-slate-600">
          E-postandaki Firebase doğrulama bağlantısı işlemi güvenli ekranda
          tamamlar. Doğrulama başarılı olduktan sonra Ben Yaparım uygulamasına
          dönüp giriş yapabilirsin.
        </p>
        <div className="mt-7 rounded-3xl bg-slate-50 p-5 text-sm leading-7 text-slate-600">
          Bağlantı kullanılamıyorsa süresi dolmuş veya daha önce kullanılmış
          olabilir. Uygulamadan yeniden doğrulama e-postası iste.
        </div>
        <div className="mt-8 flex flex-wrap gap-3">
          <Link
            href="/download"
            className="inline-flex items-center justify-center rounded-full bg-plum-700 px-5 py-3 text-sm font-bold text-white transition hover:bg-plum-800"
          >
            Uygulamaya dön
          </Link>
          <a
            href={`mailto:${siteConfig.supportEmail}`}
            className="inline-flex items-center justify-center rounded-full border border-plum-200 px-5 py-3 text-sm font-bold text-plum-700 transition hover:bg-plum-50"
          >
            Destek al
          </a>
        </div>
      </div>
    </div>
  );
}
