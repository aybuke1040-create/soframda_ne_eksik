const fs = require("fs");
const path = require("path");

const root = process.cwd();
const publicDir = path.join(root, "public");

const requiredImages = [
  {
    path: "public/brand/logo.png",
    label: "Logo",
    maxBytes: 800 * 1024
  },
  {
    path: "public/screens/request-feed.png",
    label: "Ana ekran görüntüsü",
    maxBytes: 900 * 1024
  },
  {
    path: "public/screens/food-card.jpg",
    label: "Yemek ekran görseli",
    maxBytes: 900 * 1024
  },
  {
    path: "public/qr/android.svg",
    label: "Android QR",
    maxBytes: 120 * 1024,
    mustInclude: "<svg"
  },
  {
    path: "public/qr/ios.svg",
    label: "iPhone QR",
    maxBytes: 120 * 1024,
    mustInclude: "<svg"
  }
];

const sourceFiles = [
  "app/layout.tsx",
  "app/page.tsx",
  "app/download/page.tsx",
  "components/Header.tsx",
  "components/PhoneMockup.tsx",
  "components/StoreCard.tsx"
];

const allowedExtensions = new Set([".png", ".jpg", ".jpeg", ".svg", ".webp", ".ico"]);

function mark(ok) {
  return ok ? "[OK]" : "[FAIL]";
}

function relativeToRoot(fullPath) {
  return path.relative(root, fullPath).replace(/\\/g, "/");
}

function fileExists(relativePath) {
  return fs.existsSync(path.join(root, relativePath));
}

function read(relativePath) {
  return fs.readFileSync(path.join(root, relativePath), "utf8");
}

function getSize(relativePath) {
  return fs.statSync(path.join(root, relativePath)).size;
}

function listFiles(dir) {
  if (!fs.existsSync(dir)) {
    return [];
  }

  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);

    if (entry.isDirectory()) {
      files.push(...listFiles(fullPath));
    } else {
      files.push(fullPath);
    }
  }

  return files;
}

function checkRequiredImages() {
  console.log("Zorunlu görsel kontrolleri:");
  let failed = 0;

  for (const image of requiredImages) {
    const exists = fileExists(image.path);
    failed += exists ? 0 : 1;
    console.log(`${mark(exists)} ${image.label} var - ${image.path}`);

    if (!exists) {
      continue;
    }

    const size = getSize(image.path);
    const sizeOk = size <= image.maxBytes;
    failed += sizeOk ? 0 : 1;
    console.log(`${mark(sizeOk)} ${image.label} boyutu uygun - ${Math.round(size / 1024)} KB`);

    if (image.mustInclude) {
      const content = read(image.path);
      const contentOk = content.includes(image.mustInclude);
      failed += contentOk ? 0 : 1;
      console.log(`${mark(contentOk)} ${image.label} beklenen içerik var`);
    }
  }

  console.log("");
  return failed;
}

function checkPublicImages() {
  console.log("Public görsel taraması:");
  const files = listFiles(publicDir).filter((file) => allowedExtensions.has(path.extname(file).toLowerCase()));
  let failed = 0;

  if (files.length === 0) {
    console.log("[FAIL] public içinde görsel bulunamadı");
    console.log("");
    return 1;
  }

  for (const file of files) {
    const relativePath = relativeToRoot(file);
    const size = fs.statSync(file).size;
    const sizeOk = size <= 1024 * 1024;
    failed += sizeOk ? 0 : 1;
    console.log(`${mark(sizeOk)} ${relativePath} - ${Math.round(size / 1024)} KB`);
  }

  console.log("");
  return failed;
}

function collectReferencedPublicAssets() {
  const references = new Set();
  const regex = /["'`]\/([^"'`]+\.(?:png|jpg|jpeg|svg|webp|ico))["'`]/gi;

  for (const file of sourceFiles) {
    if (!fileExists(file)) {
      continue;
    }

    const content = read(file);
    let match;

    while ((match = regex.exec(content)) !== null) {
      references.add(`public/${match[1]}`);
    }
  }

  return Array.from(references).sort();
}

function checkReferences() {
  console.log("Kod içindeki görsel referansları:");
  const references = collectReferencedPublicAssets();
  let failed = 0;

  if (references.length === 0) {
    console.log("[FAIL] Kod içinde public görsel referansı bulunamadı");
    console.log("");
    return 1;
  }

  for (const reference of references) {
    const ok = fileExists(reference);
    failed += ok ? 0 : 1;
    console.log(`${mark(ok)} ${reference}`);
  }

  console.log("");
  return failed;
}

function checkDuplicateScreenImages() {
  console.log("Ekran görseli temizlik kontrolü:");
  const png = "public/screens/request-feed.png";
  const jpg = "public/screens/request-feed.jpg";
  const hasBoth = fileExists(png) && fileExists(jpg);

  if (!hasBoth) {
    console.log("[OK] Aynı ekran görselinin iki formatlı kopyası yok");
    console.log("");
    return 0;
  }

  const pngSize = getSize(png);
  const jpgSize = getSize(jpg);
  const sameSize = pngSize === jpgSize;

  if (sameSize) {
    console.log("[WARN] request-feed.png ve request-feed.jpg aynı boyutta görünüyor. Kullanılmayan kopya temizlenebilir.");
  } else {
    console.log("[OK] request-feed.png ve request-feed.jpg farklı dosyalar");
  }

  console.log("");
  return 0;
}

function main() {
  console.log("Görsel kontrolü başlıyor.");
  console.log("");

  let failed = 0;
  failed += checkRequiredImages();
  failed += checkPublicImages();
  failed += checkReferences();
  failed += checkDuplicateScreenImages();

  if (failed > 0) {
    console.log(`${failed} görsel kontrolü başarısız oldu. Yukarıdaki satırları incele.`);
    process.exit(1);
  }

  console.log("Tüm görsel kontrolleri başarılı.");
}

main();
