const https = require("https");
const tls = require("tls");

const baseUrl = process.env.SITE_URL || "https://benyaparimci.com";
const host = new URL(baseUrl).hostname;

const pages = [
  { label: "Ana sayfa", path: "/" },
  { label: "İndirme", path: "/download" },
  { label: "Gizlilik", path: "/privacy" },
  { label: "Destek", path: "/support" },
  { label: "Hesap silme", path: "/delete-account" },
  { label: "Sitemap", path: "/sitemap.xml", includes: "<urlset" },
  { label: "Robots", path: "/robots.txt", includes: "Sitemap:" },
  { label: "Manifest", path: "/manifest.webmanifest", includes: "Ben" }
];

const requiredHeaders = [
  "strict-transport-security",
  "x-frame-options",
  "x-content-type-options",
  "referrer-policy",
  "content-security-policy"
];

function checkUrl(path, includes) {
  const url = new URL(path, baseUrl);

  return new Promise((resolve) => {
    const request = https.get(
      url,
      {
        timeout: 15000,
        headers: {
          "User-Agent": "BenYaparimSiteCheck/1.0"
        }
      },
      (response) => {
        let body = "";

        response.on("data", (chunk) => {
          body += chunk.toString("utf8");
        });

        response.on("end", () => {
          const statusOk = response.statusCode >= 200 && response.statusCode < 400;
          const contentOk = includes ? body.includes(includes) : true;

          resolve({
            ok: statusOk && contentOk,
            status: response.statusCode,
            headers: response.headers,
            url: url.toString(),
            contentOk
          });
        });
      }
    );

    request.on("timeout", () => {
      request.destroy(new Error("Request timeout"));
    });

    request.on("error", (error) => {
      resolve({
        ok: false,
        status: "ERR",
        url: url.toString(),
        error: error.message,
        headers: {}
      });
    });
  });
}

function checkCertificate() {
  return new Promise((resolve) => {
    const socket = tls.connect(
      443,
      host,
      {
        servername: host,
        timeout: 15000
      },
      () => {
        const cert = socket.getPeerCertificate();
        const validTo = cert.valid_to ? new Date(cert.valid_to) : null;
        const daysLeft = validTo ? Math.ceil((validTo.getTime() - Date.now()) / 86400000) : 0;

        socket.end();
        resolve({
          ok: socket.authorized && daysLeft > 14,
          authorized: socket.authorized,
          issuer: cert.issuer?.O || cert.issuer?.CN || "Bilinmiyor",
          validTo,
          daysLeft
        });
      }
    );

    socket.on("timeout", () => {
      socket.destroy(new Error("TLS timeout"));
    });

    socket.on("error", (error) => {
      resolve({
        ok: false,
        authorized: false,
        error: error.message
      });
    });
  });
}

function mark(ok) {
  return ok ? "[OK]" : "[FAIL]";
}

async function main() {
  console.log(`Site kontrolü başlıyor: ${baseUrl}`);
  console.log("");

  const cert = await checkCertificate();
  console.log(`${mark(cert.ok)} SSL sertifikası`);

  if (cert.validTo) {
    console.log(`     Sağlayıcı: ${cert.issuer}`);
    console.log(`     Geçerlilik: ${cert.validTo.toISOString().slice(0, 10)} (${cert.daysLeft} gün kaldı)`);
  } else if (cert.error) {
    console.log(`     Hata: ${cert.error}`);
  }

  console.log("");

  let failed = cert.ok ? 0 : 1;
  let homeHeaders = null;

  for (const page of pages) {
    const result = await checkUrl(page.path, page.includes);
    failed += result.ok ? 0 : 1;
    console.log(`${mark(result.ok)} ${page.label} - ${result.status} - ${result.url}`);

    if (!result.contentOk) {
      console.log(`     Beklenen içerik bulunamadı: ${page.includes}`);
    }

    if (result.error) {
      console.log(`     Hata: ${result.error}`);
    }

    if (page.path === "/") {
      homeHeaders = result.headers;
    }
  }

  console.log("");
  console.log("Güvenlik header kontrolü:");

  for (const header of requiredHeaders) {
    const ok = Boolean(homeHeaders?.[header]);
    failed += ok ? 0 : 1;
    console.log(`${mark(ok)} ${header}${ok ? `: ${homeHeaders[header]}` : ""}`);
  }

  console.log("");

  if (failed > 0) {
    console.log(`${failed} kontrol başarısız oldu. Yukarıdaki satırları incele.`);
    process.exit(1);
  }

  console.log("Tüm kontroller başarılı.");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
