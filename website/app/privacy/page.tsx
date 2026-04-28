import type {Metadata} from "next";
import {siteConfig} from "@/components/site-config";

export const metadata: Metadata = {
  title: "Gizlilik Politikasi",
  alternates: {
    canonical: "/privacy",
  },
};

const sections = [
  {
    title: "Hangi verileri topluyoruz",
    items: [
      "Hesap olusturma ve giris islemleri icin temel kimlik ve iletisim bilgileri.",
      "Sana yakin ilanlari ve uygun eslesmeleri gosterebilmek icin konum veya bolgesel bilgi.",
      "Teklif, sohbet ve is birligi akislarini surdurebilmek icin kullanici tarafindan olusturulan icerikler.",
      "Bildirimleri dogru sekilde iletmek icin cihaz ve bildirim tercihleri.",
    ],
  },
  {
    title: "Verileri neden isliyoruz",
    items: [
      "Ilan, teklif, mesajlasma ve eslesme deneyimini calistirmak.",
      "Dolandiricilik, taciz, spam ve uygunsuz icerige karsi guvenlik kontrolleri uygulamak.",
      "Destek taleplerini, hesap sorunlarini ve guvenlik bildirimlerini yonetmek.",
    ],
  },
  {
    title: "Moderasyon, sikayet ve engelleme verileri",
    items: [
      "Uygulama icinden yapilan sikayet kayitlari, raporlanan icerigi incelemek ve topluluk guvenligini korumak icin islenir.",
      "Engellenen kullanicilar bilgisi, ilgili kisinin icerigini kullanicinin akisindan gizlemek ve istenmeyen iletisimi durdurmak icin kullanilir.",
      "Raporlanan icerikler ve ilgili hesaplar en gec 24 saat icinde incelenir; gerekli durumlarda icerik kaldirilir veya hesap kapatilir.",
    ],
  },
  {
    title: "Hesap silme ve veri talepleri",
    items: [
      "Kullanicilar uygulama icinden hesap silme adimlarini baslatabilir.",
      "Ek veri silme veya bilgi talepleri icin destek ekibimize ulasilabilir.",
      "Yasal yukumlulukler, guvenlik incelemeleri ve acik uyusmazliklar nedeniyle bazi kayitlar belirli surelerle saklanabilir.",
    ],
  },
] as const;

export default function PrivacyPage() {
  return (
    <div className="section-shell py-16 sm:py-20">
      <div className="max-w-3xl">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">Privacy</p>
        <h1 className="mt-3 text-4xl font-black tracking-tight text-ink sm:text-5xl">
          Gizlilik politikamiz
        </h1>
        <p className="mt-5 text-lg leading-8 text-slate-600">
          Ben Yaparim, kullanicilarina guvenli ve seffaf bir deneyim sunabilmek icin
          gerekli verileri isler. Hangi bilginin neden kullanildigini acikca anlatmayi
          ve topluluk guvenligini korumayi onemsiyoruz.
        </p>
      </div>

      <div className="mt-10 grid gap-6">
        {sections.map((section) => (
          <section key={section.title} className="glass-card rounded-4xl p-6 sm:p-8">
            <h2 className="text-2xl font-black text-ink">{section.title}</h2>
            <ul className="mt-4 space-y-3 text-sm leading-7 text-slate-600">
              {section.items.map((item) => (
                <li key={item} className="rounded-3xl bg-white/70 px-4 py-3">
                  {item}
                </li>
              ))}
            </ul>
          </section>
        ))}
      </div>

      <div className="mt-8 rounded-4xl border border-plum-100 bg-white p-6">
        <h2 className="text-2xl font-black text-ink">Iletisim</h2>
        <p className="mt-3 text-sm leading-7 text-slate-600">
          Gizlilik, veri talepleri, sikayetler veya hesap silme surecleriyle ilgili her
          konuda{" "}
          <a className="font-bold text-plum-700" href={`mailto:${siteConfig.supportEmail}`}>
            {siteConfig.supportEmail}
          </a>{" "}
          adresinden bize ulasabilirsin.
        </p>
      </div>
    </div>
  );
}
