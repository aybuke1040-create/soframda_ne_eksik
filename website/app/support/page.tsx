import type {Metadata} from "next";
import {SupportForm} from "@/components/SupportForm";
import {faqs, siteConfig} from "@/components/site-config";

export const metadata: Metadata = {
  title: "Destek",
  alternates: {
    canonical: "/support",
  },
};

const platformAgreementTitle =
  "BEN YAPARIM PLATFORM KULLANIM ŞARTLARI, ARACILIK, SORUMLULUK SINIRLARI VE KİŞİSEL VERİLERİN KORUNMASI SÖZLEŞMESİ";

const platformAgreementSections = [
  {
    title: "1. Taraflar, Sözleşmenin Konusu ve Hukuki Niteliği",
    paragraphs: [
      'İşbu Ben Yaparım Platform Kullanım Şartları, Aracılık, Sorumluluk Sınırları ve Kişisel Verilerin Korunması Sözleşmesi, bir tarafta [Şirket Adı / Girişim Adı] tarafından işletilen "Ben Yaparım" adlı dijital uygulama, internet sitesi ve/veya mobil uygulama sistemi ile diğer tarafta Platform\'u kullanan gerçek ve/veya tüzel kişiler arasında akdedilmiştir.',
      "İşbu sözleşmenin amacı; Platform'un hukuki niteliğini, işleyiş sınırlarını, kullanıcıların karşılıklı hak ve yükümlülüklerini, Platform'un taşıma, yemek siparişi ve organizasyon siparişi süreçlerindeki konumunu, sorumluluk sınırlarını ve kişisel verilerin korunmasına ilişkin kuralları açık, anlaşılır ve yorum ihtimalini azaltacak şekilde düzenlemektir.",
      "Taraflar açıkça kabul eder ki Platform; kullanıcıları dijital ortamda bir araya getiren, ilan, eşleştirme, iletişim, mesajlaşma ve teknik aracılık işlevi gören bir yazılım/teknoloji altyapısıdır. Platform; taşıma hizmeti, yemek hazırlama hizmeti, organizasyon hizmeti, kurulum hizmeti, lojistik hizmeti, nakliye, kurye, kargo, catering, etkinlik planlama, davet organizasyonu veya benzeri bir hizmeti kendi adına sunmaz, üstlenmez, organize etmez ve ifa etmez. Platform'un sunduğu hizmet yalnızca, kullanıcıların birbirini bulmasına ve kendi aralarında sözleşme görüşmesi yapmasına imkân veren teknik bir ortam sağlamaktır.",
      "Kullanıcılar; taşıma, yemek siparişi veya organizasyon siparişi kapsamında kurulabilecek her türlü hukuki ilişkinin yalnızca ilgili kullanıcılar arasında doğacağını; Platform'un bu ilişkilerin tarafı olmadığını; sözleşme kurucu, ifa eden, temerrüde düşen, bedel alacaklısı, bedel borçlusu, taşıyıcı, satıcı, sağlayıcı, organizatör, aracı hizmet sağlayıcı olarak hareket eden taraf sıfatını haiz olmadığını kabul, beyan ve taahhüt eder.",
    ],
  },
  {
    title: "2. Platform'un Rolü ve Sınırları",
    paragraphs: [
      "Platform'un rolü; kullanıcıların ilan oluşturması, ilanları görüntülemesi, filtrelemesi, eşleştirme sonuçlarını görmesi, karşılıklı mesajlaşması ve kendi aralarında iletişim kurması ile sınırlıdır. Platform, kullanıcıların hangi ilanı kabul edeceğine, hangi kullanıcıyla anlaşacağına, hangi bedelle anlaşacağına, hangi hizmetin seçileceğine, hangi tarihte, hangi adreste veya hangi içerikle hizmet verileceğine ilişkin hiçbir karar vermez ve yönlendirme yapmaz.",
      "Platform, eşleştirme sonucu oluşan iş, sipariş veya hizmet ilişkilerinde tarafların anlaşmasını kolaylaştıran teknik bir araçtır. Platform'un sistemi; fiyat belirleme, pazarlık etme, hizmetin içeriğini tayin etme, teslim zamanını zorunlu kılma, güzergâhı belirleme, personel tahsis etme, hizmetin kalitesini garanti etme veya ifa sürecini denetleme amaçlı kullanılmaz. Kullanıcılar arasında oluşan ilişkinin hukuki niteliği, sadece ilgili kullanıcıların beyanları, fiili davranışları ve kendi aralarında kurdukları sözleşme ile belirlenir.",
      "Kullanıcılar; Platform'da yer alan ilanların, mesajların, görsellerin, açıklamaların ve teknik eşleştirme sonuçlarının Platform tarafından sahiplenilmediğini; bunların yalnızca kullanıcılar tarafından sağlandığını; Platform'un bunlar üzerinde satıcı, sağlayıcı, taşımacı, organizatör, teslimatçı veya benzeri bir sıfat üstlenmediğini kabul eder.",
    ],
  },
  {
    title: "3. Taşıma, Yemek ve Organizasyon Siparişlerinde Taraf Olmama",
    paragraphs: [
      "Kullanıcılar, Platform üzerinden taşıma, yemek siparişi veya organizasyon siparişi için iletişime geçilmesi ve eşleşme sağlanmasının, Platform'u ilgili sözleşmenin tarafı haline getirmeyeceğini açıkça kabul eder. Platform; ne taşıma ilişkisinde taşımacı veya taşıma işleri komisyoncusu, ne yemek siparişinde satıcı/sağlayıcı/catering hizmeti sunan, ne de organizasyon siparişinde organizatör, etkinlik sağlayıcısı veya hizmet sağlayıcıdır.",
      "Taşıma ilişkilerinde taşıma hizmetini fiilen üstlenen kişi, sözleşmenin tarafı olan kullanıcıdır. Yemek siparişlerinde yemeği hazırlayan, sağlayan, temin eden veya teslim etmeyi üstlenen taraf, ilgili kullanıcıdır. Organizasyon siparişlerinde etkinliği planlayan, kuran, icra eden veya bu işe ilişkin hizmeti sunan taraf yine ilgili kullanıcıdır. Platform bu hizmetlerin bedelini belirlemez, hizmeti kendi adına üstlenmez, ifayı taahhüt etmez ve hizmetin sonucundan sorumlu olmaz.",
      'Kullanıcılar, Platform\'un söz konusu hizmetlere dair yalnızca bir "tanışma, eşleştirme ve iletişim" altyapısı olduğunu; hizmetin kendisinin Platform tarafından verilmediğini; dolayısıyla tüketici, müşteri, alıcı, gönderici, katılımcı veya hizmetten yararlanan kişi ile Platform arasında ilgili hizmete ilişkin bir satım, eser, vekâlet, taşıma, organizasyon veya hizmet sözleşmesi kurulmadığını kabul eder.',
    ],
  },
  {
    title: "4. Fiyat, Ücret ve Bedel Politikası",
    paragraphs: [
      "Platform, taşıma, yemek siparişi veya organizasyon siparişi kapsamında ortaya çıkan ücret, bedel, komisyon, ücret tarifesi, paket fiyat, servis bedeli, hizmet bedeli, iptal bedeli, ceza koşulu veya ek maliyetleri tek taraflı olarak belirlemez. Taraflar arasındaki bedel, tamamen kullanıcıların kendi serbest iradeleriyle, kendi aralarında belirledikleri koşullara göre ortaya çıkar.",
      "Platform, kullanıcılar arasında oluşan bedel konusunda herhangi bir teklif, onay, garanti, tahsilat veya dağıtım mekanizması kurmadıkça, bu bedelin tarafı değildir. Platform üzerinde yer alan fiyat alanları, teklif kutuları, tahmini tutar gösterimleri veya benzeri teknik unsurlar, bağlayıcı fiyat bildirimi, resmi tarife, taahhüt ya da Platform adına verilmiş bir ücret garantisi olarak değerlendirilemez. Bu unsurlar yalnızca kullanıcıların birbirini değerlendirmesine ve kendi aralarında iletişim kurmasına yardımcı olan teknik araçlardır.",
      "Kullanıcılar, Platform'un herhangi bir siparişte veya hizmette ücretin alacaklısı, borçlusu, tahsil edeni, havuzlayanı, dağıtıcısı, garantörü veya sorumlusu olmadığını; bedelin doğrudan kullanıcılar arasında kararlaştırıldığını; Platform'un bu ekonomik ilişkiye taraf olmadığını kabul eder. Platform'un gelir elde etmesi halinde bu gelir, varsa yalnızca yazılım erişim bedeli, abonelik, reklam, görünürlük artırma, ilan yayınlama veya teknik hizmet bedeli niteliğinde olur; taşıma, yemek veya organizasyon hizmetinin satış bedeli olarak yorumlanmaz.",
    ],
  },
  {
    title: "5. Hizmetin İfası, Teslim ve Organizasyon Süreci",
    paragraphs: [
      "Platform; taşıma, yemek veya organizasyon hizmetlerinin ifasını, teslimini, hazırlanmasını, icrasını, zamanlamasını, yönlendirilmesini veya koordinasyonunu üstlenmez. Kullanıcılar arasındaki hizmetin nasıl, ne zaman, nerede, hangi araçla, hangi personelle, hangi içerikle, hangi menüyle, hangi ekipmanla veya hangi etkinlik planı ile gerçekleşeceği tamamen tarafların kendi arasında belirleyeceği husustur.",
      "Yemek siparişlerinde ürünün hazırlanması, pişirilmesi, paketlenmesi, hijyen uygunluğu, teslim süresi, sıcaklık, içerik doğruluğu, porsiyon, menü ve kalite gibi hususlar ilgili satıcı/sağlayıcı kullanıcının sorumluluğundadır. Organizasyon siparişlerinde organizasyonun planlanması, mekân uygunluğu, ekipman, servis, zamanlama, katılımcı yönetimi, kurulum ve benzeri unsurlar ilgili hizmet sağlayıcı kullanıcının sorumluluğundadır. Taşıma siparişlerinde ise eşyanın uygun şekilde hazırlanması, taşınması, teslimi, yükleme ve boşaltılması ilgili taşıyan kullanıcının sorumluluğundadır.",
      "Platform, teslim sürecinin fiilen yönetilmesi, gecikmenin telafisi, ikame ürün sunulması, eksik ifanın tamamlanması, kalite kontrol, hasar tazmini, yeniden hizmet verilmesi veya hizmetin yeniden organize edilmesi konusunda herhangi bir doğrudan borç üstlenmez. Taraflar arasında oluşabilecek her türlü ihtilaf, ilgili tarafların kendi aralarında çözümlenecek özel hukuk ilişkisi niteliğindedir.",
    ],
  },
  {
    title: "6. Kullanıcıların Birbirine Karşı Kurduğu İlişkinin Niteliği",
    paragraphs: [
      "Kullanıcılar, Platform'un bir tarafı olmaksızın kendi aralarında taşıma, yemek siparişi veya organizasyon siparişi ilişkisi kurabilir. Bu durumda taraflar; sözleşmenin türünü, kapsamını, ifa zamanını, hizmetin içeriğini, bedelini, teslim şeklini, iptal koşullarını, gecikme yaptırımını, iade hükümlerini, sorumluluk sınırlarını ve varsa sigorta/teminat düzenlemelerini kendi iradeleriyle belirler.",
      "Platform'un sağladığı sistem, tarafların birbirini bulmasına yarayan teknik bir araç olduğundan, Platform'a atfedilebilecek herhangi bir edim borcu doğmaz. Kullanıcılar, Platform'un kendilerine sadece eşleşme sağladığını; sözleşmenin kurulmasına aracılık etmekle birlikte sözleşmenin ifasını üstlenmediğini; bu nedenle ifa, ayıp, gecikme, zarar, eksik teslim, yanlış teslim veya hizmet kalitesi bakımından doğrudan sorumlu olmadığını kabul eder.",
      "Taraflar, Platform'un sözleşme metinlerine, mesaj içeriklerine, ilan açıklamalarına veya kullanıcılar arasındaki müzakerelere müdahale etmediğini; hizmetin içeriğini belirlemediğini; kullanıcılar arasındaki anlaşmanın sadece taraflar bakımından hüküm doğurduğunu kabul eder.",
    ],
  },
  {
    title: "7. Farklı Hizmet Türlerine İlişkin Özel Hükümler",
    paragraphs: [
      "7.1 Taşıma Siparişleri: Taşıma siparişlerinde Platform; taşıma yolu, güzergâh, araç tipi, teslim noktası, yükleme sırası, teslim süresi, emniyet tedbiri, paketleme, yükün niteliği ve teslim koşulları hakkında karar vermez. Taşımanın hukuki ve fiili sorumluluğu, hizmeti üstlenen kullanıcıya aittir. Platform, taşıma işini kendi adına üstlenen ya da taşıma bedelini kendisi tahsil eden taraf değildir.",
      "7.2 Yemek Siparişleri: Yemek siparişlerinde Platform; satıcı veya sağlayıcının menüsünü, pişirme sürecini, kullanılan malzemeleri, ürünün gıda güvenliğini, hijyenini, teslim kalitesini, porsiyonunu, alerjen bilgisini, paketlemesini ve zamanında teslimini üstlenmez. Bu hususlarda sorumluluk, ilgili yemeği hazırlayan ve/veya teslim etmeyi üstlenen kullanıcıya aittir. Platform yalnızca alıcı ile satıcı/sağlayıcıyı buluşturur.",
      "7.3 Organizasyon Siparişleri: Organizasyon siparişlerinde Platform; etkinliğin tasarımı, kurulum planı, sahne düzeni, ekipman tedariki, servis personeli, konuk yönetimi, mekân uygunluğu, program akışı, davet listesi, görsel/işitsel düzen, güvenlik, izinler ve benzeri konularda hiçbir taahhüt altına girmez. Organizasyonun başarısı, kapsamı ve ifası tamamen ilgili kullanıcıların sorumluluğundadır. Platform yalnızca organizatör ile hizmet talep eden kişiyi dijital ortamda buluşturur.",
    ],
  },
  {
    title: "8. Kullanıcı Beyanları ve Garanti Yasağı",
    paragraphs: [
      "Kullanıcı, Platform üzerinden yaptığı her ilan, teklif, kabul, mesaj, açıklama ve yükleme işleminin kendi sorumluluğunda olduğunu; bunların hukuka uygun, doğru, yanıltıcı olmayan ve eksiksiz olması gerektiğini kabul eder. Kullanıcı, Platform'u kendi hizmetiymiş gibi tanıtmayacağını, üçüncü kişilere Platform'un taşıma, yemek, organizasyon veya teslimat hizmetini üstlendiğini söylemeyeceğini, böyle bir algı oluşturacak beyanlarda bulunmayacağını taahhüt eder.",
      "Kullanıcı; hizmetin içeriği, kalitesi, süresi, teslimatı, ürün güvenliği, etkinlik başarısı, ulaşım güvenliği ve benzeri unsurlar bakımından Platform'un herhangi bir garanti vermediğini kabul eder. Platform üzerinden kurulan ilişki, taraflar arasında bağımsız bir özel hukuk ilişkisi doğurur; Platform bu ilişkinin doğal sonucu olarak ortaya çıkabilecek herhangi bir borçtan sorumlu değildir.",
    ],
  },
  {
    title: "9. Sorumluluğun Sınırlandırılması",
    paragraphs: [
      "Platform, kullanıcılar arasındaki taşıma, yemek veya organizasyon ilişkilerinden doğabilecek gecikme, kayıp, hasar, bozulma, yanlış teslim, eksik teslim, ayıplı hizmet, hizmetin hiç ifa edilmemesi, iptal, anlaşmazlık, iletişim problemi, ifa kalitesizliği, üçüncü kişi müdahalesi, ödeme ihtilafı ve benzeri sonuçlardan kural olarak sorumlu değildir.",
      "Platform'un sorumluluğu varsa, yalnızca kendi doğrudan kusurundan kaynaklanan ve dijital altyapının çalışmaması, teknik erişim hatası, sistemsel kayıt problemi veya Platform'un kendi kontrol alanındaki bir ihlalden doğan zararlarla sınırlıdır. Kullanıcılar arasındaki hizmet ilişkisi nedeniyle Platform'un taşıyıcı, satıcı, sağlayıcı, organizatör veya hizmetin fiilen ifa eden tarafı gibi yorumlanamayacağı kabul edilir.",
      "Taraflar, Platform'un hiçbir durumda hizmetin sonucu, kalitesi, zamanlaması veya içeriği bakımından teminat vermediğini; Platform'a karşı bu nedenlerle tazminat, bedel iadesi, yeniden ifa, cezai şart veya benzeri talepler ileri sürülemeyeceğini kabul eder.",
    ],
  },
  {
    title: "10. İçerik Denetimi ve Hukuka Uygunluk",
    paragraphs: [
      "Platform, hukuka aykırı, yanıltıcı, hileli, suç teşkil eden, kamu düzenini bozan veya üçüncü kişilerin haklarını ihlal eden içerikleri kaldırma, erişimi sınırlama, ilanı askıya alma, kullanıcıyı uyarma veya üyeliği sonlandırma yetkisini saklı tutar. Bu yetki, Platform'un hizmetin tarafı olduğu anlamına gelmez; yalnızca güvenli ve hukuka uygun işletim amacıyla kullanılır.",
      "Kullanıcı, Platform üzerinden sunulan hizmetlerde ilgili mevzuata, tüketici hukukuna, vergi düzenlemelerine, gıda güvenliğine, etkinlik/izin düzenlemelerine, taşıma kurallarına, kişisel verilerin korunması hükümlerine ve mesafeli sözleşmeler ile elektronik ticaret hükümlerine uygun davranmak zorundadır. Platform, kullanıcıların kendi mevzuat uyumundan sorumlu değildir; ancak hukuka aykırılık şüphesi halinde gerekli önlemleri alabilir.",
    ],
  },
  {
    title: "11. Ödemeler, Tahsilat ve Transfer Mekanizması",
    paragraphs: [
      "Platform, aksi açıkça belirtilmedikçe kullanıcılar arasındaki hizmet bedelini tahsil eden taraf değildir. Platform üzerinde görülen ücret, tahmini ücret, teklif, fiyat aralığı veya maliyet bilgileri, taraflar arasında kurulabilecek ilişkiye dair teknik/öneri niteliğinde olup, bağlayıcı tahsilat hükmü doğurmaz. Kullanıcılar, ödemeyi kendi aralarında ve kendi yöntemleriyle gerçekleştireceklerini kabul eder.",
      "Platform üzerinden ileride bir ödeme altyapısı kullanılacaksa, bunun kapsamı ayrıca ayrı bir ödeme sözleşmesi ve ödeme hizmetine ilişkin bilgilendirme metni ile düzenlenir. Aksi halde Platform'un ödeme akışını yönetmesi, bedeli kendi hesabında toplaması veya bedeli taraflar adına dağıtması, işbu sözleşmedeki aracı platform niteliğiyle çelişebilir. Bu nedenle, kullanıcılar ödeme ilişkisinin Platform'dan bağımsız kurulduğunu kabul eder.",
    ],
  },
  {
    title: "12. Tazminat ve Rücu",
    paragraphs: [
      "Kullanıcı, kendi kusuru, ihmali, yanıltıcı beyanı, mevzuata aykırı davranışı veya Platform'u yanlış tanıtıcı söz ve işlemleri nedeniyle Platform'un uğrayabileceği tüm zararları tazmin etmeyi kabul eder. Kullanıcı, üçüncü kişilerin Platform'u taşıyıcı, satıcı, sağlayıcı, organizatör veya fiili hizmet sunucusu olarak görmesi nedeniyle doğabilecek taleplerde Platform'un zarar görmesi halinde bu zararı karşılayacağını kabul eder.",
      "Platform'un hukuken sorumlu tutulması halinde dahi, bu sorumluluğun yalnızca kendi doğrudan kusuruyla sınırlı olduğu; kullanıcıların birbirlerine karşı üstlendikleri hizmet borçlarının, ifa yükümlülüklerinin ve sözleşmesel sonuçların Platform'a rücu edilemeyeceği kabul edilir.",
    ],
  },
  {
    title: "13. Sözleşmenin Yorumu ve Öncelik",
    paragraphs: [
      "İşbu sözleşmenin yorumunda esas alınacak temel ilke, Platform'un hiçbir şekilde taşıma, yemek veya organizasyon hizmetini üstlenmediği; yalnızca kullanıcıları dijital ortamda buluşturan teknik aracılık fonksiyonu gördüğüdür. Kullanıcıların Platform'u satıcı, sağlayıcı, taşıyıcı, organizatör, teslim eden, ifa eden, sipariş alan veya hizmet garantörü gibi yorumlaması kabul edilemez.",
      "Sözleşmenin herhangi bir hükmünün geçersiz hale gelmesi, diğer hükümlerin geçerliliğini etkilemez. Özellikle Platform'un aracı/teknik platform niteliğini koruyan hükümler, sözleşmenin temelini oluşturur ve dar yorumlanamaz.",
    ],
  },
  {
    title: "14. Son Hükümler",
    paragraphs: [
      "İşbu sözleşme, kullanıcı ile Platform arasındaki hukuki ilişkiyi ve özellikle taşıma, yemek siparişi ve organizasyon siparişi bakımından Platform'un sorumluluk sınırlarını belirlemek amacıyla düzenlenmiştir. Kullanıcı, Platform'u kullanmakla işbu sözleşmeyi okuduğunu, anladığını ve kabul ettiğini beyan eder.",
      "Platform, işbu sözleşmede açıkça düzenlenmeyen hiçbir durumda ilgili hizmetlerin tarafı sayılmaz. Kullanıcılar arasındaki taşıma, yemek veya organizasyon ilişkileri, kendi aralarında kurdukları özel hukuki ilişkidir ve Platform'a sirayet etmez.",
      "İşbu sözleşmenin kabulü, Platform'un taşıma işleri komisyoncusu, acente, taşımacı, satıcı, sağlayıcı, organizatör veya benzeri bir sıfatla nitelendirilmesine hak vermez. Platform'un hukuki konumu, işbu sözleşme ile aracı teknik platform olarak açıkça sınırlandırılmıştır.",
    ],
  },
  {
    title: "15. Kişisel Verilerin Korunması, Veri Paylaşımı ve Sorumluluk Sınırı",
    paragraphs: [
      "Taraflar, işbu Platform kapsamında paylaşılabilecek ad, soyad, kullanıcı adı, iletişim bilgileri, adres, konum, sipariş bilgisi, ilan içeriği, mesajlaşma verileri, teslimat ve hizmet ifasına ilişkin bilgiler dâhil olmak üzere kişisel verilerin; yalnızca Platform'un hizmetin teknik olarak sunulması, kullanıcılar arasında eşleştirme sağlanması, sözleşme kurulmasına aracılık edilmesi, güvenlik, uyuşmazlık yönetimi, ispat yükümlülüğü, mevzuata uyum ve sistem bütünlüğünün sağlanması amaçlarıyla, ilgili mevzuatta öngörülen şartlar çerçevesinde işleneceğini kabul eder.",
      "Kullanıcılar, Platform üzerinden birbirlerine ilettikleri veya birbirlerinden temin ettikleri kişisel veriler bakımından, kendilerinin bağımsız veri sorumlusu olabileceklerini; bu kapsamda birbirlerine aktardıkları kişisel verilerin hukuka uygun şekilde elde edilmesi, aktarılması, saklanması, silinmesi, anonimleştirilmesi ve kullanılmasından kendi aralarında sorumlu olduklarını kabul eder. Platform, yalnızca kendi sisteminde yer alan veri işleme faaliyetleri yönünden veri sorumlusu sıfatını haiz olup; kullanıcıların kendi aralarında kurdukları iletişim, sözleşme, teslimat, hizmet ifası veya ödeme süreçlerinde üçüncü kişilerce yapılan her türlü kişisel veri işleme faaliyetinin otomatik olarak tarafı sayılmaz.",
      "Kullanıcılar, Platform'a veya diğer kullanıcılara ait kişisel verileri; ilgili kişinin açık rızası, kanunda öngörülen bir işleme şartı veya diğer hukuki sebepler bulunmadıkça üçüncü kişilerle paylaşmayacaklarını; bu verileri işleme amacı dışında kullanmayacaklarını; spam, izinsiz iletişim, yetkisiz kayıt, kopyalama, depolama, ifşa veya aktarma işlemleri gerçekleştirmeyeceklerini kabul ve taahhüt eder. Kullanıcılar tarafından hukuka aykırı biçimde yapılan veri paylaşımı, ifşası veya aktarımı nedeniyle doğabilecek tüm idari, hukuki ve cezai sorumluluk ilgili kullanıcıya aittir.",
      "Platform, kişisel verilerin korunması için gerekli teknik ve idari tedbirleri alma yükümlülüğünü yerine getirmekle birlikte; kullanıcıların kendi cihazları, hesapları, şifreleri, mesaj içerikleri, ekran görüntüleri, dış iletişim kanalları veya kendi iradeleriyle gerçekleştirdikleri veri aktarım ve paylaşım işlemlerinden kaynaklanan ihlaller bakımından, kanunen zorunlu olduğu hâller hariç, sorumlu tutulamaz. Kullanıcı, Platform'un veri güvenliğini sağlamak için makul teknik önlemler almasına rağmen, kendi kusuru, ihmal veya yetkisiz erişim sonucunda doğan veri ihlallerinden Platform'u sorumlu tutamayacağını kabul eder.",
      "Taraflar, Platform'un işbu sözleşme kapsamındaki veri işleme faaliyetlerinin; hukuka ve dürüstlük kurallarına uygun, belirli, açık ve meşru amaçlarla, amaçla bağlantılı, sınırlı ve ölçülü şekilde gerçekleştirileceğini; ilgili mevzuatta veya işleme amacının gerektirdiği süre boyunca muhafaza edilip sonrasında silineceğini, yok edileceğini veya anonim hâle getirileceğini kabul eder. Platform'un gizlilik politikası, aydınlatma metni ve varsa açık rıza metinleri işbu sözleşmenin ayrılmaz tamamlayıcılarıdır.",
      "Kullanıcı, Platform'un kendi veri işleme faaliyetleri dışında, kullanıcıların birbirleriyle doğrudan kurdukları iletişim, hizmet ifası, teslimat, ödeme ve benzeri süreçlerde tarafların kendi veri sorumluluğu yükümlülüklerinden bağımsız olarak sorumlu tutulamayacağını kabul eder. Kullanıcıların kişisel verileri kullanma, paylaşma, aktarma veya saklama işlemlerinden doğacak ihlallerin hukuki sonuçları, ilgili kullanıcı veya kullanıcılar bakımından doğar.",
      "Platform'un, veri güvenliği, sistem bütünlüğü, kullanıcı doğrulama, sahteciliğin önlenmesi, uyuşmazlık çözümü ve mevzuata uyum amacıyla makul teknik ve idari tedbirleri alması; Platform'un kullanıcılar arasında gerçekleşen veri paylaşımının, ifanın, teslimin veya hizmetin tarafı olduğu anlamına gelmez. Platform, yalnızca kendi sisteminde gerçekleşen veri işleme süreçleri bakımından ve kendi kusuru oranında sorumludur.",
      "İşbu madde, Platform'un veri koruma hukukundaki pozisyonunu koruyan temel düzenleme olup, yorumda öncelikle dikkate alınır.",
    ],
  },
] as const;

export default function SupportPage() {
  return (
    <div className="section-shell py-16 sm:py-20">
      <div className="max-w-3xl">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">
          Support
        </p>
        <h1 className="mt-3 text-4xl font-black tracking-tight text-ink sm:text-5xl">
          İhtiyacın olduğunda destek burada
        </h1>
        <p className="mt-5 text-lg leading-8 text-slate-600">
          Hesap, teklifler, siparişler, mesajlaşma veya bildirimlerle ilgili
          yardıma ihtiyaç duyduğunda bize kolayca ulaşabilirsin. Uygunsuz içerik,
          kötüye kullanım, sahte ilan veya güvenlik kaygıları için de bu sayfayı
          kullanabilirsin.
        </p>
      </div>

      <div className="mt-10 grid gap-6 lg:grid-cols-[1.05fr_.95fr]">
        <SupportForm />

        <div className="glass-card rounded-4xl p-6 sm:p-8">
          <h2 className="text-2xl font-black text-ink">Destek e-postası</h2>
          <a
            href={`mailto:${siteConfig.supportEmail}`}
            className="mt-4 inline-block text-lg font-bold text-plum-700"
          >
            {siteConfig.supportEmail}
          </a>

          <div className="mt-8 rounded-3xl bg-white p-5">
            <h2 className="text-2xl font-black text-ink">Güvenlik ve moderasyon</h2>
            <ul className="mt-4 space-y-3 text-sm leading-7 text-slate-600">
              <li>Kullanıcılar uygulama içinden uygunsuz içeriği ve kullanıcıları şikayet edebilir.</li>
              <li>Kötüye kullanım gösteren kullanıcılar engellenebilir ve engellenen kullanıcıların içeriği akıştan gizlenir.</li>
              <li>Raporlanan içerikler ve kullanıcılar en geç 24 saat içinde incelenir.</li>
              <li>Uygunsuz içerik kaldırılır, tekrar eden ihlallerde hesap kapatılabilir ve gerekli durumlarda geliştirici ekibi bilgilendirilir.</li>
              <li>Topluluğumuzu korumak için taciz, tehdit, nefret söylemi, cinsel istismar, dolandırıcılık ve spam içeriklere tolerans göstermeyiz.</li>
            </ul>
          </div>

          <div className="mt-8 rounded-3xl bg-white p-5">
            <h2 className="text-2xl font-black text-ink">İçerik veya kullanıcı nasıl bildirilir?</h2>
            <ol className="mt-4 space-y-3 text-sm leading-7 text-slate-600">
              <li>Uygulamada ilgili profil, sohbet veya ilan detay ekranına gir.</li>
              <li>"Şikayet Et" veya "Kullanıcıyı Engelle" seçeneğini kullan.</li>
              <li>Gerekirse destek ekibine ekran görüntüsü ve ek açıklama gönder.</li>
              <li>Destek ekibi raporu kayda alır, inceler ve sonucuna göre içeriği veya hesabı kaldırır.</li>
            </ol>
          </div>

          <div className="mt-8 rounded-3xl bg-white p-5">
            <h2 className="text-2xl font-black text-ink">{platformAgreementTitle}</h2>
            <div className="mt-5 space-y-5">
              {platformAgreementSections.map((section) => (
                <section key={section.title} className="rounded-2xl bg-slate-50 p-4">
                  <h3 className="text-base font-black text-ink">{section.title}</h3>
                  <div className="mt-3 space-y-3 text-sm leading-7 text-slate-600">
                    {section.paragraphs.map((paragraph) => (
                      <p key={paragraph}>{paragraph}</p>
                    ))}
                  </div>
                </section>
              ))}
            </div>
          </div>

          <div className="mt-8">
            <h2 className="text-2xl font-black text-ink">Sık sorulan sorular</h2>
            <div className="mt-4 space-y-4">
              {faqs.map((faq) => (
                <details key={faq.question} className="rounded-3xl bg-white p-4">
                  <summary className="cursor-pointer list-none text-base font-bold text-ink">
                    {faq.question}
                  </summary>
                  <p className="mt-3 text-sm leading-7 text-slate-600">{faq.answer}</p>
                </details>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
