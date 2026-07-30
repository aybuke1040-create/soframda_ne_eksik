import type { MetadataRoute } from "next";
import { landingPages } from "@/components/landing-pages";
import { siteConfig } from "@/components/site-config";

export default function sitemap(): MetadataRoute.Sitemap {
  const staticRoutes = ["/", "/hizmetler", "/download", "/privacy", "/support", "/terms", "/delete-account"];
  const categoryRoutes = landingPages.map((page) => `/hizmetler/${page.slug}`);
  const routes = [...staticRoutes, ...categoryRoutes];

  return routes.map((route) => ({
    url: `${siteConfig.domain}${route}`,
    lastModified: new Date(),
    changeFrequency: route === "/" || route.startsWith("/hizmetler") ? "weekly" : "monthly",
    priority: route === "/" ? 1 : route === "/hizmetler" ? 0.9 : route.startsWith("/hizmetler/") ? 0.85 : 0.7
  }));
}
