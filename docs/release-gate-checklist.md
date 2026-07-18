# Ben Yaparim Release Gate Checklist

Bu liste her `Play Console` veya `App Store Connect` yuklemesinden once uygulanir.

## 1. Surum ve paket

- [ ] `pubspec.yaml` icindeki `version` yeni surum icin artirildi
- [ ] Android `versionCode` daha once kullanilan bir degeri tekrar etmiyor
- [ ] iOS `CFBundleShortVersionString` App Store Connect'teki son onayli surumden buyuk
- [ ] Yeni build dosyasi gercekten guncel commit'ten uretildi

## 2. Kod ve metin sagligi

- [ ] `flutter analyze` kritik dosyalarda temiz gecti
- [ ] Uygulama ici gorunur metinlerde bozuk Turkce karakter taramasi yapildi
- [ ] Yeni eklenen buton, dialog ve snackbar metinleri elle gozden gecirildi
- [ ] Gecici/debug amacli kod veya test mesaji birakilmadi

## 3. Firestore ve guvenlik

- [ ] `firestore.rules` degistiyse ilgili akislar yeniden test edildi
- [ ] `storage.rules` degistiyse yukleme/guncelleme akislari yeniden test edildi
- [ ] Yetki hatasi uretme ihtimali olan ekranlar manuel denendi
- [ ] Admin, kullanici, ilan sahibi ve teklif veren rolleri ayri ayri dusunuldu
- [ ] Firestore veya Storage rule deploy'u yapildiysa bunun Android ve iOS'u ayni anda etkiledigi not edildi

Ozellikle tekrar test edilecek akislar:

- [ ] mevcut sohbeti tekrar acma
- [ ] mevcut teklifi tekrar goruntuleme
- [ ] ilan duzenleme
- [ ] ilan silme
- [ ] teklif kabul etme
- [ ] mesaj gonderme

## 4. Kritik kullanici akislari

### Hesap

- [ ] kayit olma
- [ ] giris yapma
- [ ] sifre sifirlama maili gonderme
- [ ] sifre sifirlama linkini acma
- [ ] yeni sifre ile tekrar giris

### Profil

- [ ] eksik profil ile kisitli islem denenip uyari goruldu
- [ ] profil guncelleme kaydedildi
- [ ] profil fotografi yukleme calisti

### Ilanlar

- [ ] yemek ilani olusturma
- [ ] yemek ilani duzenleme
- [ ] yemek ilani silme
- [ ] hazir yemek gorunurlugu kontrol edildi
- [ ] tasima ilani olusturma
- [ ] tasima ilani duzenleme
- [ ] organizasyon ilani olusturma
- [ ] organizasyon ilani duzenleme
- [ ] yayin tarihi dogru gorunuyor

### Teklif zinciri

- [ ] teklif gonderme
- [ ] ayni ilana ikinci teklif engeli
- [ ] alinan teklif listede gorunuyor
- [ ] `Teklifi Incele` calisiyor
- [ ] var olan sohbet tekrar aciliyor
- [ ] teklif kabul etme
- [ ] kabul sonrasi sohbet akisi bozulmuyor

### Sohbet

- [ ] ilk mesaj akisi
- [ ] sonraki mesaj akisi
- [ ] sohbet listesi aciliyor
- [ ] sohbet sil/gizle akisi
- [ ] engellenen kullanici davranisi

### Kredi ve odeme

- [ ] kredi paketi satin alma
- [ ] ayni paketi tekrar satin alma
- [ ] yetersiz kredi uyarisi
- [ ] one cikarma akisi

## 5. Moderasyon ve icerik kontrolu

- [ ] tarif olusturma
- [ ] tarif metni yanlis pozitif uretmiyor
- [ ] acikca uygunsuz ornek icerik hala filtreleniyor
- [ ] sikayet olusturma
- [ ] admin panelinde kayit gorunurlugu
- [ ] `Incelendi` ve `Cozuldu` akislari

## 6. Guncelleme kontrolu

- [ ] `app_config/client` dokumani guncel
- [ ] `androidLatestVersion` dogru
- [ ] `androidMinVersion` gerekiyorsa dogru
- [ ] `androidStoreUrl` dogru
- [ ] `iosLatestVersion` dogru
- [ ] `iosMinVersion` gerekiyorsa dogru
- [ ] `iosStoreUrl` dogru
- [ ] uygulama acilinca update dialog beklendigi gibi cikiyor

## 7. Android yayin oncesi

- [ ] yeni `AAB` su konumda olustu:
  - `build/app/outputs/bundle/release/app-release.aab`
- [ ] Play Console uyarilari okundu
- [ ] release notes hazir
- [ ] once internal testing dusunulerek son karar verildi

## 8. iOS yayin oncesi

- [ ] degisiklikler GitHub `main` branch'e push edildi
- [ ] Codemagic dogru branch ve dogru commit ile build aliyor
- [ ] log icinde dogru iOS surumu gorunuyor
- [ ] TestFlight build'i gercekten geldi
- [ ] App Store Connect surum sayfasina dogru build baglandi

## 9. Yayin karari

### Yayin engeli kritikler

- [ ] `permission-denied`
- [ ] `not-found`
- [ ] bozuk Turkce karakter
- [ ] yanlis kullaniciya acik veri
- [ ] satin alma/kredi bozulmasi
- [ ] mesajlasma veya teklif zinciri kopmasi

Bu maddelerden biri varsa:

- [ ] build yayinlanmaz
- [ ] duzeltme yapilir
- [ ] yeni build alinir

## 10. Son karar notu

Her release oncesi kisa not birak:

- Test edilen surum:
- Test tarihi:
- Test eden:
- Bilinen dusuk riskli eksikler:
- Yayina uygun mu: `Evet / Hayir`
