import { siteConfig } from "@/components/site-config";
import { StoreBadge } from "@/components/StoreBadge";

export function DownloadButtons() {
  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:flex-wrap sm:items-center">
      <StoreBadge
        href={siteConfig.appLinks.android || undefined}
        label="Google Play üzerinden indir"
        badgeSrc="/badges/google-play.svg"
        alt="Google Play'den indirin"
      />
      <StoreBadge
        href={siteConfig.appLinks.ios || undefined}
        label="App Store üzerinden indir"
        badgeSrc="/badges/app-store.svg"
        alt="App Store'dan indirin"
      />
    </div>
  );
}
