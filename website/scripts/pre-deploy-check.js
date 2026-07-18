const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

const root = process.cwd();

const requiredFiles = [
  "app/layout.tsx",
  "app/page.tsx",
  "app/download/page.tsx",
  "app/privacy/page.tsx",
  "app/support/page.tsx",
  "app/delete-account/page.tsx",
  "app/robots.ts",
  "app/sitemap.ts",
  "app/manifest.ts",
  "components/site-config.ts",
  "components/MetaPixel.tsx",
  "public/brand/logo.png",
  "public/qr/android.svg",
  "public/qr/ios.svg",
  "public/screens/request-feed.png",
  "public/screens/food-card.jpg",
  "vercel.json",
  "next.config.mjs"
];

function mark(ok) {
  return ok ? "[OK]" : "[FAIL]";
}

function run(command, args) {
  return new Promise((resolve) => {
    const child = spawn(command, args, {
      cwd: root,
      shell: true,
      stdio: "inherit"
    });

    child.on("close", (code) => {
      resolve(code === 0);
    });
  });
}

function read(relativePath) {
  return fs.readFileSync(path.join(root, relativePath), "utf8");
}

function fileExists(relativePath) {
  return fs.existsSync(path.join(root, relativePath));
}

function checkFiles() {
  console.log("Kritik dosya kontrolü:");
  let failed = 0;

  for (const file of requiredFiles) {
    const ok = fileExists(file);
    failed += ok ? 0 : 1;
    console.log(`${mark(ok)} ${file}`);
  }

  console.log("");
  return failed;
}

function extractString(source, pattern) {
  const match = source.match(pattern);
  return match ? match[1] : "";
}

function checkConfig() {
  console.log("Site config kontrolü:");
  const source = read("components/site-config.ts");
  const domain = extractString(source, /domain:\s*"([^"]+)"/);
  const supportEmail = extractString(source, /supportEmail:\s*"([^"]+)"/);
  const android = extractString(source, /android:\s*"([^"]+)"/);
  const ios = extractString(source, /ios:\s*"([^"]+)"/);

  const checks = [
    ["Domain HTTPS kullanıyor", domain.startsWith("https://")],
    ["Domain benyaparimci.com içeriyor", domain.includes("benyaparimci.com")],
    ["Destek e-postası geçerli görünüyor", /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(supportEmail)],
    ["Android linki dolu", android.length > 0],
    ["iOS linki dolu", ios.length > 0]
  ];

  let failed = 0;

  for (const [label, ok] of checks) {
    failed += ok ? 0 : 1;
    console.log(`${mark(ok)} ${label}`);
  }

  console.log(`     Domain: ${domain || "Bulunamadı"}`);
  console.log(`     Destek: ${supportEmail || "Bulunamadı"}`);
  console.log("");

  return failed;
}

function checkSeoFiles() {
  console.log("SEO ve güvenlik kontrolü:");

  const layout = read("app/layout.tsx");
  const robots = read("app/robots.ts");
  const sitemap = read("app/sitemap.ts");
  const vercel = read("vercel.json");

  const checks = [
    ["Metadata title tanımlı", layout.includes("title:")],
    ["Metadata description tanımlı", layout.includes("description:")],
    ["Open Graph tanımlı", layout.includes("openGraph")],
    ["Twitter card tanımlı", layout.includes("twitter")],
    ["App links tanimli", layout.includes("appLinks")],
    ["Meta Pixel bileseni bagli", layout.includes("MetaPixel")],
    ["Robots sitemap bildiriyor", robots.includes("sitemap")],
    ["Sitemap ana rotaları içeriyor", sitemap.includes("/download") && sitemap.includes("/privacy")],
    ["Vercel güvenlik headerları tanımlı", vercel.includes("Strict-Transport-Security") && vercel.includes("Content-Security-Policy")]
  ];

  let failed = 0;

  for (const [label, ok] of checks) {
    failed += ok ? 0 : 1;
    console.log(`${mark(ok)} ${label}`);
  }

  console.log("");
  return failed;
}

async function main() {
  console.log("Pre-deploy kontrolü başlıyor.");
  console.log("");

  let failed = 0;
  failed += checkFiles();
  failed += checkConfig();
  failed += checkSeoFiles();

  if (failed > 0) {
    console.log(`${failed} yerel kontrol başarısız oldu. Build çalıştırılmadı.`);
    process.exit(1);
  }

  console.log("Build kontrolü:");
  const buildOk = await run("npm", ["run", "build"]);
  console.log("");

  if (!buildOk) {
    console.log("[FAIL] Build başarısız oldu. Deploy etmeden önce hataları düzelt.");
    process.exit(1);
  }

  if (process.env.SKIP_LIVE_CHECK === "1") {
    console.log("Canlı site kontrolü atlandı. SKIP_LIVE_CHECK=1 kullanıldı.");
    console.log("Pre-deploy kontrolü başarılı.");
    return;
  }

  console.log("Canlı site kontrolü:");
  const liveOk = await run("npm", ["run", "site-check"]);
  console.log("");

  if (!liveOk) {
    console.log("[FAIL] Canlı site kontrolü başarısız oldu. Deploy öncesi mevcut yayını incele.");
    process.exit(1);
  }

  console.log("Pre-deploy kontrolü başarılı. Deploy için hazır.");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
