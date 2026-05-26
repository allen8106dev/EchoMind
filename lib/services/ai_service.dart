import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ai_response.dart';

class AIService {

  static const String baseUrl =
      "https://echomind-backend-efef.onrender.com";

  static Future<AIResponse> summarizeDay(
      String diaryText) async {

    final response = await http.post(

      Uri.parse('$baseUrl/summarize'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        "text": diaryText,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['success'] == true &&
        data['ai'] != null) {

      return AIResponse.fromJson(
        data['ai'],
      );

    } else {

      throw Exception(
        data['error'] ??
            "Invalid AI response",
      );
    }
  }
}
