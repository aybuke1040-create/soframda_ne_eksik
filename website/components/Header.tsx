import Link from "next/link";
import Image from "next/image";
import { siteConfig } from "@/components/site-config";

export function Header() {
  return (
    <header className="sticky top-0 z-40 border-b border-white/50 bg-white/78 backdrop-blur-2xl">
      <div className="section-shell flex items-center justify-between gap-4 py-3 sm:py-4">
        <Link href="/" className="flex min-w-0 items-center gap-3">
          <div className="relative h-[60px] w-[60px] overflow-hidden rounded-full shadow-glow ring-2 ring-white/80">
            <Image
              src="/brand/logo.png"
              alt="Ben Yaparım logosu"
              fill
              priority
              className="scale-[1.08] object-cover"
              sizes="60px"
            />
          </div>
          <div className="min-w-0">
            <div className="truncate text-sm font-black uppercase tracking-[0.24em] text-plum-700 sm:text-base">
              Ben Yaparım
            </div>
            <div className="hidden truncate text-xs text-slate-500 sm:block">
              Mahallendeki işler için hızlı ve güvenli eşleşme
            </div>
          </div>
        </Link>

        <nav className="hidden items-center gap-5 lg:flex">
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
          className="shrink-0 rounded-full bg-plum-700 px-4 py-2.5 text-sm font-bold text-white transition hover:bg-plum-800 sm:px-5 sm:py-3"
        >
          Uygulamayı İndir
        </Link>
      </div>
    </header>
  );
}
