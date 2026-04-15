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
    title: "Hangi veriler toplanır",
    items: [
      "Hesap oluşturma ve giriş süreçleri için gerekli temel kimlik ve iletişim bilgileri.",
      "Sana yakın hizmetleri gösterebilmek için konum veya bölgesel bilgi.",
      "Teklif ve iletişim akışını sürdürebilmek için mesajlaşma içerikleri.",
      "Önemli gelişmeleri iletebilmek için bildirim tercihleri ve cihaz bilgileri."
    ]
  },
  {
    title: "Neden toplanır",
    items: [
      "Daha doğru eşleşmeler sunabilmek ve sana uygun fırsatları gösterebilmek.",
      "Talep, teklif ve mesajlaşma akışlarını güvenli şekilde yönetebilmek.",
      "Hizmet kalitesini artırmak, destek süreçlerini kolaylaştırmak ve güvenliği güçlendirmek."
    ]
  },
  {
    title: "Konum, mesajlaşma ve bildirimler",
    items: [
      "Konum verisi, bulunduğun çevredeki uygun hizmet sağlayıcılarını öne çıkarmak için kullanılabilir.",
      "Mesajlaşma içerikleri, taraflar arasındaki iletişimin sağlıklı ilerlemesi için işlenir.",
      "Bildirimler; yeni teklif, mesaj veya süreç güncellemelerini zamanında iletmek için gönderilebilir."
    ]
  },
  {
    title: "Hesap silme ve veri talebi",
    items: [
      "Kullanıcılar uygulama içinden hesap silme adımlarını takip edebilir.",
      "Ek veri silme veya bilgi talebi için destek ekibimize ulaşabilir.",
      "Talepler, yasal yükümlülükler ve operasyonel gereklilikler doğrultusunda değerlendirilir."
    ]
  }
] as const;

export default function PrivacyPage() {
  return (
    <div className="section-shell py-16 sm:py-20">
      <div className="max-w-3xl">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">Privacy</p>
        <h1 className="mt-3 text-4xl font-black tracking-tight text-ink sm:text-5xl">Gizlilik politikamız</h1>
        <p className="mt-5 text-lg leading-8 text-slate-600">
          Ben Yaparım, hizmet deneyimini güvenli, şeffaf ve sürdürülebilir biçimde sunabilmek için gerekli verileri işler.
          Hangi bilginin neden kullanıldığını açıkça anlatmayı önemsiyoruz.
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
          Gizlilik, veri talebi veya hesap silme süreçleriyle ilgili her konuda{" "}
          <a className="font-bold text-plum-700" href={`mailto:${siteConfig.supportEmail}`}>
            {siteConfig.supportEmail}
          </a>{" "}
          adresinden bize ulaşabilirsin.
        </p>
      </div>
    </div>
  );
}
