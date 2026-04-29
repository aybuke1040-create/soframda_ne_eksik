import Image from "next/image";

type PhoneMockupProps = {
  title: string;
  subtitle: string;
  image: string;
  accent: string;
};

export function PhoneMockup({ title, subtitle, image, accent }: PhoneMockupProps) {
  return (
    <div className="mx-auto aspect-[9/16] w-full max-w-[19rem] overflow-hidden rounded-[2.5rem] border border-white/70 bg-[#1e1330] p-3 shadow-glow">
      <div className="flex h-full flex-col rounded-[2rem] bg-white p-4">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm font-black text-ink">{title}</p>
            <p className="text-xs text-slate-500">{subtitle}</p>
          </div>
          <div className={`h-3 w-16 rounded-full ${accent}`} />
        </div>

        <div className="relative mt-4 min-h-0 flex-1 overflow-hidden rounded-[1.5rem] border border-slate-100 bg-slate-100">
          <Image src={image} alt={title} width={420} height={746} className="h-full w-full object-cover object-top" />
        </div>

        <div className="mt-3 grid grid-cols-2 gap-2">
          <div className="rounded-2xl bg-aqua/10 p-2">
            <p className="text-[11px] font-bold text-aqua">3 teklif</p>
            <p className="mt-0.5 text-[10px] text-slate-500">Hızlı dönüş</p>
          </div>
          <div className="rounded-2xl bg-sun/15 p-2">
            <p className="text-[11px] font-bold text-amber-700">Mesajlaşma</p>
            <p className="mt-0.5 text-[10px] text-slate-500">Tek yerde</p>
          </div>
        </div>
      </div>
    </div>
  );
}
