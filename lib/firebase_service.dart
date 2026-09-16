import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'translation_service.dart';

/// Talks to Firebase directly over its REST APIs (Identity Toolkit for
/// Auth, Firestore REST for the database) instead of using the official
/// firebase_core/firebase_auth/cloud_firestore plugins. Those plugins are
/// federated packages that need native platform build steps, which in turn
/// require Windows "Developer Mode" (symlink support) — not available on
/// this machine. Pure HTTP calls need no plugin and no symlinks.
class FirebaseService {
  static const String _apiKey = 'AIzaSyDEge_MP2QSSVFv7S0HXXr29ZIFbVsfxC4';
  static const String _projectId = 'swa-travel-app';

  static const String _authBase = 'https://identitytoolkit.googleapis.com/v1/accounts';
  static String get _firestoreBase =>
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';

  /// Holds the signed-in user's ID token in memory for the current
  /// session, so Firestore requests that require auth (per the security
  /// rules) can attach it. Also mirrored into the browser's localStorage
  /// (together with the longer-lived refresh token) so a page reload can
  /// restore the session instead of forcing a fresh sign-in — see
  /// [restoreSession].
  static String? _idToken;
  static String? _refreshToken;

  static const String _idTokenKey = 'swa_session_id_token';
  static const String _refreshTokenKey = 'swa_session_refresh_token';
  static const String _emailKey = 'swa_session_email';

  /// Clears the current session (in memory and in localStorage). Pass a
  /// non-null idToken to just update the in-memory token without touching
  /// the rest of the persisted session (not normally needed — signIn/
  /// signUp/restoreSession handle that themselves); pass null to fully
  /// sign out.
  static void setSessionToken(String? idToken) {
    _idToken = idToken;
    if (idToken == null) {
      _refreshToken = null;
      html.window.localStorage.remove(_idTokenKey);
      html.window.localStorage.remove(_refreshTokenKey);
      html.window.localStorage.remove(_emailKey);
    }
  }

  static void _persistSession(FirebaseUser user) {
    _idToken = user.idToken;
    _refreshToken = user.refreshToken;
    html.window.localStorage[_idTokenKey] = user.idToken;
    html.window.localStorage[_refreshTokenKey] = user.refreshToken;
    html.window.localStorage[_emailKey] = user.email;
  }

  static Map<String, String> _authHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_idToken != null) {
      headers['Authorization'] = 'Bearer $_idToken';
    }
    return headers;
  }

  /// Creates a new email/password account. Returns the user's email and
  /// uid on success, or throws a FirebaseAuthException with a readable
  /// message on failure.
  static Future<FirebaseUser> signUp(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_authBase:signUp?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'returnSecureToken': true}),
    );
    final user = _parseAuthResponse(response);
    _persistSession(user);
    return user;
  }

  /// Signs an existing user in. Same return/throw behavior as [signUp].
  static Future<FirebaseUser> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_authBase:signInWithPassword?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'returnSecureToken': true}),
    );
    final user = _parseAuthResponse(response);
    _persistSession(user);
    return user;
  }

  /// Attempts to restore a previously signed-in session after a page
  /// reload, using the refresh token saved in localStorage. The ID token
  /// itself is short-lived (about an hour) and is never trusted on its
  /// own across reloads — this exchanges the refresh token for a brand
  /// new ID token via Firebase's Secure Token API.
  ///
  /// Returns the restored user's email on success, or null if there was
  /// no saved session, or the refresh token has been revoked/expired (in
  /// which case any stale saved session is cleared so the sign-in dialog
  /// starts clean next time).
  static Future<String?> restoreSession() async {
    final refreshToken = html.window.localStorage[_refreshTokenKey];
    final email = html.window.localStorage[_emailKey];
    if (refreshToken == null || email == null) return null;
    try {
      final response = await http.post(
        Uri.parse('https://securetoken.googleapis.com/v1/token?key=$_apiKey'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'grant_type': 'refresh_token', 'refresh_token': refreshToken},
      );
      if (response.statusCode != 200) {
        // Refresh token no longer valid — don't keep stale data around.
        setSessionToken(null);
        return null;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _idToken = data['id_token'] as String;
      _refreshToken = data['refresh_token'] as String;
      // The refresh token can rotate on each use — keep localStorage in sync.
      html.window.localStorage[_idTokenKey] = _idToken!;
      html.window.localStorage[_refreshTokenKey] = _refreshToken!;
      return email;
    } catch (_) {
      // Network hiccup — fail quietly this time rather than wiping a
      // perfectly good saved session; the user just stays logged out
      // until their next reload succeeds.
      return null;
    }
  }

  /// Sends a Firebase-hosted "reset your password" email to the given
  /// address via the Identity Toolkit REST API (no plugin needed, same
  /// approach as signIn/signUp above). Firebase deliberately returns a
  /// generic success response even for emails that aren't registered, so
  /// this can't be used to check whether an account exists — which is
  /// intentional, standard behavior to avoid leaking that information.
  static Future<void> sendPasswordResetEmail(String email) async {
    final response = await http.post(
      Uri.parse('$_authBase:sendOobCode?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'requestType': 'PASSWORD_RESET', 'email': email}),
    );
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final code = (data['error']?['message'] as String?) ?? 'UNKNOWN_ERROR';
      throw FirebaseAuthException(code);
    }
  }

  static FirebaseUser _parseAuthResponse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      // TEMPORARY debug output — remove once auth is confirmed working.
      // ignore: avoid_print
      print('FIREBASE AUTH ERROR (${response.statusCode}): ${response.body}');
      final code = (data['error']?['message'] as String?) ?? 'UNKNOWN_ERROR';
      throw FirebaseAuthException(code);
    }
    return FirebaseUser(
      uid: data['localId'] as String,
      email: data['email'] as String,
      idToken: data['idToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  /// Saves a company partnership inquiry to the `company_inquiries`
  /// Firestore collection. This write does NOT require sign-in — the
  /// security rules allow public create on this collection so any
  /// visiting company can submit the form.
  static Future<void> saveCompanyInquiry({
    required String companyName,
    required String serviceType,
    required String contactInfo,
    required String description,
  }) async {
    final body = {
      'fields': {
        'companyName': {'stringValue': companyName},
        'serviceType': {'stringValue': serviceType},
        'contactInfo': {'stringValue': contactInfo},
        'description': {'stringValue': description},
        'createdAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      },
    };
    await http.post(
      Uri.parse('$_firestoreBase/company_inquiries'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    // Best-effort: if this fails, the WhatsApp/email paths (called
    // alongside it) still deliver the inquiry, so no error is surfaced.
  }

  /// Adds a new listing to the `offers` Firestore collection. The admin
  /// only types Arabic — [title]/[description]/[price] are all expected
  /// to be Arabic text, and this method automatically translates each
  /// into English and German (via [TranslationService]) before saving,
  /// storing all three versions as separate fields (e.g. title_ar,
  /// title_en, title_de) so the site can show the right language without
  /// re-translating on every page load. [categoryKey] is one of the
  /// fixed, language-neutral keys ('trips', 'hotels', 'flights', 'limo',
  /// 'conference') — the actual localized label is looked up from
  /// HomeStrings at display time, the same way the 4 demo offers work.
  ///
  /// Images/PDFs themselves are NOT uploaded here — they're expected to
  /// already be placed as static files under web/offer_images/ in the
  /// project (and published via the normal git push + Codemagic build
  /// cycle). This call only stores the offer's text fields plus the
  /// filenames.
  ///
  /// Requires the caller to be signed in as the admin — the security
  /// rules reject this write without a valid, matching auth token, so
  /// the Authorization header below is required, not optional.
  static Future<void> addOffer({
    required String title,
    required String description,
    required String price,
    required String categoryKey,
    String? imageFile,
    String? pdfFile,
  }) async {
    final translated = await _translateToAll(title: title, description: description, price: price);
    final body = {
      'fields': {
        ..._translatedFields(translated),
        'category_key': {'stringValue': categoryKey},
        'imageFile': {'stringValue': imageFile ?? ''},
        'pdfFile': {'stringValue': pdfFile ?? ''},
        'createdAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      },
    };
    final response = await http.post(
      Uri.parse('$_firestoreBase/offers'),
      headers: _authHeaders(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add offer: ${response.body}');
    }
  }

  /// Overwrites an existing offer's fields in place, re-translating the
  /// Arabic input the same way [addOffer] does. Same auth requirement as
  /// [addOffer] — only the signed-in admin can call this successfully,
  /// per the Firestore security rules. Editing an offer that was created
  /// before the translation system existed automatically upgrades it to
  /// the new per-language field format.
  static Future<void> updateOffer({
    required String id,
    required String title,
    required String description,
    required String price,
    required String categoryKey,
    String? imageFile,
    String? pdfFile,
  }) async {
    final translated = await _translateToAll(title: title, description: description, price: price);
    final body = {
      'fields': {
        ..._translatedFields(translated),
        'category_key': {'stringValue': categoryKey},
        'imageFile': {'stringValue': imageFile ?? ''},
        'pdfFile': {'stringValue': pdfFile ?? ''},
      },
    };
    final response = await http.patch(
      Uri.parse('$_firestoreBase/offers/$id'),
      headers: _authHeaders(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update offer: ${response.body}');
    }
  }

  /// Permanently deletes an offer. Same auth requirement as [addOffer].
  static Future<void> deleteOffer(String id) async {
    final response = await http.delete(
      Uri.parse('$_firestoreBase/offers/$id'),
      headers: _authHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete offer: ${response.body}');
    }
  }

  /// Runs all 6 translations (title/description/price × en/de) in
  /// parallel so a save only takes as long as the single slowest
  /// translation call, not all of them added up sequentially.
  static Future<Map<String, String>> _translateToAll({
    required String title,
    required String description,
    required String price,
  }) async {
    final results = await Future.wait([
      TranslationService.translate(title, from: 'ar', to: 'en'),
      TranslationService.translate(title, from: 'ar', to: 'de'),
      TranslationService.translate(description, from: 'ar', to: 'en'),
      TranslationService.translate(description, from: 'ar', to: 'de'),
      TranslationService.translate(price, from: 'ar', to: 'en'),
      TranslationService.translate(price, from: 'ar', to: 'de'),
    ]);
    return {
      'title_ar': title,
      'title_en': results[0],
      'title_de': results[1],
      'description_ar': description,
      'description_en': results[2],
      'description_de': results[3],
      'price_ar': price,
      'price_en': results[4],
      'price_de': results[5],
    };
  }

  static Map<String, Map<String, String>> _translatedFields(Map<String, String> translated) {
    return translated.map((key, value) => MapEntry(key, {'stringValue': value}));
  }

  /// Best-effort mapping from an offer's old, single-language category
  /// label (from before category_key existed) back to a stable key, so
  /// offers added before this change keep showing the right category
  /// instead of falling back to a wrong default.
  static const Map<String, List<String>> _legacyCategoryLabels = {
    'trips': ['رحلات', 'Trips', 'Ausflüge'],
    'hotels': ['حجز فنادق', 'Hotel Booking', 'Hotelbuchung'],
    'flights': ['تذاكر طيران', 'Flight tickets', 'Flugtickets'],
    'limo': ['ليموزين', 'Limousine'],
    'conference': ['قاعات ومساحات للإيجار', 'Halls & Venues for Rent', 'Säle & Veranstaltungsorte zur Miete'],
  };

  static String _categoryKeyFromLegacyLabel(String label) {
    for (final entry in _legacyCategoryLabels.entries) {
      if (entry.value.contains(label)) return entry.key;
    }
    return 'trips';
  }

  /// Fetches all documents in the `offers` collection. Returns a plain
  /// list of maps with 'id', 'title_ar'/'title_en'/'title_de' (and the
  /// same for 'description' and 'price'), 'category_key', 'imageFile'
  /// and 'pdfFile'. Offers saved before the translation system existed
  /// (which only had single 'title'/'description'/'price'/'category'
  /// fields) are transparently upgraded here: the same original text is
  /// used for all three languages, and the old category label is mapped
  /// back to a stable key — so nothing old breaks or disappears, it just
  /// won't be translated until the admin re-saves it. Returns an empty
  /// list (never throws) if the collection doesn't exist yet or the
  /// request fails, so callers can safely fall back to demo content.
  /// This is a public read, so no auth header is needed.
  static Future<List<Map<String, String>>> getOffers() async {
    try {
      final response = await http.get(Uri.parse('$_firestoreBase/offers'));
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final documents = data['documents'] as List<dynamic>?;
      if (documents == null) return [];
      final offers = documents.map((doc) {
        final fields = (doc['fields'] as Map<String, dynamic>?) ?? {};
        String field(String key) => (fields[key]?['stringValue'] as String?) ?? '';
        final name = (doc['name'] as String?) ?? '';

        final legacyTitle = field('title');
        final legacyDescription = field('description');
        final legacyPrice = field('price');
        final legacyCategory = field('category');

        String titleAr = field('title_ar');
        String titleEn = field('title_en');
        String titleDe = field('title_de');
        if (titleAr.isEmpty && titleEn.isEmpty && titleDe.isEmpty && legacyTitle.isNotEmpty) {
          titleAr = legacyTitle;
          titleEn = legacyTitle;
          titleDe = legacyTitle;
        }

        String descAr = field('description_ar');
        String descEn = field('description_en');
        String descDe = field('description_de');
        if (descAr.isEmpty && descEn.isEmpty && descDe.isEmpty && legacyDescription.isNotEmpty) {
          descAr = legacyDescription;
          descEn = legacyDescription;
          descDe = legacyDescription;
        }

        String priceAr = field('price_ar');
        String priceEn = field('price_en');
        String priceDe = field('price_de');
        if (priceAr.isEmpty && priceEn.isEmpty && priceDe.isEmpty && legacyPrice.isNotEmpty) {
          priceAr = legacyPrice;
          priceEn = legacyPrice;
          priceDe = legacyPrice;
        }

        String categoryKey = field('category_key');
        if (categoryKey.isEmpty) {
          categoryKey = legacyCategory.isNotEmpty ? _categoryKeyFromLegacyLabel(legacyCategory) : 'trips';
        }

        return {
          'id': name.split('/').last,
          'title_ar': titleAr,
          'title_en': titleEn,
          'title_de': titleDe,
          'description_ar': descAr,
          'description_en': descEn,
          'description_de': descDe,
          'price_ar': priceAr,
          'price_en': priceEn,
          'price_de': priceDe,
          'category_key': categoryKey,
          'imageFile': field('imageFile'),
          'pdfFile': field('pdfFile'),
        };
      }).toList();
      return offers;
    } catch (_) {
      return [];
    }
  }
}

class FirebaseUser {
  final String uid;
  final String email;
  final String idToken;
  final String refreshToken;
  FirebaseUser({required this.uid, required this.email, required this.idToken, required this.refreshToken});
}

class FirebaseAuthException implements Exception {
  final String code;
  FirebaseAuthException(this.code);

  /// Maps Firebase's raw error codes to a friendly message. Falls back to
  /// the raw code for anything not explicitly handled.
  String friendlyMessage(bool isRtl) {
    switch (code) {
      case 'EMAIL_EXISTS':
        return isRtl ? 'الإيميل ده مسجّل بالفعل' : 'This email is already registered';
      case 'EMAIL_NOT_FOUND':
      case 'INVALID_LOGIN_CREDENTIALS':
      case 'INVALID_PASSWORD':
        return isRtl ? 'الإيميل أو كلمة المرور غلط' : 'Incorrect email or password';
      case 'WEAK_PASSWORD : Password should be at least 6 characters':
      case 'WEAK_PASSWORD':
        return isRtl ? 'كلمة المرور لازم تكون 6 حروف/أرقام على الأقل' : 'Password must be at least 6 characters';
      case 'INVALID_EMAIL':
        return isRtl ? 'صيغة الإيميل غير صحيحة' : 'Invalid email format';
      default:
        return isRtl ? 'حصل خطأ، حاول تاني' : 'Something went wrong, please try again';
    }
  }
}