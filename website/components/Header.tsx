import Link from "next/link";
import Image from "next/image";
import {siteConfig} from "@/components/site-config";

export function Header() {
  return (
    <header className="sticky top-0 z-40 border-b border-white/40 bg-white/70 backdrop-blur-xl">
      <div className="section-shell flex items-center justify-between gap-4 py-4">
        <Link href="/" className="flex items-center gap-3">
          <div className="rounded-3xl bg-white p-2 shadow-glow">
            <Image
              src="/brand/logo.png"
              alt="Ben Yaparim logosu"
              width={44}
              height={44}
              priority
            />
          </div>
          <div>
            <div className="text-sm font-black uppercase tracking-[0.24em] text-plum-700">
              Ben Yaparim
            </div>
            <div className="text-xs text-slate-500">
              Mahallendeki isler icin hizli ve guvenli eslesme
            </div>
          </div>
        </Link>

        <nav className="hidden items-center gap-6 md:flex">
          {siteConfig.nav.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="text-sm font-semibold text-slate-700 transition hover:text-plum-700"
            >
              {item.label}
            </Link>
          ))}
        </nav>

        <Link
          href="/download"
          className="rounded-full bg-plum-700 px-5 py-3 text-sm font-bold text-white transition hover:bg-plum-800"
        >
          Uygulamayi Indir
        </Link>
      </div>
    </header>
  );
}
