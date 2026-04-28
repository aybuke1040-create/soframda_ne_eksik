export const siteConfig = {
  name: "Ben Yaparim",
  domain: "https://benyaparimci.com",
  supportEmail: "destek@benyaparimci.com",
  nav: [
    {href: "/", label: "Ana Sayfa"},
    {href: "/download", label: "Uygulamayi Indir"},
    {href: "/support", label: "Destek"},
    {href: "/terms", label: "Kullanim Kosullari"},
    {href: "/privacy", label: "Gizlilik"},
  ],
  footerNav: [
    {href: "/terms", label: "Kullanim Kosullari"},
    {href: "/privacy", label: "Gizlilik Politikasi"},
    {href: "/support", label: "Destek"},
    {href: "/delete-account", label: "Hesap Silme"},
  ],
  appLinks: {
    android: "https://play.google.com/store/apps/details?id=com.benyaparim.app",
    ios: "",
  },
} as const;

export const steps = [
  {
    title: "Ilan ver",
    copy: "Ihtiyacini birkac net cumleyle paylas. Yemekten organizasyona kadar ne aradigini dogru sekilde anlat.",
  },
  {
    title: "Teklif al",
    copy: "Yakinindaki uygun kisiler sana hizlica donus yapsin. Seceneklerini tek ekranda rahatca karsilastir.",
  },
  {
    title: "Mesajlas",
    copy: "Detaylari uygulama icinden konus. Teslim zamani, beklenti ve fiyat gibi konulari hizlica netlestir.",
  },
  {
    title: "Guvenle ilerle",
    copy: "Sureci tek yerden yonet, dogru kisiyle kolayca bulus ve kararini daha rahat ver.",
  },
] as const;

export const categories = [
  "Ben Yaparim",
  "Ben Tasirim",
  "Ben Dizayn Ederim",
  "Hazir Yemekler",
] as const;

export const trustPoints = [
  {
    title: "Kolay kullanim",
    copy: "Anlasilir akislar sayesinde ilan acmak, teklifleri gormek ve iletisimi surdurmek cok daha pratik.",
  },
  {
    title: "Hizli teklif",
    copy: "Ihtiyacini paylastiktan sonra beklemeden geri donus alabilir, kararini daha kisa surede verebilirsin.",
  },
  {
    title: "Yerel firsatlar",
    copy: "Sana yakin hizmet verenleri kesfet, iletisimi hizlandir ve dogru eslesmeye daha kolay ulas.",
  },
] as const;

export const faqs = [
  {
    question: "Hesabima giremiyorum, ne yapmaliyim?",
    answer:
      "Giris, dogrulama veya hesap bilgileriyle ilgili bir sorun yasiyorsan destek ekibimize yazabilir ve kullandigin iletisim bilgisini paylasabilirsin.",
  },
  {
    question: "Teklifler neden gelmiyor?",
    answer:
      "Ilanin yeterince acik degilse ya da konum bilgisi eksikse gorunurlugun dusebilir. Daha net bir aciklama ve dogru bilgilerle daha hizli donus alirsin.",
  },
  {
    question: "Uygunsuz icerik veya kotuye kullanim gordugumde ne yapabilirim?",
    answer:
      "Uygulama icinden kullaniciyi engelleyebilir, kullaniciyi veya icerigi sikayet edebilir ve destek ekibimize ulasabilirsin. Raporlanan icerikleri en gec 24 saat icinde inceler, gerekirse kaldirir ve ihlal eden hesaplari kapatiriz.",
  },
  {
    question: "Bildirimler gelmiyor, ne kontrol etmeliyim?",
    answer:
      "Telefonundaki bildirim izinlerini ve uygulama ici ayarlari kontrol et. Sorun surerse destek ekibimize ulasabilirsin.",
  },
] as const;
