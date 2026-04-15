import type { Metadata } from "next";
import "./globals.css";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { siteConfig } from "@/components/site-config";

export const metadata: Metadata = {
  metadataBase: new URL(siteConfig.domain),
  title: {
    default: "Ben Yaparım | Mahallendeki yemek, ikram ve organizasyon işleri",
    template: "%s | Ben Yaparım"
  },
  description:
    "Mahallendeki yemek, ikram, taşıma ve organizasyon ihtiyaçların için ilan ver, teklif al, mesajlaş ve doğru kişiyle buluş.",
  applicationName: "Ben Yaparım",
  keywords: [
    "Ben Yaparım",
    "ev yemeği",
    "ikramlık sipariş",
    "organizasyon hizmetleri",
    "hazır yemek",
    "taşıma hizmeti",
    "yerel hizmet verenler"
  ],
  authors: [{ name: "Ben Yaparım" }],
  creator: "Ben Yaparım",
  publisher: "Ben Yaparım",
  alternates: {
    canonical: "/"
  },
  openGraph: {
    type: "website",
    locale: "tr_TR",
    url: siteConfig.domain,
    siteName: "Ben Yaparım",
    title: "Ben Yaparım | Mahallendeki yemek, ikram ve organizasyon işleri",
    description:
      "İhtiyacını yaz, teklifleri karşılaştır, mesajlaş ve doğru kişiyle kolayca buluş.",
    images: [
      {
        url: "/screens/request-feed.png",
        width: 1200,
        height: 630,
        alt: "Ben Yaparım uygulama önizlemesi"
      }
    ]
  },
  twitter: {
    card: "summary_large_image",
    title: "Ben Yaparım",
    description:
      "Mahallendeki yemek, ikram ve organizasyon ihtiyaçların için teklif al ve doğru kişiyle buluş.",
    images: ["/screens/request-feed.png"]
  },
  icons: {
    icon: "/brand/logo.png",
    shortcut: "/brand/logo.png",
    apple: "/brand/logo.png"
  },
  manifest: "/manifest.webmanifest",
  robots: {
    index: true,
    follow: true
  }
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="tr">
      <body>
        <Header />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}
