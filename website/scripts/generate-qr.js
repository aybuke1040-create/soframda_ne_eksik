const QRCode = require("qrcode");
const fs = require("fs");
const path = require("path");

const targets = [
  ["android.svg", "https://play.google.com/store/apps/details?id=com.benyaparim.app"],
  ["ios.svg", "https://apps.apple.com/app/id6762226701"]
];

const outDir = path.join(process.cwd(), "public", "qr");
fs.mkdirSync(outDir, { recursive: true });

(async () => {
  for (const [name, url] of targets) {
    const svg = await QRCode.toString(url, {
      type: "svg",
      margin: 1,
      color: { dark: "#20152F", light: "#FFFFFF" },
      width: 256
    });

    fs.writeFileSync(path.join(outDir, name), svg, "utf8");
  }
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
