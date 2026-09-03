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
        AppLanguage.en => 'Flights, limousines, trips & venues — compare and book fast',
        AppLanguage.de => 'Flüge, Limousinen, Ausflüge & Locations — schnell buchen',
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

  // Offer 3 (renamed: general halls/venues, not just Bibliotheca Alexandrina)
  static String get offer3Title => switch (current) {
        AppLanguage.ar => 'قاعات ومساحات مميزة',
        AppLanguage.en => 'Premium Halls & Venues',
        AppLanguage.de => 'Premium-Säle & Veranstaltungsorte',
      };
  static String get offer3Sub => switch (current) {
        AppLanguage.ar => 'قاعات فعاليات ومؤتمرات في الإسكندرية',
        AppLanguage.en => 'Event and conference venues in Alexandria',
        AppLanguage.de => 'Veranstaltungs- und Konferenzorte in Alexandria',
      };
  static String get offer3Price => switch (current) {
        AppLanguage.ar => 'اطلب عرض سعر',
        AppLanguage.en => 'Request a quote',
        AppLanguage.de => 'Angebot anfordern',
      };

  // Offer 4 (hotels)
  static String get offer4Title => switch (current) {
        AppLanguage.ar => 'فنادق الإسكندرية المميزة',
        AppLanguage.en => 'Alexandria Premium Hotels',
        AppLanguage.de => 'Premium-Hotels in Alexandria',
      };
  static String get offer4Sub => switch (current) {
        AppLanguage.ar => 'غرف 3 و4 و5 نجوم على الكورنيش',
        AppLanguage.en => '3, 4 & 5-star rooms on the Corniche',
        AppLanguage.de => '3-, 4- und 5-Sterne-Zimmer an der Corniche',
      };
  static String get offer4Price => switch (current) {
        AppLanguage.ar => 'يبدأ من 1,800 ج.م',
        AppLanguage.en => 'From EGP 1,800',
        AppLanguage.de => 'Ab 1.800 EGP',
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
  static String get catHotels => switch (current) {
        AppLanguage.ar => 'حجز فنادق',
        AppLanguage.en => 'Hotel Booking',
        AppLanguage.de => 'Hotelbuchung',
      };
  static String get catConference => switch (current) {
        AppLanguage.ar => 'قاعات ومساحات للإيجار',
        AppLanguage.en => 'Halls & Venues for Rent',
        AppLanguage.de => 'Säle & Veranstaltungsorte zur Miete',
      };
  static String companiesCount(int n) => switch (current) {
        AppLanguage.ar => '$n شركات',
        AppLanguage.en => '$n companies',
        AppLanguage.de => '$n Unternehmen',
      };

  // ---------- Company inquiry ("Submit your offer as a company") ----------
  static String get joinAsCompanyButton => switch (current) {
        AppLanguage.ar => 'قدّم عرضك كشركة',
        AppLanguage.en => 'Submit your offer as a company',
        AppLanguage.de => 'Als Unternehmen bewerben',
      };
  static String get joinFormTitle => switch (current) {
        AppLanguage.ar => 'انضم كشريك',
        AppLanguage.en => 'Become a partner',
        AppLanguage.de => 'Partner werden',
      };
  static String get joinFormSubtitle => switch (current) {
        AppLanguage.ar => 'اعرض خدماتك على آلاف المسافرين',
        AppLanguage.en => 'Showcase your services to thousands of travelers',
        AppLanguage.de => 'Präsentieren Sie Ihre Dienstleistungen',
      };
  static String get companyNameLabel => switch (current) {
        AppLanguage.ar => 'اسم الشركة',
        AppLanguage.en => 'Company name',
        AppLanguage.de => 'Firmenname',
      };
  static String get serviceTypeLabel => switch (current) {
        AppLanguage.ar => 'نوع الخدمة',
        AppLanguage.en => 'Service type',
        AppLanguage.de => 'Dienstleistungsart',
      };
  static String get catOther => switch (current) {
        AppLanguage.ar => 'أخرى',
        AppLanguage.en => 'Other',
        AppLanguage.de => 'Sonstiges',
      };
  static String get contactInfoLabel => switch (current) {
        AppLanguage.ar => 'بيانات التواصل (رقم/إيميل)',
        AppLanguage.en => 'Contact info (phone/email)',
        AppLanguage.de => 'Kontaktdaten (Telefon/E-Mail)',
      };
  static String get offerDescriptionLabel => switch (current) {
        AppLanguage.ar => 'وصف العرض',
        AppLanguage.en => 'Offer description',
        AppLanguage.de => 'Angebotsbeschreibung',
      };
  static String get requiredFieldError => switch (current) {
        AppLanguage.ar => 'مطلوب',
        AppLanguage.en => 'Required',
        AppLanguage.de => 'Erforderlich',
      };
  static String get submitButton => switch (current) {
        AppLanguage.ar => 'إرسال الطلب',
        AppLanguage.en => 'Submit request',
        AppLanguage.de => 'Anfrage senden',
      };
  static String get cancelButton => switch (current) {
        AppLanguage.ar => 'إلغاء',
        AppLanguage.en => 'Cancel',
        AppLanguage.de => 'Abbrechen',
      };
  static String get joinMessageIntro => switch (current) {
        AppLanguage.ar => 'طلب انضمام شركة جديدة - SWA Travel',
        AppLanguage.en => 'New company partnership request - SWA Travel',
        AppLanguage.de => 'Neue Partnerschaftsanfrage - SWA Travel',
      };

  // ---------- Emergency numbers ----------
  static String get emergencyTitle => switch (current) {
        AppLanguage.ar => 'أرقام الطوارئ',
        AppLanguage.en => 'Emergency Numbers',
        AppLanguage.de => 'Notrufnummern',
      };
  static String get emergencyPolice => switch (current) {
        AppLanguage.ar => 'الشرطة',
        AppLanguage.en => 'Police',
        AppLanguage.de => 'Polizei',
      };
  static String get emergencyAmbulance => switch (current) {
        AppLanguage.ar => 'الإسعاف',
        AppLanguage.en => 'Ambulance',
        AppLanguage.de => 'Krankenwagen',
      };
  static String get emergencyFire => switch (current) {
        AppLanguage.ar => 'المطافئ',
        AppLanguage.en => 'Fire Department',
        AppLanguage.de => 'Feuerwehr',
      };
  static String get emergencyTouristPolice => switch (current) {
        AppLanguage.ar => 'شرطة السياحة والآثار',
        AppLanguage.en => 'Tourist & Antiquities Police',
        AppLanguage.de => 'Tourismus- und Altertümerpolizei',
      };
  static String get emergencyTrafficPolice => switch (current) {
        AppLanguage.ar => 'المرور',
        AppLanguage.en => 'Traffic Police',
        AppLanguage.de => 'Verkehrspolizei',
      };

  // ---------- Currency rates ----------
  static String get currencyTitle => switch (current) {
        AppLanguage.ar => 'أسعار العملات',
        AppLanguage.en => 'Exchange Rates',
        AppLanguage.de => 'Wechselkurse',
      };
  static String get currencyLoading => switch (current) {
        AppLanguage.ar => 'جاري التحديث...',
        AppLanguage.en => 'Updating...',
        AppLanguage.de => 'Wird aktualisiert...',
      };
  static String get currencyError => switch (current) {
        AppLanguage.ar => 'تعذّر تحميل السعر الحالي',
        AppLanguage.en => 'Could not load live rates',
        AppLanguage.de => 'Kurse konnten nicht geladen werden',
      };
  static String get currencyPerEgp => switch (current) {
        AppLanguage.ar => 'مقابل الجنيه المصري',
        AppLanguage.en => 'against the Egyptian Pound',
        AppLanguage.de => 'gegenüber dem ägyptischen Pfund',
      };
}