# Destek ve moderasyon otomasyonu

## Tek destek adresi

Tüm web ve uygulama destek yönlendirmeleri şu adrese sabitlenir:

`benyaparimci@gmail.com`

## Gmail otomatik cevap temeli

Gmail tarafında kullanıcı destek e-postası gönderdiğinde otomatik dönüş için:

1. Gmail hesabında `Ayarlar > Tüm ayarları görüntüle > Gelişmiş` bölümünden `Şablonlar` özelliğini aç.
2. Aşağıdaki metinle bir şablon oluştur.
3. `Filtreler ve Engellenen Adresler > Yeni filtre oluştur` alanında `To: benyaparimci@gmail.com` filtresi ekle.
4. Filtre işleminde `Şablon gönder` seçeneğiyle bu cevabı bağla.

Konu:

```text
Destek talebiniz bize ulaştı
```

Gövde:

```text
Merhaba,

Ben Yaparım destek talebiniz bize ulaştı. Mesajınızı inceleyip en kısa sürede size geri dönüş yapacağız.

Hesap, ödeme, güvenlik veya kullanıcı şikayeti gibi konularda ek bilgi gerekiyorsa bu e-postayı yanıtlayarak paylaşabilirsiniz.

Teşekkürler,
Ben Yaparım Destek Ekibi
```

## Moderasyon paneli

Uygulama içindeki admin paneli `moderation_reports` koleksiyonunu okur. Bir kullanıcıyı admin yapmak için Firestore'da ilgili `users/{userId}` dokümanına aşağıdakilerden biri eklenir:

```json
{
  "role": "admin"
}
```

veya

```json
{
  "isAdmin": true
}
```

Bildirim dağıtımı için alternatif olarak `app_config/moderation` dokümanına şu liste de eklenebilir:

```json
{
  "adminUserIds": ["ADMIN_USER_ID"]
}
```

Uygulama içinde `Ayarlar > Admin Paneli` menüsünün görünmesi için kullanıcının kendi `users/{userId}` dokümanında `role: "admin"` veya `isAdmin: true` alanı bulunmalıdır. Admin kullanıcı bu bölümden açık, incelenmiş ve çözülen şikayetleri görebilir.
