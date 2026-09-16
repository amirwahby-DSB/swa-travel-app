import 'dart:convert';
import 'package:http/http.dart' as http;

/// Thin wrapper around the free MyMemory translation API
/// (https://mymemory.translated.net/) — no API key required, generous
/// free quota, good enough quality for short marketing text like offer
/// titles/descriptions/prices. Used so the admin can type an offer once
/// in Arabic and have English/German versions generated automatically,
/// instead of typing everything three times.
class TranslationService {
  static const String _endpoint = 'https://api.mymemory.translated.net/get';

  /// Translates [text] from [from] to [to] (ISO language codes, e.g.
  /// 'ar', 'en', 'de'). Returns the original [text] unchanged if it's
  /// empty, or if the translation call fails for any reason — callers
  /// never need to handle a translation failure specially, the offer
  /// just gets saved with the Arabic text as a safe fallback in that
  /// language's slot rather than blocking the save entirely.
  static Future<String> translate(String text, {required String from, required String to}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;
    try {
      final uri = Uri.parse('$_endpoint?q=${Uri.encodeComponent(trimmed)}&langpair=$from|$to');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return text;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final translated = data['responseData']?['translatedText'] as String?;
      if (translated == null || translated.trim().isEmpty) return text;
      return translated;
    } catch (_) {
      return text;
    }
  }
}