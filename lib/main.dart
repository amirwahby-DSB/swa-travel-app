import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_strings.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0C447C),
          primary: const Color(0xFF0C447C),
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

class HomeScreen extends StatelessWidget {
  final void Function(AppLanguage) onLanguageChange;
  const HomeScreen({super.key, required this.onLanguageChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  _buildHero(),
                  _buildFeaturedOffers(),
                  _buildCategories(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF0C447C),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'SWA',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            HomeStrings.appName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          PopupMenuButton<AppLanguage>(
            onSelected: onLanguageChange,
            itemBuilder: (context) => const [
              PopupMenuItem(value: AppLanguage.ar, child: Text('العربية')),
              PopupMenuItem(value: AppLanguage.en, child: Text('English')),
              PopupMenuItem(value: AppLanguage.de, child: Text('Deutsch')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('AR / EN / DE', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Hero ----------
  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C447C), Color(0xFF15669E)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(top: -10, left: -10, child: Icon(Icons.flight, size: 40, color: Colors.white.withOpacity(0.12))),
          Positioned(bottom: -6, right: 10, child: Icon(Icons.account_balance, size: 46, color: Colors.white.withOpacity(0.12))),
          Positioned(top: 30, right: -14, child: Icon(Icons.directions_car_filled, size: 36, color: Colors.white.withOpacity(0.10))),
          Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                HomeStrings.heroTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                HomeStrings.heroSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Featured Offers ----------
  Widget _buildFeaturedOffers() {
    final offers = [
      {'title': HomeStrings.offer1Title, 'sub': HomeStrings.offer1Sub, 'price': HomeStrings.offer1Price, 'icon': Icons.flight, 'featured': true},
      {'title': HomeStrings.offer2Title, 'sub': HomeStrings.offer2Sub, 'price': HomeStrings.offer2Price, 'icon': Icons.directions_car, 'featured': false},
      {'title': HomeStrings.offer3Title, 'sub': HomeStrings.offer3Sub, 'price': HomeStrings.offer3Price, 'icon': Icons.apartment, 'featured': false},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(HomeStrings.featuredOffersTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...offers.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (o['featured'] as bool) ? const Color(0xFF0C447C) : const Color(0xFFE5E7EB),
                      width: (o['featured'] as bool) ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F1FB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(o['icon'] as IconData, color: const Color(0xFF0C447C)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(o['sub'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      Text(o['price'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ---------- Categories ----------
  Widget _buildCategories() {
    final categories = [
      {'label': HomeStrings.catFlights, 'count': HomeStrings.companiesCount(6), 'icon': Icons.confirmation_number},
      {'label': HomeStrings.catLimo, 'count': HomeStrings.companiesCount(4), 'icon': Icons.directions_car},
      {'label': HomeStrings.catTrips, 'count': HomeStrings.companiesCount(9), 'icon': Icons.map},
      {'label': HomeStrings.catConference, 'count': HomeStrings.companiesCount(3), 'icon': Icons.apartment},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(HomeStrings.browseByCategory, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: categories.map((c) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(c['icon'] as IconData, color: const Color(0xFF0C447C)),
                    const SizedBox(height: 8),
                    Text(c['label'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    Text(c['count'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}