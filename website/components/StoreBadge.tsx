import Image from "next/image";

type StoreBadgeProps = {
  href?: string;
  label: string;
  badgeSrc: string;
  alt: string;
};

export function StoreBadge({ href, label, badgeSrc, alt }: StoreBadgeProps) {
  const badge = (
    <span className="inline-flex overflow-hidden rounded-[1.15rem] border border-slate-200/80 bg-white p-1 shadow-[0_14px_35px_rgba(32,21,47,0.08)] transition duration-200 hover:-translate-y-0.5 hover:shadow-[0_20px_45px_rgba(32,21,47,0.12)]">
      <Image src={badgeSrc} alt={alt} width={220} height={68} className="h-[54px] w-auto rounded-[0.9rem]" />
    </span>
  );

  if (!href) {
    return (
      <span aria-disabled="true" className="cursor-not-allowed opacity-60" title={label}>
        {badge}
      </span>
    );
  }

  return (
    <a href={href} target="_blank" rel="noreferrer" title={label}>
      {badge}
    </a>
  );
}
