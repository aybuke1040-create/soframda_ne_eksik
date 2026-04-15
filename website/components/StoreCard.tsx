import Image from "next/image";
import Link from "next/link";

type StoreCardProps = {
  id: string;
  platform: string;
  buttonLabel: string;
  href: string;
  qrSrc: string;
  note: string;
};

export function StoreCard({ id, platform, buttonLabel, href, qrSrc, note }: StoreCardProps) {
  return (
    <section
      id={id}
      className="glass-card rounded-4xl p-6 shadow-glow transition hover:-translate-y-1 sm:p-8"
    >
      <div className="flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
        <div className="max-w-xl">
          <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">{platform}</p>
          <h2 className="mt-3 text-3xl font-black text-ink">{platform} için hızlı kurulum</h2>
          <p className="mt-3 text-base leading-7 text-slate-600">{note}</p>
          <Link
            href={href}
            className="mt-6 inline-flex rounded-full bg-plum-700 px-5 py-3 text-sm font-bold text-white transition hover:bg-plum-800"
          >
            {buttonLabel}
          </Link>
        </div>

        <div className="rounded-[2rem] border border-plum-100 bg-white p-5 text-center">
          <Image src={qrSrc} alt={`${platform} QR kodu`} width={180} height={180} className="mx-auto" />
          <p className="mt-4 text-sm font-semibold text-slate-600">Telefonundan QR okut, uygulamayı hemen indir.</p>
        </div>
      </div>
    </section>
  );
}
