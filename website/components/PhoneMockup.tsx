import Image from "next/image";

type PhoneMockupProps = {
  title: string;
  subtitle: string;
  image: string;
  accent: string;
};

export function PhoneMockup({ title, subtitle, image, accent }: PhoneMockupProps) {
  return (
    <div className="rounded-[2.5rem] border border-white/70 bg-[#1e1330] p-3 shadow-glow">
      <div className="rounded-[2rem] bg-white p-4">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm font-black text-ink">{title}</p>
            <p className="text-xs text-slate-500">{subtitle}</p>
          </div>
          <div className={`h-3 w-16 rounded-full ${accent}`} />
        </div>
        <div className="mt-4 overflow-hidden rounded-[1.5rem] border border-slate-100">
          <Image src={image} alt={title} width={420} height={640} className="h-[22rem] w-full object-cover" />
        </div>
        <div className="mt-4 space-y-3">
          <div className="rounded-3xl bg-plum-50 p-3">
            <p className="text-xs font-bold text-plum-800">İlan özeti</p>
            <p className="mt-1 text-xs leading-5 text-slate-600">
              Ev daveti için ikramlık, özenli sunum ve hızlı teslim arıyorum.
            </p>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div className="rounded-3xl bg-aqua/10 p-3">
              <p className="text-xs font-bold text-aqua">3 teklif</p>
              <p className="mt-1 text-xs text-slate-500">Kısa sürede geri dönüş</p>
            </div>
            <div className="rounded-3xl bg-sun/15 p-3">
              <p className="text-xs font-bold text-amber-700">Mesajlaşma</p>
              <p className="mt-1 text-xs text-slate-500">Tüm detaylar tek yerde</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
