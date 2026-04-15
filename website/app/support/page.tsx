import type { Metadata } from "next";
import { SupportForm } from "@/components/SupportForm";
import { faqs, siteConfig } from "@/components/site-config";

export const metadata: Metadata = {
  title: "Destek",
  alternates: {
    canonical: "/support"
  }
};

export default function SupportPage() {
  return (
    <div className="section-shell py-16 sm:py-20">
      <div className="max-w-3xl">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">Support</p>
        <h1 className="mt-3 text-4xl font-black tracking-tight text-ink sm:text-5xl">İhtiyacın olduğunda destek burada</h1>
        <p className="mt-5 text-lg leading-8 text-slate-600">
          Hesap, teklifler, siparişler veya bildirimlerle ilgili yardıma ihtiyaç duyduğunda bize kolayca ulaşabilirsin.
          Sorunları hızlı, net ve çözüm odaklı şekilde ele alıyoruz.
        </p>
      </div>

      <div className="mt-10 grid gap-6 lg:grid-cols-[1.05fr_.95fr]">
        <SupportForm />

        <div className="glass-card rounded-4xl p-6 sm:p-8">
          <h2 className="text-2xl font-black text-ink">Destek e-postası</h2>
          <a href={`mailto:${siteConfig.supportEmail}`} className="mt-4 inline-block text-lg font-bold text-plum-700">
            {siteConfig.supportEmail}
          </a>

          <div className="mt-8">
            <h2 className="text-2xl font-black text-ink">Sık sorulan sorular</h2>
            <div className="mt-4 space-y-4">
              {faqs.map((faq) => (
                <details key={faq.question} className="rounded-3xl bg-white p-4">
                  <summary className="cursor-pointer list-none text-base font-bold text-ink">{faq.question}</summary>
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
