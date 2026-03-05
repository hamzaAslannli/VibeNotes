import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  static const String _apiKeyPref = 'gemini_api_key';
  GenerativeModel? _model;

  /// Get the stored API key
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }

  /// Save the API key
  static Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, key);
  }

  /// Check if API key is configured
  static Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Initialize the Gemini model
  Future<bool> _initModel() async {
    if (_model != null) return true;
    
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) return false;

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
    return true;
  }

  /// Summarize text content
  Future<String?> summarizeText(String text) async {
    if (!await _initModel()) return null;

    try {
      final prompt = '''
Sen bir sesli not uygulamasının AI asistanısın. Aşağıdaki notu kısa ve öz şekilde özetle.

Kurallar:
- Türkçe özetle
- Maksimum 3-4 cümle kullan
- Ana fikirleri ve önemli noktaları vurgula
- Eyleme geçirilebilir noktaları belirt
- Emoji kullanarak görsel zenginlik kat

Not içeriği:
$text
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      debugPrint('AI Summary Error: $e');
      return 'Özetleme sırasında hata oluştu: ${e.toString()}';
    }
  }

  /// Extract keywords from text
  Future<List<String>> extractKeywords(String text) async {
    if (!await _initModel()) return [];

    try {
      final prompt = '''
Aşağıdaki metinden en önemli 5 anahtar kelimeyi çıkar. Sadece kelimeleri virgülle ayırarak yaz, başka bir şey yazma.

Metin:
$text
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final keywords = response.text?.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
      return keywords ?? [];
    } catch (e) {
      debugPrint('Keywords Error: $e');
      return [];
    }
  }

  /// Suggest a category for the note
  Future<String?> suggestCategory(String text) async {
    if (!await _initModel()) return null;

    try {
      final prompt = '''
Aşağıdaki sesli not için en uygun kategoriyi seç. Sadece aşağıdakilerden birini yaz:
- work
- personal
- ideas
- meetings
- other

Not:
$text
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text?.trim().toLowerCase();
    } catch (e) {
      debugPrint('Category Error: $e');
      return null;
    }
  }

  /// Generate action items from text
  Future<String?> generateActionItems(String text) async {
    if (!await _initModel()) return null;

    try {
      final prompt = '''
Aşağıdaki sesli nottan yapılacak görevleri (action items) çıkar. 
Her görev için checkbox formatında listele.
Eğer yapılacak görev yoksa "Bu notta belirli bir görev bulunamadı." yaz.
Türkçe yaz.

Not:
$text
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      debugPrint('Action Items Error: $e');
      return null;
    }
  }

  /// Expand an idea into deeper insights
  Future<String?> expandIdea(String text) async {
    if (!await _initModel()) return null;

    try {
      final prompt = '''
Sen yaratıcı bir düşünce genişletici AI'sın. Aşağıdaki kısa fikri veya notu al ve derinleştir.

Kurallar:
- Türkçe yaz
- Fikri 3-4 farklı açıdan genişlet
- Olası bağlantılar ve ilişkili fikirler öner
- Pratik bir sonraki adım öner
- Emoji kullan, kısa ve etkili yaz
- Başlıkları kalın yap

Fikir:
$text
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      debugPrint('Expand Idea Error: $e');
      return null;
    }
  }
}
