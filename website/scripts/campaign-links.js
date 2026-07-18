const STORE_LINKS = {
  android: "https://play.google.com/store/apps/details?id=com.benyaparim.app",
  ios: "https://apps.apple.com/app/id6762226701"
};

const LANDING_URL = "https://benyaparimci.com/download";
const DEFAULT_CAMPAIGN = "benyaparim_2026_07_07_social";
const SOURCE_PRESETS = {
  facebook: {
    source: "facebook",
    medium: "paid_social"
  },
  instagram: {
    source: "instagram",
    medium: "paid_social"
  },
  meta: {
    source: "meta",
    medium: "paid_social"
  }
};

function withUtm(url, params) {
  const target = new URL(url);

  Object.entries(params).forEach(([key, value]) => {
    if (value) target.searchParams.set(key, value);
  });

  return target.toString();
}

function buildStoreCampaignLinks({
  source,
  medium = "organic_social",
  campaign = DEFAULT_CAMPAIGN,
  content = "weekly_post"
}) {
  const utm = {
    utm_source: source,
    utm_medium: medium,
    utm_campaign: campaign,
    utm_content: content
  };

  return {
    landing: withUtm(LANDING_URL, utm),
    android: withUtm(STORE_LINKS.android, utm),
    ios: withUtm(STORE_LINKS.ios, utm)
  };
}

function resolvePreset(source, explicitMedium) {
  const preset = SOURCE_PRESETS[source] || { source, medium: "organic_social" };

  return {
    source: preset.source,
    medium: explicitMedium || preset.medium
  };
}

function parseArgs(argv) {
  return argv.reduce((acc, item) => {
    const [key, ...rest] = item.replace(/^--/, "").split("=");
    if (key && rest.length) acc[key] = rest.join("=");
    return acc;
  }, {});
}

if (require.main === module) {
  const args = parseArgs(process.argv.slice(2));
  const preset = resolvePreset(args.source || "facebook", args.medium);
  const source = preset.source;
  const content = args.content || "weekly_post";
  const campaign = args.campaign || DEFAULT_CAMPAIGN;
  const medium = preset.medium;
  const links = buildStoreCampaignLinks({ source, medium, campaign, content });

  console.log(JSON.stringify({
    source,
    medium,
    campaign,
    content,
    recommendedMetaEvent: "StoreDownloadClick",
    links
  }, null, 2));
}

module.exports = {
  LANDING_URL,
  STORE_LINKS,
  DEFAULT_CAMPAIGN,
  SOURCE_PRESETS,
  buildStoreCampaignLinks
};
