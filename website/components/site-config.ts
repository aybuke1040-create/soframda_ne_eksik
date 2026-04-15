export const siteConfig = {
  name: "Ben Yaparım",
  domain: "https://benyaparimci.com",
  supportEmail: "destek@benyaparimci.com",
  nav: [
    { href: "/", label: "Ana Sayfa" },
    { href: "/download", label: "Uygulamayı İndir" },
    { href: "/support", label: "Destek" },
    { href: "/privacy", label: "Gizlilik" }
  ],
  footerNav: [
    { href: "/privacy", label: "Gizlilik Politikası" },
    { href: "/support", label: "Destek" },
    { href: "/delete-account", label: "Hesap Silme" }
  ],
  appLinks: {
    android: "https://play.google.com/store/apps/details?id=com.benyaparim.app",
    ios: "https://benyaparimci.com/download#ios"
  }
} as const;

export const steps = [
  {
    title: "İlan ver",
    copy: "İhtiyacını birkaç net cümleyle paylaş. Yemekten organizasyona kadar ne aradığını doğru şekilde anlat."
  },
  {
    title: "Teklif al",
    copy: "Yakınındaki uygun kişiler sana hızlıca dönüş yapsın. Seçeneklerini tek ekranda rahatça karşılaştır."
  },
  {
    title: "Mesajlaş",
    copy: "Detayları uygulama içinden konuş. Teslim zamanı, beklenti ve fiyat gibi konuları hızlıca netleştir."
  },
  {
    title: "Güvenle ilerle",
    copy: "Süreci tek yerden yönet, doğru kişiyle kolayca buluş ve kararını daha rahat ver."
  }
] as const;

export const categories = [
  "Ben Yaparım",
  "Ben Taşırım",
  "Ben Dizayn Ederim",
  "Hazır Yemekler"
] as const;

export const trustPoints = [
  {
    title: "Kolay kullanım",
    copy: "Anlaşılır akışlar sayesinde ilan açmak, teklifleri görmek ve iletişimi sürdürmek çok daha pratik."
  },
  {
    title: "Hızlı teklif",
    copy: "İhtiyacını paylaştıktan sonra beklemeden geri dönüş alabilir, kararını daha kısa sürede verebilirsin."
  },
  {
    title: "Yerel fırsatlar",
    copy: "Sana yakın hizmet verenleri keşfet, iletişimi hızlandır ve doğru eşleşmeye daha kolay ulaş."
  }
] as const;

export const faqs = [
  {
    question: "Hesabıma giremiyorum, ne yapmalıyım?",
    answer:
      "Giriş, doğrulama veya hesap bilgileriyle ilgili bir sorun yaşıyorsan destek ekibimize yazabilir ve kullandığın iletişim bilgisini paylaşabilirsin."
  },
  {
    question: "Teklifler neden gelmiyor?",
    answer:
      "İlanın yeterince açık değilse ya da konum bilgisi eksikse görünürlüğün düşebilir. Daha net bir açıklama ve doğru bilgilerle daha hızlı dönüş alırsın."
  },
  {
    question: "Sipariş veya hizmet sürecinde nasıl iletişim kurarım?",
    answer:
      "Eşleştiğin kişiyle uygulama içindeki mesajlaşma alanından doğrudan iletişim kurabilir, tüm detayları aynı yerde yönetebilirsin."
  },
  {
    question: "Bildirimler gelmiyor, ne kontrol etmeliyim?",
    answer:
      "Telefonundaki bildirim izinlerini ve uygulama içi ayarları kontrol et. Sorun sürerse destek ekibimize ulaşabilirsin."
  }
] as const;
