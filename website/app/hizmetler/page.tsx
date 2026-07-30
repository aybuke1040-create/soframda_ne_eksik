import type { Metadata } from "next";
import Link from "next/link";
import { landingPages } from "@/components/landing-pages";
import { siteConfig } from "@/components/site-config";

export const metadata: Metadata = {
  title: "Yerel Hizmetler: Yemek, Taşıma ve Organizasyon",
  description:
    "Ev yemeği, küçük taşıma, organizasyon, pasta ve ikramlık ihtiyaçları için Ben Yaparım kategori rehberlerini incele.",
  alternates: { canonical: "/hizmetler" },
  openGraph: {
    title: "Yerel Hizmetler | Ben Yaparım",
    description:
      "Ev yemeğinden küçük taşımaya, organizasyondan ikramlığa kadar yerel hizmet rehberleri.",
    url: `${siteConfig.domain}/hizmetler`
  }
};

export default function ServicesPage() {
  const itemListSchema = {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "Ben Yaparım yerel hizmet kategorileri",
    itemListElement: landingPages.map((page, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: page.name,
      url: `${siteConfig.domain}/hizmetler/${page.slug}`
    }))
  };

  return (
    <div className="section-shell py-16 sm:py-20">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(itemListSchema) }}
      />
      <div className="max-w-3xl">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">
          Hizmet rehberleri
        </p>
        <h1 className="mt-4 text-4xl font-black tracking-tight text-ink sm:text-6xl">
          İhtiyacına uygun yerel hizmet kategorisini keşfet.
        </h1>
        <p className="mt-6 text-lg leading-8 text-slate-600">
          Ne aradığını daha iyi tarif etmek, doğru ilanı oluşturmak ve teklifleri
          karşılaştırmak için kategori rehberlerimizi incele.
        </p>
      </div>
      <div className="mt-12 grid gap-5 md:grid-cols-2">
        {landingPages.map((page) => (
          <article key={page.slug} className="glass-card rounded-4xl p-7">
            <p className="text-xs font-black uppercase tracking-[0.2em] text-plum-500">
              {page.eyebrow}
            </p>
            <h2 className="mt-4 text-3xl font-black text-ink">{page.name}</h2>
            <p className="mt-4 text-sm leading-7 text-slate-600">{page.summary}</p>
            <Link
              href={`/hizmetler/${page.slug}`}
              className="mt-6 inline-flex rounded-full bg-plum-700 px-5 py-3 text-sm font-bold text-white transition hover:bg-plum-800"
            >
              {page.name} rehberini incele
            </Link>
          </article>
        ))}
      </div>
    </div>
  );
}
