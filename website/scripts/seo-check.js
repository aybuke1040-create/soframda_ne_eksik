const fs = require("fs");
const https = require("https");
const path = require("path");

const root = process.cwd();

function mark(ok) {
  return ok ? "[OK]" : "[FAIL]";
}

function read(relativePath) {
  return fs.readFileSync(path.join(root, relativePath), "utf8");
}

function exists(relativePath) {
  return fs.existsSync(path.join(root, relativePath));
}

function extract(source, pattern) {
  const match = source.match(pattern);
  return match ? match[1] : "";
}

function request(url) {
  return new Promise((resolve) => {
    https
      .get(
        url,
        {
          timeout: 15000,
          headers: {
            "User-Agent": "BenYaparimSeoCheck/1.0"
          }
        },
        (response) => {
          let body = "";

          response.on("data", (chunk) => {
            body += chunk.toString("utf8");
          });

          response.on("end", () => {
            resolve({
              ok: response.statusCode >= 200 && response.statusCode < 400,
              status: response.statusCode,
              headers: response.headers,
              body,
              url
            });
          });
        }
      )
      .on("error", (error) => {
        resolve({
          ok: false,
          status: "ERR",
          body: "",
          headers: {},
          error: error.message,
          url
        });
      });
  });
}

function result(label, ok, details = "") {
  console.log(`${mark(ok)} ${label}${details ? ` - ${details}` : ""}`);
  return ok ? 0 : 1;
}

function getConfig() {
  const config = read("components/site-config.ts");
  return {
    domain: extract(config, /domain:\s*"([^"]+)"/),
    supportEmail: extract(config, /supportEmail:\s*"([^"]+)"/)
  };
}

function localSeoChecks(config) {
  console.log("Yerel SEO dosya kontrolleri:");

  const layout = read("app/layout.tsx");
  const page = read("app/page.tsx");
  const robots = read("app/robots.ts");
  const sitemap = read("app/sitemap.ts");
  const manifest = read("app/manifest.ts");

  let failed = 0;

  failed += result("Domain HTTPS kullanıyor", config.domain.startsWith("https://"), config.domain);
  failed += result("Domain benyaparimci.com içeriyor", config.domain.includes("benyaparimci.com"));
  failed += result("Destek e-postası tanımlı", /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(config.supportEmail));
  failed += result("Root metadata title var", layout.includes("title:"));
  failed += result("Root metadata description var", layout.includes("description:"));
  failed += result("Keywords tanımlı", layout.includes("keywords"));
  failed += result("Open Graph tanımlı", layout.includes("openGraph"));
  failed += result("Twitter card tanımlı", layout.includes("twitter"));
  failed += result("Canonical tanımlı", layout.includes("canonical"));
  failed += result("Robots index/follow açık", layout.includes("index: true") && layout.includes("follow: true"));
  failed += result("Manifest bağlı", layout.includes("manifest"));
  failed += result("Organization schema var", page.includes('"@type": "Organization"'));
  failed += result("WebSite schema var", page.includes('"@type": "WebSite"'));
  failed += result("FAQPage schema var", page.includes('"@type": "FAQPage"'));
  failed += result("Robots sitemap bildiriyor", robots.includes("sitemap"));
  failed += result("Robots login/messages engelliyor", robots.includes("/login") && robots.includes("/messages"));
  failed += result("Sitemap kritik rotaları içeriyor", sitemap.includes("/download") && sitemap.includes("/privacy") && sitemap.includes("/support"));
  failed += result("Manifest isim ve tema rengi içeriyor", manifest.includes("name") && manifest.includes("theme_color"));
  failed += result("Logo var", exists("public/brand/logo.png"));
  failed += result("Sosyal paylaşım görseli var", exists("public/screens/request-feed.png"));

  console.log("");
  return failed;
}

async function liveSeoChecks(config) {
  console.log("Canlı SEO erişim kontrolleri:");

  let failed = 0;
  const sitemapUrl = `${config.domain}/sitemap.xml`;
  const robotsUrl = `${config.domain}/robots.txt`;
  const manifestUrl = `${config.domain}/manifest.webmanifest`;
  const homeUrl = `${config.domain}/`;

  const [home, sitemap, robots, manifest] = await Promise.all([
    request(homeUrl),
    request(sitemapUrl),
    request(robotsUrl),
    request(manifestUrl)
  ]);

  failed += result("Ana sayfa erişilebilir", home.ok, `${home.status} ${homeUrl}`);
  failed += result("Sitemap erişilebilir", sitemap.ok, `${sitemap.status} ${sitemapUrl}`);
  failed += result("Sitemap urlset içeriyor", sitemap.body.includes("<urlset"));
  failed += result("Sitemap ana sayfayı içeriyor", sitemap.body.includes(`<loc>${config.domain}/</loc>`));
  failed += result("Robots erişilebilir", robots.ok, `${robots.status} ${robotsUrl}`);
  failed += result("Robots doğru sitemap bildiriyor", robots.body.includes(`Sitemap: ${sitemapUrl}`));
  failed += result("Manifest erişilebilir", manifest.ok, `${manifest.status} ${manifestUrl}`);
  failed += result("Ana sayfada title var", /<title>.+<\/title>/i.test(home.body));
  failed += result("Ana sayfada description meta var", home.body.includes('name="description"'));
  failed += result("Ana sayfada og:title var", home.body.includes('property="og:title"'));
  failed += result("Ana sayfada twitter:card var", home.body.includes('name="twitter:card"'));
  failed += result("Ana sayfada JSON-LD var", home.body.includes('application/ld+json'));

  console.log("");
  return failed;
}

async function main() {
  console.log("SEO kontrolü başlıyor.");
  console.log("");

  const config = getConfig();
  let failed = 0;

  failed += localSeoChecks(config);
  failed += await liveSeoChecks(config);

  if (failed > 0) {
    console.log(`${failed} SEO kontrolü başarısız oldu. Yukarıdaki satırları incele.`);
    process.exit(1);
  }

  console.log("Tüm SEO kontrolleri başarılı.");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
