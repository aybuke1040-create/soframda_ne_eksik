import type { Metadata } from "next";
import Link from "next/link";
import { siteConfig } from "@/components/site-config";

export const metadata: Metadata = {
  title: "Kullanım Koşulları",
  alternates: {
    canonical: "/terms"
  }
};

const rules = [
  "Taciz, tehdit, nefret söylemi, ayrımcılık, cinsel istismar, şiddeti teşvik eden içerik ve dolandırıcılık yasaktır.",
  "Spam, sahte ilan, sahte teklif, aldatıcı profil ve başkalarını kandırmaya yönelik davranışlar kabul edilmez.",
  "Kullanıcılar, uygunsuz içerik veya kötüye kullanım gördüklerinde ilgili kullanıcıyı engelleyebilir ve içeriği şikayet edebilir.",
  "Engellenen kullanıcıların içeriği ilgili kullanıcının akışından gizlenir ve istenmeyen iletişim durdurulur.",
  "Raporlanan içerikler ve kullanıcılar en geç 24 saat içinde incelenir; gerekli durumlarda içerik kaldırılır ve ihlal eden hesap kapatılır."
] as const;

const promises = [
  "Kullanıcılar, uygulama içindeki topluluk kurallarını kabul etmeden kullanıcı kaynaklı içeriğe erişemez.",
  "Şikayet kayıtları destek ve moderasyon ekibi tarafından takip edilir.",
  "Tekrar eden veya ağır ihlallerde hesaba erişim kaldırılabilir.",
  "Güvenlik, moderasyon ve hesap işlemleri için destek ekibine e-posta ile ulaşılabilir."
] as const;

export default function TermsPage() {
  return (
    <div className="section-shell py-16 sm:py-20">
      <div className="max-w-3xl">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">Koşullar</p>
        <h1 className="mt-3 text-4xl font-black tracking-tight text-ink sm:text-5xl">
          Kullanım koşulları ve topluluk kuralları
        </h1>
        <p className="mt-5 text-lg leading-8 text-slate-600">
          Ben Yaparım üzerindeki ilanlar, mesajlar, teklifler ve diğer kullanıcı kaynaklı
          içerikler topluluk güvenliğini koruyan kurallara tabidir. Uygulamayı
          kullanarak bu kurallara uymayı kabul etmiş olursun.
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
          <h2 className="text-2xl font-black text-ink">Güvenlik ve moderasyon taahhüdümüz</h2>
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
              Uygunsuz içerik, kötüye kullanım veya hesap güvenliğiyle ilgili bir durum
              gördüğünde uygulama içinden şikayet etme ve engelleme araçlarını
              kullanabilir, ayrıca{" "}
              <a className="font-bold text-plum-700" href={`mailto:${siteConfig.supportEmail}`}>
                {siteConfig.supportEmail}
              </a>{" "}
              adresine ulaşabilirsin.
            </p>
            <p className="mt-3 text-sm leading-7 text-slate-600">
              Hesap gizliliği ve veri kullanımı detayları için{" "}
              <Link className="font-bold text-plum-700" href="/privacy">
                Gizlilik Politikası
              </Link>{" "}
              sayfamızı inceleyebilirsin.
            </p>
          </div>
        </section>
      </div>
    </div>
  );
}
