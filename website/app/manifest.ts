import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Ben Yaparım",
    short_name: "Ben Yaparım",
    description:
      "Mahallendeki yemek, ikram ve organizasyon işleri için ilan ver, teklif al ve mesajlaş.",
    start_url: "/",
    display: "standalone",
    background_color: "#fffdf9",
    theme_color: "#7b32d4",
    lang: "tr",
    icons: [
      {
        src: "/brand/logo.png",
        sizes: "192x192",
        type: "image/png"
      },
      {
        src: "/brand/logo.png",
        sizes: "512x512",
        type: "image/png"
      }
    ]
  };
}
