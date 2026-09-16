import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

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

  /// Adds a new listing to the `offers` Firestore collection. Images/PDFs
  /// themselves are NOT uploaded here — they're expected to already be
  /// placed as static files under web/offer_images/ in the project (and
  /// published via the normal git push + Codemagic build cycle). This
  /// call only stores the offer's text fields plus the filenames.
  ///
  /// Requires the caller to be signed in as the admin — the security
  /// rules reject this write without a valid, matching auth token, so
  /// the Authorization header below is required, not optional.
  static Future<void> addOffer({
    required String title,
    required String description,
    required String price,
    required String category,
    String? imageFile,
    String? pdfFile,
  }) async {
    final body = {
      'fields': {
        'title': {'stringValue': title},
        'description': {'stringValue': description},
        'price': {'stringValue': price},
        'category': {'stringValue': category},
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

  /// Overwrites an existing offer's fields in place. Same auth
  /// requirement as [addOffer] — only the signed-in admin can call this
  /// successfully, per the Firestore security rules.
  static Future<void> updateOffer({
    required String id,
    required String title,
    required String description,
    required String price,
    required String category,
    String? imageFile,
    String? pdfFile,
  }) async {
    final body = {
      'fields': {
        'title': {'stringValue': title},
        'description': {'stringValue': description},
        'price': {'stringValue': price},
        'category': {'stringValue': category},
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

  /// Fetches all documents in the `offers` collection, newest first.
  /// Returns a plain list of maps with the offer's fields already
  /// unwrapped from Firestore's typed-value format, plus an 'id' field
  /// (the Firestore document ID) so callers can target a specific offer
  /// for [updateOffer]/[deleteOffer]. Returns an empty list (never
  /// throws) if the collection doesn't exist yet or the request fails,
  /// so callers can safely fall back to demo content. This is a public
  /// read, so no auth header is needed.
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
        return {
          'id': name.split('/').last,
          'title': field('title'),
          'description': field('description'),
          'price': field('price'),
          'category': field('category'),
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