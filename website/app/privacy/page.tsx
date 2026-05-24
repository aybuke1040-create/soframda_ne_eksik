import type { Metadata } from "next";
import { siteConfig } from "@/components/site-config";

export const metadata: Metadata = {
  title: "Gizlilik Politikası",
  alternates: {
    canonical: "/privacy"
  }
};

const sections = [
  {
    title: "Hangi verileri topluyoruz",
    items: [
      "Hesap oluşturma ve giriş işlemleri için temel kimlik ve iletişim bilgileri.",
      "Sana yakın ilanları ve uygun eşleşmeleri gösterebilmek için konum veya bölgesel bilgi.",
      "Teklif, sohbet ve iş birliği akışlarını sürdürebilmek için kullanıcı tarafından oluşturulan içerikler.",
      "Bildirimleri doğru şekilde iletmek için cihaz ve bildirim tercihleri."
    ]
  },
  {
    title: "Verileri neden işliyoruz",
    items: [
      "İlan, teklif, mesajlaşma ve eşleşme deneyimini çalıştırmak.",
      "Dolandırıcılık, taciz, spam ve uygunsuz içeriğe karşı güvenlik kontrolleri uygulamak.",
      "Destek taleplerini, hesap sorunlarını ve güvenlik bildirimlerini yönetmek."
    ]
  },
  {
    title: "Moderasyon, şikayet ve engelleme verileri",
    items: [
      "Uygulama içinden yapılan şikayet kayıtları, raporlanan içeriği incelemek ve topluluk güvenliğini korumak için işlenir.",
      "Engellenen kullanıcılar bilgisi, ilgili kişinin içeriğini kullanıcının akışından gizlemek ve istenmeyen iletişimi durdurmak için kullanılır.",
      "Raporlanan içerikler ve ilgili hesaplar en geç 24 saat içinde incelenir; gerekli durumlarda içerik kaldırılır veya hesap kapatılır."
    ]
  },
  {
    title: "Hesap silme ve veri talepleri",
    items: [
      "Kullanıcılar uygulama içinden hesap silme adımlarını başlatabilir.",
      "Ek veri silme veya bilgi talepleri için destek ekibimize ulaşılabilir.",
      "Yasal yükümlülükler, güvenlik incelemeleri ve açık uyuşmazlıklar nedeniyle bazı kayıtlar belirli sürelerle saklanabilir."
    ]
  }
] as const;

export default function PrivacyPage() {
  return (
    <div className="section-shell py-16 sm:py-20">
      <div className="max-w-3xl">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">Gizlilik</p>
        <h1 className="mt-3 text-4xl font-black tracking-tight text-ink sm:text-5xl">
          Gizlilik politikamız
        </h1>
        <p className="mt-5 text-lg leading-8 text-slate-600">
          Ben Yaparım, kullanıcılarına güvenli ve şeffaf bir deneyim sunabilmek için
          gerekli verileri işler. Hangi bilginin neden kullanıldığını açıkça anlatmayı
          ve topluluk güvenliğini korumayı önemsiyoruz.
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
        <h2 className="text-2xl font-black text-ink">İletişim</h2>
        <p className="mt-3 text-sm leading-7 text-slate-600">
          Gizlilik, veri talepleri, şikayetler veya hesap silme süreçleriyle ilgili her
          konuda{" "}
          <a className="font-bold text-plum-700" href={`mailto:${siteConfig.supportEmail}`}>
            {siteConfig.supportEmail}
          </a>{" "}
          adresinden bize ulaşabilirsin.
        </p>
      </div>
    </div>
  );
}
