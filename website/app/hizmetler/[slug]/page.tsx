import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { DownloadButtons } from "@/components/DownloadButtons";
import { landingPageBySlug, landingPages } from "@/components/landing-pages";
import { siteConfig } from "@/components/site-config";

type PageProps = { params: { slug: string } };

export function generateStaticParams() {
  return landingPages.map((page) => ({ slug: page.slug }));
}

export function generateMetadata({ params }: PageProps): Metadata {
  const page = landingPageBySlug[params.slug];
  if (!page) return {};
  const canonicalPath = `/hizmetler/${page.slug}`;
  return {
    title: page.metaTitle,
    description: page.metaDescription,
    keywords: [
      page.name,
      `${page.name} hizmeti`,
      `${page.name} teklifi`,
      `yakınımdaki ${page.name.toLocaleLowerCase("tr-TR")}`,
      "Ben Yaparım"
    ],
    alternates: { canonical: canonicalPath },
    openGraph: {
      type: "article",
      locale: "tr_TR",
      url: `${siteConfig.domain}${canonicalPath}`,
      title: page.metaTitle,
      description: page.metaDescription,
      siteName: siteConfig.name
    },
    twitter: {
      card: "summary",
      title: page.metaTitle,
      description: page.metaDescription
    }
  };
}

export default function ServiceLandingPage({ params }: PageProps) {
  const page = landingPageBySlug[params.slug];
  if (!page) notFound();

  const pageUrl = `${siteConfig.domain}/hizmetler/${page.slug}`;
  const schemas = [
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      itemListElement: [
        { "@type": "ListItem", position: 1, name: "Ana Sayfa", item: siteConfig.domain },
        {
          "@type": "ListItem",
          position: 2,
          name: "Hizmetler",
          item: `${siteConfig.domain}/hizmetler`
        },
        { "@type": "ListItem", position: 3, name: page.name, item: pageUrl }
      ]
    },
    {
      "@context": "https://schema.org",
      "@type": "Service",
      name: `${page.name} ihtiyaçları için yerel eşleşme`,
      serviceType: page.name,
      description: page.metaDescription,
      areaServed: { "@type": "Country", name: "Türkiye" },
      provider: { "@type": "Organization", name: siteConfig.name, url: siteConfig.domain },
      url: pageUrl
    },
    {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      mainEntity: page.faqs.map((faq) => ({
        "@type": "Question",
        name: faq.question,
        acceptedAnswer: { "@type": "Answer", text: faq.answer }
      }))
    }
  ];

  return (
    <div className="pb-20">
      {schemas.map((schema, index) => (
        <script
          key={index}
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
        />
      ))}
      <section className="mesh">
        <div className="section-shell py-14 sm:py-20">
          <nav aria-label="İçerik yolu" className="text-sm font-semibold text-slate-600">
            <Link href="/" className="hover:text-plum-700">Ana Sayfa</Link>
            <span aria-hidden="true"> / </span>
            <Link href="/hizmetler" className="hover:text-plum-700">Hizmetler</Link>
            <span aria-hidden="true"> / {page.name}</span>
          </nav>
          <div className="mt-10 max-w-4xl">
            <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">
              {page.eyebrow}
            </p>
            <h1 className="mt-5 text-4xl font-black leading-tight tracking-tight text-ink sm:text-6xl">
              {page.headline}
            </h1>
            <p className="mt-6 max-w-3xl text-lg leading-8 text-slate-600">{page.summary}</p>
            <div className="mt-8"><DownloadButtons /></div>
          </div>
        </div>
      </section>

      <section className="section-shell py-16">
        <div className="rounded-[2.5rem] bg-ink p-7 text-white sm:p-10">
          <p className="text-xs font-black uppercase tracking-[0.22em] text-sun">Kısa cevap</p>
          <h2 className="mt-4 text-3xl font-black">{page.name} ihtiyacı nasıl karşılanır?</h2>
          <p className="mt-4 max-w-4xl text-base leading-8 text-white/80">{page.intentAnswer}</p>
        </div>
      </section>

      <section className="section-shell py-8">
        <div className="grid gap-5 lg:grid-cols-2">
          <div className="glass-card rounded-4xl p-7">
            <h2 className="text-3xl font-black text-ink">Ben Yaparım ile neler yapabilirsin?</h2>
            <ul className="mt-6 space-y-4">
              {page.highlights.map((item) => (
                <li key={item} className="flex gap-3 text-sm leading-7 text-slate-600">
                  <span aria-hidden="true" className="mt-2 h-2 w-2 shrink-0 rounded-full bg-aqua" />
                  {item}
                </li>
              ))}
            </ul>
          </div>
          <div className="glass-card rounded-4xl p-7">
            <h2 className="text-3xl font-black text-ink">Hangi ihtiyaçlar için kullanılabilir?</h2>
            <ul className="mt-6 space-y-4">
              {page.useCases.map((item) => (
                <li key={item} className="flex gap-3 text-sm leading-7 text-slate-600">
                  <span aria-hidden="true" className="mt-2 h-2 w-2 shrink-0 rounded-full bg-plum-500" />
                  {item}
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      <section className="section-shell py-16">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">Adım adım</p>
        <h2 className="mt-4 text-4xl font-black text-ink">Daha doğru teklif almak için süreç</h2>
        <div className="mt-8 grid gap-5 lg:grid-cols-3">
          {page.steps.map((step, index) => (
            <article key={step.title} className="glass-card rounded-4xl p-7">
              <span className="inline-flex h-11 w-11 items-center justify-center rounded-full bg-plum-700 font-black text-white">
                {index + 1}
              </span>
              <h3 className="mt-5 text-2xl font-black text-ink">{step.title}</h3>
              <p className="mt-3 text-sm leading-7 text-slate-600">{step.copy}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section-shell py-12">
        <div className="max-w-3xl">
          <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">
            Uzun kuyruklu sorular
          </p>
          <h2 className="mt-4 text-4xl font-black text-ink">
            {page.name} hakkında sık aranan sorular
          </h2>
          <p className="mt-4 text-base leading-8 text-slate-600">
            Karar vermeden önce fiyatı etkileyen unsurları, teklif kapsamını ve teslim
            koşullarını açıkça konuş. Ben Yaparım hizmeti doğrudan sunmaz; kullanıcıların
            ilan, teklif ve mesajlaşma yoluyla bağlantı kurmasını kolaylaştırır.
          </p>
        </div>
        <div className="mt-8 grid gap-5 lg:grid-cols-2">
          {page.faqs.map((faq) => (
            <article key={faq.question} className="glass-card rounded-4xl p-7">
              <h3 className="text-xl font-black text-ink">{faq.question}</h3>
              <p className="mt-3 text-sm leading-7 text-slate-600">{faq.answer}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section-shell pt-12">
        <div className="rounded-[2.5rem] bg-gradient-to-br from-plum-700 to-plum-500 px-7 py-10 text-white sm:px-10">
          <h2 className="text-3xl font-black">{page.name} ihtiyacını şimdi paylaş.</h2>
          <p className="mt-3 max-w-2xl leading-7 text-white/80">
            Uygulamayı indir, ilanını oluştur ve yakınındaki uygun kişilerden teklif almaya başla.
          </p>
          <div className="mt-7"><DownloadButtons /></div>
        </div>
      </section>
    </div>
  );
}
