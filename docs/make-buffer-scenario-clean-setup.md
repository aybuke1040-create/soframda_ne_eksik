# Make.com Buffer Scenario Clean Setup

Bu dokuman, Beylikduzu pilot kampanyasi icin Make.com senaryosunu sifirdan ve onceki hatalari tekrar etmeden kurmak icindir.

## Onceki Hatalar ve Cozumler

### 1. Buffer yerine filter ekranina girildi

Belirti:
- "Set up a filter" penceresi acildi.

Cozum:
- Moduller arasindaki cizgiye degil, Google Sheets modulunun sagindaki buyuk `+` butonuna tikla.
- Buffer modulu dogrudan Google Sheets modulunden sonra eklenmeli.

### 2. Buffer degiskenleri gorunmedi

Belirti:
- Buffer Text alaninda sadece system variables gorundu.
- `caption`, `cta`, `utm_campaign` cikmadi.

Cozum:
- Buffer modulu Google Sheets Search Rows modulunden hemen sonra bagli olmali.
- Once Google Sheets Search Rows en az bir satir bulacak sekilde test edilmeli.

### 3. Update a Row rowNumber hatasi verdi

Belirti:
- `Missing value of required parameter 'rowNumber'`

Cozum:
- Row number alanina elle sayi yazma.
- Google Sheets 1 ciktisindan `Row number` token'i secilmeli.

### 4. Update a Row yanlis hucreyi guncelledi

Belirti:
- `content_calendar!A2` guncellendi.
- `status` degismedi.

Cozum:
- `Update a Row` kullanma.
- Bunun yerine `Update a Cell` kullan.
- Status icin `B + Row number`.
- Published URL icin `M + Row number`.

### 5. Update a Cell range hatasi verdi

Belirti:
- `Unable to parse range: 'content_calendar'!B`

Cozum:
- Cell alani sadece `B` olmamali.
- `B` yaz, sonra Google Sheets 1 ciktisindan `Row number` token'ini ekle.
- Sonuc `B2`, `B5` gibi olmalidir.

### 6. Buffer duplicate hatasi verdi

Belirti:
- `DuplicateDataError`
- Buffer ayni postu yakin zamanda tekrar yayinlamaya izin vermedi.

Cozum:
- Sheet'te ayni anda sadece bir `approved` satir birak.
- Buffer Text sonuna benzersiz takip kodu ekle.
- Ornek: `Takip kodu: {{id}} - {{publish_at}} - {{random}}`
- Buffer queue icindeki onceki test postlarini temizle.

## Temiz Final Senaryo

Final akis:

```text
Google Sheets Search Rows
  -> Buffer Create a status update
  -> Google Sheets Update a Cell, B{rowNumber} = scheduled
  -> Google Sheets Update a Cell, M{rowNumber} = buffer_queue
```

## Google Sheets Hazirligi

Sekme adi:

```text
content_calendar
```

Kolon sirasi:

```text
A: id
B: status
C: channel
D: city
E: district
F: persona
G: hook
H: caption
I: cta
J: asset_url
K: publish_at
L: utm_campaign
M: published_url
N: result_installs
O: result_signups
```

Test icin:
- Tum satirlar `draft` olsun.
- Sadece bir satir `approved` olsun.
- Test satirinin caption alanina benzersiz bir ifade ekle.

Ornek:

```text
DENEME-20260514-001
```

## Modul 1: Google Sheets Search Rows

Uygulama:

```text
Google Sheets
```

Aksiyon:

```text
Search Rows
```

Ayarlar:
- Spreadsheet: `Ben Yaparim Growth Automation`
- Sheet: `content_calendar`
- Table contains headers: `Yes`
- Search/filter:
  - Column: `status`
  - Operator: `Equal to`
  - Value: `approved`
- Limit: `1`

Not:
- Limit mutlaka 1 olsun. Testte ayni anda birden fazla satir islenmesin.

## Modul 2: Buffer Create a Status Update

Uygulama:

```text
Buffer
```

Aksiyon:

```text
Create a status update
```

Ayarlar:
- Profile: `Facebook Page (Ben Yaparim)` veya bagli sosyal medya profili
- Publication: `Add to queue` varsa onu sec. Yoksa testte `Post immediately` kullanilabilir.
- Attach media: `No`

Text:

```text
{{caption}}

{{cta}}

https://play.google.com/store/apps/details?id=com.benyaparim.app&utm_source={{channel}}&utm_medium=organic&utm_campaign={{utm_campaign}}

Takip kodu: {{id}} - {{publish_at}} - {{random}}
```

Not:
- `{{...}}` ifadelerini elle yazmak yerine Make mapping panelinden sec.
- `random` Make system variable olarak secilebilir.

## Modul 3: Google Sheets Update a Cell - Status

Uygulama:

```text
Google Sheets
```

Aksiyon:

```text
Update a Cell
```

Ayarlar:
- Spreadsheet: `Ben Yaparim Growth Automation`
- Sheet: `content_calendar`
- Cell: `B` + `Google Sheets 1 > Row number`
- Value:

```text
scheduled
```

## Modul 4: Google Sheets Update a Cell - Published URL

Uygulama:

```text
Google Sheets
```

Aksiyon:

```text
Update a Cell
```

Ayarlar:
- Spreadsheet: `Ben Yaparim Growth Automation`
- Sheet: `content_calendar`
- Cell: `M` + `Google Sheets 1 > Row number`
- Value:

```text
buffer_queue
```

## Test Sirasi

1. Sheet'te tum status degerlerini `draft` yap.
2. Sadece bir satiri `approved` yap.
3. O satirin caption alanina benzersiz test kodu ekle.
4. Buffer queue icindeki onceki test postlarini sil.
5. Make'te `Run once`.
6. Beklenen sonuc:
   - Buffer postu queue'ya ekler veya paylasir.
   - Sheet'te ilgili satirin `status` kolonu `scheduled` olur.
   - Sheet'te ilgili satirin `published_url` kolonu `buffer_queue` olur.

## Canliya Alma

Test basarili olduktan sonra:
- Scenario schedule: Free planda `Every 15 minutes`.
- Make Core'a gecince: `Every 5 minutes` veya ihtiyaca gore `Every 1 minute`.
- Limit ilk hafta `1` kalsin.
- Sistem stabil olunca Limit `3` yapilabilir.
