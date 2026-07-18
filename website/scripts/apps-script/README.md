Google Sheets + Apps Script model for Ben Yaparim Meta publishing.

Files:

- Code.gs: main Apps Script code
- appsscript.json: manifest

What it does:

1. Creates the workbook tabs automatically.
2. Writes field descriptions and workflow notes.
3. Seeds a ready-to-publish Facebook and Instagram monthly plan.
4. Builds a daily queue for posts due today or overdue.
5. Publishes due Facebook and Instagram queue rows through Meta Graph API.
6. Updates both the queue row and original plan row after publishing.

Recommended tabs:

- README
- AYLIK_PLAN
- GUNLUK_KUYRUK
- AYARLAR
- ARSIV

How to use:

1. Open the target Google Sheet.
2. Open Extensions > Apps Script.
3. Replace the default files with `Code.gs` and `appsscript.json`.
4. Add the Meta script properties listed in `SECRETS_SETUP.md`.
5. Run `setupWorkbook`.
6. Run `seedJune2026Plan`.
   - For the 7 July 2026 weekly package, run `seedJuly72026WeekPlan`.
7. Run `buildDailyQueue`.
8. Run `publishMetaQueue` to test the first due Facebook or Instagram row.
9. Add time-driven triggers:
   - `buildDailyQueue` once per day
   - `publishMetaQueue` every hour

Workflow:

- `AYLIK_PLAN` is prefilled with ready and approved Facebook/Instagram rows.
- `buildDailyQueue` copies due approved rows to `GUNLUK_KUYRUK`.
- `publishMetaQueue` posts due Facebook/Instagram rows automatically.
- Successful Meta posts update both queue and original plan row to `posted`.

Notes:

- Asset URLs are website-hosted under `https://benyaparimci.com/social/...`.
- Store campaign links can be generated locally with `npm run campaign:links -- --source=facebook --content=facebook_post_1`.
- Facebook and Instagram automation requires a valid Page access token and Instagram Business account ID.
- Asset URLs must be direct HTTPS image URLs that Meta can fetch without login or redirects.
