Meta automation setup checklist for Ben Yaparim.

Use Apps Script > Project Settings > Script properties.
Do not store secrets in code or in Google Sheets cells.

Required script properties:

- SPREADSHEET_ID
- META_PAGE_ID
- META_PAGE_ACCESS_TOKEN
- INSTAGRAM_BUSINESS_ACCOUNT_ID

Optional script property:

- INSTAGRAM_ACCESS_TOKEN

If `INSTAGRAM_ACCESS_TOKEN` is empty, the script uses `META_PAGE_ACCESS_TOKEN` for Instagram publishing too.

Current Meta publishing functions:

- `setupWorkbook`: creates the required Google Sheet tabs.
- `seedJune2026Plan`: fills `AYLIK_PLAN` with ready and approved Facebook/Instagram rows.
- `buildDailyQueue`: moves due rows into `GUNLUK_KUYRUK`.
- `publishMetaQueue`: publishes one due Facebook or Instagram row from `GUNLUK_KUYRUK`.
- `createDailyTrigger`: creates a daily trigger for `buildDailyQueue`.
- `createMetaPublishingTrigger`: creates an hourly trigger for `publishMetaQueue`.

Expected queue fields:

- `scheduled_at`: ISO-like date, for example `2026-06-10T18:00:00+03:00`
- `platform`: `Facebook` or `Instagram`
- `caption_tr`: main caption text
- `cta_short`: optional call to action appended under the caption
- `asset_url`: direct public HTTPS image URL
- `status`: `queued_meta`, `publishing`, `posted`, or `error`

Minimum setup actions:

1. Confirm Instagram Professional is linked to the Facebook Page.
2. Generate a long-lived Page access token.
3. Collect the Facebook Page ID and Instagram Business Account ID.
4. Add the required script properties.
5. Run `setupWorkbook`.
6. Run `seedJune2026Plan`.
7. Run `buildDailyQueue`.
8. Run `publishMetaQueue` once and check `operator_notes`.
