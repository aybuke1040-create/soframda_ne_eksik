# Ben Yaparim Marketing Automation Playbook

Bu dokumanin amaci, uygulamayi en ekonomik yoldan hizli yaymak icin Make.com merkezli ama Firebase altyapisini da kullanan pratik bir otomasyon sistemi kurmaktir.

## Asama 1: Meta + SEO Olcum Kurulumu

Bu repoda ilk teknik kurulum tamamlandi:
- Website tarafinda `NEXT_PUBLIC_META_PIXEL_ID` ile calisan Meta Pixel altyapisi eklendi.
- Ana sayfa `PageView`, magazaya tiklama ise `StoreDownloadClick` custom event'i olarak izlenir.
- Kampanya link script'i artik landing, Android ve iOS linklerini UTM ile birlikte uretir.
- Ana sayfaya `MobileApplication` schema eklendi.
- Flutter web giris HTML'i varsayilan proje metalarindan marka odakli SEO metalarina tasindi.

Kurulum adimlari:
1. Meta Events Manager icinde Pixel olustur.
2. Vercel veya hosting ortaminda `NEXT_PUBLIC_META_PIXEL_ID` degerini tanimla.
3. `website` klasorunde `npm run campaign:links -- --source=facebook --campaign=istanbul_ev_yemegi_2026w28 --content=creative_01` calistir.
4. Meta Ads Manager'da trafik hedefini oncelikle `links.landing` olarak kullan; store yonlendirme tiklamalari Pixel tarafinda `StoreDownloadClick` ile olculur.
5. Yayin sonrasi Events Manager'da `PageView` ve `StoreDownloadClick` event'lerinin geldigini dogrula.

Sonraki teknik asama:
- Conversions API icin server-side event endpoint'i ekle.
- Firebase Analytics install/signup event'lerini kampanya UTM'leriyle raporla.
- Izinli kullanicilar icin yeniden pazarlama segmentlerini anonim ve KVKK uyumlu sekilde hazirla.

## Plan Karari

Baslangic icin onerilen Make plani: Core.

Neden:
- Free plan prototip icin yeterli, ancak aktif senaryo sayisi ve 15 dakikalik calisma araligi buyume otomasyonu icin dar kalir.
- Core plan, dakikaya kadar zamanlama ve sinirsiz aktif senaryo ile ilk ciddi tanitim sistemi icin yeterlidir.
- Pro plana ilk etapta gerek yoktur. Pro sadece yogun calisma, oncelikli execution, ozel degiskenler ve log arama ihtiyaci dogdugunda mantikli olur.

Baslangic stratejisi:
1. Ilk 2-3 gun Free planda senaryolari test et.
2. Uygulama linkleri, Sheets yapisi, e-posta ve sosyal medya baglantilari dogru calisinca Core plana gec.
3. Aylik kredi kullanimini 10-14 gun takip et. Kullanim limitlere yaklasmiyorsa Pro alma.

## Minimum Arac Seti

- Make.com: Ana otomasyon merkezi
- Google Sheets: Icerik, kampanya ve lead havuzu
- Firebase / Cloud Functions: Uygulama ici bildirimler ve kullanici segmentleri
- Firebase Analytics veya GA4: UTM ve funnel olcumu
- Brevo: Ucretsiz/ekonomik e-posta otomasyonu
- Buffer, Publer veya Metricool: Sosyal medya zamanlama
- Play Store / App Store linkleri: Tum kampanyalar icin UTM parametreli linkler

## Google Sheets Tablolari

### content_calendar

Kolonlar:
- id
- status: draft, approved, scheduled, published, failed
- channel: instagram, tiktok, youtube_shorts, linkedin, x, facebook, whatsapp, blog
- city
- district
- persona: ilan_sahibi, hizmet_veren, ev_yemegi, tasima, organizasyon
- hook
- caption
- cta
- asset_url
- publish_at
- utm_campaign
- published_url
- result_installs
- result_signups

### leads

Kolonlar:
- created_at
- name
- email
- phone
- city
- district
- source
- utm_campaign
- status: new, welcomed, activated, inactive

### local_density_watch

Kolonlar:
- city
- district
- users_last_7_days
- listings_last_7_days
- active_supply
- active_demand
- density_status: cold, warming, active
- recommended_message
- next_action

### referral_rewards

Kolonlar:
- user_id
- invited_phone_or_email
- invite_channel
- invite_date
- joined
- rewarded
- reward_amount

## Make Senaryolari

### Scenario 1: Haftalik Icerik Uretim ve Takvim

Zamanlama: Haftada 1, Pazartesi 09:00

Akis:
1. Google Sheets `content_calendar` icinde bos haftayi kontrol et.
2. Persona ve ilce bazli icerik fikirleri uret.
3. Her fikir icin platforma uygun metin olustur.
4. `status=draft` olarak Sheets'e yaz.

Ekonomi notu:
- AI metin uretimini ilk etapta Make icinde degil, manuel veya dusuk maliyetli toplu uretimle yap.
- Onay mekanizmasi olmadan otomatik yayin yapma.

### Scenario 2: Onaylanan Icerigi Sosyal Medyaya Gonder

Zamanlama: Her 2 saatte bir

Akis:
1. `status=approved` ve `publish_at <= now` satirlarini bul.
2. Buffer/Publer/Metricool'a gonder.
3. UTM linkini caption icine ekle.
4. Basariliysa `status=scheduled`, hata varsa `failed` yap.

CTA ornekleri:
- "Mahallende bir is lazimsa Ben Yaparim'i indir."
- "30 km icindeki ilanlari gor, teklif ver, kazan."
- "Cevrende kullanici arttikca ilanlar daha hizli eslesir. Uygulamayi tanidiklarinla paylas."

### Scenario 3: Yeni Lead Karsilama

Trigger: Form, website veya Sheets'e yeni lead

Akis:
1. Lead'i Brevo listesine ekle.
2. Kaynak ve UTM bilgisini sakla.
3. Hos geldin e-postasi gonder.
4. 2 gun sonra kullanim senaryosu e-postasi gonder.
5. 5 gun sonra uygulamayi tanidiklarina onerme e-postasi gonder.

E-posta 1:
Konu: Ben Yaparim'a hos geldin
Metin: "Ben Yaparim, 30 km cevrendeki ilanlari ve yardim taleplerini gormen icin tasarlandi. Bolgende henuz az kullanici varsa bu normal; uygulama buyudukce daha fazla ilan ve teklif goreceksin. Cevrendeki kisiler katildikca eslesmeler hizlanir."

E-posta 2:
Konu: Ilk ilani veya teklifini dene
Metin: "Bir is yaptirmak ya da bir ise teklif vermek istiyorsan konumuna yakin ilanlari kontrol et. Su an bolgende az ilan varsa uygulamayi tanidiklarina onererek bolgendeki agi buyutebilirsin."

E-posta 3:
Konu: Bolgendeki ilk kullanicilardan biri ol
Metin: "Yeni bolgelerde ilk kullanicilar cok degerli. Sen paylastikca 30 km icindeki kullanici sayisi artar, ilanlar ve teklifler daha hizli eslesir."

### Scenario 4: Durgun Bolge Kullanici Mesaji

Trigger: Firebase'den veya manuel export ile `local_density_watch` tablosu guncellenir.

Kural:
- `users_last_7_days < 10` veya `listings_last_7_days < 3` ise bolge `cold`.
- `users_last_7_days >= 10` ve `listings_last_7_days >= 3` ise `warming`.
- `users_last_7_days >= 30` ve `listings_last_7_days >= 10` ise `active`.

Cold bolge uygulama ici mesaj:
"Bolgende henuz yeni yeni buyuyoruz. Ilanlar 30 km icinde gosterildigi icin su an az kisi goruyor olabilirsin. Tanidiklarini davet ettikce bolgendeki ilan ve teklif sayisi artacak."

Warming bolge mesaj:
"Bolgende hareket basliyor. Daha fazla kisinin katilmasi, ilanlarin daha hizli yanit almasini saglar. Uygulamayi yakinlarinla paylasarak agi buyutebilirsin."

Active bolge mesaj:
"Bolgende yeni ilanlar gelmeye devam ediyor. Bildirimlerini acik tut, yakinindaki firsatlari kacirma."

### Scenario 5: Paylasim ve Davet Tesviki

Mevcut altyapi:
- Uygulamada `share_plus` var.
- Cloud Functions icinde aylik paylasim odulu mantigi var: `claimMonthlyShareReward`.

Akis:
1. Kullanici cold/warming bolgede ise uygulama ici paylasim karti goster.
2. Paylasim sonrasi aylik kredi odulu ver.
3. Davet linki UTM ile takip edilir.
4. Yeni kullanici kaydolursa `referral_rewards` tablosuna yazilir.

Paylasim metni:
"Ben Yaparim'da 30 km cevrendeki isleri, yardim taleplerini ve ilanlari gorebilirsin. Bolgemizde kullanici arttikca ilanlar daha hizli eslesecek. Sen de katil: {app_link}"

### Scenario 6: Haftalik Performans Raporu

Zamanlama: Her Pazartesi 10:00

Rapor alanlari:
- En cok kayit getiren kanal
- En cok indirme getiren UTM kampanyasi
- En aktif il/ilce
- Cold bolgeler
- Haftalik yeni kullanici
- Haftalik yeni ilan
- Teklif sayisi
- E-posta acilma/tiklama
- Sosyal medya yayin sayisi

Rapor hedefi:
- E-posta veya Telegram/Slack bildirimi.

## Uygulama Ici Mesajlar

### Bos veya Az Ilan Ekrani

Baslik:
"Bolgende ag yeni kuruluyor"

Govde:
"Ilanlar ve teklifler 30 km cevrende gosterilir. Bu yuzden bolgende henuz az kullanici varsa bir sure daha az ilan gorebilirsin. Tanidiklarini davet ettikce bolgendeki eslesmeler hizlanir."

Butonlar:
- "Uygulamayi Paylas"
- "Ilan Olustur"
- "Bildirimleri Ac"

### Ilan Olusturduktan Sonra

"Ilanin 30 km cevrendeki uygun kisilere gosterilecek. Bolgende kullanici sayisi arttikca daha hizli yanit alirsin. Istersen uygulamayi tanidiklarinla paylasarak bolgendeki agi buyutabilirsin."

### Ilk Acilis / Onboarding

"Ben Yaparim yerel calisir: ilanlar 30 km cevrendeki kisilerle eslesir. Yeni bolgelerde kullanici sayisi zamanla artar. Cevrendeki kisiler katildikca uygulama senin bolgende daha guclu calisir."

### Push Bildirimleri

Cold bolge:
"Bolgende agi birlikte buyutelim"
"Ilanlar 30 km icinde calisir. Tanidiklarini davet ederek bolgendeki eslesmeleri hizlandirabilirsin."

Warming bolge:
"Bolgende yeni hareket var"
"Yeni kullanicilar katiliyor. Bildirimlerini acik tut, yakinindaki ilanlari kacirma."

Paylasim tesviki:
"Bu ay paylasim odulunu al"
"Uygulamayi bir tanidigina oner, bolgendeki ag buyusun."

## Ilk 30 Gun Yol Haritasi

### Gun 1-2

- Google Sheets tablolari acilir.
- Make Free ile senaryolar test edilir.
- UTM link standardi belirlenir.
- Brevo listesi ve ilk 3 e-posta hazirlanir.

### Gun 3-7

- Make Core plana gecilir.
- Haftalik icerik uretim ve yayinlama akisi acilir.
- Bos bolge mesajlari uygulama icine eklenir.
- Paylasim metinleri ve odul akisi test edilir.

### Gun 8-14

- Il/ilce bazli organik paylasim baslar.
- 3-5 hedef bolge secilir.
- WhatsApp, Facebook gruplari, yerel esnaf ve mikro influencer denemeleri baslar.
- Haftalik rapor okunur, calismayan kanallar kesilir.

### Gun 15-30

- En iyi 2 kanal buyutulur.
- Dusuk butceli Meta/TikTok reklam testi yapilir.
- Cold bolgeler icin davet kampanyasi acilir.
- En aktif bolgelerde referans/yorum/vaka icerikleri yayinlanir.

## Kanal Onceligi

1. WhatsApp ve yerel cevre paylasimlari
2. Facebook yerel gruplar
3. Instagram Reels
4. TikTok kisa videolar
5. Google Business / yerel SEO
6. Mikro influencer ve mahalle sayfalari
7. Dusuk butceli Meta reklam
8. Blog/SEO icerikleri

## Reklam Butcesi

Baslangic:
- Gunluk 100-200 TL test butcesi
- 3 farkli kreatif
- 3 farkli hedef kitle
- 3-5 gun test

Kesme kurali:
- Kayit veya indirme getirmeyen kreatif 72 saat sonra kapatilir.
- En iyi kampanyaya butce kaydirilir.

## Olcum

Her linkte UTM kullan:

`utm_source={platform}&utm_medium=organic_or_paid&utm_campaign={city}_{persona}_{week}`

Ornek:

`utm_source=instagram&utm_medium=organic&utm_campaign=istanbul_hizmet_2026w19`

Ana metrikler:
- Install
- Signup
- Ilan olusturma
- Teklif verme
- Ilk mesaj
- Paylasim tiklamasi
- Davetle gelen yeni kullanici

## Guvenlik ve KVKK Notlari

- Kullanici riza vermeden pazarlama e-postasi veya SMS gonderme.
- FCM token, e-posta, telefon gibi verileri Make senaryolarinda gereksiz yere tasima.
- Kullanici segmentleri mumkunse Firebase tarafinda hesaplanip Make'e sadece anonim ozet olarak aktarilsin.
- Otomatik sosyal medya paylasimlarinda spam gibi gorunecek tekrarli metinlerden kacin.
