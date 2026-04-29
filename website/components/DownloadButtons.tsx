import { siteConfig } from "@/components/site-config";

function StoreButton({
  href,
  label,
  variant = "primary"
}: {
  href?: string;
  label: string;
  variant?: "primary" | "secondary";
}) {
  const classes =
    variant === "primary"
      ? "rounded-full bg-plum-700 px-6 py-4 text-center text-sm font-bold text-white transition hover:bg-plum-800"
      : "rounded-full border border-plum-200 bg-white px-6 py-4 text-center text-sm font-bold text-plum-800 transition hover:border-plum-400 hover:bg-plum-50";

  if (!href) {
    return (
      <span
        aria-disabled="true"
        className={`${classes} cursor-not-allowed opacity-60 hover:border-plum-200 hover:bg-white`}
      >
        {label}
      </span>
    );
  }

  return (
    <a href={href} target="_blank" rel="noreferrer" className={classes}>
      {label}
    </a>
  );
}

export function DownloadButtons() {
  return (
    <div className="flex flex-col gap-3 sm:flex-row">
      <StoreButton href={siteConfig.appLinks.android} label="Android için indir" variant="primary" />
      <StoreButton href={siteConfig.appLinks.ios || undefined} label="iPhone sürümü yakında" variant="secondary" />
    </div>
  );
}
