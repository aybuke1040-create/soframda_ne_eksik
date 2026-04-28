import type {Metadata} from "next";
import {SupportForm} from "@/components/SupportForm";
import {faqs, siteConfig} from "@/components/site-config";

export const metadata: Metadata = {
  title: "Destek",
  alternates: {
    canonical: "/support",
  },
};

export default function SupportPage() {
  return (
    <div className="section-shell py-16 sm:py-20">
      <div className="max-w-3xl">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">
          Support
        </p>
        <h1 className="mt-3 text-4xl font-black tracking-tight text-ink sm:text-5xl">
          Ihtiyacin oldugunda destek burada
        </h1>
        <p className="mt-5 text-lg leading-8 text-slate-600">
          Hesap, teklifler, siparisler, mesajlasma veya bildirimlerle ilgili
          yardima ihtiyac duydugunda bize kolayca ulasabilirsin. Uygunsuz icerik,
          kotuye kullanim, sahte ilan veya guvenlik kaygilari icin de bu sayfayi
          kullanabilirsin.
        </p>
      </div>

      <div className="mt-10 grid gap-6 lg:grid-cols-[1.05fr_.95fr]">
        <SupportForm />

        <div className="glass-card rounded-4xl p-6 sm:p-8">
          <h2 className="text-2xl font-black text-ink">Destek e-postasi</h2>
          <a
            href={`mailto:${siteConfig.supportEmail}`}
            className="mt-4 inline-block text-lg font-bold text-plum-700"
          >
            {siteConfig.supportEmail}
          </a>

          <div className="mt-8 rounded-3xl bg-white p-5">
            <h2 className="text-2xl font-black text-ink">Guvenlik ve moderasyon</h2>
            <ul className="mt-4 space-y-3 text-sm leading-7 text-slate-600">
              <li>Kullanicilar uygulama icinden uygunsuz icerigi ve kullanicilari sikayet edebilir.</li>
              <li>Kotuye kullanim gosteren kullanicilar engellenebilir ve engellenen kullanicilarin icerigi akistan gizlenir.</li>
              <li>Raporlanan icerikler ve kullanicilar en gec 24 saat icinde incelenir.</li>
              <li>Uygunsuz icerik kaldirilir, tekrar eden ihlallerde hesap kapatilabilir ve gerekli durumlarda gelistirici ekibi bilgilendirilir.</li>
              <li>Toplulugumuzu korumak icin taciz, tehdit, nefret soylemi, cinsel istismar, dolandiricilik ve spam iceriklere tolerans gostermeyiz.</li>
            </ul>
          </div>

          <div className="mt-8 rounded-3xl bg-white p-5">
            <h2 className="text-2xl font-black text-ink">Icerik veya kullanici nasil bildirilir?</h2>
            <ol className="mt-4 space-y-3 text-sm leading-7 text-slate-600">
              <li>Uygulamada ilgili profil, sohbet veya ilan detay ekranina gir.</li>
              <li>"Sikayet Et" veya "Kullaniciyi Engelle" secenegini kullan.</li>
              <li>Gerekirse destek ekibine ekran goruntusu ve ek aciklama gonder.</li>
              <li>Destek ekibi raporu kayda alir, inceler ve sonucuna gore icerigi veya hesabi kaldirir.</li>
            </ol>
          </div>

          <div className="mt-8">
            <h2 className="text-2xl font-black text-ink">Sik sorulan sorular</h2>
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
