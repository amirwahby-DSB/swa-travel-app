enum AppLanguage { ar, en, de }

class HomeStrings {
  static AppLanguage current = AppLanguage.ar;

  static bool get isRtl => current == AppLanguage.ar;

  static String get appName => 'SWA Travel';

  static String get heroTitle => switch (current) {
        AppLanguage.ar => 'كل عروض السفر في مكان واحد',
        AppLanguage.en => 'All your travel offers in one place',
        AppLanguage.de => 'Alle Reiseangebote an einem Ort',
      };

  static String get heroSubtitle => switch (current) {
        AppLanguage.ar => 'تذاكر، ليموزين، رحلات، وأماكن مؤتمرات — قارن واطلب في دقايق',
        AppLanguage.en => 'Flights, limousines, trips, and conference venues — compare and book in minutes',
        AppLanguage.de => 'Flüge, Limousinen, Ausflüge und Konferenzräume — vergleichen und in Minuten buchen',
      };

  static String get featuredOffersTitle => switch (current) {
        AppLanguage.ar => 'عروض مميزة اليوم',
        AppLanguage.en => 'Featured offers today',
        AppLanguage.de => 'Heutige Top-Angebote',
      };

  static String get browseByCategory => switch (current) {
        AppLanguage.ar => 'تصفح حسب الفئة',
        AppLanguage.en => 'Browse by category',
        AppLanguage.de => 'Nach Kategorie durchsuchen',
      };

  // Offer 1
  static String get offer1Title => switch (current) {
        AppLanguage.ar => 'شركة النيل للسفريات',
        AppLanguage.en => 'Nile Travel Company',
        AppLanguage.de => 'Nile Reiseunternehmen',
      };
  static String get offer1Sub => switch (current) {
        AppLanguage.ar => 'رحلات القاهرة - برلين',
        AppLanguage.en => 'Cairo - Berlin flights',
        AppLanguage.de => 'Flüge Kairo - Berlin',
      };
  static String get offer1Price => switch (current) {
        AppLanguage.ar => 'يبدأ من 8,500 ج.م',
        AppLanguage.en => 'From EGP 8,500',
        AppLanguage.de => 'Ab 8.500 EGP',
      };

  // Offer 2
  static String get offer2Title => switch (current) {
        AppLanguage.ar => 'ليموزين الإسكندرية VIP',
        AppLanguage.en => 'Alexandria VIP Limousine',
        AppLanguage.de => 'Alexandria VIP-Limousine',
      };
  static String get offer2Sub => switch (current) {
        AppLanguage.ar => 'توصيل مطار، رحلات خاصة',
        AppLanguage.en => 'Airport transfer, private trips',
        AppLanguage.de => 'Flughafentransfer, private Fahrten',
      };
  static String get offer2Price => switch (current) {
        AppLanguage.ar => 'يبدأ من 450 ج.م',
        AppLanguage.en => 'From EGP 450',
        AppLanguage.de => 'Ab 450 EGP',
      };

  // Offer 3
  static String get offer3Title => switch (current) {
        AppLanguage.ar => 'قاعة مكتبة الإسكندرية',
        AppLanguage.en => 'Bibliotheca Alexandrina Hall',
        AppLanguage.de => 'Halle der Bibliotheca Alexandrina',
      };
  static String get offer3Sub => switch (current) {
        AppLanguage.ar => 'مؤتمرات وفعاليات كبرى',
        AppLanguage.en => 'Conferences and major events',
        AppLanguage.de => 'Konferenzen und Großveranstaltungen',
      };
  static String get offer3Price => switch (current) {
        AppLanguage.ar => 'اطلب عرض سعر',
        AppLanguage.en => 'Request a quote',
        AppLanguage.de => 'Angebot anfordern',
      };

  // Categories
  static String get catFlights => switch (current) {
        AppLanguage.ar => 'تذاكر طيران',
        AppLanguage.en => 'Flight tickets',
        AppLanguage.de => 'Flugtickets',
      };
  static String get catLimo => switch (current) {
        AppLanguage.ar => 'ليموزين',
        AppLanguage.en => 'Limousine',
        AppLanguage.de => 'Limousine',
      };
  static String get catTrips => switch (current) {
        AppLanguage.ar => 'رحلات',
        AppLanguage.en => 'Trips',
        AppLanguage.de => 'Ausflüge',
      };
  static String get catConference => switch (current) {
        AppLanguage.ar => 'قاعات مؤتمرات',
        AppLanguage.en => 'Conference halls',
        AppLanguage.de => 'Konferenzräume',
      };
  static String companiesCount(int n) => switch (current) {
        AppLanguage.ar => '$n شركات',
        AppLanguage.en => '$n companies',
        AppLanguage.de => '$n Unternehmen',
      };
}