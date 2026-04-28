import type {Metadata} from "next";
import Link from "next/link";
import {siteConfig} from "@/components/site-config";

export const metadata: Metadata = {
  title: "Kullanim Kosullari",
  alternates: {
    canonical: "/terms",
  },
};

const rules = [
  "Taciz, tehdit, nefret soylemi, ayrimcilik, cinsel istismar, siddeti tesvik eden icerik ve dolandiricilik yasaktir.",
  "Spam, sahte ilan, sahte teklif, aldatici profil ve baskalarini kandirmaya yonelik davranislar kabul edilmez.",
  "Kullanicilar, uygunsuz icerik veya kotuye kullanim gorduklerinde ilgili kullaniciyi engelleyebilir ve icerigi sikayet edebilir.",
  "Engellenen kullanicilarin icerigi ilgili kullanicinin akisindan gizlenir ve istenmeyen iletisim durdurulur.",
  "Raporlanan icerikler ve kullanicilar en gec 24 saat icinde incelenir; gerekli durumlarda icerik kaldirilir ve ihlal eden hesap kapatilir.",
] as const;

const promises = [
  "Kullanicilar, uygulama icindeki topluluk kurallarini kabul etmeden kullanici kaynakli icerige erisemez.",
  "Sikayet kayitlari destek ve moderasyon ekibi tarafindan takip edilir.",
  "Tekrar eden veya agir ihlallerde hesaba erisim kaldirilabilir.",
  "Guvenlik, moderasyon ve hesap islemleri icin destek ekibine e-posta ile ulasilabilir.",
] as const;

export default function TermsPage() {
  return (
    <div className="section-shell py-16 sm:py-20">
      <div className="max-w-3xl">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">Terms</p>
        <h1 className="mt-3 text-4xl font-black tracking-tight text-ink sm:text-5xl">
          Kullanim kosullari ve topluluk kurallari
        </h1>
        <p className="mt-5 text-lg leading-8 text-slate-600">
          Ben Yaparim uzerindeki ilanlar, mesajlar, teklifler ve diger kullanici kaynakli
          icerikler topluluk guvenligini koruyan kurallara tabidir. Uygulamayi kullanarak
          bu kurallara uymayi kabul etmis olursun.
        </p>
      </div>

      <div className="mt-10 grid gap-6 lg:grid-cols-[1.05fr_.95fr]">
        <section className="glass-card rounded-4xl p-6 sm:p-8">
          <h2 className="text-2xl font-black text-ink">Toplulukta neleri kabul etmiyoruz</h2>
          <ul className="mt-4 space-y-3 text-sm leading-7 text-slate-600">
            {rules.map((rule) => (
              <li key={rule} className="rounded-3xl bg-white/70 px-4 py-3">
                {rule}
              </li>
            ))}
          </ul>
        </section>

        <section className="glass-card rounded-4xl p-6 sm:p-8">
          <h2 className="text-2xl font-black text-ink">Guvenlik ve moderasyon taahhudumuz</h2>
          <ul className="mt-4 space-y-3 text-sm leading-7 text-slate-600">
            {promises.map((promise) => (
              <li key={promise} className="rounded-3xl bg-white/70 px-4 py-3">
                {promise}
              </li>
            ))}
          </ul>

          <div className="mt-8 rounded-3xl bg-white p-5">
            <h3 className="text-lg font-black text-ink">Rapor ve destek</h3>
            <p className="mt-3 text-sm leading-7 text-slate-600">
              Uygunsuz icerik, kotuye kullanim veya hesap guvenligiyle ilgili bir durum
              gordugunde uygulama icinden sikayet etme ve engelleme araclarini kullanabilir,
              ayrica{" "}
              <a className="font-bold text-plum-700" href={`mailto:${siteConfig.supportEmail}`}>
                {siteConfig.supportEmail}
              </a>{" "}
              adresine ulasabilirsin.
            </p>
            <p className="mt-3 text-sm leading-7 text-slate-600">
              Hesap gizliligi ve veri kullanimi detaylari icin{" "}
              <Link className="font-bold text-plum-700" href="/privacy">
                Gizlilik Politikasi
              </Link>{" "}
              sayfamizi inceleyebilirsin.
            </p>
          </div>
        </section>
      </div>
    </div>
  );
}
