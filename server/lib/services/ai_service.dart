import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class AiService {
  final String _apiKey;
  // Using OpenAI for now, but can be swapped
  // If "Antigravity" is internal, we might mock it or use a specific URL.
  // We'll use a standard OpenAI completion endpoint as a template.
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  AiService() : _apiKey = EnvConfig().aiApiKey;

  Future<String> generateDescription({
    required String productName,
    required String category,
    List<String> keywords = const [],
  }) async {
    if (_apiKey.isEmpty) {
      // Return mock response if no key
      await Future.delayed(const Duration(seconds: 2));
      return '✨ (AI Mock) Легкие и стильные $productName идеально подойдут для категории $category! ${keywords.isNotEmpty ? "Особенности: " + keywords.join(", ") : ""} 🚀 Успейте заказать! 🔥';
    }

    try {
      final prompt =
          'Ты профессиональный копирайтер для маркетплейса. Напиши короткое, продающее описание (до 300 символов) для товара "$productName" (Категория: $category). ${keywords.isNotEmpty ? "Ключевые слова: ${keywords.join(", ")}." : ""} Используй эмодзи. Стиль: дружелюбный и энергичный.';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo', // Or gpt-4
          'messages': [
            {'role': 'system', 'content': 'You are a helpful copywriter.'},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        print(
          'AI API Description Error (Fallback): ${response.statusCode} ${response.body}',
        );
        return '✨ (AI Mock) Легкие и стильные $productName идеально подойдут для категории $category! ${keywords.isNotEmpty ? "Особенности: " + keywords.join(", ") : ""} 🚀 Успейте заказать! 🔥';
      }
    } catch (e) {
      print('AI Service Description Error (Fallback): $e');
      return '✨ (AI Mock) Легкие и стильные $productName идеально подойдут для категории $category! ${keywords.isNotEmpty ? "Особенности: " + keywords.join(", ") : ""} 🚀 Успейте заказать! 🔥';
    }
  }

  Future<String> chat(List<Map<String, String>> messages) async {
    if (_apiKey.isEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      return '✨ (AI Mock) Я получил ваши сообщения. Чем еще я могу вам помочь?';
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        print(
          'AI API Error (Falling back to mock): ${response.statusCode} ${response.body}',
        );
        return '🤖 (AI Mock) Извините, сейчас я не могу связаться с сервером AI (Код ошибки: ${response.statusCode}). Но я здесь, чтобы помочь! Чем могу быть полезен?';
      }
    } catch (e) {
      print('AI Service Connection Error (Falling back to mock): $e');
      return '🤖 (AI Mock) Произошла ошибка соединения. Но не волнуйтесь, я все равно с вами! Задавайте вопросы.';
    }
  }
}
