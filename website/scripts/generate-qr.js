const QRCode = require("qrcode");
const fs = require("fs");
const path = require("path");

const targets = [
  ["android.svg", "https://www.benyaparim.app/download#android"],
  ["ios.svg", "https://www.benyaparim.app/download#ios"]
];

const outDir = path.join(process.cwd(), "public", "qr");
fs.mkdirSync(outDir, { recursive: true });

(async () => {
  for (const [name, url] of targets) {
    const svg = await QRCode.toString(url, {
      type: "svg",
      margin: 1,
      color: { dark: "#20152F", light: "#FFFFFF" },
      width: 180
    });

    fs.writeFileSync(path.join(outDir, name), svg, "utf8");
  }
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
