import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'firebase_service.dart';
import 'home_strings.dart';

// ---------- Brand palette (VIP travel: deep ink navy + champagne gold) ----------
// A single accent color used consistently (not a different hue per section)
// is what reads as "luxury membership" rather than "consumer app".
class SwaColors {
  static const ink = Color(0xFF0A1A26); // near-black navy, primary dark surface
  static const inkDeep = Color(0xFF050F16); // deepest gradient stop
  static const gold = Color(0xFFC9A24B); // champagne gold — the one accent
  static const goldLight = Color(0xFFE4D2A0);
  static const ivory = Color(0xFFF6F2E8); // warm off-white page background
  static const ivoryLine = Color(0xFFE3DAC4); // hairline dividers on ivory
  static const inkLine = Color(0x33C9A24B); // faint gold hairline on ink
  static const textDark = Color(0xFF1C2733);
  static const textMuted = Color(0xFF7A7368);
}

void main() {
  runApp(const SwaTravelApp());
}

class SwaTravelApp extends StatefulWidget {
  const SwaTravelApp({super.key});

  @override
  State<SwaTravelApp> createState() => _SwaTravelAppState();
}

class _SwaTravelAppState extends State<SwaTravelApp> {
  String? _userEmail;

  void _setLanguage(AppLanguage lang) {
    setState(() {
      HomeStrings.current = lang;
    });
  }

  void _onLoggedIn(String email) {
    setState(() => _userEmail = email);
  }

  void _onLoggedOut() {
    setState(() => _userEmail = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SWA Travel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: SwaColors.ivory,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SwaColors.ink,
          primary: SwaColors.ink,
          secondary: SwaColors.gold,
        ),
        textTheme: GoogleFonts.cairoTextTheme(),
      ),
      home: Directionality(
        textDirection: HomeStrings.isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: HomeScreen(
          onLanguageChange: _setLanguage,
          userEmail: _userEmail,
          onLoggedIn: _onLoggedIn,
          onLoggedOut: _onLoggedOut,
        ),
      ),
    );
  }
}

// ---------- Fine geometric pattern (used sparingly, as texture not decoration) ----------
class _PatternPainter extends CustomPainter {
  final Color color;
  _PatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    const step = 34.0;
    for (double x = -step; x < size.width + step; x += step) {
      for (double y = -step; y < size.height + step; y += step) {
        final path = Path();
        final cx = x, cy = y;
        path.moveTo(cx, cy - 10);
        path.lineTo(cx + 10, cy);
        path.lineTo(cx, cy + 10);
        path.lineTo(cx - 10, cy);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) => false;
}

class HomeScreen extends StatelessWidget {
  final void Function(AppLanguage) onLanguageChange;
  final String? userEmail;
  final void Function(String email) onLoggedIn;
  final VoidCallback onLoggedOut;
  const HomeScreen({
    super.key,
    required this.onLanguageChange,
    required this.userEmail,
    required this.onLoggedIn,
    required this.onLoggedOut,
  });

  static const double _referenceWidth = 420.0;

  // Elegant serif-style display type for headlines — the one deliberately
  // "expensive" typographic choice; body text stays plain Cairo throughout.
  static TextStyle _display({
    required double size,
    required Color color,
    FontWeight weight = FontWeight.w700,
    double? height,
  }) {
    return GoogleFonts.amiri(fontSize: size, color: color, fontWeight: weight, height: height);
  }

  // ---------- WhatsApp quick-contact ----------
  static const String _whatsappNumber = '201223275747';

  Future<void> _openWhatsApp(String offerTitle) async {
    final message = HomeStrings.isRtl
        ? 'أهلاً، أنا مهتم بـ: $offerTitle - SWA Travel'
        : 'Hi, I\'m interested in: $offerTitle - SWA Travel';
    final uri = Uri.parse('https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(message)}');
    html.window.open(uri.toString(), '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 700;
    final isWide = screenWidth >= 1000;
    final maxWidth = isWide ? 860.0 : (isDesktop ? _referenceWidth : double.infinity);

    return Scaffold(
      body: Stack(
        children: [
          // fixed background — does not scroll
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDesktop
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [SwaColors.inkDeep, Color(0xFF10222F), Color(0xFF1B3040)],
                      )
                    : null,
                color: isDesktop ? null : SwaColors.ivory,
              ),
            ),
          ),
          // scroll view spans the FULL screen so the wheel/drag works
          // no matter where the cursor is — not just over the card itself.
          SingleChildScrollView(
            child: SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                child: Center(
                  child: Container(
                    width: isDesktop ? maxWidth : null,
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    margin: isDesktop ? const EdgeInsets.symmetric(vertical: 28) : EdgeInsets.zero,
                    decoration: isDesktop
                        ? BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [SwaColors.ivory, Color(0xFFF1EADA)],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: SwaColors.gold.withOpacity(0.25), width: 1),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 60, offset: const Offset(0, 30)),
                            ],
                          )
                        : null,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        _buildHero(),
                        _buildFeaturedOffers(isWide),
                        _buildCategories(),
                        _CurrencyRatesSection(),
                        _buildJoinCompanySection(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // fixed SOS button — always visible regardless of scroll position
          Positioned(
            bottom: 22,
            right: HomeStrings.isRtl ? null : 22,
            left: HomeStrings.isRtl ? 22 : null,
            child: _buildEmergencyButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.55),
        builder: (_) => const _EmergencyNumbersDialog(),
      ),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [SwaColors.ink, Color(0xFF14283A)]),
          border: Border.all(color: SwaColors.gold.withOpacity(0.7), width: 1.4),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
            BoxShadow(color: SwaColors.gold.withOpacity(0.2), blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sos, color: SwaColors.goldLight, size: 22),
          ],
        ),
      ),
    );
  }

  // ---------- Header: quiet wordmark, thin gold rule, no icon badge ----------
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: const BoxDecoration(
        color: SwaColors.ivory,
        border: Border(bottom: BorderSide(color: SwaColors.ivoryLine, width: 1)),
      ),
      child: Row(
        children: [
          Text(
            HomeStrings.appName,
            style: _display(size: 19, color: SwaColors.textDark, weight: FontWeight.w700),
          ),
          const Spacer(),
          _buildAuthControl(context),
          const SizedBox(width: 14),
          _buildLanguageSwitch(),
        ],
      ),
    );
  }

  Widget _buildAuthControl(BuildContext context) {
    if (userEmail != null) {
      return InkWell(
        onTap: onLoggedOut,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_circle, size: 16, color: SwaColors.gold),
            const SizedBox(width: 4),
            Text(
              HomeStrings.logout,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SwaColors.textMuted),
            ),
          ],
        ),
      );
    }
    return InkWell(
      onTap: () => showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.55),
        builder: (_) => _AuthDialog(onLoggedIn: onLoggedIn),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 16, color: SwaColors.gold),
          const SizedBox(width: 4),
          Text(
            HomeStrings.signIn,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SwaColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSwitch() {
    return Row(
      children: [
        PopupMenuButton<AppLanguage>(
          onSelected: onLanguageChange,
          color: SwaColors.ink,
          itemBuilder: (context) => [
            _langItem(AppLanguage.ar, 'العربية'),
            _langItem(AppLanguage.en, 'English'),
            _langItem(AppLanguage.de, 'Deutsch'),
          ],
          child: const Text(
            'AR · EN · DE',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SwaColors.textMuted, letterSpacing: 0.4),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<AppLanguage> _langItem(AppLanguage lang, String label) {
    return PopupMenuItem(
      value: lang,
      child: Text(label, style: const TextStyle(color: SwaColors.goldLight)),
    );
  }

  // ---------- Hero: rich layered gradient + radial glow + serif headline ----------
  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 58),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SwaColors.inkDeep, SwaColors.ink, Color(0xFF14283A)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // soft radial glow behind the mark, off-center for depth
          Positioned(
            top: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [SwaColors.gold.withOpacity(0.22), SwaColors.gold.withOpacity(0.0)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: CustomPaint(painter: _PatternPainter(SwaColors.gold.withOpacity(0.10))),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                    // outer glow ring — same badge frame as before
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: SwaColors.gold.withOpacity(0.6), width: 1.3),
                        gradient: RadialGradient(colors: [SwaColors.gold.withOpacity(0.18), Colors.transparent]),
                        boxShadow: [BoxShadow(color: SwaColors.gold.withOpacity(0.25), blurRadius: 26, spreadRadius: 2)],
                      ),
                    ),
                    // faint airplane, trailing off in the background — small and unobtrusive
                    Positioned(
                      top: 6,
                      right: 4,
                      child: Transform.rotate(
                        angle: -0.45,
                        child: Icon(Icons.flight, size: 20, color: SwaColors.goldLight.withOpacity(0.55)),
                      ),
                    ),
                    // hotel — the single anchor element, centered and unobstructed
                    Positioned(
                      top: 20,
                      child: Icon(Icons.apartment_rounded, size: 32, color: SwaColors.goldLight),
                    ),
                    // limousine, resting along the base of the badge
                    Positioned(
                      bottom: 16,
                      child: Icon(Icons.directions_car_filled_rounded, size: 26, color: Colors.white.withOpacity(0.95)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [SwaColors.goldLight, SwaColors.gold],
                ).createShader(bounds),
                child: Text(
                  HomeStrings.heroTitle,
                  textAlign: TextAlign.center,
                  style: _display(
                    size: HomeStrings.isRtl ? 27 : 21,
                    color: Colors.white,
                    weight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                HomeStrings.heroSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: HomeStrings.isRtl ? 12.5 : 11,
                  color: Colors.white.withOpacity(0.68),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                height: 1,
                width: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.transparent, SwaColors.gold, Colors.transparent]),
                ),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Featured Offers: dark cards, thin gold rule, outline icon ----------
  Widget _buildFeaturedOffers(bool isWide) {
    final offers = [
      {'title': HomeStrings.offer1Title, 'sub': HomeStrings.offer1Sub, 'price': HomeStrings.offer1Price, 'icon': Icons.flight_outlined, 'featured': true, 'rating': 4.8},
      {'title': HomeStrings.offer4Title, 'sub': HomeStrings.offer4Sub, 'price': HomeStrings.offer4Price, 'icon': Icons.hotel_outlined, 'featured': false, 'rating': 4.7},
      {'title': HomeStrings.offer2Title, 'sub': HomeStrings.offer2Sub, 'price': HomeStrings.offer2Price, 'icon': Icons.directions_car_outlined, 'featured': false, 'rating': 4.6},
      {'title': HomeStrings.offer3Title, 'sub': HomeStrings.offer3Sub, 'price': HomeStrings.offer3Price, 'icon': Icons.apartment_outlined, 'featured': false, 'rating': 4.9},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel(HomeStrings.featuredOffersTitle),
          const SizedBox(height: 16),
          if (isWide)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: offers.map((o) => SizedBox(width: 340, child: _offerCard(o))).toList(),
            )
          else
            Column(
              children: offers.map((o) => Padding(padding: const EdgeInsets.only(bottom: 14), child: _offerCard(o))).toList(),
            ),
        ],
      ),
    );
  }

  Widget _offerCard(Map<String, Object> o) {
    final featured = o['featured'] as bool;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SwaColors.ink, Color(0xFF132938)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: featured ? SwaColors.gold.withOpacity(0.55) : SwaColors.inkLine, width: featured ? 1.2 : 1),
        boxShadow: featured
            ? [BoxShadow(color: SwaColors.gold.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8))]
            : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              border: Border.all(color: SwaColors.gold.withOpacity(0.5), width: 1),
              shape: BoxShape.circle,
            ),
            child: Icon(o['icon'] as IconData, color: SwaColors.gold, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (featured)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'FEATURED',
                      style: const TextStyle(fontSize: 9, color: SwaColors.gold, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                    ),
                  ),
                Text(o['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Colors.white)),
                const SizedBox(height: 2),
                Text(o['sub'] as String, style: TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(0.55))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star, size: 12, color: SwaColors.gold.withOpacity(0.9)),
                    const SizedBox(width: 3),
                    Text('${o['rating']}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.75))),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(o['price'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: SwaColors.gold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _openWhatsApp(o['title'] as String),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF25D366).withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat, size: 12, color: Color(0xFF25D366)),
                      const SizedBox(width: 4),
                      Text(
                        HomeStrings.isRtl ? 'واتساب' : 'WhatsApp',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF25D366)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Categories: quiet ivory rows with a gold rule, not colored tiles ----------
  Widget _buildCategories() {
    final categories = [
      {'label': HomeStrings.catTrips, 'count': HomeStrings.companiesCount(9), 'icon': Icons.map_outlined},
      {'label': HomeStrings.catHotels, 'count': HomeStrings.companiesCount(7), 'icon': Icons.hotel_outlined},
      {'label': HomeStrings.catFlights, 'count': HomeStrings.companiesCount(6), 'icon': Icons.confirmation_number_outlined},
      {'label': HomeStrings.catLimo, 'count': HomeStrings.companiesCount(4), 'icon': Icons.directions_car_outlined},
      {'label': HomeStrings.catConference, 'count': HomeStrings.companiesCount(3), 'icon': Icons.apartment_outlined},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel(HomeStrings.browseByCategory),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SwaColors.ivoryLine, width: 1),
            ),
            child: Column(
              children: categories.asMap().entries.map((entry) {
                final isLast = entry.key == categories.length - 1;
                final c = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    border: isLast ? null : const Border(bottom: BorderSide(color: SwaColors.ivoryLine, width: 1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(color: SwaColors.gold.withOpacity(0.45), width: 1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(c['icon'] as IconData, color: SwaColors.gold, size: 16),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(c['label'] as String, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: SwaColors.textDark)),
                      ),
                      Text(c['count'] as String, style: const TextStyle(fontSize: 11, color: SwaColors.textMuted)),
                      const SizedBox(width: 10),
                      Icon(HomeStrings.isRtl ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios, size: 12, color: SwaColors.textMuted.withOpacity(0.6)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(width: 18, height: 1.4, color: SwaColors.gold),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: SwaColors.textDark, letterSpacing: 0.2)),
      ],
    );
  }

  // ---------- "Submit your offer as a company" entry point ----------
  Widget _buildJoinCompanySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.55),
          builder: (_) => const _CompanyInquiryDialog(),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SwaColors.gold.withOpacity(0.5), width: 1.2),
            gradient: LinearGradient(colors: [SwaColors.gold.withOpacity(0.08), SwaColors.gold.withOpacity(0.02)]),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront_outlined, size: 17, color: SwaColors.gold),
              const SizedBox(width: 8),
              Text(
                HomeStrings.joinAsCompanyButton,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SwaColors.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Company inquiry form dialog ----------
class _CompanyInquiryDialog extends StatefulWidget {
  const _CompanyInquiryDialog();

  @override
  State<_CompanyInquiryDialog> createState() => _CompanyInquiryDialogState();
}

class _CompanyInquiryDialogState extends State<_CompanyInquiryDialog> {
  static const String _whatsappNumber = '201223275747';
  static const String _companyEmail = 'egyptswawork@gmail.com';

  final _formKey = GlobalKey<FormState>();
  final _companyNameCtrl = TextEditingController();
  final _contactInfoCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  late String _serviceType;

  @override
  void initState() {
    super.initState();
    _serviceType = HomeStrings.catFlights;
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _contactInfoCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  String _buildMessage() {
    final buffer = StringBuffer()
      ..writeln(HomeStrings.joinMessageIntro)
      ..writeln()
      ..writeln('${HomeStrings.companyNameLabel}: ${_companyNameCtrl.text}')
      ..writeln('${HomeStrings.serviceTypeLabel}: $_serviceType')
      ..writeln('${HomeStrings.contactInfoLabel}: ${_contactInfoCtrl.text}')
      ..writeln('${HomeStrings.offerDescriptionLabel}: ${_descriptionCtrl.text}');
    return buffer.toString();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final message = _buildMessage();

    final whatsappUri = Uri.parse('https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(message)}');
    final emailUri = Uri(
      scheme: 'mailto',
      path: _companyEmail,
      query: 'subject=${Uri.encodeComponent(HomeStrings.joinMessageIntro)}&body=${Uri.encodeComponent(message)}',
    );

    // Opened synchronously (no await in between) so both windows are
    // still treated as user-initiated by the browser's popup blocker.
    html.window.open(emailUri.toString(), '_blank');
    html.window.open(whatsappUri.toString(), '_blank');

    // Fire-and-forget: persists the inquiry in Firestore too, independent
    // of whether the WhatsApp/email windows actually got through.
    FirebaseService.saveCompanyInquiry(
      companyName: _companyNameCtrl.text,
      serviceType: _serviceType,
      contactInfo: _contactInfoCtrl.text,
      description: _descriptionCtrl.text,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      HomeStrings.catFlights,
      HomeStrings.catHotels,
      HomeStrings.catLimo,
      HomeStrings.catTrips,
      HomeStrings.catConference,
      HomeStrings.catOther,
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: SwaColors.ivory,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SwaColors.gold.withOpacity(0.3), width: 1),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    HomeStrings.joinFormTitle,
                    style: HomeScreen._display(size: 19, color: SwaColors.textDark, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    HomeStrings.joinFormSubtitle,
                    style: const TextStyle(fontSize: 11.5, color: SwaColors.textMuted),
                  ),
                  const SizedBox(height: 18),
                  _field(controller: _companyNameCtrl, label: HomeStrings.companyNameLabel),
                  const SizedBox(height: 12),
                  Text(HomeStrings.serviceTypeLabel, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: SwaColors.textMuted)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _serviceType,
                    isExpanded: true,
                    decoration: _inputDecoration(),
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12.5)))).toList(),
                    onChanged: (v) => setState(() => _serviceType = v ?? _serviceType),
                  ),
                  const SizedBox(height: 12),
                  _field(controller: _contactInfoCtrl, label: HomeStrings.contactInfoLabel),
                  const SizedBox(height: 12),
                  _field(controller: _descriptionCtrl, label: HomeStrings.offerDescriptionLabel, maxLines: 3),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(HomeStrings.cancelButton, style: const TextStyle(color: SwaColors.textMuted, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SwaColors.ink,
                            foregroundColor: SwaColors.goldLight,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(HomeStrings.submitButton, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SwaColors.ivoryLine)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: SwaColors.ivoryLine)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SwaColors.gold, width: 1.4)),
    );
  }

  Widget _field({required TextEditingController controller, required String label, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: SwaColors.textMuted)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13),
          decoration: _inputDecoration(),
          validator: (v) => (v == null || v.trim().isEmpty) ? HomeStrings.requiredFieldError : null,
        ),
      ],
    );
  }
}

// ---------- Sign in / sign up dialog (Firebase Auth via REST) ----------
class _AuthDialog extends StatefulWidget {
  final void Function(String email) onLoggedIn;
  const _AuthDialog({required this.onLoggedIn});

  @override
  State<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<_AuthDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = _isSignUp
          ? await FirebaseService.signUp(_emailCtrl.text.trim(), _passwordCtrl.text)
          : await FirebaseService.signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
      widget.onLoggedIn(user.email);
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.friendlyMessage(HomeStrings.isRtl);
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = HomeStrings.isRtl ? 'حصل خطأ، حاول تاني' : 'Something went wrong, please try again';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: SwaColors.ivory,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SwaColors.gold.withOpacity(0.3), width: 1),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isSignUp ? HomeStrings.signUp : HomeStrings.signIn,
                  style: HomeScreen._display(size: 19, color: SwaColors.textDark, weight: FontWeight.w700),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: HomeStrings.emailLabel,
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: SwaColors.ivoryLine)),
                  ),
                  validator: (v) => (v == null || !v.contains('@')) ? HomeStrings.requiredFieldError : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: HomeStrings.passwordLabel,
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: SwaColors.ivoryLine)),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? HomeStrings.requiredFieldError : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: TextStyle(fontSize: 11.5, color: Colors.red.shade700)),
                ],
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SwaColors.ink,
                    foregroundColor: SwaColors.goldLight,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: SwaColors.goldLight))
                      : Text(_isSignUp ? HomeStrings.signUp : HomeStrings.signIn, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _loading ? null : () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp ? HomeStrings.haveAccountAlready : HomeStrings.noAccountYet,
                    style: const TextStyle(fontSize: 11.5, color: SwaColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Live currency rates (USD/EUR -> EGP) ----------
class _CurrencyRatesSection extends StatefulWidget {
  const _CurrencyRatesSection();

  @override
  State<_CurrencyRatesSection> createState() => _CurrencyRatesSectionState();
}

class _CurrencyRatesSectionState extends State<_CurrencyRatesSection> {
  bool _loading = true;
  bool _error = false;
  double? _usdToEgp;
  double? _eurToEgp;

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final response = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
          .timeout(const Duration(seconds: 8));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>;
      final usdToEgp = (rates['EGP'] as num).toDouble();
      final usdToEur = (rates['EUR'] as num).toDouble();
      setState(() {
        _usdToEgp = usdToEgp;
        _eurToEgp = usdToEgp / usdToEur;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(width: 18, height: 1.4, color: SwaColors.gold),
              const SizedBox(width: 8),
              Text(HomeStrings.currencyTitle, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: SwaColors.textDark, letterSpacing: 0.2)),
              const Spacer(),
              InkWell(
                onTap: _loading ? null : _fetchRates,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.refresh_rounded, size: 16, color: SwaColors.gold.withOpacity(0.8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SwaColors.ivoryLine, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: _loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: SwaColors.gold),
                      ),
                      const SizedBox(width: 10),
                      Text(HomeStrings.currencyLoading, style: const TextStyle(fontSize: 12, color: SwaColors.textMuted)),
                    ],
                  )
                : _error
                    ? Text(HomeStrings.currencyError, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: SwaColors.textMuted))
                    : Column(
                        children: [
                          _rateRow('USD', _usdToEgp!),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(height: 1, color: SwaColors.ivoryLine),
                          ),
                          _rateRow('EUR', _eurToEgp!),
                          const SizedBox(height: 8),
                          Text(
                            HomeStrings.currencyPerEgp,
                            style: TextStyle(fontSize: 10, color: SwaColors.textMuted.withOpacity(0.8)),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _rateRow(String code, double value) {
    return Row(
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            border: Border.all(color: SwaColors.gold.withOpacity(0.4), width: 1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(code, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: SwaColors.gold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text('1 $code', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SwaColors.textDark)),
        ),
        Text('${value.toStringAsFixed(2)} EGP', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: SwaColors.textDark)),
      ],
    );
  }
}

// ---------- Emergency numbers dialog ----------
class _EmergencyNumbersDialog extends StatelessWidget {
  const _EmergencyNumbersDialog();

  static const _numbers = [
    {'labelGetter': 'police', 'number': '122', 'icon': Icons.local_police_outlined},
    {'labelGetter': 'ambulance', 'number': '123', 'icon': Icons.medical_services_outlined},
    {'labelGetter': 'fire', 'number': '180', 'icon': Icons.local_fire_department_outlined},
    {'labelGetter': 'touristPolice', 'number': '126', 'icon': Icons.shield_outlined},
    {'labelGetter': 'trafficPolice', 'number': '128', 'icon': Icons.traffic_outlined},
  ];

  String _labelFor(String key) {
    switch (key) {
      case 'police':
        return HomeStrings.emergencyPolice;
      case 'ambulance':
        return HomeStrings.emergencyAmbulance;
      case 'fire':
        return HomeStrings.emergencyFire;
      case 'touristPolice':
        return HomeStrings.emergencyTouristPolice;
      default:
        return HomeStrings.emergencyTrafficPolice;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [SwaColors.inkDeep, SwaColors.ink]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SwaColors.gold.withOpacity(0.4), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.sos, color: SwaColors.gold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    HomeStrings.emergencyTitle,
                    style: HomeScreen._display(size: 17, color: Colors.white, weight: FontWeight.w700),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.white54, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._numbers.map((n) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(n['icon'] as IconData, color: SwaColors.goldLight, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(_labelFor(n['labelGetter'] as String), style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                        Text(n['number'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SwaColors.gold)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}