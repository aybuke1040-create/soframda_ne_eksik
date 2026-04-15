import type { Metadata } from "next";
import { StoreCard } from "@/components/StoreCard";
import { siteConfig } from "@/components/site-config";

export const metadata: Metadata = {
  title: "Uygulamayı İndir",
  alternates: {
    canonical: "/download"
  }
};

export default function DownloadPage() {
  return (
    <div className="section-shell py-16 sm:py-20">
      <div className="max-w-3xl">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">Download</p>
        <h1 className="mt-3 text-4xl font-black tracking-tight text-ink sm:text-5xl">Ben Yaparım uygulamasını hemen indir</h1>
        <p className="mt-5 text-lg leading-8 text-slate-600">
          Telefonundan QR okut, uygulamaya saniyeler içinde ulaş. Android ve iPhone için tüm indirme adımlarını tek sayfada topladık.
        </p>
      </div>

      <div className="mt-10 grid gap-6">
        <StoreCard
          id="android"
          platform="Android"
          buttonLabel="Play Store'a git"
          href={siteConfig.appLinks.android}
          qrSrc="/qr/android.svg"
          note="Android kullanıcıları için doğrudan Play Store bağlantısı hazır. QR kodu okutabilir ya da mağaza sayfasına tek dokunuşla geçebilirsin."
        />
        <StoreCard
          id="ios"
          platform="iPhone"
          buttonLabel="App Store yayını yakında"
          href={siteConfig.appLinks.ios}
          qrSrc="/qr/ios.svg"
          note="iPhone sürümü App Store yayını tamamlandığında aynı sayfadan güncellenecek. Şimdilik QR kodu ve bu sayfa üzerinden en doğru bilgiye ulaşabilirsin."
        />
      </div>
    </div>
  );
}
