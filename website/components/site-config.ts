export const siteConfig = {
  name: "Ben Yaparım",
  domain: "https://benyaparimci.com",
  supportEmail: "benyaparimci@gmail.com",
  nav: [
    { href: "/", label: "Ana Sayfa" },
    { href: "/download", label: "Uygulamayı İndir" },
    { href: "/support", label: "Destek" },
    { href: "/terms", label: "Kullanım Koşulları" },
    { href: "/privacy", label: "Gizlilik" },
    { href: "/#sss", label: "S.S.S." }
  ],
  footerNav: [
    { href: "/terms", label: "Kullanım Koşulları" },
    { href: "/privacy", label: "Gizlilik Politikası" },
    { href: "/support", label: "Destek" },
    { href: "/delete-account", label: "Hesap Silme" }
  ],
  appLinks: {
    android: "https://play.google.com/store/apps/details?id=com.benyaparim.app",
    ios: "https://apps.apple.com/app/id6762226701"
  }
} as const;

export const steps = [
  {
    title: "İlan ver",
    copy:
      "İhtiyacını birkaç net cümleyle paylaş. Yemekten organizasyona kadar ne aradığını doğru şekilde anlat."
  },
  {
    title: "Teklif al",
    copy:
      "Yakınındaki uygun kişiler sana hızlıca dönüş yapsın. Seçeneklerini tek ekranda rahatça karşılaştır."
  },
  {
    title: "Mesajlaş",
    copy:
      "Detayları uygulama içinden konuş. Teslim zamanı, beklenti ve fiyat gibi konuları hızlıca netleştir."
  },
  {
    title: "Güvenle ilerle",
    copy:
      "Süreci tek yerden yönet, doğru kişiyle kolayca buluş ve kararını daha rahat ver."
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
    copy:
      "Anlaşılır akışlar sayesinde ilan açmak, teklifleri görmek ve iletişimi sürdürmek çok daha pratik."
  },
  {
    title: "Hızlı teklif",
    copy:
      "İhtiyacını paylaştıktan sonra beklemeden geri dönüş alabilir, kararını daha kısa sürede verebilirsin."
  },
  {
    title: "Yerel fırsatlar",
    copy:
      "Sana yakın hizmet verenleri keşfet, iletişimi hızlandır ve doğru eşleşmeye daha kolay ulaş."
  }
] as const;

export const faqs = [
  {
    question: "Ben Yaparım nedir ve nasıl çalışır?",
    answer:
      "Ben Yaparım; hizmet arayan kullanıcılarla evden üretim yapan, yerel hizmet sunan veya emeğiyle iş almak isteyen kişileri buluşturan mobil pazaryeri uygulamasıdır. Kullanıcı ilan açar, yakınındaki hizmet verenlerden teklif alır, teklifleri karşılaştırır ve süreci uygulama içi güvenli mesajlaşma ile yönetir."
  },
  {
    question: "Ben Yaparım uygulamasının diğer hizmet ve nakliye uygulamalarından farkı nedir?",
    answer:
      "Ben Yaparım büyük ve karmaşık işler yerine yakın çevredeki pratik ihtiyaçlara odaklanır: ev yemeği, ikram, küçük taşıma, organizasyon ve tasarım gibi yerel hizmetler. Platform komisyon almaz; amaç işi en yakındaki doğru kişiyle hızlı ve zahmetsiz buluşturmaktır."
  },
  {
    question: "Ben Yaparım uygulaması üzerinden ne tür ilanlar açabilirim?",
    answer:
      "Ev yemeği, doğum günü pastası, davet ikramlığı, toplu yemek, hazır yemek, organizasyon, nişan veya kutlama süslemesi, açılış konsepti, küçük hacimli taşıma, parça eşya taşıma ve benzeri yerel hizmet ihtiyaçları için ilan oluşturabilirsiniz."
  },
  {
    question: "Evden yemek veya üretim yapan biri olarak neden bu uygulamayı indirmeliyim?",
    answer:
      "Yakın çevredeki potansiyel müşterilere görünür olursunuz, profil puanı ve yorumlarla güven inşa edersiniz, teklif ve mesajları tek yerden yönetirsiniz. Ben Yaparım komisyon almadığı için kazancınız doğrudan size kalır."
  },
  {
    question: "Uygulamada ödeme süreci nasıl işliyor, banka veya kart bilgisi istenir mi?",
    answer:
      "Ben Yaparım iş bedellerinden komisyon almaz ve kullanıcıların banka hesap bilgisi, kart şifresi veya ödeme bilgilerini istemez. Hizmet bedeli ve ödeme yöntemi hizmet alan ile hizmet veren arasında platform dışında kararlaştırılır."
  },
  {
    question: "Uygulamayı kullanırken telefon numaram diğer kullanıcılar tarafından görülür mü?",
    answer:
      "Hayır. Telefon numaranız ve kişisel iletişim bilgileriniz diğer kullanıcılara gösterilmez. İlan, teklif ve hizmet detaylarını uygulama içi güvenli mesajlaşma üzerinden paylaşabilirsiniz."
  },
  {
    question: "Yakın çevremdeki ilanlardan nasıl haberdar olabilirim?",
    answer:
      "Konum servisleri ve bildirimler açık olduğunda yakınınızdaki yeni ilanlar, teklifler ve mesajlar için bildirim alabilirsiniz. Böylece mahallenizdeki güncel hizmet taleplerini ve fırsatları kaçırmazsınız."
  },
  {
    question: "Uygulama içi kredileri nasıl kazanabilirim ve kredi satın alabilir miyim?",
    answer:
      "Yeni kullanıcılar hoş geldin kredisi alır. Günlük giriş ödülleri, tarif paylaşımı ve uygulama içi etkinliklerle ek kredi kazanabilirsiniz. İsterseniz küçük tutarlı kredi paketleri de satın alabilirsiniz."
  },
  {
    question: "Açılan ilanlar neden belirli bir süre sonra otomatik olarak siliniyor?",
    answer:
      "Platformdaki ilanların güncel kalması için süre sınırı vardır. Hazır yemek ve ev yemeği ilanları tazelik amacıyla 2 gün sonra, diğer hizmet ilanları ise genellikle 7 gün sonra otomatik olarak yayından kalkar."
  },
  {
    question: "Ben Yaparım güvenli mi, sorun yaşarsam ne yapabilirim?",
    answer:
      "Uygulama içi mesajlaşma, profil puanı, şikayet, engelleme ve moderasyon özellikleri güvenli deneyim için tasarlanmıştır. Uygunsuz içerik, kötüye kullanım veya şüpheli davranış gördüğünüzde kullanıcıyı engelleyebilir, ilanı şikayet edebilir veya destek ekibine ulaşabilirsiniz."
  }
] as const;
