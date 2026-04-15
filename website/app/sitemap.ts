import type { MetadataRoute } from "next";
import { siteConfig } from "@/components/site-config";

export default function sitemap(): MetadataRoute.Sitemap {
  const routes = ["/", "/download", "/privacy", "/support", "/delete-account"];

  return routes.map((route) => ({
    url: `${siteConfig.domain}${route}`,
    lastModified: new Date(),
    changeFrequency: route === "/" ? "weekly" : "monthly",
    priority: route === "/" ? 1 : 0.7
  }));
}
