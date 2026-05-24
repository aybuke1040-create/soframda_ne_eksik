import type { Metadata } from "next";
import { SupportForm } from "@/components/SupportForm";
import { faqs, siteConfig } from "@/components/site-config";

export const metadata: Metadata = {
  title: "Destek",
  alternates: {
    canonical: "/support"
  }
};

const moderationItems = [
  "Kullanıcılar uygulama içinden uygunsuz içerikleri ve hesapları şikayet edebilir.",
  "Kötüye kullanım gösteren kullanıcılar engellenebilir ve engellenen hesapların içerikleri akıştan gizlenir.",
  "Raporlanan içerikler ve kullanıcılar en geç 24 saat içinde incelenir.",
  "Uygunsuz içerik kaldırılır, tekrar eden ihlallerde hesap kapatılabilir.",
  "Taciz, tehdit, nefret söylemi, dolandırıcılık ve spam içeriklere tolerans göstermeyiz."
] as const;

const reportSteps = [
  "Uygulamada ilgili profil, sohbet veya ilan detay ekranına gir.",
  "\"Şikayet Et\" veya \"Kullanıcıyı Engelle\" seçeneğini kullan.",
  "Gerekirse destek ekibine ekran görüntüsü ve kısa açıklama gönder.",
  "Destek ekibi raporu inceler ve sonucuna göre içerik veya hesap hakkında işlem uygular."
] as const;

const agreementSections = [
  {
    title: "Platformun rolü",
    paragraphs: [
      "Ben Yaparım; kullanıcıları dijital ortamda bir araya getiren, ilan, eşleşme ve mesajlaşma altyapısı sunan bir teknoloji platformudur.",
      "Platform; taşıma, yemek, organizasyon veya benzeri hizmetleri kendi adına sunmaz, üstlenmez ve ifa etmez."
    ]
  },
  {
    title: "Hizmet ilişkileri",
    paragraphs: [
      "Platform üzerinden kurulan hizmet ilişkileri yalnızca ilgili kullanıcılar arasında doğar.",
      "Fiyat, teslim, içerik, kalite, zamanlama ve ifaya ilişkin kararlar kullanıcıların kendi aralarında belirlenir."
    ]
  },
  {
    title: "Sorumluluk sınırları",
    paragraphs: [
      "Platform; kullanıcılar arasındaki hizmetin sonucu, kalitesi, gecikmesi, iptali veya özel uyuşmazlıklardan doğrudan sorumlu değildir.",
      "Platformun sorumluluğu varsa, yalnızca kendi teknik altyapısından kaynaklanan doğrudan kusur alanıyla sınırlıdır."
    ]
  },
  {
    title: "Kişisel veriler ve güvenlik",
    paragraphs: [
      "Paylaşılan kişisel veriler; hizmetin teknik olarak sunulması, güvenlik, destek ve mevzuata uyum amaçlarıyla işlenir.",
      "Kullanıcılar, birbirleriyle paylaştıkları kişisel verileri hukuka uygun şekilde kullanmakla yükümlüdür."
    ]
  }
] as const;

export default function SupportPage() {
  return (
    <div className="section-shell py-16 sm:py-20">
      <div className="max-w-3xl">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">Destek</p>
        <h1 className="mt-3 text-4xl font-black tracking-tight text-ink sm:text-5xl">
          İhtiyacın olduğunda destek burada
        </h1>
        <p className="mt-5 text-lg leading-8 text-slate-600">
          Hesap, teklifler, siparişler, mesajlaşma veya bildirimlerle ilgili yardıma
          ihtiyaç duyduğunda bize kolayca ulaşabilirsin. Uygunsuz içerik, kötüye
          kullanım, sahte ilan veya güvenlik kaygıları için de bu sayfayı kullanabilirsin.
        </p>
      </div>

      <div className="mt-10 grid gap-6 lg:grid-cols-[1.05fr_.95fr]">
        <SupportForm />

        <div className="glass-card rounded-4xl p-6 sm:p-8">
          <h2 className="text-2xl font-black text-ink">Destek e-postası</h2>
          <a
            href={`mailto:${siteConfig.supportEmail}`}
            className="mt-4 inline-block text-lg font-bold text-plum-700"
          >
            {siteConfig.supportEmail}
          </a>

          <div className="mt-8 rounded-3xl bg-white p-5">
            <h2 className="text-2xl font-black text-ink">Güvenlik ve moderasyon</h2>
            <ul className="mt-4 space-y-3 text-sm leading-7 text-slate-600">
              {moderationItems.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </div>

          <div className="mt-8 rounded-3xl bg-white p-5">
            <h2 className="text-2xl font-black text-ink">İçerik veya kullanıcı nasıl bildirilir?</h2>
            <ol className="mt-4 space-y-3 text-sm leading-7 text-slate-600">
              {reportSteps.map((step) => (
                <li key={step}>{step}</li>
              ))}
            </ol>
          </div>

          <div className="mt-8 rounded-3xl bg-white p-5">
            <h2 className="text-2xl font-black text-ink">
              Platform kullanımı ve sorumluluk çerçevesi
            </h2>
            <div className="mt-5 space-y-5">
              {agreementSections.map((section) => (
                <section key={section.title} className="rounded-2xl bg-slate-50 p-4">
                  <h3 className="text-base font-black text-ink">{section.title}</h3>
                  <div className="mt-3 space-y-3 text-sm leading-7 text-slate-600">
                    {section.paragraphs.map((paragraph) => (
                      <p key={paragraph}>{paragraph}</p>
                    ))}
                  </div>
                </section>
              ))}
            </div>
          </div>

          <div className="mt-8">
            <h2 className="text-2xl font-black text-ink">Sık sorulan sorular</h2>
            <div className="mt-4 space-y-4">
              {faqs.map((faq) => (
                <details key={faq.question} className="rounded-3xl bg-white p-4">
                  <summary className="cursor-pointer list-none text-base font-bold text-ink">
                    {faq.question}
                  </summary>
                  <p className="mt-3 text-sm leading-7 text-slate-600">{faq.answer}</p>
                </details>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
