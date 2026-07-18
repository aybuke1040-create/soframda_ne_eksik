const TZ = 'Europe/Istanbul';
const META_CONFIG = {
  apiVersion: 'v24.0',
  statusPosted: 'posted',
  statusPublishing: 'publishing',
  statusError: 'error',
  maxContainerWaitMs: 120000,
  pollIntervalMs: 10000,
};

const SHEET_NAMES = {
  readme: 'README',
  plan: 'AYLIK_PLAN',
  queue: 'GUNLUK_KUYRUK',
  settings: 'AYARLAR',
  archive: 'ARSIV',
};

const PLAN_HEADERS = [
  'week_start',
  'campaign_theme',
  'priority_rank',
  'platform',
  'account_name',
  'post_title',
  'caption_tr',
  'cta_short',
  'creative_brief',
  'post_day',
  'post_time',
  'goal',
  'status',
  'approval',
  'asset_url',
  'scheduled_at',
  'meta_post_id',
  'notes',
];

const QUEUE_HEADERS = [
  'scheduled_at',
  'platform',
  'post_title',
  'caption_tr',
  'cta_short',
  'asset_url',
  'goal',
  'status',
  'source_row',
  'operator_notes',
];

const SETTINGS_HEADERS = ['key', 'value', 'description'];

const README_LINES = [
  ['Amac', 'Ucretsiz ve surdurulebilir Meta sosyal medya icerik operasyonu'],
  ['Model', 'Google Sheets + Apps Script + website-hosted gorseller + Facebook/Instagram otomatik yayin'],
  ['Sekmeler', 'AYLIK_PLAN, GUNLUK_KUYRUK, AYARLAR, ARSIV'],
  ['Durum akisi', 'ready -> queued_meta -> posted'],
  ['Onay akisi', 'pending -> approved'],
  ['Operasyon notu', 'Facebook ve Instagram icin asset_url her zaman dogrudan HTTPS gorsel linki olmali.'],
];

const SETTINGS_ROWS = [
  ['brand_name', 'Ben Yaparim', 'Marka adi'],
  ['timezone', TZ, 'Planlama zaman dilimi'],
  ['base_asset_url', 'https://benyaparimci.com/social/', 'Gorsellerin temel URL yolu'],
  ['queue_window_days', '1', 'Gunluk kuyruga kac gun ileri tarih alinacagi'],
  ['operator_name', '', 'Otomasyonu takip eden kisi'],
];

function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('Ben Yaparim Ops')
    .addItem('Workbook kur', 'setupWorkbook')
    .addItem('Haziran 2026 planini yukle', 'seedJune2026Plan')
    .addItem('7 Temmuz 2026 haftasini yukle', 'seedJuly72026WeekPlan')
    .addItem('Gunluk kuyrugu olustur', 'buildDailyQueue')
    .addSeparator()
    .addItem('Meta kuyrugunu paylas', 'publishMetaQueue')
    .addToUi();
}

function setupWorkbook() {
  const ss = getWorkbook_();
  createReadmeSheet_(ss);
  createDataSheet_(ss, SHEET_NAMES.plan, PLAN_HEADERS, [
    'Aylik ana plan buraya yazilir.',
    'Onaylanmis ve ready durumundaki satirlar gunluk kuyruga tasinir.',
    'scheduled_at alanini duz metin ISO formatta tutun. Ornek: 2026-06-04T13:00:00+03:00',
  ]);
  createDataSheet_(ss, SHEET_NAMES.queue, QUEUE_HEADERS, [
    'Bugun yayinlanacak ya da gecikmis onayli icerikler burada listelenir.',
    'Yayin sonrasi kaynak satiri posted yapin.',
  ]);
  createDataSheet_(ss, SHEET_NAMES.settings, SETTINGS_HEADERS, [
    'Sistem ayarlari ve referans degerler.',
  ]);
  createDataSheet_(ss, SHEET_NAMES.archive, PLAN_HEADERS, [
    'Tamamlanan veya kullanilmayan satirlar burada saklanabilir.',
  ]);
  writeSettings_(ss);
  SpreadsheetApp.flush();
}

function seedJune2026Plan() {
  const ss = getWorkbook_();
  const sheet = ss.getSheetByName(SHEET_NAMES.plan) || createDataSheet_(ss, SHEET_NAMES.plan, PLAN_HEADERS, []);
  clearDataRows_(sheet);

  const rows = getJune2026Rows_();
  if (!rows.length) return;

  sheet.getRange(3, 1, rows.length, PLAN_HEADERS.length).setValues(rows);
  sheet.autoResizeColumns(1, PLAN_HEADERS.length);
}

function seedJuly72026WeekPlan() {
  const ss = getWorkbook_();
  const sheet = ss.getSheetByName(SHEET_NAMES.plan) || createDataSheet_(ss, SHEET_NAMES.plan, PLAN_HEADERS, []);
  const rows = getJuly72026Rows_();
  const startRow = Math.max(sheet.getLastRow() + 1, 3);

  if (!rows.length) return;

  sheet.getRange(startRow, 1, rows.length, PLAN_HEADERS.length).setValues(rows);
  sheet.autoResizeColumns(1, PLAN_HEADERS.length);
}

function buildDailyQueue() {
  const ss = getWorkbook_();
  const planSheet = ss.getSheetByName(SHEET_NAMES.plan);
  const queueSheet = ss.getSheetByName(SHEET_NAMES.queue) || createDataSheet_(ss, SHEET_NAMES.queue, QUEUE_HEADERS, []);

  if (!planSheet) {
    throw new Error('AYLIK_PLAN sekmesi bulunamadi. Once setupWorkbook ve seedJune2026Plan calistirin.');
  }

  clearDataRows_(queueSheet);

  const lastRow = planSheet.getLastRow();
  if (lastRow < 3) return;

  const values = planSheet.getRange(3, 1, lastRow - 2, PLAN_HEADERS.length).getValues();
  const today = midnight_(new Date());
  const queueRows = [];

  values.forEach((row, index) => {
    const rowObj = objectFromRow_(PLAN_HEADERS, row);
    if (String(rowObj.approval).toLowerCase() !== 'approved') return;
    if (String(rowObj.status).toLowerCase() !== 'ready') return;

    const scheduled = parseIsoLikeDate_(rowObj.scheduled_at);
    if (!scheduled) return;

    if (midnight_(scheduled).getTime() <= today.getTime()) {
      queueRows.push([
        rowObj.scheduled_at,
        rowObj.platform,
        rowObj.post_title,
        rowObj.caption_tr,
        rowObj.cta_short,
        rowObj.asset_url,
        rowObj.goal,
        'queued_meta',
        index + 3,
        '',
      ]);

      planSheet.getRange(index + 3, PLAN_HEADERS.indexOf('status') + 1).setValue('queued_meta');
      planSheet.getRange(index + 3, PLAN_HEADERS.indexOf('notes') + 1).setValue('Gunluk kuyruga tasindi');
    }
  });

  if (queueRows.length) {
    queueSheet.getRange(3, 1, queueRows.length, QUEUE_HEADERS.length).setValues(queueRows);
  }
}

function createDailyTrigger() {
  ScriptApp.newTrigger('buildDailyQueue')
    .timeBased()
    .everyDays(1)
    .atHour(8)
    .create();
}

function publishMetaQueue() {
  const lock = LockService.getScriptLock();

  if (!lock.tryLock(30000)) {
    Logger.log('Baska bir calisma devam ediyor. Bu calisma atlandi.');
    return;
  }

  try {
    const ss = getWorkbook_();
    const queueSheet = ss.getSheetByName(SHEET_NAMES.queue);
    const planSheet = ss.getSheetByName(SHEET_NAMES.plan);

    if (!queueSheet) {
      throw new Error('GUNLUK_KUYRUK sekmesi bulunamadi. Once buildDailyQueue calistirin.');
    }

    const lastRow = queueSheet.getLastRow();
    if (lastRow < 3) {
      Logger.log('Paylasilacak kuyruk satiri yok.');
      return;
    }

    const values = queueSheet.getRange(3, 1, lastRow - 2, QUEUE_HEADERS.length).getValues();

    for (let i = 0; i < values.length; i++) {
      const rowNumber = i + 3;
      const row = objectFromRow_(QUEUE_HEADERS, values[i]);
      const platform = normalizePlatform_(row.platform);
      const status = String(row.status || '').toLowerCase();

      if (!isMetaPlatform_(platform)) continue;
      if (status === META_CONFIG.statusPosted || status === META_CONFIG.statusPublishing) continue;

      const scheduled = parseIsoLikeDate_(row.scheduled_at);
      if (scheduled && scheduled.getTime() > Date.now()) continue;

      queueSheet.getRange(rowNumber, QUEUE_HEADERS.indexOf('status') + 1).setValue(META_CONFIG.statusPublishing);
      queueSheet.getRange(rowNumber, QUEUE_HEADERS.indexOf('operator_notes') + 1).clearContent();
      SpreadsheetApp.flush();

      try {
        const caption = buildMetaCaption_(row);
        const result = publishToMetaPlatform_(platform, row.asset_url, caption);

        queueSheet.getRange(rowNumber, QUEUE_HEADERS.indexOf('status') + 1).setValue(META_CONFIG.statusPosted);
        queueSheet.getRange(rowNumber, QUEUE_HEADERS.indexOf('operator_notes') + 1).setValue(result.platform + ' id: ' + result.id);

        markSourcePlanPosted_(planSheet, row.source_row, result);
        Logger.log('Meta paylasim tamamlandi. Satir: ' + rowNumber + ', platform: ' + result.platform);
      } catch (err) {
        const message = err && err.message ? err.message : String(err);
        queueSheet.getRange(rowNumber, QUEUE_HEADERS.indexOf('status') + 1).setValue(META_CONFIG.statusError);
        queueSheet.getRange(rowNumber, QUEUE_HEADERS.indexOf('operator_notes') + 1).setValue(message.substring(0, 45000));
        Logger.log('Meta paylasim hatasi. Satir: ' + rowNumber + ' - ' + message);
      }

      return;
    }

    Logger.log('Bekleyen Facebook/Instagram paylasimi bulunamadi.');
  } finally {
    lock.releaseLock();
  }
}

function createMetaPublishingTrigger() {
  ScriptApp.newTrigger('publishMetaQueue')
    .timeBased()
    .everyHours(1)
    .create();
}

function createReadmeSheet_(ss) {
  const sheet = getOrCreateSheet_(ss, SHEET_NAMES.readme);
  sheet.clear();
  sheet.getRange('A1').setValue('Ben Yaparim Icerik Operasyonu');
  sheet.getRange('A1').setFontWeight('bold').setFontSize(14);
  sheet.getRange(3, 1, README_LINES.length, 2).setValues(README_LINES);
  sheet.getRange(3, 1, README_LINES.length, 1).setFontWeight('bold');
  sheet.autoResizeColumns(1, 2);
  sheet.setFrozenRows(1);
  return sheet;
}

function createDataSheet_(ss, name, headers, notes) {
  const sheet = getOrCreateSheet_(ss, name);
  sheet.clear();
  if (notes.length) {
    sheet.getRange('A1').setValue(notes.join(' | '));
    sheet.getRange('A1').setFontStyle('italic');
  }
  sheet.getRange(2, 1, 1, headers.length).setValues([headers]);
  sheet.getRange(2, 1, 1, headers.length).setFontWeight('bold');
  sheet.setFrozenRows(2);
  sheet.autoResizeColumns(1, headers.length);
  return sheet;
}

function writeSettings_(ss) {
  const sheet = ss.getSheetByName(SHEET_NAMES.settings);
  if (!sheet) return;
  clearDataRows_(sheet);
  sheet.getRange(3, 1, SETTINGS_ROWS.length, SETTINGS_HEADERS.length).setValues(SETTINGS_ROWS);
  sheet.autoResizeColumns(1, SETTINGS_HEADERS.length);
}

function clearDataRows_(sheet) {
  const lastRow = sheet.getLastRow();
  if (lastRow > 2) {
    sheet.getRange(3, 1, lastRow - 2, sheet.getMaxColumns()).clearContent();
  }
}

function getOrCreateSheet_(ss, name) {
  return ss.getSheetByName(name) || ss.insertSheet(name);
}

function getWorkbook_() {
  const spreadsheetId = getOptionalProperty_('SPREADSHEET_ID');

  if (spreadsheetId) {
    return SpreadsheetApp.openById(spreadsheetId);
  }

  const ss = SpreadsheetApp.getActive();
  if (!ss) {
    throw new Error('Aktif Google Sheet bulunamadi. Script Properties icine SPREADSHEET_ID ekleyin veya scripti Google Sheet icinden Extensions > Apps Script ile acin.');
  }

  return ss;
}

function objectFromRow_(headers, row) {
  return headers.reduce((acc, key, index) => {
    acc[key] = row[index];
    return acc;
  }, {});
}

function midnight_(date) {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

function parseIsoLikeDate_(value) {
  if (!value) return null;
  const text = String(value).trim();
  const parsed = new Date(text);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

function publishToMetaPlatform_(platform, assetUrl, caption) {
  const url = normalizeAssetUrl_(assetUrl);
  validateHttpsUrl_(url, 'Asset URL');

  if (platform === 'facebook') {
    return publishFacebookPagePost_(url, caption);
  }

  if (platform === 'instagram') {
    return publishInstagramImage_(url, caption);
  }

  throw new Error('Desteklenmeyen Meta platformu: ' + platform);
}

function publishFacebookPagePost_(assetUrl, caption) {
  const pageId = getRequiredProperty_('META_PAGE_ID');
  const token = getRequiredProperty_('META_PAGE_ACCESS_TOKEN');
  const endpoint = metaGraphUrl_(pageId + '/photos');

  const json = fetchJson_(endpoint, {
    method: 'post',
    payload: {
      url: assetUrl,
      caption: caption,
      published: true,
      access_token: token,
    },
    muteHttpExceptions: true,
  });

  if (!json.id && !json.post_id) {
    throw new Error('Facebook yayinlama basarisiz: ' + JSON.stringify(json));
  }

  return {
    platform: 'Facebook',
    id: json.post_id || json.id,
  };
}

function publishInstagramImage_(assetUrl, caption) {
  const igAccountId = getRequiredProperty_('INSTAGRAM_BUSINESS_ACCOUNT_ID');
  const token = getInstagramToken_();
  const containerId = createInstagramImageContainer_(igAccountId, assetUrl, caption, token);

  waitUntilInstagramContainerReady_(containerId, token);

  const publishJson = fetchJson_(metaGraphUrl_(igAccountId + '/media_publish'), {
    method: 'post',
    payload: {
      creation_id: containerId,
      access_token: token,
    },
    muteHttpExceptions: true,
  });

  if (!publishJson.id) {
    throw new Error('Instagram yayinlama basarisiz: ' + JSON.stringify(publishJson));
  }

  return {
    platform: 'Instagram',
    id: publishJson.id,
  };
}

function createInstagramImageContainer_(igAccountId, assetUrl, caption, token) {
  const json = fetchJson_(metaGraphUrl_(igAccountId + '/media'), {
    method: 'post',
    payload: {
      image_url: assetUrl,
      caption: caption,
      access_token: token,
    },
    muteHttpExceptions: true,
  });

  if (!json.id) {
    throw new Error('Instagram container olusturulamadi: ' + JSON.stringify(json));
  }

  return json.id;
}

function waitUntilInstagramContainerReady_(containerId, token) {
  const startedAt = Date.now();

  while (Date.now() - startedAt < META_CONFIG.maxContainerWaitMs) {
    const url = metaGraphUrl_(containerId) +
      '?fields=status_code,status' +
      '&access_token=' + encodeURIComponent(token);

    const json = fetchJson_(url, {
      method: 'get',
      muteHttpExceptions: true,
    });

    if (json.status_code === 'FINISHED') {
      return;
    }

    if (json.status_code === 'ERROR' || json.status_code === 'EXPIRED') {
      throw new Error('Instagram container hazirlanamadi: ' + JSON.stringify(json));
    }

    Utilities.sleep(META_CONFIG.pollIntervalMs);
  }

  throw new Error('Instagram container hazir olma suresi asildi: ' + containerId);
}

function fetchJson_(url, options) {
  const response = UrlFetchApp.fetch(url, options);
  const code = response.getResponseCode();
  const text = response.getContentText();

  let json;
  try {
    json = text ? JSON.parse(text) : {};
  } catch (err) {
    throw new Error('JSON okunamadi. HTTP ' + code + ': ' + text);
  }

  if (code < 200 || code >= 300) {
    throw new Error('Meta Graph API hatasi. HTTP ' + code + ': ' + JSON.stringify(json));
  }

  if (json.error) {
    throw new Error('Meta Graph API error: ' + JSON.stringify(json.error));
  }

  return json;
}

function buildMetaCaption_(row) {
  const parts = [];
  const caption = String(row.caption_tr || '').trim();
  const cta = String(row.cta_short || '').trim();

  if (caption) parts.push(caption);
  if (cta) parts.push(cta);

  return parts.join('\n\n');
}

function markSourcePlanPosted_(planSheet, sourceRow, result) {
  const rowNumber = Number(sourceRow);
  if (!planSheet || !rowNumber || rowNumber < 3) return;

  planSheet.getRange(rowNumber, PLAN_HEADERS.indexOf('status') + 1).setValue(META_CONFIG.statusPosted);
  planSheet.getRange(rowNumber, PLAN_HEADERS.indexOf('meta_post_id') + 1).setValue(result.id);
  planSheet.getRange(rowNumber, PLAN_HEADERS.indexOf('notes') + 1).setValue(result.platform + ' otomatik paylasildi');
}

function normalizePlatform_(value) {
  return String(value || '').trim().toLowerCase();
}

function isMetaPlatform_(platform) {
  return platform === 'facebook' || platform === 'instagram';
}

function normalizeAssetUrl_(url) {
  const text = String(url || '').trim();
  const fileId = getDriveId_(text);

  if (!fileId) {
    return text;
  }

  return 'https://drive.google.com/uc?export=download&id=' + fileId;
}

function getDriveId_(url) {
  const text = String(url || '');

  let match = text.match(/[?&]id=([^&]+)/);
  if (match && match[1]) {
    return match[1];
  }

  match = text.match(/\/d\/([^/]+)/);
  if (match && match[1]) {
    return match[1];
  }

  return '';
}

function validateHttpsUrl_(url, label) {
  if (!url) {
    throw new Error(label + ' bos.');
  }

  if (!/^https:\/\//i.test(url)) {
    throw new Error(label + ' https olmali: ' + url);
  }
}

function getInstagramToken_() {
  return getOptionalProperty_('INSTAGRAM_ACCESS_TOKEN') ||
    getRequiredProperty_('META_PAGE_ACCESS_TOKEN');
}

function getRequiredProperty_(key) {
  const value = getOptionalProperty_(key);

  if (!value) {
    throw new Error(key + ' Script Properties icinde yok.');
  }

  return value;
}

function getOptionalProperty_(key) {
  return String(PropertiesService.getScriptProperties().getProperty(key) || '').trim();
}

function metaGraphUrl_(path) {
  return 'https://graph.facebook.com/' + META_CONFIG.apiVersion + '/' + path;
}

function getJune2026Rows_() {
  const theme = 'Mahallende isi bugun cozen biri var';
  const assets = {
    '2026-06-08': {
      Facebook: 'https://benyaparimci.com/social/benyaparim-2026-06-08-facebook-1.png',
      Instagram: 'https://benyaparimci.com/social/benyaparim-2026-06-08-instagram-1.png',
    },
    '2026-06-15': {
      Facebook: 'https://benyaparimci.com/social/benyaparim-2026-06-15-facebook-1.png',
      Instagram: 'https://benyaparimci.com/social/benyaparim-2026-06-15-instagram-1.png',
    },
    '2026-06-22': {
      Facebook: 'https://benyaparimci.com/social/benyaparim-2026-06-22-facebook-1.png',
      Instagram: 'https://benyaparimci.com/social/benyaparim-2026-06-22-instagram-1.png',
    },
    '2026-06-29': {
      Facebook: 'https://benyaparimci.com/social/benyaparim-2026-06-29-facebook-1.png',
      Instagram: 'https://benyaparimci.com/social/benyaparim-2026-06-29-instagram-1.png',
    },
  };

  return [
    [
      '2026-06-08', theme, 1, 'Facebook', 'Ben Yaparim',
      'Is arayan degil cozum bulan taraf ol',
      'Bir isin varsa saatlerce aramana gerek yok. Ben Yaparim ile ilanini ver, yakinindaki kisilerden donus al, detaylari guvenli mesajlasma ile netlestir. Uygulamayi indir ve kolayligi dene.',
      'Ilk ilani ver',
      'Statik gorsel. Sorun cozum akisi, yerel ve sicak ton.',
      'Monday', '10:00', 'Ilan verme', 'ready', 'approved', assets['2026-06-08'].Facebook, '2026-06-08T10:00:00+03:00', '', ''
    ],
    [
      '2026-06-08', theme, 2, 'Instagram', 'benyaparim.app',
      'Mahallende cozum sandigindan daha yakin',
      'Bazen ihtiyacin olan sey sadece yakininda guvenilir birini bulmak. Ben Yaparim ile ilan ver, teklif al, guvenli mesajlas. Uygulamayi indir ve bugun cozumun ne kadar yakin oldugunu gor.',
      'Cozumu kesfet',
      'Kare post. Yakinda cozum duygusu, net CTA, sade tipografi.',
      'Wednesday', '18:00', 'Uygulama indirme', 'ready', 'approved', assets['2026-06-08'].Instagram, '2026-06-10T18:00:00+03:00', '', ''
    ],
    [
      '2026-06-15', theme, 3, 'Facebook', 'Ben Yaparim',
      'Guvenli mesajlasma her seyi kolaylastirir',
      'Ne yaptiracagini uzun uzun anlatmak yerine detaylari tek yerde guvenli sekilde konus. Ben Yaparim ile ihtiyacini paylas, teklif al ve iletisimi duzenli tut. Uygulamayi indirip farki gor.',
      'Guvenle basla',
      'Mesajlasma odakli statik gorsel. Sohbet balonu ve guven duygusu.',
      'Tuesday', '09:30', 'Guvenli mesajlasma', 'ready', 'approved', assets['2026-06-15'].Facebook, '2026-06-16T09:30:00+03:00', '', ''
    ],
    [
      '2026-06-15', theme, 4, 'Instagram', 'benyaparim.app',
      'Ihtiyacin oldugunda uygulama hazir olsun',
      'Bir sey bozuldugunda ya da yardima ihtiyacin oldugunda sifirdan arama yapmak zorunda kalma. Ben Yaparim telefonunda hazir olsun; ilan ver, teklif al, guvenli sekilde ilerle. Bugun indir.',
      'Simdi indir',
      'Mobil ekran hissi veren gorsel. Uygulama her an elinin altinda mesaji.',
      'Wednesday', '18:30', 'Uygulama indirme', 'ready', 'approved', assets['2026-06-15'].Instagram, '2026-06-17T18:30:00+03:00', '', ''
    ],
    [
      '2026-06-22', theme, 5, 'Facebook', 'Ben Yaparim',
      'Bugun ilan ver yarin bekleme',
      'Erteledigin isler buyumeden cozulmeli. Ben Yaparim ile ilanini ver, yakinindaki kisilerden hizli donus al, iletisimi guvenli sekilde yonet. Uygulamayi indir ve harekete gec.',
      'Ilani ac',
      'Yerel ve sicak tonlu feed gorseli. Bekletme yerine harekete gec mesaji.',
      'Wednesday', '10:30', 'Ilan verme', 'ready', 'approved', assets['2026-06-22'].Facebook, '2026-06-24T10:30:00+03:00', '', ''
    ],
    [
      '2026-06-22', theme, 6, 'Instagram', 'benyaparim.app',
      'Bir uygulama bircok cozum',
      'Tamirden destege, ihtiyactan teklife kadar her adimi tek yerde yonetmek daha kolay. Ben Yaparim ile ilan ver, teklif al, guvenli mesajlas. Uygulamayi indir ve kendi hizinda ilerle.',
      'Tek yerde basla',
      'Minimal kare tasarim. Bir uygulama bircok cozum ana mesaji.',
      'Thursday', '13:30', 'Uygulama indirme', 'ready', 'approved', assets['2026-06-22'].Instagram, '2026-06-25T13:30:00+03:00', '', ''
    ],
    [
      '2026-06-29', theme, 7, 'Facebook', 'Ben Yaparim',
      'Bir ilan birden cok teklif',
      'Tek bir ilanla birden fazla secenek gormek iyi hissettirir. Ben Yaparim tam da bunu saglar. Ihtiyacini yaz, teklifleri gor, icine sinen kisiyle guvenli sekilde anlas. Uygulamayi bugun indir.',
      'Secenekleri gor',
      'Statik feed gorseli. Ilan acma ve teklif gelme hissi.',
      'Tuesday', '10:00', 'Teklif alma', 'ready', 'approved', assets['2026-06-29'].Facebook, '2026-06-30T10:00:00+03:00', '', ''
    ],
    [
      '2026-06-29', theme, 8, 'Instagram', 'benyaparim.app',
      'Karsilastir sec rahat et',
      'Fiyat, hiz ve guven arasinda tek basina karar vermeye calisma. Ben Yaparim ile teklifleri karsilastir, detaylari sor, icine sinen secimi yap. Uygulamayi indir ve sureci kolaylastir.',
      'Rahat secim yap',
      'Kare post. Karsilastirma, mesajlasma ve rahat secim akisi.',
      'Wednesday', '18:00', 'Teklif alma', 'ready', 'approved', assets['2026-06-29'].Instagram, '2026-07-01T18:00:00+03:00', '', ''
    ],
  ];
}

function getJuly72026Rows_() {
  const theme = 'Yakindaki emekle sofran ve isin kolaylassin';
  const campaign = 'benyaparim_2026_07_07_social';
  const assets = {
    Facebook: 'https://benyaparimci.com/social/benyaparim-2026-07-07-facebook-1.png',
    Instagram: 'https://benyaparimci.com/social/benyaparim-2026-07-07-instagram-1.png',
  };

  return [
    [
      '2026-07-07', theme, 1, 'Facebook', 'Ben Yaparim',
      'Bugunku ihtiyacin icin uzaga gitme',
      'Ev yemeginden kucuk tasimaya, tasarimdan organizasyon destegine kadar ihtiyacini tek ilanla anlat. Ben Yaparim ile yakinindaki kisilerden teklif al, guvenli mesajlasma ile detaylari netlestir. Uygulamayi indir ve bugun ilk adimi at.',
      'Ilk ilani ver',
      'Feed gorseli. Mahalle hissi veren aydinlik bir mutfak/ev girisi sahnesi; telefon ekraninda ilan karti ve gelen teklif bildirimleri; net baslik: Bugunku ihtiyacin yakinda.',
      'Tuesday', '10:00', 'Ilan verme', 'ready', 'approved', assets.Facebook, '2026-07-07T10:00:00+03:00', '',
      buildStoreCampaignNotes_('facebook', campaign, 'facebook_post_1')
    ],
    [
      '2026-07-07', theme, 2, 'Instagram', 'benyaparim.app',
      'Sofrana da isine de yakin cozum',
      'Bugun hazir yemek, ikram, kucuk destek ya da tasarim ihtiyacin mi var? Ben Yaparim\'da ilan ver, teklifleri karsilastir, icine sinen kisiyle uygulama icinden guvenle konus. Indir, yakinindaki cozumleri kesfet.',
      'Cozumu kesfet',
      'Kare post. Ustte guclu tipografik mesaj, altta telefon ekraninda kategori kartlari; yemek, tasima ve tasarim ikonlari; sicak ama sade renk dengesi.',
      'Thursday', '18:00', 'Uygulama indirme', 'ready', 'approved', assets.Instagram, '2026-07-09T18:00:00+03:00', '',
      buildStoreCampaignNotes_('instagram', campaign, 'instagram_post_1')
    ],
  ];
}

function buildStoreCampaignNotes_(source, campaign, content) {
  const utm = {
    utm_source: source,
    utm_medium: 'organic_social',
    utm_campaign: campaign,
    utm_content: content,
  };

  return 'android=' + addQueryParams_('https://play.google.com/store/apps/details?id=com.benyaparim.app', utm) +
    ' | ios=' + addQueryParams_('https://apps.apple.com/app/id6762226701', utm);
}

function addQueryParams_(url, params) {
  const separator = url.indexOf('?') === -1 ? '?' : '&';
  const query = Object.keys(params)
    .map(function(key) {
      return encodeURIComponent(key) + '=' + encodeURIComponent(params[key]);
    })
    .join('&');

  return url + separator + query;
}
