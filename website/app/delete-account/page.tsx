import type { Metadata } from "next";
import { siteConfig } from "@/components/site-config";

export const metadata: Metadata = {
  title: "Hesap Silme",
  alternates: {
    canonical: "/delete-account"
  }
};

const steps = [
  "Uygulama içinde profil veya ayarlar alanına gir.",
  "Hesap ayarları altında yer alan hesap silme seçeneğini aç.",
  "Bilgilendirme ekranını dikkatlice inceleyip işlemi onayla.",
  "Ek veri silme talebin varsa destek ekibimize ayrıca ulaş."
];

const outcomes = [
  "Hesabına bağlı oturumlar ve temel erişimler sonlandırılır.",
  "Mesajlaşma, teklif ve hesapla bağlantılı veriler ilgili süreçlere göre değerlendirilir.",
  "Yasal saklama yükümlülüğü bulunan kayıtlar gerektiğinde ayrı tutulabilir.",
  "Ek soruların veya özel veri taleplerin için destek ekibimizden yardım alabilirsin."
];

export default function DeleteAccountPage() {
  return (
    <div className="section-shell py-16 sm:py-20">
      <div className="max-w-3xl">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">Delete Account</p>
        <h1 className="mt-3 text-4xl font-black tracking-tight text-ink sm:text-5xl">Hesap silme ve veri talebi</h1>
        <p className="mt-5 text-lg leading-8 text-slate-600">
          Hesabını uygulama içinden silebilir, ek veri silme taleplerini ise destek ekibimize güvenle iletebilirsin.
        </p>
      </div>

      <div className="mt-10 grid gap-6 lg:grid-cols-2">
        <section className="glass-card rounded-4xl p-6 sm:p-8">
          <h2 className="text-2xl font-black text-ink">Uygulama içinden silme adımı</h2>
          <ol className="mt-5 space-y-3 text-sm leading-7 text-slate-600">
            {steps.map((step, index) => (
              <li key={step} className="rounded-3xl bg-white px-4 py-3">
                <span className="mr-2 font-black text-plum-700">0{index + 1}</span>
                {step}
              </li>
            ))}
          </ol>
        </section>

        <section className="glass-card rounded-4xl p-6 sm:p-8">
          <h2 className="text-2xl font-black text-ink">Silme sonrası neler olur</h2>
          <ul className="mt-5 space-y-3 text-sm leading-7 text-slate-600">
            {outcomes.map((item) => (
              <li key={item} className="rounded-3xl bg-white px-4 py-3">
                {item}
              </li>
            ))}
          </ul>
        </section>
      </div>

      <section className="mt-6 rounded-4xl border border-plum-100 bg-white p-6 sm:p-8">
        <h2 className="text-2xl font-black text-ink">Veri silme talebi için iletişim</h2>
        <p className="mt-4 text-sm leading-7 text-slate-600">
          Mail veya destek formu üzerinden veri silme talebini iletebilirsin. Destek adresimiz:{" "}
          <a href={`mailto:${siteConfig.supportEmail}`} className="font-bold text-plum-700">
            {siteConfig.supportEmail}
          </a>
        </p>
      </section>
    </div>
  );
}
