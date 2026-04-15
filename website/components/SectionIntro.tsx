type SectionIntroProps = {
  eyebrow: string;
  title: string;
  copy: string;
};

export function SectionIntro({ eyebrow, title, copy }: SectionIntroProps) {
  return (
    <div className="max-w-3xl">
      <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">{eyebrow}</p>
      <h2 className="section-title mt-3">{title}</h2>
      <p className="section-copy mt-4">{copy}</p>
    </div>
  );
}
