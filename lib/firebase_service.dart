import 'dart:convert';
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

  /// Creates a new email/password account. Returns the user's email and
  /// uid on success, or throws a FirebaseAuthException with a readable
  /// message on failure.
  static Future<FirebaseUser> signUp(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_authBase:signUp?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'returnSecureToken': true}),
    );
    return _parseAuthResponse(response);
  }

  /// Signs an existing user in. Same return/throw behavior as [signUp].
  static Future<FirebaseUser> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_authBase:signInWithPassword?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'returnSecureToken': true}),
    );
    return _parseAuthResponse(response);
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
    );
  }

  /// Saves a company partnership inquiry to the `company_inquiries`
  /// Firestore collection. Firestore is currently in test mode, so no
  /// auth token is required for this write.
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
}

class FirebaseUser {
  final String uid;
  final String email;
  final String idToken;
  FirebaseUser({required this.uid, required this.email, required this.idToken});
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