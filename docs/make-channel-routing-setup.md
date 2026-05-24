# Make Channel Routing Setup

Bu dokuman, Facebook ve Instagram icin ayri Buffer senaryolari kurmak icindir.

## Neden Ayri Senaryo?

Tek senaryoda birden fazla Buffer profili secilirse her `approved` satir tum profillere gider. Bu, Instagram'a yazilan bir metnin Facebook'a veya Facebook'a yazilan bir metnin Instagram'a aynen gitmesine neden olur.

Bu yuzden ilk etapta en temiz yapi:

```text
Facebook scenario: status=approved AND channel=facebook
Instagram scenario: status=approved AND channel=instagram
```

## Facebook Scenario

Ad:

```text
Beylikduzu Facebook Buffer Publishing
```

Google Sheets Search Rows:
- Sheet: `content_calendar`
- Limit: `1`
- Filter 1:
  - `status`
  - Equal to
  - `approved`
- Filter 2:
  - `channel`
  - Equal to
  - `facebook`

Buffer:
- Profile: `Facebook Page (Ben Yaparim)`
- Publication: `Add to queue`
- Attach media: `No`

Google Sheets Update a Cell:
- `B{Row number}` = `scheduled`
- `M{Row number}` = `buffer_queue_facebook`

## Instagram Scenario

Ad:

```text
Beylikduzu Instagram Buffer Publishing
```

Google Sheets Search Rows:
- Sheet: `content_calendar`
- Limit: `1`
- Filter 1:
  - `status`
  - Equal to
  - `approved`
- Filter 2:
  - `channel`
  - Equal to
  - `instagram`

Buffer:
- Profile: Instagram Business account
- Publication: `Add to queue`
- Attach media: `No`

Google Sheets Update a Cell:
- `B{Row number}` = `scheduled`
- `M{Row number}` = `buffer_queue_instagram`

## Buffer Text Template

```text
{{caption}}

{{cta}}

https://play.google.com/store/apps/details?id=com.benyaparim.app&utm_source={{channel}}&utm_medium=organic&utm_campaign={{utm_campaign}}

Takip kodu: {{id}} - {{publish_at}} - {{random}}
```

## Canli Kullanim Kurali

- Facebook'a gidecek satirlarda `channel=facebook`.
- Instagram'a gidecek satirlarda `channel=instagram`.
- Ayni anda her kanalda en fazla 1 satir `approved` yap.
- Testler bittikten sonra her iki senaryo da `Every 15 minutes` calisabilir.
