import Link from "next/link";
import { siteConfig } from "@/components/site-config";

export function DownloadButtons() {
  return (
    <div className="flex flex-col gap-3 sm:flex-row">
      <Link
        href={siteConfig.appLinks.android}
        className="rounded-full bg-plum-700 px-6 py-4 text-center text-sm font-bold text-white transition hover:bg-plum-800"
      >
        Android için indir
      </Link>
      <Link
        href={siteConfig.appLinks.ios}
        className="rounded-full border border-plum-200 bg-white px-6 py-4 text-center text-sm font-bold text-plum-800 transition hover:border-plum-400 hover:bg-plum-50"
      >
        iPhone için indir
      </Link>
    </div>
  );
}
