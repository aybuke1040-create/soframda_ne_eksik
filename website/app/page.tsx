import Image from "next/image";
import Link from "next/link";
import { DownloadButtons } from "@/components/DownloadButtons";
import { PhoneMockup } from "@/components/PhoneMockup";
import { SectionIntro } from "@/components/SectionIntro";
import { categories, siteConfig, steps, trustPoints } from "@/components/site-config";

export default function HomePage() {
  const organizationSchema = {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: "Ben Yaparım",
    url: siteConfig.domain,
    logo: `${siteConfig.domain}/brand/logo.png`,
    contactPoint: {
      "@type": "ContactPoint",
      email: siteConfig.supportEmail,
      contactType: "customer support",
      availableLanguage: ["Turkish"]
    }
  };

  const websiteSchema = {
    "@context": "https://schema.org",
    "@type": "WebSite",
    name: "Ben Yaparım",
    url: siteConfig.domain,
    inLanguage: "tr-TR",
    description:
      "Mahallendeki yemek, ikram ve organizasyon işleri için ilan ver, teklif al ve mesajlaş."
  };

  return (
    <div className="pb-20">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(organizationSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(websiteSchema) }}
      />
      <section className="mesh overflow-hidden">
        <div className="section-shell grid gap-12 py-14 lg:grid-cols-[1.1fr_.9fr] lg:items-center lg:py-24">
          <div>
            <div className="inline-flex rounded-full border border-plum-200 bg-white/80 px-4 py-2 text-xs font-black uppercase tracking-[0.2em] text-plum-700">
              Mahallendeki yemek, ikram ve organizasyon işlerini tek yerde bul.
            </div>
            <h1 className="mt-6 max-w-3xl text-5xl font-black leading-tight tracking-tight text-ink sm:text-6xl">
              İhtiyacını yaz, doğru teklifleri al, işini güvenle çözüme ulaştır.
            </h1>
            <p className="mt-6 max-w-2xl text-lg leading-8 text-slate-600">
              Ben Yaparım ile ev yemeğinden organizasyona, taşımadan tasarıma kadar aradığın hizmete hızlıca ulaş.
              İlan ver, teklifleri karşılaştır, mesajlaş ve sana en uygun kişiyle kolayca buluş.
            </p>
            <div className="mt-8">
              <DownloadButtons />
            </div>

            <div className="mt-10 grid gap-4 sm:grid-cols-2">
              <div className="glass-card rounded-4xl p-5">
                <p className="text-sm font-black text-ink">Android QR</p>
                <Image src="/qr/android.svg" alt="Android QR" width={132} height={132} className="mt-4" />
              </div>
              <div className="glass-card rounded-4xl p-5">
                <p className="text-sm font-black text-ink">iPhone QR</p>
                <Image src="/qr/ios.svg" alt="iPhone QR" width={132} height={132} className="mt-4" />
              </div>
            </div>
          </div>

          <div className="grid items-start gap-6 md:grid-cols-2 lg:grid-cols-1 xl:grid-cols-2">
            <PhoneMockup
              title="Teklifleri karşılaştır"
              subtitle="Yerel hizmet verenlerle hızlı eşleş"
              image="/screens/request-feed.png"
              accent="bg-plum-500"
            />
            <PhoneMockup
              title="Hazır yemekleri keşfet"
              subtitle="Sipariş ve mesaj akışı tek yerde"
              image="/screens/food-card.jpg"
              accent="bg-aqua"
            />
          </div>
        </div>
      </section>

      <section className="section-shell py-20">
        <SectionIntro
          eyebrow="Nasıl Çalışır"
          title="İhtiyacını paylaş, gerisini doğru eşleşmeler kolaylaştırsın."
          copy="Ben Yaparım, talep oluşturmaktan teklif toplamaya ve iletişimi sürdürmeye kadar tüm süreci mobilde akıcı hale getirir."
        />
        <div className="mt-10 grid gap-5 md:grid-cols-2 xl:grid-cols-4">
          {steps.map((step, index) => (
            <article key={step.title} className="glass-card rounded-4xl p-6">
              <div className="inline-flex h-12 w-12 items-center justify-center rounded-full bg-plum-700 text-lg font-black text-white">
                0{index + 1}
              </div>
              <h3 className="mt-5 text-xl font-black text-ink">{step.title}</h3>
              <p className="mt-3 text-sm leading-6 text-slate-600">{step.copy}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section-shell py-10">
        <div className="glass-card rounded-[2.5rem] p-6 sm:p-8">
          <SectionIntro
            eyebrow="Kategoriler"
            title="Tek bir ihtiyaç için değil, hayatın farklı anları için tasarlandı."
            copy="Ev davetlerinden günlük ihtiyaçlara, yaratıcı işlerden hazır yemek siparişine kadar farklı beklentileri tek platformda bir araya getirir."
          />
          <div className="mt-8 grid gap-4 md:grid-cols-2 xl:grid-cols-4">
            {categories.map((category, index) => (
              <div
                key={category}
                className="rounded-4xl border border-white/70 bg-white p-5 shadow-sm transition hover:-translate-y-1"
              >
                <p className="text-sm font-black uppercase tracking-[0.18em] text-plum-500">0{index + 1}</p>
                <h3 className="mt-4 text-2xl font-black text-ink">{category}</h3>
                <p className="mt-3 text-sm leading-6 text-slate-600">
                  İhtiyacını paylaş, sana uygun hizmet verenlerle hızlıca bağlantı kur ve süreci tek yerden yönet.
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="section-shell py-20">
        <SectionIntro
          eyebrow="Uygulama Deneyimi"
          title="Sıcak, pratik ve güven veren bir mobil deneyim."
          copy="Talep oluşturma, teklif değerlendirme ve mesajlaşma akışı; tek elde rahat kullanıma ve hızlı karar almaya göre tasarlandı."
        />
        <div className="mt-10 grid items-start gap-5 lg:grid-cols-3">
          <div className="glass-card rounded-4xl p-4">
            <Image
              src="/screens/request-feed.png"
              alt="Talep akışı"
              width={720}
              height={1080}
              className="mx-auto aspect-[9/16] w-full max-w-[19rem] rounded-[2rem] border-[10px] border-[#1e1330] bg-slate-100 object-cover object-top shadow-glow"
            />
          </div>
          <div className="glass-card rounded-4xl p-4">
            <Image
              src="/screens/food-card.jpg"
              alt="Hazır yemekler"
              width={720}
              height={1080}
              className="mx-auto aspect-[9/16] w-full max-w-[19rem] rounded-[2rem] border-[10px] border-[#1e1330] bg-slate-100 object-cover object-top shadow-glow"
            />
          </div>
          <div className="glass-card rounded-4xl p-4">
            <div className="flex h-full min-h-[24rem] flex-col justify-between rounded-[1.75rem] bg-gradient-to-br from-plum-700 via-plum-600 to-aqua p-6 text-white">
              <div>
                <p className="text-xs font-black uppercase tracking-[0.24em] text-white/75">Mesajlaşma</p>
                <h3 className="mt-4 text-3xl font-black">Detayları kaybetmeden iletişimde kal.</h3>
              </div>
              <div className="space-y-3">
                <div className="ml-auto max-w-[80%] rounded-[1.5rem] rounded-br-md bg-white/20 p-4 text-sm">
                  Yarın 16.00 teslim mümkün mü?
                </div>
                <div className="max-w-[80%] rounded-[1.5rem] rounded-bl-md bg-white p-4 text-sm text-ink">
                  Evet, teslim ve sunum detaylarını birlikte netleştirebiliriz.
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="section-shell py-10">
        <div className="grid gap-5 lg:grid-cols-3">
          {trustPoints.map((point) => (
            <article key={point.title} className="glass-card rounded-4xl p-6">
              <h3 className="text-2xl font-black text-ink">{point.title}</h3>
              <p className="mt-3 text-sm leading-7 text-slate-600">{point.copy}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section-shell pt-16">
        <div className="rounded-[2.5rem] bg-ink px-6 py-10 text-white sm:px-10">
          <p className="text-xs font-black uppercase tracking-[0.24em] text-sun">Hazırsan başlayalım</p>
          <div className="mt-4 flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
            <div>
              <h2 className="max-w-2xl text-4xl font-black">Ben Yaparım ile ihtiyacını doğru kişiyle bugün buluştur.</h2>
              <p className="mt-3 max-w-2xl text-base leading-7 text-white/75">
                Android ve iPhone için indirme adımlarını, destek kanallarını ve tüm temel bilgi sayfalarını senin için hazırladık.
              </p>
            </div>
            <Link
              href="/download"
              className="rounded-full bg-white px-6 py-4 text-sm font-bold text-ink transition hover:bg-cream"
            >
              İndirme sayfasına git
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
