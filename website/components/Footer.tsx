import Link from "next/link";
import {siteConfig} from "@/components/site-config";

export function Footer() {
  return (
    <footer className="border-t border-plum-100 bg-white/80">
      <div className="section-shell flex flex-col gap-6 py-10 sm:flex-row sm:items-end sm:justify-between">
        <div className="max-w-md">
          <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">
            Ben Yaparim
          </p>
          <h2 className="mt-3 text-2xl font-black text-ink">
            Yemekten organizasyona, ihtiyacini yaz ve dogru kisiyle hizla bulus.
          </h2>
          <p className="mt-3 text-sm leading-6 text-slate-600">
            Ister ev yemegi, ister organizasyon, ister tasima. Ihtiyacini paylas,
            dogru kisiler sana kolayca ulassin. Topluluk kurallari, sikayet ve
            engelleme mekanizmalariyla guvenli bir deneyim sunmayi hedefliyoruz.
          </p>
        </div>

        <div className="flex flex-col gap-3 text-sm font-semibold text-slate-600">
          {siteConfig.footerNav.map((item) => (
            <Link key={item.href} href={item.href} className="transition hover:text-plum-700">
              {item.label}
            </Link>
          ))}
          <a href={`mailto:${siteConfig.supportEmail}`} className="transition hover:text-plum-700">
            {siteConfig.supportEmail}
          </a>
        </div>
      </div>
    </footer>
  );
}
