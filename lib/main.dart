import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  void _setLanguage(AppLanguage lang) {
    setState(() {
      HomeStrings.current = lang;
    });
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
        child: HomeScreen(onLanguageChange: _setLanguage),
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
  const HomeScreen({super.key, required this.onLanguageChange});

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 700;
    final maxWidth = isDesktop ? _referenceWidth : double.infinity;

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
                        _buildHeader(),
                        _buildHero(),
                        _buildFeaturedOffers(),
                        _buildCategories(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Header: quiet wordmark, thin gold rule, no icon badge ----------
  Widget _buildHeader() {
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
          _buildLanguageSwitch(),
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
          Column(
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
        ],
      ),
    );
  }

  // ---------- Featured Offers: dark cards, thin gold rule, outline icon ----------
  Widget _buildFeaturedOffers() {
    final offers = [
      {'title': HomeStrings.offer1Title, 'sub': HomeStrings.offer1Sub, 'price': HomeStrings.offer1Price, 'icon': Icons.flight_outlined, 'featured': true, 'rating': 4.8},
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
          ...offers.map((o) {
            final featured = o['featured'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
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
                    Text(o['price'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: SwaColors.gold)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------- Categories: quiet ivory rows with a gold rule, not colored tiles ----------
  Widget _buildCategories() {
    final categories = [
      {'label': HomeStrings.catTrips, 'count': HomeStrings.companiesCount(9), 'icon': Icons.map_outlined},
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
}