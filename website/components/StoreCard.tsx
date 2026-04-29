import Image from "next/image";

type StoreCardProps = {
  id: string;
  platform: string;
  buttonLabel: string;
  href: string;
  qrSrc: string;
  note: string;
};

export function StoreCard({ id, platform, buttonLabel, href, qrSrc, note }: StoreCardProps) {
  const isActive = Boolean(href);

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

          {isActive ? (
            <a
              href={href}
              target="_blank"
              rel="noreferrer"
              className="mt-6 inline-flex rounded-full bg-plum-700 px-5 py-3 text-sm font-bold text-white transition hover:bg-plum-800"
            >
              {buttonLabel}
            </a>
          ) : (
            <span className="mt-6 inline-flex cursor-not-allowed rounded-full border border-plum-200 bg-white px-5 py-3 text-sm font-bold text-plum-800 opacity-60">
              {buttonLabel}
            </span>
          )}
        </div>

        <div className="rounded-[2rem] border border-plum-100 bg-white p-5 text-center">
          <Image src={qrSrc} alt={`${platform} QR kodu`} width={180} height={180} className="mx-auto" />
          <p className="mt-4 text-sm font-semibold text-slate-600">
            {isActive ? "Telefonundan QR okut, uygulamayı hemen indir." : "Bu platform için mağaza bağlantısı yayınlandığında burada aktif olacak."}
          </p>
        </div>
      </div>
    </section>
  );
}
