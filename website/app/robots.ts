import type { MetadataRoute } from "next";
import { siteConfig } from "@/components/site-config";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      disallow: ["/login", "/messages"]
    },
    sitemap: `${siteConfig.domain}/sitemap.xml`
  };
}
