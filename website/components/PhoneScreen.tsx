import Image from "next/image";

type PhoneScreenProps = {
  src: string;
  alt: string;
};

export function PhoneScreen({ src, alt }: PhoneScreenProps) {
  return (
    <div className="mx-auto aspect-[9/16] w-full max-w-[19rem] overflow-hidden rounded-[2.5rem] border border-white/70 bg-[#1e1330] p-3 shadow-glow">
      <div className="h-full overflow-hidden rounded-[2rem] bg-white p-3">
        <div className="h-full overflow-hidden rounded-[1.5rem] border border-slate-100 bg-slate-100">
          <Image src={src} alt={alt} width={420} height={746} className="h-full w-full object-cover object-top" />
        </div>
      </div>
    </div>
  );
}
