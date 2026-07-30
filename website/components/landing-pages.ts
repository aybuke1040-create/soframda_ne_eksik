export type LandingPage = {
  slug: string;
  name: string;
  metaTitle: string;
  metaDescription: string;
  eyebrow: string;
  headline: string;
  summary: string;
  intentAnswer: string;
  highlights: string[];
  useCases: string[];
  steps: { title: string; copy: string }[];
  faqs: { question: string; answer: string }[];
};

export const landingPages: LandingPage[] = [
  {
    slug: "ev-yemegi",
    name: "Ev Yemeği",
    metaTitle: "Ev Yemeği Siparişi ve Yakındaki Ev Aşçıları",
    metaDescription:
      "Yakınındaki ev yemeği seçeneklerini keşfet, ihtiyacını ilan olarak paylaş, porsiyon ve teslimat detaylarını konuşarak teklifleri karşılaştır.",
    eyebrow: "Ev yemeği arayanlar için",
    headline: "Yakınındaki ev aşçılarına ulaş, ev yemeği ihtiyacın için teklif al.",
    summary:
      "Günlük yemek, misafir sofrası veya belirli sayıda porsiyon için ihtiyacını paylaş. Ben Yaparım, ev yemeği arayanlarla yakın çevrede üretim yapan kişilerin uygulama içinde iletişim kurmasını kolaylaştırır.",
    intentAnswer:
      "Ev yemeği siparişi vermek için uygulamada yemek türünü, porsiyon sayısını, tarihi ve yaklaşık konumunu belirten bir ilan açabilirsin. Yakındaki uygun kişiler teklif gönderir; menü, alerjen, teslimat ve fiyat ayrıntılarını mesajlaşarak netleştirirsin.",
    highlights: [
      "Porsiyon ve teslim tarihi belirterek net talep oluşturma",
      "Yakındaki evden üretim yapan kişilerden teklif alma",
      "Menü, içerik ve alerjen ayrıntılarını mesajla konuşma",
      "Puan ve yorumları inceleyerek karar verme"
    ],
    useCases: [
      "Günlük ev yemeği ve çalışanlar için öğle yemeği",
      "Kalabalık aile sofraları için tencere yemeği",
      "Misafir ağırlarken çorba, ana yemek ve yardımcı yemek",
      "Mantı, sarma, börek ve yöresel yemek talepleri",
      "Belirli beslenme tercihine uygun menü arayışı"
    ],
    steps: [
      {
        title: "İhtiyacını tarif et",
        copy: "Yemek adını, porsiyon sayısını, teslim tarihini ve varsa içerik tercihlerini yaz."
      },
      {
        title: "Yakın teklifleri karşılaştır",
        copy: "Gelen teklifleri fiyat, profil puanı, yorum ve uygunluk bilgisiyle birlikte değerlendir."
      },
      {
        title: "Detayları mesajlaş",
        copy: "Teslim şekli, alerjenler, menü içeriği ve saat gibi önemli ayrıntıları netleştir."
      }
    ],
    faqs: [
      {
        question: "Yakınımda ev yemeği yapan birini nasıl bulabilirim?",
        answer:
          "Ben Yaparım uygulamasında konumunu ve ihtiyacını belirten bir ilan açabilirsin. Konum ve bildirim izinleri açık olduğunda yakın çevredeki uygun kullanıcılar talebini görerek teklif gönderebilir."
      },
      {
        question: "Ev yemeği siparişinde en az kaç porsiyon istemeliyim?",
        answer:
          "Platform genel bir minimum porsiyon belirlemez. İhtiyacın olan miktarı ilana yazarsın; hizmet verenler hazırlayabilecekleri miktara göre teklif verir."
      },
      {
        question: "Günlük ev yemeği fiyatı nasıl belirlenir?",
        answer:
          "Fiyat; menü içeriği, porsiyon sayısı, malzeme, hazırlanma süresi ve teslimat koşullarına göre değişir. Ben Yaparım fiyat belirlemez veya yemek bedelinden komisyon almaz; taraflar ayrıntıları kendi aralarında netleştirir."
      },
      {
        question: "Alerjen veya özel beslenme tercihimi belirtebilir miyim?",
        answer:
          "Evet. Alerjen, vejetaryen menü, az tuzlu yemek veya istemediğin malzemeler gibi bilgileri ilan açıklamasında ve mesajlaşmada açıkça belirtmelisin. Son kararı vermeden önce içeriği hizmet verenle doğrulaman önemlidir."
      },
      {
        question: "Ev yemeği teslimatı uygulama tarafından mı yapılır?",
        answer:
          "Hayır. Ben Yaparım eşleşme ve iletişim sağlayan bir pazaryeridir. Elden teslim, adresten alma veya farklı bir teslimat yöntemi taraflar arasında kararlaştırılır."
      },
      {
        question: "Evden yemek yapan biri uygulamada müşteri bulabilir mi?",
        answer:
          "Evet. Profilini tamamlayıp yakınındaki uygun ilanları inceleyebilir ve yapabileceğin işler için teklif gönderebilirsin. Üretim ve satış faaliyetlerinde bulunduğun yerde geçerli mevzuat ve hijyen yükümlülüklerini takip etmek senin sorumluluğundadır."
      }
    ]
  },
  {
    slug: "kucuk-tasima",
    name: "Küçük Taşıma",
    metaTitle: "Küçük Taşıma ve Parça Eşya Taşıma Teklifi",
    metaDescription:
      "Tek parça veya az miktarda eşya için küçük taşıma ilanı ver; araç, mesafe, kat ve zaman bilgilerini paylaşarak yakındaki taşıma tekliflerini karşılaştır.",
    eyebrow: "Parça eşya ve küçük nakliye için",
    headline: "Büyük nakliye aramadan, küçük taşıma ihtiyacın için yerel teklif al.",
    summary:
      "Tek bir koltuk, birkaç koli, beyaz eşya veya kısa mesafeli parça eşya taşıması için ayrıntılı ilan oluştur. Uygun araç ve zamanı olan kişilerden teklif alarak süreci uygulama içinde yönet.",
    intentAnswer:
      "Küçük taşıma teklifi almak için eşyanın türünü ve ölçüsünü, alınacağı ve bırakılacağı yaklaşık konumu, kat bilgisini, asansör durumunu ve istediğin tarihi yazmalısın. Bu bilgiler taşıma tekliflerinin daha doğru hazırlanmasını sağlar.",
    highlights: [
      "Tek parça ve az hacimli eşya için ilan açma",
      "Mesafe, kat, asansör ve araç ihtiyacını belirtme",
      "Yakındaki taşıma tekliflerini tek ekranda karşılaştırma",
      "Teslim zamanı ve taşıma koşullarını mesajla netleştirme"
    ],
    useCases: [
      "Koltuk, masa, sandalye veya dolap taşıma",
      "Öğrenci evi için birkaç koli ve küçük eşya",
      "Buzdolabı, çamaşır makinesi veya televizyon taşıma",
      "İnternetten alınan ikinci el eşyanın adrese getirilmesi",
      "Aynı ilçe içinde kısa mesafeli parça eşya taşıması"
    ],
    steps: [
      {
        title: "Eşyayı ve rotayı anlat",
        copy: "Ölçü, ağırlık, kat, asansör, başlangıç ve varış bilgilerini mümkün olduğunca açık yaz."
      },
      {
        title: "Araç ve yardım ihtiyacını belirt",
        copy: "Taşıma için yalnız araç mı yoksa yükleme ve indirme desteği de mi gerektiğini ekle."
      },
      {
        title: "Teklifi ve zamanı netleştir",
        copy: "Fiyata dahil hizmetleri, tarihi ve olası ek koşulları mesajlaşarak doğrula."
      }
    ],
    faqs: [
      {
        question: "Küçük taşıma ile evden eve nakliyat arasındaki fark nedir?",
        answer:
          "Küçük taşıma genellikle tek parça veya sınırlı sayıdaki eşyanın kısa ya da orta mesafede taşınmasını ifade eder. Komple ev taşımaya göre daha az araç alanı ve daha kısa operasyon gerektirir."
      },
      {
        question: "Parça eşya taşıma fiyatı nasıl hesaplanır?",
        answer:
          "Mesafe, eşyanın hacmi ve ağırlığı, kat ve asansör durumu, yükleme desteği, araç tipi ve tarih fiyatı etkiler. Platform sabit fiyat belirlemez; hizmet verenler ilan ayrıntılarına göre teklif sunar."
      },
      {
        question: "Taşıma ilanına hangi bilgileri eklemeliyim?",
        answer:
          "Eşyanın fotoğrafı ve yaklaşık ölçüsü, alınacağı ve bırakılacağı semt, katlar, asansör bilgisi, tarih, sökme veya kurulum gereksinimi ve yüklemeye yardımcı olacak kişi olup olmadığını yazmalısın."
      },
      {
        question: "Aynı gün küçük nakliye teklifi alabilir miyim?",
        answer:
          "Yakındaki kullanıcıların uygunluğuna bağlı olarak aynı gün teklif gelebilir. Acil olduğunu, net saat aralığını ve tüm taşıma ayrıntılarını ilan başlığında belirtmek dönüşü hızlandırabilir."
      },
      {
        question: "Eşyanın zarar görmesine karşı sigorta sağlanıyor mu?",
        answer:
          "Ben Yaparım taşıma hizmetini doğrudan sunmaz ve otomatik sigorta sağlamaz. Sigorta, paketleme ve hasar sorumluluğu gibi koşulları işi kabul etmeden önce hizmet verenle açıkça konuşmalısın."
      },
      {
        question: "Taşıma ödemesi uygulamadan mı yapılır?",
        answer:
          "Hayır. Ben Yaparım iş bedelini tahsil etmez. Fiyat ve ödeme yöntemi hizmet alan ile hizmet veren arasında kararlaştırılır."
      }
    ]
  },
  {
    slug: "organizasyon",
    name: "Organizasyon",
    metaTitle: "Organizasyon, Süsleme ve Etkinlik Hizmeti Teklifi",
    metaDescription:
      "Doğum günü, nişan, açılış ve özel gün organizasyonu için konseptini paylaş; süsleme ve etkinlik hizmeti verenlerden yerel teklifler al.",
    eyebrow: "Kutlama ve etkinlik planlayanlar için",
    headline: "Organizasyon fikrini paylaş, konseptine uygun yerel hizmet verenlerle buluş.",
    summary:
      "Doğum günü, nişan, söz, açılış veya küçük davet için tarihini, kişi sayını ve konsept beklentini yaz. Organizasyon ve süsleme işi yapan kişilerden teklif alıp ayrıntıları tek yerde konuş.",
    intentAnswer:
      "Organizasyon teklifi alırken etkinlik türünü, tarihi, yeri, tahmini kişi sayısını, tema ve renkleri, ihtiyaç duyulan masa düzeni, süsleme veya ikram ayrıntılarını belirtmek gerekir. Net bir bütçe aralığı eklemek uygun tekliflere daha hızlı ulaşmayı sağlayabilir.",
    highlights: [
      "Etkinlik tarihi, kişi sayısı ve konsepti tek ilanda toplama",
      "Süsleme, masa düzeni ve yardımcı hizmetleri belirtme",
      "Yerel organizasyon tekliflerini karşılaştırma",
      "Örnek çalışma, kapsam ve kurulum saatini mesajla doğrulama"
    ],
    useCases: [
      "Çocuk ve yetişkin doğum günü organizasyonu",
      "Nişan, söz ve isteme günü masa süslemesi",
      "Mağaza veya işletme açılış konsepti",
      "Baby shower, mezuniyet ve özel gün kutlaması",
      "Evde veya küçük mekânda davet düzeni"
    ],
    steps: [
      {
        title: "Konsepti tanımla",
        copy: "Etkinlik türünü, renkleri, temayı, kişi sayısını, yeri ve tarihi belirt."
      },
      {
        title: "Kapsamı karşılaştır",
        copy: "Tekliflerde kurulum, söküm, masa, arka fon, balon ve diğer kalemlerin dahil olup olmadığını incele."
      },
      {
        title: "Planı kesinleştir",
        copy: "Örnek görselleri, giriş saatini, teslim koşullarını ve son değişiklik tarihini mesajlaşarak onayla."
      }
    ],
    faqs: [
      {
        question: "Organizasyon teklifi almak için hangi bilgileri vermeliyim?",
        answer:
          "Etkinliğin türü, tarih ve saat, konum, kişi sayısı, konsept veya renk tercihi, istediğin hizmetler ve yaklaşık bütçe aralığı en yararlı bilgilerdir."
      },
      {
        question: "Sadece süsleme hizmeti için ilan açabilir miyim?",
        answer:
          "Evet. Yalnızca balon süsleme, masa düzeni, arka fon, karşılama panosu veya belirli bir dekorasyon ihtiyacı için ilan oluşturabilirsin."
      },
      {
        question: "Doğum günü organizasyonu fiyatı neye göre değişir?",
        answer:
          "Konseptin kapsamı, kullanılacak malzemeler, kişi sayısı, mekân, kurulum süresi, özel üretimler ve ek hizmetler fiyatı etkiler. Her teklifin hangi kalemleri kapsadığını karşılaştırmalısın."
      },
      {
        question: "Organizasyon hizmeti verenlerin önceki çalışmalarını görebilir miyim?",
        answer:
          "Profil bilgilerini, puanları ve mevcut örnekleri inceleyebilir; ayrıca mesajlaşma sırasında benzer çalışmaların görsellerini ve ayrıntılarını isteyebilirsin."
      },
      {
        question: "Mekân bulma hizmeti de sunuluyor mu?",
        answer:
          "İlanında mekân ihtiyacını belirtebilirsin; ancak mevcut seçenekler hizmet verenlerin sunduğu kapsama göre değişir. Mekânın kapasitesi, kullanım koşulları ve ücretini ayrıca doğrulamalısın."
      },
      {
        question: "Organizasyon için kapora ve iptal koşulları nasıl belirlenir?",
        answer:
          "Ben Yaparım kapora veya iptal koşulu belirlemez. Ödeme takvimi, iptal, tarih değişikliği ve iade koşullarını işi kabul etmeden önce hizmet verenle yazılı biçimde netleştirmen gerekir."
      }
    ]
  },
  {
    slug: "pasta",
    name: "Pasta",
    metaTitle: "Ev Yapımı Pasta ve Özel Gün Pastası Siparişi",
    metaDescription:
      "Doğum günü ve özel gün pastası için kişi sayısı, tema, aroma ve teslim tarihini paylaş; yakınındaki pasta yapan kişilerden teklif al.",
    eyebrow: "Özel gün pastası arayanlar için",
    headline: "Hayalindeki pastayı tarif et, yakınındaki pasta üreticilerinden teklif al.",
    summary:
      "Doğum günü, kutlama veya özel bir masa için kişi sayısını, görsel beklentini, aroma ve teslim tarihini belirterek ilan aç. Yakın çevrede pasta yapan kişilerle ayrıntıları mesajlaşarak netleştir.",
    intentAnswer:
      "Özel pasta siparişinde kişi sayısı, pasta ölçüsü, tema veya referans görsel, kek ve krema aroması, yazılacak mesaj, alerjenler ve teslim tarihi belirtilmelidir. Teslim sırasında pastanın nasıl korunacağını da önceden konuşmak önemlidir.",
    highlights: [
      "Kişi sayısı, tema ve aroma bilgisiyle talep oluşturma",
      "Referans görsel ve yazı beklentisini paylaşma",
      "Yakındaki ev yapımı pasta tekliflerini değerlendirme",
      "Alerjen, teslim ve saklama ayrıntılarını konuşma"
    ],
    useCases: [
      "Çocuk ve yetişkin doğum günü pastası",
      "Nişan, söz ve yıldönümü pastası",
      "Butik tasarımlı veya fotoğraflı pasta",
      "Cupcake, mini pasta ve kişiye özel kutlama seti",
      "Belirli aroma veya içerik tercihine uygun pasta"
    ],
    steps: [
      {
        title: "Pastayı tarif et",
        copy: "Kişi sayısı, tema, renk, aroma, yazı ve teslim tarihi gibi ayrıntıları ekle."
      },
      {
        title: "Örnekleri ve teklifleri incele",
        copy: "Profil, yorum, benzer çalışma ve teklif kapsamını birlikte değerlendir."
      },
      {
        title: "Teslimi planla",
        copy: "Alerjen, saklama, taşıma, teslim saati ve son tasarım onayını mesajla netleştir."
      }
    ],
    faqs: [
      {
        question: "Doğum günü pastası siparişini kaç gün önce vermeliyim?",
        answer:
          "Basit pastalar daha kısa sürede hazırlanabilir; özel figür, baskı veya detaylı tasarım isteyen pastalarda daha erken ilan açmak seçenekleri artırır. Kesin hazırlık süresini teklif veren kişiyle doğrulamalısın."
      },
      {
        question: "Kaç kişilik pasta gerektiğini nasıl hesaplarım?",
        answer:
          "Dilim büyüklüğü, pasta şekli ve menüde başka tatlıların bulunması porsiyon hesabını etkiler. Davetli sayını ilana yazıp önerilen ölçüyü pasta yapan kişiyle birlikte belirleyebilirsin."
      },
      {
        question: "Referans görseldeki pastanın aynısı yapılabilir mi?",
        answer:
          "Referans görsel beklentini anlatmaya yardımcı olur; malzeme, teknik ve telifli karakter ayrıntıları nedeniyle sonuç birebir aynı olmayabilir. Yapılabilecek uyarlamayı siparişten önce konuşmalısın."
      },
      {
        question: "Pasta fiyatına teslimat dahil mi?",
        answer:
          "Teklifin kapsamına göre değişir. Adrese teslim, elden alma, taşıma mesafesi ve teslim saati gibi bilgileri kabulden önce açıkça doğrulamalısın."
      },
      {
        question: "Alerjen içermeyen pasta isteyebilir miyim?",
        answer:
          "Alerjen veya özel içerik tercihini ilana ekleyebilirsin. Ancak çapraz bulaşma riski ve üretim ortamı hakkında doğrudan üreticiden ayrıntılı bilgi almalı, sağlık açısından kritik durumlarda profesyonel görüşe göre hareket etmelisin."
      },
      {
        question: "Ev yapımı pasta satmak isteyenler nasıl teklif verir?",
        answer:
          "Uygulamada profilini tamamladıktan sonra yakınındaki uygun pasta ilanlarını inceleyebilir ve hazırlayabileceğin taleplere teklif gönderebilirsin. Yerel üretim, hijyen ve satış kurallarına uymak hizmet verenin sorumluluğundadır."
      }
    ]
  },
  {
    slug: "ikramlik",
    name: "İkramlık",
    metaTitle: "Davet İkramlıkları, Börek, Sarma ve Tatlı Siparişi",
    metaDescription:
      "Davet, gün ve toplantı için börek, sarma, kurabiye, tatlı ve diğer ikramlık ihtiyaçlarını paylaş; yakınındaki üreticilerden teklif al.",
    eyebrow: "Davet ve toplantı sofraları için",
    headline: "İkramlık listesini paylaş, sofrana uygun yerel teklifleri karşılaştır.",
    summary:
      "Misafir, gün, toplantı veya kutlama için börekten sarmaya, kurabiyeden tatlıya kadar ihtiyacını tek ilanda anlat. Adet, porsiyon, tarih ve teslim detaylarıyla yakınındaki kişilerden teklif al.",
    intentAnswer:
      "İkramlık siparişi için ürün listesini, kişi sayısını veya adetleri, teslim tarih ve saatini, sunum ya da paketleme beklentisini ve alerjen bilgilerini yazmalısın. Birden fazla ürün istiyorsan her ürünün miktarını ayrı belirtmek teklifleri karşılaştırmayı kolaylaştırır.",
    highlights: [
      "Birden fazla ikramlığı tek listede talep etme",
      "Adet, porsiyon, paketleme ve teslim saatini belirtme",
      "Yerel üreticilerden farklı menü teklifleri alma",
      "İçerik, tazelik ve sunum ayrıntılarını mesajla konuşma"
    ],
    useCases: [
      "Altın günü ve ev daveti için börek, sarma ve salata",
      "Doğum günü için kurabiye, cupcake ve mini sandviç",
      "Ofis toplantısı için tuzlu ve tatlı atıştırmalık",
      "Nişan veya söz masası için karışık ikramlık",
      "Kalabalık misafir için adetli hamur işi ve meze"
    ],
    steps: [
      {
        title: "Menü ve miktarı yaz",
        copy: "Her ürünün adedini veya porsiyonunu, kişi sayısını ve istemediğin içerikleri belirt."
      },
      {
        title: "Teklif kapsamını karşılaştır",
        copy: "Paketleme, sunum tabağı, teslimat ve ürün çeşitlerinin fiyata dahil olup olmadığını incele."
      },
      {
        title: "Tazelik ve teslimi doğrula",
        copy: "Hazırlanma zamanı, saklama koşulları ve teslim saatini mesajlaşarak netleştir."
      }
    ],
    faqs: [
      {
        question: "Kişi başı ne kadar ikramlık hesaplanır?",
        answer:
          "Etkinliğin süresi, ana yemek olup olmaması, ürün çeşitliliği ve davetli profili miktarı değiştirir. Kişi sayını ve etkinlik türünü yazıp teklif verenlerden porsiyon önerisi alabilirsin."
      },
      {
        question: "Karışık ikramlık menüsü için tek ilan açabilir miyim?",
        answer:
          "Evet. Börek, sarma, kısır, kurabiye ve tatlı gibi tüm ihtiyaçlarını adetleriyle birlikte aynı ilanda listeleyebilirsin."
      },
      {
        question: "İkramlık siparişi ne kadar önce verilmelidir?",
        answer:
          "Ürün çeşidi ve miktarı arttıkça daha erken ilan açmak uygundur. Küçük siparişler daha kısa sürede hazırlanabilir; kesin süreyi teklif veren kişiyle doğrulamalısın."
      },
      {
        question: "İkramlıklar paketli veya sunuma hazır gelebilir mi?",
        answer:
          "Paketleme ve sunum hizmeti teklif veren kişiye göre değişir. Tek kullanımlık kutu, servis tabağı veya ayrı porsiyon paket istediğini ilana eklemelisin."
      },
      {
        question: "Tatlı ve tuzlu ürünleri farklı kişilerden alabilir miyim?",
        answer:
          "Evet. Gelen tekliflerin kapsamını karşılaştırarak tüm menüyü tek kişiden veya farklı ürünleri farklı hizmet verenlerden temin etmeyi seçebilirsin."
      },
      {
        question: "İkramlıklarda içerik ve alerjen bilgisini nasıl öğrenirim?",
        answer:
          "İlanında hassasiyetlerini belirtmeli ve kabulden önce kullanılan malzemeleri hizmet verenle doğrulamalısın. Sağlık açısından kritik alerjilerde üretim ortamı ve çapraz bulaşma riskini özellikle sormalısın."
      }
    ]
  }
];

export const landingPageBySlug = Object.fromEntries(
  landingPages.map((page) => [page.slug, page])
) as Record<string, LandingPage>;
